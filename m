Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAFA6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:35:59 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xy5so34623768wjc.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:35:59 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id b5si6798003wjw.261.2016.12.16.04.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 04:35:57 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id g23so5196739wme.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:35:57 -0800 (PST)
Date: Fri, 16 Dec 2016 15:35:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: crash during oom reaper
Message-ID: <20161216123555.GE27758@node>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
 <20161216104438.GD27758@node>
 <20161216114243.GG13940@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216114243.GG13940@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Dec 16, 2016 at 12:42:43PM +0100, Michal Hocko wrote:
> On Fri 16-12-16 13:44:38, Kirill A. Shutemov wrote:
> > On Fri, Dec 16, 2016 at 11:11:13AM +0100, Michal Hocko wrote:
> > > On Fri 16-12-16 10:43:52, Vegard Nossum wrote:
> > > [...]
> > > > I don't think it's a bug in the OOM reaper itself, but either of the
> > > > following two patches will fix the problem (without my understand how or
> > > > why):
> > > > 
> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > index ec9f11d4f094..37b14b2e2af4 100644
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -485,7 +485,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk,
> > > > struct mm_struct *mm)
> > > >  	 */
> > > >  	mutex_lock(&oom_lock);
> > > > 
> > > > -	if (!down_read_trylock(&mm->mmap_sem)) {
> > > > +	if (!down_write_trylock(&mm->mmap_sem)) {
> > > 
> > > __oom_reap_task_mm is basically the same thing as MADV_DONTNEED and that
> > > doesn't require the exlusive mmap_sem. So this looks correct to me.
> > 
> > BTW, shouldn't we filter out all VM_SPECIAL VMAs there? Or VM_PFNMAP at
> > least.
> > 
> > MADV_DONTNEED doesn't touch VM_PFNMAP, but I don't see anything matching
> > on __oom_reap_task_mm() side.
> 
> I guess you are right and we should match the MADV_DONTNEED behavior
> here. Care to send a patch?

Below. Testing required.

> > Other difference is that you use unmap_page_range() witch doesn't touch
> > mmu_notifiers. MADV_DONTNEED goes via zap_page_range(), which invalidates
> > the range. Not sure if it can make any difference here.
> 
> Which mmu notifier would care about this? I am not really familiar with
> those users so I might miss something easily.

No idea either.

Is there any reason not to use zap_page_range here too?

Few more notes:

I propably miss something, but why do we need details->ignore_dirty?
It only appiled for non-anon pages, but since we filter out shared
mappings, how can we have pte_dirty() for !PageAnon()?

check_swap_entries is also sloppy: the behavior doesn't match the comment:
details == NULL makes it check swap entries. I removed it and restore
details->check_mapping test as we had before.

After the change no user of zap_page_range() wants non-NULL details, I've
dropped the argument.

If it looks okay, I'll split it into several patches with proper commit
messages.

-----8<-----

diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index ec1f0dedb948..59ac93714fa4 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -687,7 +687,7 @@ void gmap_discard(struct gmap *gmap, unsigned long from, unsigned long to)
 		/* Find vma in the parent mm */
 		vma = find_vma(gmap->mm, vmaddr);
 		size = min(to - gaddr, PMD_SIZE - (gaddr & ~PMD_MASK));
-		zap_page_range(vma, vmaddr, size, NULL);
+		zap_page_range(vma, vmaddr, size);
 	}
 	up_read(&gmap->mm->mmap_sem);
 }
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index e4f800999b32..4bfb31e79d5d 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -796,7 +796,7 @@ static noinline int zap_bt_entries_mapping(struct mm_struct *mm,
 			return -EINVAL;
 
 		len = min(vma->vm_end, end) - addr;
-		zap_page_range(vma, addr, len, NULL);
+		zap_page_range(vma, addr, len);
 		trace_mpx_unmap_zap(addr, addr+len);
 
 		vma = vma->vm_next;
diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index 3c71b982bf2a..d97f6725cf8c 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -629,7 +629,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 		page = &proc->pages[(page_addr - proc->buffer) / PAGE_SIZE];
 		if (vma)
 			zap_page_range(vma, (uintptr_t)page_addr +
-				proc->user_buffer_offset, PAGE_SIZE, NULL);
+				proc->user_buffer_offset, PAGE_SIZE);
 err_vm_insert_page_failed:
 		unmap_kernel_range((unsigned long)page_addr, PAGE_SIZE);
 err_map_kernel_failed:
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index b653451843c8..0fb0e28ace70 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -865,8 +865,7 @@ static void ion_buffer_sync_for_device(struct ion_buffer *buffer,
 	list_for_each_entry(vma_list, &buffer->vmas, list) {
 		struct vm_area_struct *vma = vma_list->vma;
 
-		zap_page_range(vma, vma->vm_start, vma->vm_end - vma->vm_start,
-			       NULL);
+		zap_page_range(vma, vma->vm_start, vma->vm_end - vma->vm_start);
 	}
 	mutex_unlock(&buffer->lock);
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4424784ac374..92dcada8caaf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1148,8 +1148,6 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	bool ignore_dirty;			/* Ignore dirty pages */
-	bool check_swap_entries;		/* Check also swap entries */
 };
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
@@ -1160,7 +1158,7 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
 void zap_page_range(struct vm_area_struct *vma, unsigned long address,
-		unsigned long size, struct zap_details *);
+		unsigned long size);
 void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long start, unsigned long end);
 
