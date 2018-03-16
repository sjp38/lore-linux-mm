Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 617CC6B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:08:41 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q65so5221937pga.15
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:08:41 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id j18si1688342pfk.286.2018.03.16.14.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:08:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2] mm/shmem: Do not wait for lock_page() in shmem_unused_huge_shrink()
Date: Sat, 17 Mar 2018 00:08:30 +0300
Message-Id: <20180316210830.43738-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Eric Wheeler <linux-mm@lists.ewheeler.net>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

shmem_unused_huge_shrink() gets called from reclaim path. Waiting for page
lock may lead to deadlock there.

There was a bug report that may be attributed to this:

http://lkml.kernel.org/r/alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net

Replace lock_page() with trylock_page() and skip the page if we failed
to lock it. We will get to the page on the next scan.

We can test for the PageTransHuge() outside the page lock as we only
need protection against splitting the page under us. Holding pin oni
the page is enough for this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reported-by: Eric Wheeler <linux-mm@lists.ewheeler.net>
Fixes: 779750d20b93 ("shmem: split huge pages beyond i_size under memory pressure")
Cc: stable@vger.kernel.org # v4.8+
---
 mm/shmem.c | 31 ++++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 11 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 1907688b75ee..b85919243399 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -493,36 +493,45 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
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
 
+		/* No huge page at the end of the file: nothing to split */
 		if (!PageTransHuge(page)) {
-			unlock_page(page);
 			put_page(page);
 			goto drop;
 		}
 
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
 		ret = split_huge_page(page);
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
2.16.1
