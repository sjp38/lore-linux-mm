Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0A46B0062
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 13:33:59 -0400 (EDT)
Date: Mon, 21 Sep 2009 19:33:38 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: a patch drop request in -mm
Message-ID: <20090921173338.GA2578@cmpxchg.org>
References: <2f11576a0909210800l639560e4jad6cfc2e7f74538f@mail.gmail.com> <2f11576a0909210808r7912478cyd7edf3550fe5ce6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f11576a0909210808r7912478cyd7edf3550fe5ce6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Sep 22, 2009 at 12:08:28AM +0900, KOSAKI Motohiro wrote:
> 2009/9/22 KOSAKI Motohiro <kosaki.motohiro@gmail.com>:
> > Mel,
> >
> > Today, my test found following patch makes false-positive warning.
> > because, truncate can free the pages
> > although the pages are mlock()ed.
> >
> > So, I think following patch should be dropped.
> > .. or, do you think truncate should clear PG_mlock before free the page?
> >
> > Can I ask your patch intention?
> 
> stacktrace is here.
> 
> 
> ------------[ cut here ]------------
> WARNING: at mm/page_alloc.c:502 free_page_mlock+0x84/0xce()
> Hardware name: PowerEdge T105
> Page flag mlocked set for process dd at pfn:172d4b
> page:ffffea00096a6678 flags:0x700000000400000
> Modules linked in: fuse usbhid bridge stp llc nfsd lockd nfs_acl
> exportfs sunrpc cpufreq_ondemand powernow_k8 freq_table dm_multipath
> kvm_amd kvm serio_raw e1000e i2c_nforce2 i2c_core tg3 dcdbas sr_mod
> cdrom pata_acpi sata_nv uhci_hcd ohci_hcd ehci_hcd usbcore [last
> unloaded: scsi_wait_scan]
> Pid: 27030, comm: dd Tainted: G        W  2.6.31-rc9-mm1 #13
> Call Trace:
>  [<ffffffff8105fd76>] warn_slowpath_common+0x8d/0xbb
>  [<ffffffff8105fe31>] warn_slowpath_fmt+0x50/0x66
>  [<ffffffff81102483>] ? mempool_alloc+0x80/0x146
>  [<ffffffff811060fb>] free_page_mlock+0x84/0xce
>  [<ffffffff8110640a>] free_hot_cold_page+0x105/0x20b
>  [<ffffffff81106597>] __pagevec_free+0x87/0xb2
>  [<ffffffff8110ad61>] release_pages+0x17c/0x1e8
>  [<ffffffff810a24b8>] ? trace_hardirqs_on_caller+0x32/0x17b
>  [<ffffffff8112ff82>] free_pages_and_swap_cache+0x72/0xa3
>  [<ffffffff8111f2f4>] tlb_flush_mmu+0x46/0x68
>  [<ffffffff8111f935>] unmap_vmas+0x61f/0x85b
>  [<ffffffff810a24b8>] ? trace_hardirqs_on_caller+0x32/0x17b
>  [<ffffffff8111fc2b>] zap_page_range+0xba/0xf9
>  [<ffffffff8111fce4>] unmap_mapping_range_vma+0x7a/0xff
>  [<ffffffff8111ff2f>] unmap_mapping_range+0x1c6/0x26d
>  [<ffffffff8110c407>] truncate_pagecache+0x49/0x85
>  [<ffffffff8117bd84>] simple_setsize+0x44/0x64
>  [<ffffffff8110b856>] vmtruncate+0x25/0x5f

This calls unmap_mapping_range() before actually munlocking the page.

Other unmappers like do_munmap() and exit_mmap() munlock explicitely
before unmapping.

We could do the same here but I would argue that mlock lifetime
depends on actual userspace mappings and then move the munlocking a
few levels down into the unmapping guts to make this implicit.

Because truncation makes sure pages get unmapped, this is handled too.

Below is roughly outlined and untested demonstration patch.  What do
you think?