diff --git a/mm/internal.h b/mm/internal.h
index 44d68895a9b9..5c355855e4ad 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -41,10 +41,9 @@ int do_swap_page(struct vm_fault *vmf);
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
-void unmap_page_range(struct mmu_gather *tlb,
-			     struct vm_area_struct *vma,
-			     unsigned long addr, unsigned long end,
-			     struct zap_details *details);
+long madvise_dontneed(struct vm_area_struct *vma,
+			     struct vm_area_struct **prev,
+			     unsigned long start, unsigned long end);
 
 extern int __do_page_cache_readahead(struct address_space *mapping,
 		struct file *filp, pgoff_t offset, unsigned long nr_to_read,
diff --git a/mm/madvise.c b/mm/madvise.c
index 0e3828eae9f8..8c9f19b62b4a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -468,7 +468,7 @@ static long madvise_free(struct vm_area_struct *vma,
  * An interface that causes the system to free clean pages and flush
  * dirty pages is already available as msync(MS_INVALIDATE).
  */
-static long madvise_dontneed(struct vm_area_struct *vma,
+long madvise_dontneed(struct vm_area_struct *vma,
 			     struct vm_area_struct **prev,
 			     unsigned long start, unsigned long end)
 {
@@ -476,7 +476,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
 		return -EINVAL;
 
-	zap_page_range(vma, start, end - start, NULL);
+	zap_page_range(vma, start, end - start);
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 455c3e628d52..f8836232a492 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1155,12 +1155,6 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 
 			if (!PageAnon(page)) {
 				if (pte_dirty(ptent)) {
-					/*
-					 * oom_reaper cannot tear down dirty
-					 * pages
-					 */
-					if (unlikely(details && details->ignore_dirty))
-						continue;
 					force_flush = 1;
 					set_page_dirty(page);
 				}
@@ -1179,8 +1173,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			}
 			continue;
 		}
-		/* only check swap_entries if explicitly asked for in details */
-		if (unlikely(details && !details->check_swap_entries))
+		/* If details->check_mapping, we leave swap entries. */
+		if (unlikely(details))
 			continue;
 
 		entry = pte_to_swp_entry(ptent);
@@ -1277,7 +1271,7 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 	return addr;
 }
 
-void unmap_page_range(struct mmu_gather *tlb,
+static void unmap_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end,
 			     struct zap_details *details)
@@ -1381,7 +1375,7 @@ void unmap_vmas(struct mmu_gather *tlb,
  * Caller must protect the VMA list
  */
 void zap_page_range(struct vm_area_struct *vma, unsigned long start,
-		unsigned long size, struct zap_details *details)
+		unsigned long size)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_gather tlb;
@@ -1392,7 +1386,7 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	update_hiwater_rss(mm);
 	mmu_notifier_invalidate_range_start(mm, start, end);
 	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
-		unmap_single_vma(&tlb, vma, start, end, details);
+		unmap_single_vma(&tlb, vma, start, end, NULL);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 	tlb_finish_mmu(&tlb, start, end);
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d4f094..f6451eacb0aa 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -465,8 +465,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	struct zap_details details = {.check_swap_entries = true,
-				      .ignore_dirty = true};
 	bool ret = true;
 
 	/*
@@ -481,7 +479,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 *				out_of_memory
 	 *				  select_bad_process
 	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
+	 *  madv_dontneed # frees some memory
 	 */
 	mutex_lock(&oom_lock);
 
@@ -510,16 +508,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
-		if (is_vm_hugetlb_page(vma))
-			continue;
-
-		/*
-		 * mlocked VMAs require explicit munlocking before unmap.
-		 * Let's keep it simple here and skip such VMAs.
-		 */
-		if (vma->vm_flags & VM_LOCKED)
-			continue;
-
 		/*
 		 * Only anonymous pages have a good chance to be dropped
 		 * without additional steps which we cannot afford as we
@@ -531,8 +519,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		 * count elevated without a good reason.
 		 */
 		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
-			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
-					 &details);
+			madvise_dontneed(vma, &vma, vma->vm_start, vma->vm_end);
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
