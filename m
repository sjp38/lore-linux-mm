Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C67296B018E
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 01:01:38 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so383614pdi.35
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 22:01:38 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id s3si528200pbo.217.2014.03.19.22.01.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 22:01:31 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so386088pdj.20
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 22:01:30 -0700 (PDT)
Date: Wed, 19 Mar 2014 22:00:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: bad rss-counter message in 3.14rc5
In-Reply-To: <20140319145200.GA4608@redhat.com>
Message-ID: <alpine.LSU.2.11.1403192147470.971@eggly.anvils>
References: <20140311142817.GA26517@redhat.com> <20140311143750.GE32390@moon> <20140311171045.GA4693@redhat.com> <20140311173603.GG32390@moon> <20140311173917.GB4693@redhat.com> <alpine.LSU.2.11.1403181703470.7055@eggly.anvils> <5328F3B4.1080208@oracle.com>
 <20140319020602.GA29787@redhat.com> <20140319021131.GA30018@redhat.com> <alpine.LSU.2.11.1403181918130.3423@eggly.anvils> <20140319145200.GA4608@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Wed, 19 Mar 2014, Dave Jones wrote:
> On Tue, Mar 18, 2014 at 07:19:09PM -0700, Hugh Dickins wrote:
> 
>  > Another positive on the rss counters, great, thanks Dave.
>  > That encourages me to think again on the swapops BUG, but no promises.
> 
> So while I slept I ran a test kernel with that swapops BUG replaced with a printk.
> I'm not sure of the validity of this, given the state of the kernel afterwards
> is somewhat suspect, but I did see in the logs this morning..
> 
> [18728.075153] migration_entry_to_page BUG hit
> [18728.200705] BUG: Bad rss-counter state mm:ffff880241b3f500 idx:0 val:1 (Not tainted)
> [18728.200706] BUG: Bad rss-counter state mm:ffff880241b3f500 idx:1 val:-1 (Not tainted)
> 
> This might be collateral damage from the swapops thing, I guess we won't know until
> that gets fixed, but I thought I'd mention that we might still have a problem here.

Yes, those Bad rss-counters could well be collateral damage from the
swapops BUG.  To which I believe I now have the answer: again untested,
but please give this a try...

(It's worth saying, by the way, that these bugs are not a consequence
of recent changes at all, they've been there for ages; but trinity has
just got better at taunting remap_file_pages and the rest of mm...)


[PATCH] mm: fix swapops.h:131 bug if remap_file_pages raced migration

Add remove_linear_migration_ptes_from_nonlinear(), to fix an interesting
little include/linux/swapops.h:131 BUG_ON(!PageLocked) found by trinity:
indicating that remove_migration_ptes() failed to find one of the
migration entries that was temporarily inserted.

The problem comes from remap_file_pages()'s switch from vma_interval_tree
(good for inserting the migration entry) to i_mmap_nonlinear list (no good
for locating it again); but can only be a problem if the remap_file_pages()
range does not cover the whole of the vma (zap_pte() clears the range).

remove_migration_ptes() needs a file_nonlinear method to go down the
i_mmap_nonlinear list, applying linear location to look for migration
entries in those vmas too, just in case there was this race.

The file_nonlinear method does need rmap_walk_control.arg to do this;
but it never needed vma passed in - vma comes from its own iteration.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 include/linux/rmap.h |    3 +--
 mm/migrate.c         |   32 ++++++++++++++++++++++++++++++++
 mm/rmap.c            |    5 +++--
 3 files changed, 36 insertions(+), 4 deletions(-)

--- 3.14-rc7/include/linux/rmap.h	2014-02-02 18:49:07.429302104 -0800
+++ linux/include/linux/rmap.h	2014-03-19 20:12:27.056451541 -0700
@@ -250,8 +250,7 @@ struct rmap_walk_control {
 	int (*rmap_one)(struct page *page, struct vm_area_struct *vma,
 					unsigned long addr, void *arg);
 	int (*done)(struct page *page);
-	int (*file_nonlinear)(struct page *, struct address_space *,
-					struct vm_area_struct *vma);
+	int (*file_nonlinear)(struct page *, struct address_space *, void *arg);
 	struct anon_vma *(*anon_lock)(struct page *page);
 	bool (*invalid_vma)(struct vm_area_struct *vma, void *arg);
 };
--- 3.14-rc7/mm/migrate.c	2014-03-16 19:24:19.635512576 -0700
+++ linux/mm/migrate.c	2014-03-19 21:06:02.704527965 -0700
@@ -178,6 +178,37 @@ out:
 }
 
 /*
+ * Congratulations to trinity for discovering this bug.
+ * mm/fremap.c's remap_file_pages() accepts any range within a single vma to
+ * convert that vma to VM_NONLINEAR; and generic_file_remap_pages() will then
+ * replace the specified range by file ptes throughout (maybe populated after).
+ * If page migration finds a page within that range, while it's still located
+ * by vma_interval_tree rather than lost to i_mmap_nonlinear list, no problem:
+ * zap_pte() clears the temporary migration entry before mmap_sem is dropped.
+ * But if the migrating page is in a part of the vma outside the range to be
+ * remapped, then it will not be cleared, and remove_migration_ptes() needs to
+ * deal with it.  Fortunately, this part of the vma is of course still linear,
+ * so we just need to use linear location on the nonlinear list.
+ */
+static int remove_linear_migration_ptes_from_nonlinear(struct page *page,
+		struct address_space *mapping, void *arg)
+{
+	struct vm_area_struct *vma;
+	/* hugetlbfs does not support remap_pages, so no huge pgoff worries */
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	unsigned long addr;
+
+	list_for_each_entry(vma,
+		&mapping->i_mmap_nonlinear, shared.nonlinear) {
+
+		addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+		if (addr >= vma->vm_start && addr < vma->vm_end)
+			remove_migration_pte(page, vma, addr, arg);
+	}
+	return SWAP_AGAIN;
+}
+
+/*
  * Get rid of all migration entries and replace them by
  * references to the indicated page.
  */
@@ -186,6 +217,7 @@ static void remove_migration_ptes(struct
 	struct rmap_walk_control rwc = {
 		.rmap_one = remove_migration_pte,
 		.arg = old,
+		.file_nonlinear = remove_linear_migration_ptes_from_nonlinear,
 	};
 
 	rmap_walk(new, &rwc);
--- 3.14-rc7/mm/rmap.c	2014-02-02 18:49:07.929302115 -0800
+++ linux/mm/rmap.c	2014-03-19 20:16:03.552456686 -0700
@@ -1360,8 +1360,9 @@ static int try_to_unmap_cluster(unsigned
 }
 
 static int try_to_unmap_nonlinear(struct page *page,
-		struct address_space *mapping, struct vm_area_struct *vma)
+		struct address_space *mapping, void *arg)
 {
+	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
 	unsigned long cursor;
 	unsigned long max_nl_cursor = 0;
@@ -1663,7 +1664,7 @@ static int rmap_walk_file(struct page *p
 	if (list_empty(&mapping->i_mmap_nonlinear))
 		goto done;
 
-	ret = rwc->file_nonlinear(page, mapping, vma);
+	ret = rwc->file_nonlinear(page, mapping, rwc->arg);
 
 done:
 	mutex_unlock(&mapping->i_mmap_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
