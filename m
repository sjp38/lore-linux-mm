Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id A3AA56B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 21:24:07 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v2] Support volatile range for anon vma
Date: Tue, 30 Oct 2012 10:29:54 +0900
Message-Id: <1351560594-18366-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch introudces new madvise behavior MADV_VOLATILE and
MADV_NOVOLATILE for anonymous pages. It's different with
John Stultz's version which considers only tmpfs while this patch
considers only anonymous pages so this cannot cover John's one.
If below idea is proved as reasonable, I hope we can unify both
concepts by madvise/fadvise.

Rationale is following as.
Many allocators call munmap(2) when user call free(3) if ptr is
in mmaped area. But munmap isn't cheap because it have to clean up
all pte entries and unlinking a vma so overhead would be increased
linearly by mmaped area's size.

Volatile conecept of Robert Love could be very useful for reducing
free(3) overhead. Allocators can do madvise(MADV_VOLATILE) instead of
munmap(2)(Of course, they need to manage volatile mmaped area to
reduce shortage of address space and sometime ends up unmaping them).
The madvise(MADV_VOLATILE|NOVOLATILE) is very cheap opeartion because

1) it just marks the flag in VMA and
2) if memory pressure happens, VM can discard pages of volatile VMA
   instead of swapping out when volatile pages is selected as victim
   by normal VM aging policy.
3) freed mmaped area doesn't include any meaningful data so there
   is no point to swap them out.

Allocator should call madvise(MADV_NOVOLATILE) before reusing for
allocating that area to user. Otherwise, accessing of volatile range
will meet SIGBUS error.

The downside is that we have to age anon lru list although we don't
have swap because I don't want to discard volatile pages by top priority
when memory pressure happens as volatile in this patch means "We don't
need to swap out because user can handle the situation which data are
disappear suddenly", NOT "They are useless so hurry up to reclaim them".
So I want to apply same aging rule of nomal pages to them.