>  [<ffffffff81170558>] inode_setattr+0x4a/0x83
>  [<ffffffff811e817b>] ext4_setattr+0x26b/0x314
>  [<ffffffff8117088f>] ? notify_change+0x19c/0x31d
>  [<ffffffff811708ac>] notify_change+0x1b9/0x31d
>  [<ffffffff81150556>] do_truncate+0x7b/0xac
>  [<ffffffff811606c1>] ? get_write_access+0x59/0x76
>  [<ffffffff81163019>] may_open+0x1c0/0x1d3
>  [<ffffffff811638bd>] do_filp_open+0x4c3/0x998
>  [<ffffffff81171d80>] ? alloc_fd+0x4a/0x14b
>  [<ffffffff81171e5b>] ? alloc_fd+0x125/0x14b
>  [<ffffffff8114f472>] do_sys_open+0x6f/0x14f
>  [<ffffffff8114f5bf>] sys_open+0x33/0x49
>  [<ffffffff8100bf72>] system_call_fastpath+0x16/0x1b
> ---[ end trace e76f92f117e9e06e ]---

---

diff --git a/mm/internal.h b/mm/internal.h
index f290c4d..0d3c6c6 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -67,10 +67,6 @@ extern long mlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
-static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
-{
-	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
-}
 #endif
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index aede2ce..f8c5ac6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -971,7 +971,7 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
 
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
-		unsigned long end;
+		unsigned long end, nr_pages;
 
 		start = max(vma->vm_start, start_addr);
 		if (start >= vma->vm_end)
@@ -980,8 +980,15 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
 		if (end <= vma->vm_start)
 			continue;
 
+		nr_pages = (end - start) >> PAGE_SHIFT;
+
+		if (vma->vm_flags & VM_LOCKED) {
+			mm->locked_vm -= nr_pages;
+			munlock_vma_pages_range(vma, start, end);
+		}
+
 		if (vma->vm_flags & VM_ACCOUNT)
-			*nr_accounted += (end - start) >> PAGE_SHIFT;
+			*nr_accounted += nr_pages;
 
 		if (unlikely(is_pfn_mapping(vma)))
 			untrack_pfn_vma(vma, 0, 0);
diff --git a/mm/mmap.c b/mm/mmap.c
index 8101de4..02189f3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1921,20 +1921,6 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	vma = prev? prev->vm_next: mm->mmap;
 
 	/*
-	 * unlock any mlock()ed ranges before detaching vmas
-	 */
-	if (mm->locked_vm) {
-		struct vm_area_struct *tmp = vma;
-		while (tmp && tmp->vm_start < end) {
-			if (tmp->vm_flags & VM_LOCKED) {
-				mm->locked_vm -= vma_pages(tmp);
-				munlock_vma_pages_all(tmp);
-			}
-			tmp = tmp->vm_next;
-		}
-	}
-
-	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
@@ -2089,15 +2075,6 @@ void exit_mmap(struct mm_struct *mm)
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
 
-	if (mm->locked_vm) {
-		vma = mm->mmap;
-		while (vma) {
-			if (vma->vm_flags & VM_LOCKED)
-				munlock_vma_pages_all(vma);
-			vma = vma->vm_next;
-		}
-	}
-
 	arch_exit_mmap(mm);
 
 	vma = mm->mmap;
diff --git a/mm/truncate.c b/mm/truncate.c
index ccc3ecf..a4e3b8f 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -104,7 +104,6 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
-	clear_page_mlock(page);
 	remove_from_page_cache(page);
 	ClearPageMappedToDisk(page);
 	page_cache_release(page);	/* pagecache ref */
@@ -129,7 +128,6 @@ invalidate_complete_page(struct address_space *mapping, struct page *page)
 	if (page_has_private(page) && !try_to_release_page(page, 0))
 		return 0;
 
-	clear_page_mlock(page);
 	ret = remove_mapping(mapping, page);
 
 	return ret;
@@ -348,7 +346,6 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	if (PageDirty(page))
 		goto failed;
 
-	clear_page_mlock(page);
 	BUG_ON(page_has_private(page));
 	__remove_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
