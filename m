Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8EB6B0008
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 10:42:30 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id b17-v6so5516040otf.2
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 07:42:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r129si1969921oia.412.2018.03.16.07.42.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Mar 2018 07:42:29 -0700 (PDT)
Subject: Re: [PATCH] mm/shmem: Do not wait for lock_page() in shmem_unused_huge_shrink()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180316122508.fv4edpx34hdqybwx@node.shutemov.name>
	<20180316125827.GC11461@dhcp22.suse.cz>
	<20180316130200.rbke66zjyoc6zwzl@node.shutemov.name>
	<201803162214.ECJ30715.StOOFHOFVLJMQF@I-love.SAKURA.ne.jp>
	<20180316133417.hk2lvnvgildsc65n@node.shutemov.name>
In-Reply-To: <20180316133417.hk2lvnvgildsc65n@node.shutemov.name>
Message-Id: <201803162342.IJD26023.MHJQFOOFLFStVO@I-love.SAKURA.ne.jp>
Date: Fri, 16 Mar 2018 23:42:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill@shutemov.name
Cc: mhocko@kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@lists.ewheeler.net

Kirill A. Shutemov wrote:

> On Fri, Mar 16, 2018 at 10:14:24PM +0900, Tetsuo Handa wrote:
> > f2fs is doing
> > 
> >   page = f2fs_pagecache_get_page(inode->i_mapping, 0, FGP_LOCK|FGP_NOWAIT, 0);
> > 
> > which calls
> > 
> >   struct page *pagecache_get_page(inode->i_mapping, 0, FGP_LOCK|FGP_NOWAIT, 0);
> > 
> > . Then, can't we define
> > 
> >   static inline struct page *find_trylock_page(struct address_space *mapping,
> >   					     pgoff_t offset)
> >   {
> >   	return pagecache_get_page(mapping, offset, FGP_LOCK|FGP_NOWAIT, 0);
> >   }
> > 
> > and replace find_lock_page() with find_trylock_page() ?
> 
> This won't work in this case. We need to destinct no-page-in-page-cache
> from failed-to-lock-page. We take different routes depending on this.
> 

OK. Then, I think we should avoid reordering trylock_page() and PageTransHuge()
without patch description why it is safe. Below patch preserves the ordering
and sounds safer for stable. But either patch, please add why it is safe to omit
"/* Has the page been truncated? */" check which would have been done for FGP_LOCK
in patch description.

---
 mm/shmem.c | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8ead6cb..5e94ca4 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -493,16 +493,27 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
 		info = list_entry(pos, struct shmem_inode_info, shrinklist);
 		inode = &info->vfs_inode;
 
-		if (nr_to_split && split >= nr_to_split) {
-			iput(inode);
-			continue;
-		}
+		if (nr_to_split && split >= nr_to_split)
+			goto leave;
 
-		page = find_lock_page(inode->i_mapping,
+		page = find_get_page(inode->i_mapping,
 				(inode->i_size & HPAGE_PMD_MASK) >> PAGE_SHIFT);
 		if (!page)
 			goto drop;
 
+		/*
+		 * Leave the inode on the list if we failed to lock
+		 * the page at this time.
+		 *
+		 * Waiting for the lock may lead to deadlock in the
+		 * reclaim path.
+		 */
+		if (!trylock_page(page)) {
+			put_page(page);
+			goto leave;
+		}
+
+		/* No huge page at the end of the file: nothing to split */
 		if (!PageTransHuge(page)) {
 			unlock_page(page);
 			put_page(page);
@@ -513,16 +524,15 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
 		unlock_page(page);
 		put_page(page);
 
-		if (ret) {
-			/* split failed: leave it on the list */
-			iput(inode);
-			continue;
-		}
+		/* If split failed leave the inode on the list */
+		if (ret)
+			goto leave;
 
 		split++;
 drop:
 		list_del_init(&info->shrinklist);
 		removed++;
+leave:
 		iput(inode);
 	}
 
-- 