Anon background aging of non-swap system would be a trade-off for
getting good feature. Even, we had done it two years ago until merge
[1] and I believe free(3) performance gain will beat loss of anon lru
aging's overead once all of allocator start to use madvise.
(This patch doesn't include background aging in case of non-swap system
 but it's trivial if we decide)

I hope seeing opinions from others before diving into glibc or bionic.
Welcome to any comment.

[1] 74e3f3c3, vmscan: prevent background aging of anon page in no swap system

Changelog
 * from RFC v1
   * add clear comment of purge - Christoph
   * Change patch descritpion

Cc: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/asm-generic/mman-common.h |    3 +
 include/linux/mm.h                |    9 ++-
 include/linux/mm_types.h          |    5 ++
 include/linux/rmap.h              |   24 ++++++-
 mm/ksm.c                          |    4 +-
 mm/madvise.c                      |   32 +++++++++-
 mm/memory.c                       |    2 +
 mm/migrate.c                      |    6 +-
 mm/rmap.c                         |  126 +++++++++++++++++++++++++++++++++++--
 mm/vmscan.c                       |    3 +
 10 files changed, 202 insertions(+), 12 deletions(-)

diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
index d030d2c..5f8090d 100644
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -34,6 +34,9 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_VOLATILE	5		/* pages will disappear suddenly */
+#define MADV_NOVOLATILE 6		/* pages will not disappear */
+
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 311be90..78c8c08 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -120,6 +120,13 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
+/*
+ * Recently, Konstantin removed a few flags but not merged yet
+ * so we will get a room for new flag for supporting 32 bit.
+ * Thanks, Konstantin!
+ */
+#define VM_VOLATILE	0x100000000
+
 /* Bits set in the VMA until the stack is in its final location */
 #define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)
 
@@ -143,7 +150,7 @@ extern unsigned int kobjsize(const void *objp);
  * Special vmas that are non-mergable, non-mlock()able.
  * Note: mm/huge_memory.c VM_NO_THP depends on this definition.
  */
-#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)
+#define VM_SPECIAL (VM_IO|VM_DONTEXPAND|VM_RESERVED|VM_PFNMAP|VM_VOLATILE)
 
 /*
  * mapping from the currently active vm_flags protection bits (the
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bf78672..c813daa 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -279,6 +279,11 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	/*
+	 * True if more than a page in this vma is reclaimed.
+	 * It's protected by anon_vma->mutex.
+	 */
+	bool purged;
 };
 
 struct core_thread {
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 3fce545..65b9f33 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -67,6 +67,10 @@ struct anon_vma_chain {
 	struct list_head same_anon_vma;	/* locked by anon_vma->mutex */
 };
 
+
+void volatile_lock(struct vm_area_struct *vma);
+void volatile_unlock(struct vm_area_struct *vma);
+
 #ifdef CONFIG_MMU
 static inline void get_anon_vma(struct anon_vma *anon_vma)
 {
@@ -170,12 +174,14 @@ enum ttu_flags {
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
 	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
+	TTU_IGNORE_VOLATILE = (1 << 11),/* ignore volatile */
 };
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 
 int try_to_unmap(struct page *, enum ttu_flags flags);
 int try_to_unmap_one(struct page *, struct vm_area_struct *,
-			unsigned long address, enum ttu_flags flags);
+			unsigned long address, enum ttu_flags flags,
+			bool *is_volatile);
 
 /*
  * Called from mm/filemap_xip.c to unmap empty zero page
@@ -194,6 +200,21 @@ static inline pte_t *page_check_address(struct page *page, struct mm_struct *mm,
 	return ptep;
 }
 
+pte_t *__page_check_volatile_address(struct page *, struct mm_struct *,
+				unsigned long, spinlock_t **);
+
+static inline pte_t *page_check_volatile_address(struct page *page,
+					struct mm_struct *mm,
+					unsigned long address,
+					spinlock_t **ptlp)
+{
+	pte_t *ptep;
+
+	__cond_lock(*ptlp, ptep = __page_check_volatile_address(page,
+					mm, address, ptlp));
+	return ptep;
+}
+
 /*
  * Used by swapoff to help locate where page is expected in vma.
  */
@@ -257,5 +278,6 @@ static inline int page_mkclean(struct page *page)
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 #define SWAP_MLOCK	3
+#define SWAP_DISCARD	4
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/mm/ksm.c b/mm/ksm.c
index 47c8853..22c54d2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1653,6 +1653,7 @@ int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
 	struct rmap_item *rmap_item;
 	int ret = SWAP_AGAIN;
 	int search_new_forks = 0;
+	bool dummy_volatile;
 
 	VM_BUG_ON(!PageKsm(page));
 	VM_BUG_ON(!PageLocked(page));
@@ -1682,7 +1683,8 @@ again:
 				continue;
 
 			ret = try_to_unmap_one(page, vma,
-					rmap_item->address, flags);
+					rmap_item->address, flags,
+					&dummy_volatile);
 			if (ret != SWAP_AGAIN || !page_mapped(page)) {
 				anon_vma_unlock(anon_vma);
 				goto out;
diff --git a/mm/madvise.c b/mm/madvise.c
index 14d260f..53cd77f 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -86,6 +86,22 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		if (error)
 			goto out;
 		break;
+	case MADV_VOLATILE:
+		if (vma->vm_flags & VM_LOCKED) {
+			error = -EINVAL;
+			goto out;
+		}
+		new_flags |= VM_VOLATILE;
+		vma->purged = false;
+		break;
+	case MADV_NOVOLATILE:
+		if (!(vma->vm_flags & VM_VOLATILE)) {
+			error = -EINVAL;
+			goto out;
+		}
+
+		new_flags &= ~VM_VOLATILE;
+		break;
 	}
 
 	if (new_flags == vma->vm_flags) {
@@ -118,9 +134,15 @@ static long madvise_behavior(struct vm_area_struct * vma,
 success:
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
+	 * In case of VOLATILE, we need volatile_lock, additionally.
 	 */
+	if (behavior == MADV_NOVOLATILE || behavior == MADV_VOLATILE)
+		volatile_lock(vma);
 	vma->vm_flags = new_flags;
-
+	if (behavior == MADV_NOVOLATILE)
+		error = vma->purged;
+	if (behavior == MADV_NOVOLATILE || behavior == MADV_VOLATILE)
+		volatile_unlock(vma);
 out:
 	if (error == -ENOMEM)
 		error = -EAGAIN;
@@ -310,6 +332,8 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+	case MADV_VOLATILE:
+	case MADV_NOVOLATILE:
 		return 1;
 
 	default:
@@ -383,7 +407,11 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 
 	if (start & ~PAGE_MASK)
 		goto out;
-	len = (len_in + ~PAGE_MASK) & PAGE_MASK;
+
+	if (behavior != MADV_VOLATILE && behavior != MADV_NOVOLATILE)
+		len = (len_in + ~PAGE_MASK) & PAGE_MASK;
+	else
+		len = len_in & PAGE_MASK;
 
 	/* Check to see whether len was rounded up from small -ve to zero */
 	if (len_in && !len)
diff --git a/mm/memory.c b/mm/memory.c
index 5736170..26b3f73 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3441,6 +3441,8 @@ int handle_pte_fault(struct mm_struct *mm,
 	entry = *pte;
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
+			if (unlikely(vma->vm_flags & VM_VOLATILE))
+				return VM_FAULT_SIGBUS;
 			if (vma->vm_ops) {
 				if (likely(vma->vm_ops->fault))
 					return do_linear_fault(mm, vma, address,
diff --git a/mm/migrate.c b/mm/migrate.c
index 77ed2d7..d1b51af 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -800,7 +800,8 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	}
 
 	/* Establish migration ptes or remove ptes */
-	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|
+			TTU_IGNORE_ACCESS|TTU_IGNORE_VOLATILE);
 
 skip_unmap:
 	if (!page_mapped(page))
@@ -915,7 +916,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	if (PageAnon(hpage))
 		anon_vma = page_get_anon_vma(hpage);
 
-	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|
+				TTU_IGNORE_ACCESS|TTU_IGNORE_VOLATILE);
 
 	if (!page_mapped(hpage))
 		rc = move_to_new_page(new_hpage, hpage, 1, mode);
diff --git a/mm/rmap.c b/mm/rmap.c
index 0f3b7cd..778abfc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -603,6 +603,57 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 	return vma_address(page, vma);
 }
 
+pte_t *__page_check_volatile_address(struct page *page, struct mm_struct *mm,
+			  unsigned long address, spinlock_t **ptlp)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	swp_entry_t entry = { .val = page_private(page) };
+
+	if (unlikely(PageHuge(page))) {
+		pte = huge_pte_offset(mm, address);
+		ptl = &mm->page_table_lock;
+		goto check;
+	}
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return NULL;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return NULL;
+
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		return NULL;
+	if (pmd_trans_huge(*pmd))
+		return NULL;
+
+	pte = pte_offset_map(pmd, address);
+	ptl = pte_lockptr(mm, pmd);
+check:
+	spin_lock(ptl);
+	if (PageAnon(page)) {
+		if (!pte_present(*pte) && entry.val ==
+				pte_to_swp_entry(*pte).val) {
+			*ptlp = ptl;
+			return pte;
+		}
+	} else {
+		if (pte_none(*pte)) {
+			*ptlp = ptl;
+			return pte;
+		}
+	}
+	pte_unmap_unlock(pte, ptl);
+	return NULL;
+}
+
 /*
  * Check that @page is mapped at @address into @mm.
  *
@@ -1218,12 +1269,42 @@ out:
 		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
+int try_to_zap_one(struct page *page, struct vm_area_struct *vma,
+		unsigned long address)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *pte;
+	pte_t pteval;
+	spinlock_t *ptl;
+
+	pte = page_check_volatile_address(page, mm, address, &ptl);
+	if (!pte)
+		return 0;
+
+	/* Nuke the page table entry. */
+	flush_cache_page(vma, address, page_to_pfn(page));
+	pteval = ptep_clear_flush(vma, address, pte);
+
+	if (PageAnon(page)) {
+		swp_entry_t entry = { .val = page_private(page) };
+		if (PageSwapCache(page)) {
+			dec_mm_counter(mm, MM_SWAPENTS);
+			swap_free(entry);
+		}
+	}
+
+	pte_unmap_unlock(pte, ptl);
+	mmu_notifier_invalidate_page(mm, address);
+	return 1;
+}
+
 /*
  * Subfunctions of try_to_unmap: try_to_unmap_one called
  * repeatedly from try_to_unmap_ksm, try_to_unmap_anon or try_to_unmap_file.
  */
 int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
-		     unsigned long address, enum ttu_flags flags)
+		     unsigned long address, enum ttu_flags flags,
+		     bool *is_volatile)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte;
@@ -1235,6 +1316,8 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if (!pte)
 		goto out;
 
+	if (!(vma->vm_flags & VM_VOLATILE))
+		*is_volatile = false;
 	/*
 	 * If the page is mlock()d, we cannot swap it out.
 	 * If it's recently referenced (perhaps page_referenced
@@ -1494,6 +1577,10 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
+	bool is_volatile = true;
+
+	if (flags & TTU_IGNORE_VOLATILE)
+		is_volatile = false;
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
@@ -1512,17 +1599,32 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 		 * temporary VMAs until after exec() completes.
 		 */
 		if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION) &&
-				is_vma_temporary_stack(vma))
+				is_vma_temporary_stack(vma)) {
+			is_volatile = false;
 			continue;
+		}
 
 		address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
-		ret = try_to_unmap_one(page, vma, address, flags);
+		ret = try_to_unmap_one(page, vma, address, flags, &is_volatile);
 		if (ret != SWAP_AGAIN || !page_mapped(page))
 			break;
 	}
 
+	if (page_mapped(page) || is_volatile == false)
+		goto out;
+
+	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+		struct vm_area_struct *vma = avc->vma;
+		unsigned long address;
+
+		address = vma_address(page, vma);
+		if (try_to_zap_one(page, vma, address))
+			vma->purged = true;
+	}
+	ret = SWAP_DISCARD;
+out:
 	page_unlock_anon_vma(anon_vma);
 	return ret;
 }
@@ -1553,13 +1655,14 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
+	bool dummy;
 
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
-		ret = try_to_unmap_one(page, vma, address, flags);
+		ret = try_to_unmap_one(page, vma, address, flags, &dummy);
 		if (ret != SWAP_AGAIN || !page_mapped(page))
 			goto out;
 	}
@@ -1651,6 +1754,7 @@ out:
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
  * SWAP_MLOCK	- page is mlocked.
+ * SWAP_DISCARD - page is volatile.
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
@@ -1665,7 +1769,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 		ret = try_to_unmap_anon(page, flags);
 	else
 		ret = try_to_unmap_file(page, flags);
-	if (ret != SWAP_MLOCK && !page_mapped(page))
+	if (ret != SWAP_MLOCK && !page_mapped(page) && ret != SWAP_DISCARD)
 		ret = SWAP_SUCCESS;
 	return ret;
 }
@@ -1707,6 +1811,18 @@ void __put_anon_vma(struct anon_vma *anon_vma)
 	anon_vma_free(anon_vma);
 }
 
+void volatile_lock(struct vm_area_struct *vma)
+{
+	if (vma->anon_vma)
+		anon_vma_lock(vma->anon_vma);
+}
+
+void volatile_unlock(struct vm_area_struct *vma)
+{
+	if (vma->anon_vma)
+		anon_vma_unlock(vma->anon_vma);
+}
+
 #ifdef CONFIG_MIGRATION
 /*
  * rmap_walk() and its helpers rmap_walk_anon() and rmap_walk_file():
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 99b434b..d5b60d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -789,6 +789,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		if (page_mapped(page) && mapping) {
 			switch (try_to_unmap(page, TTU_UNMAP)) {
+			case SWAP_DISCARD:
+				goto discard_page;
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -857,6 +859,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
+discard_page:
 		/*
 		 * If the page has buffers, try to free the buffer mappings
 		 * associated with this page. If we succeed we try to free
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
