Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD3F06B03A3
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:14:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u9so15923423wme.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:14:59 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 09/13] mm/memory: Add function to one-to-one duplicate page ranges
Date: Mon, 13 Mar 2017 15:14:11 -0700
Message-Id: <20170313221415.9375-10-till.smejkal@gmail.com>
In-Reply-To: <20170313221415.9375-1-till.smejkal@gmail.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

Add new function to one-to-one duplicate a page table range of one memory
map to another memory map. The new function 'dup_page_range' copies the
page table entries for the specified region from the page table of the
source memory map to the page table of the destination memory map and
thereby allows actual sharing of the referenced memory pages instead of
relying on copy-on-write for anonymous memory pages or page faults for
read-only memory pages as it is done by the existing function
'copy_page_range'. Hence, 'dup_page_range' will produce shared pages
between two address spaces whereas 'copy_page_range' will result in copies
of pages if necessary.

Preexisting mappings in the page table of the destination memory map are
properly zapped by the 'dup_page_range' function if they differ from the
ones in the source memory map before they are replaced with the new ones.

Signed-off-by: Till Smejkal <till.smejkal@gmail.com>
---
 include/linux/huge_mm.h |   6 +
 include/linux/hugetlb.h |   5 +
 include/linux/mm.h      |   2 +
 mm/huge_memory.c        |  65 +++++++
 mm/hugetlb.c            | 205 +++++++++++++++------
 mm/memory.c             | 461 +++++++++++++++++++++++++++++++++++++++++-------
 6 files changed, 620 insertions(+), 124 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 94a0e680b7d7..52c0498426ef 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -5,6 +5,12 @@ extern int do_huge_pmd_anonymous_page(struct vm_fault *vmf);
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
+extern int dup_huge_pmd(struct mm_struct *dst_mm,
+			struct vm_area_struct *dst_vma,
+			struct mm_struct *src_mm,
+			struct vm_area_struct *src_vma,
+			struct mmu_gather *tlb, pmd_t *dst_pmd, pmd_t *src_pmd,
+			unsigned long addr);
 extern void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd);
 extern int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd);
 extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 72260cc252f2..d8eb682e39a1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -63,6 +63,10 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
 #endif
 
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
+int dup_hugetlb_page_range(struct mm_struct *dst_mm,
+			   struct vm_area_struct *dst_vma,
+			   struct mm_struct *src_mm,
+			   struct vm_area_struct *src_vma);
 long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			 struct page **, struct vm_area_struct **,
 			 unsigned long *, unsigned long *, long, unsigned int);
@@ -134,6 +138,7 @@ static inline unsigned long hugetlb_total_pages(void)
 #define follow_hugetlb_page(m,v,p,vs,a,b,i,w)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
+#define dup_hugetlb_page_range(dst, dst_vma, src, src_vma) ({ BUG(); 0; })
 static inline void hugetlb_report_meminfo(struct seq_file *m)
 {
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 92925d97da20..b39ec795f64c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1208,6 +1208,8 @@ void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
+int dup_page_range(struct mm_struct *dst, struct vm_area_struct *dst_vma,
+		   struct mm_struct *src, struct vm_area_struct *src_vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d5b2604867e5..1edf8c6d1814 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -887,6 +887,71 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	return ret;
 }
 
+int dup_huge_pmd(struct mm_struct *dst_mm, struct vm_area_struct *dst_vma,
+		 struct mm_struct *src_mm, struct vm_area_struct *src_vma,
+		 struct mmu_gather *tlb, pmd_t *dst_pmd, pmd_t *src_pmd,
+		 unsigned long addr)
+{
+	spinlock_t *dst_ptl, *src_ptl;
+	struct page *page;
+	pmd_t pmd;
+	pgtable_t pgtable;
+	int ret;
+
+	pgtable = pte_alloc_one(dst_mm, addr);
+	if (!pgtable)
+		return -ENOMEM;
+
+	if (!pmd_none_or_clear_bad(dst_pmd) &&
+	    unlikely(zap_huge_pmd(tlb, dst_vma, dst_pmd, addr)))
+		return -ENOMEM;
+
+	dst_ptl = pmd_lock(dst_mm, dst_pmd);
+	src_ptl = pmd_lockptr(src_mm, src_pmd);
+	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
+
+	if (!pmd_trans_huge(*src_pmd)) {
+		pte_free(dst_mm, pgtable);
+		ret = -EAGAIN;
+		goto out_unlock;
+	}
+
+	if (is_huge_zero_pmd(*src_pmd)) {
+		struct page *zero_page;
+
+		zero_page = mm_get_huge_zero_page(dst_mm);
+		set_huge_zero_page(pgtable, dst_mm, dst_vma, addr, dst_pmd,
+				   zero_page);
+
+		ret = 0;
+		goto out_unlock;
+	}
+
+	pmd = *src_pmd;
+
+	page = pmd_page(pmd);
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	get_page(page);
+	page_dup_rmap(page, true);
+
+	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+	atomic_long_inc(&dst_mm->nr_ptes);
+	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
+
+	if (!(dst_vma->vm_flags & VM_WRITE))
+		pmd = pmd_wrprotect(pmd);
+	pmd = pmd_mkold(pmd);
+
+	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
+	ret = 0;
+
+out_unlock:
+	spin_unlock(src_ptl);
+	spin_unlock(dst_ptl);
+
+	return ret;
+}
+
 void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	pmd_t entry;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c7025c132670..776c024de7c1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3286,6 +3286,74 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	return ret;
 }
 
+static inline int
+unmap_one_hugepage(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		   pte_t *ptep, unsigned long addr, struct page *ref_page)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t pte;
+	spinlock_t *ptl;
+	struct page *page;
+	struct hstate *h = hstate_vma(vma);
+
+	ptl = huge_pte_lock(h, mm, ptep);
+	if (huge_pmd_unshare(mm, &addr, ptep)) {
+		spin_unlock(ptl);
+		return 0;
+	}
+
+	pte = huge_ptep_get(ptep);
+	if (huge_pte_none(pte)) {
+		spin_unlock(ptl);
+		return 0;
+	}
+
+	/*
+	 * Migrating hugepage or HWPoisoned hugepage is already
+	 * unmapped and its refcount is dropped, so just clear pte here.
+	 */
+	if (unlikely(!pte_present(pte))) {
+		huge_pte_clear(mm, addr, ptep);
+		spin_unlock(ptl);
+		return 0;
+	}
+
+	page = pte_page(pte);
+	/*
+	 * If a reference page is supplied, it is because a specific
+	 * page is being unmapped, not a range. Ensure the page we
+	 * are about to unmap is the actual page of interest.
+	 */
+	if (ref_page) {
+		if (page != ref_page) {
+			spin_unlock(ptl);
+			return 0;
+		}
+		/*
+		 * Mark the VMA as having unmapped its page so that
+		 * future faults in this VMA will fail rather than
+		 * looking like data was lost
+		 */
+		set_vma_resv_flags(vma, HPAGE_RESV_UNMAPPED);
+	}
+
+	pte = huge_ptep_get_and_clear(mm, addr, ptep);
+	tlb_remove_huge_tlb_entry(h, tlb, ptep, addr);
+	if (huge_pte_dirty(pte))
+		set_page_dirty(page);
+
+	hugetlb_count_sub(pages_per_huge_page(h), mm);
+	page_remove_rmap(page, true);
+
+	spin_unlock(ptl);
+	tlb_remove_page_size(tlb, page, huge_page_size(h));
+
+	/*
+	 * Bail out after unmapping reference page if supplied
+	 */
+	return ref_page ? 1 : 0;
+}
+
 void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			    unsigned long start, unsigned long end,
 			    struct page *ref_page)
@@ -3293,9 +3361,6 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *ptep;
-	pte_t pte;
-	spinlock_t *ptl;
-	struct page *page;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
 	const unsigned long mmun_start = start;	/* For mmu_notifiers */
@@ -3318,62 +3383,10 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		if (!ptep)
 			continue;
 
-		ptl = huge_pte_lock(h, mm, ptep);
-		if (huge_pmd_unshare(mm, &address, ptep)) {
-			spin_unlock(ptl);
-			continue;
-		}
-
-		pte = huge_ptep_get(ptep);
-		if (huge_pte_none(pte)) {
-			spin_unlock(ptl);
-			continue;
-		}
-
-		/*
-		 * Migrating hugepage or HWPoisoned hugepage is already
-		 * unmapped and its refcount is dropped, so just clear pte here.
-		 */
-		if (unlikely(!pte_present(pte))) {
-			huge_pte_clear(mm, address, ptep);
-			spin_unlock(ptl);
-			continue;
-		}
-
-		page = pte_page(pte);
-		/*
-		 * If a reference page is supplied, it is because a specific
-		 * page is being unmapped, not a range. Ensure the page we
-		 * are about to unmap is the actual page of interest.
-		 */
-		if (ref_page) {
-			if (page != ref_page) {
-				spin_unlock(ptl);
-				continue;
-			}
-			/*
-			 * Mark the VMA as having unmapped its page so that
-			 * future faults in this VMA will fail rather than
-			 * looking like data was lost
-			 */
-			set_vma_resv_flags(vma, HPAGE_RESV_UNMAPPED);
-		}
-
-		pte = huge_ptep_get_and_clear(mm, address, ptep);
-		tlb_remove_huge_tlb_entry(h, tlb, ptep, address);
-		if (huge_pte_dirty(pte))
-			set_page_dirty(page);
-
-		hugetlb_count_sub(pages_per_huge_page(h), mm);
-		page_remove_rmap(page, true);
-
-		spin_unlock(ptl);
-		tlb_remove_page_size(tlb, page, huge_page_size(h));
-		/*
-		 * Bail out after unmapping reference page if supplied
-		 */
-		if (ref_page)
+		if (unlikely(unmap_one_hugepage(tlb, vma, ptep, address,
+						ref_page)))
 			break;
+
 	}
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	tlb_end_vma(tlb, vma);
@@ -3411,6 +3424,82 @@ void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 	tlb_finish_mmu(&tlb, start, end);
 }
 
+int dup_hugetlb_page_range(struct mm_struct *dst_mm,
+			   struct vm_area_struct *dst_vma,
+			   struct mm_struct *src_mm,
+			   struct vm_area_struct *src_vma)
+{
+	pte_t *dst_pte, *src_pte;
+	struct mmu_gather tlb;
+	struct hstate *h = hstate_vma(dst_vma);
+	unsigned long addr;
+	unsigned long mmu_start = dst_vma->vm_start;
+	unsigned long mmu_end = dst_vma->vm_end;
+	unsigned long size = huge_page_size(h);
+	int ret;
+
+	tlb_gather_mmu(&tlb, dst_mm, mmu_start, mmu_end);
+	tlb_remove_check_page_size_change(&tlb, size);
+	mmu_notifier_invalidate_range_start(dst_mm, mmu_start, mmu_end);
+
+	for (addr = src_vma->vm_start; addr < src_vma->vm_end; addr += size) {
+		pte_t pte;
+		spinlock_t *dst_ptl, *src_ptl;
+		struct page *page;
+
+		dst_pte = huge_pte_offset(dst_mm, addr);
+		src_pte = huge_pte_offset(src_mm, addr);
+
+		if (dst_pte == src_pte)
+			/* Just continue if the ptes are already equal. */
+			continue;
+		else if (dst_pte && !huge_pte_none(*dst_pte))
+			/*
+			 * ptes are not equal, so we have to get rid of the old
+			 * mapping in the destination page table.
+			 */
+			unmap_one_hugepage(&tlb, dst_vma, dst_pte, addr, NULL);
+
+		if (!src_pte || huge_pte_none(*src_pte))
+			continue;
+
+		dst_pte = huge_pte_alloc(dst_mm, addr, size);
+		if (!dst_pte) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		dst_ptl = huge_pte_lock(h, dst_mm, dst_pte);
+		src_ptl = huge_pte_lockptr(h, src_mm, src_pte);
+		spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
+
+		pte = huge_ptep_get(src_pte);
+		page = pte_page(pte);
+		if (page) {
+			get_page(page);
+			page_dup_rmap(page, true);
+		}
+
+		if (likely(!is_hugetlb_entry_migration(pte) &&
+			   !is_hugetlb_entry_hwpoisoned(pte)))
+			hugetlb_count_add(pages_per_huge_page(h), dst_mm);
+
+		if (!(dst_vma->vm_flags & VM_WRITE))
+			pte = pte_wrprotect(pte);
+		pte = pte_mkold(pte);
+
+		set_huge_pte_at(dst_mm, addr, dst_pte, pte);
+
+		spin_unlock(src_ptl);
+		spin_unlock(dst_ptl);
+	}
+
+	mmu_notifier_invalidate_range_end(dst_mm, mmu_start, mmu_end);
+	tlb_finish_mmu(&tlb, mmu_start, mmu_end);
+
+	return ret;
+}
+
 /*
  * This is called when the original mapper is failing to COW a MAP_PRIVATE
  * mappping it owns the reserve page for. The intention is to unmap the page
diff --git a/mm/memory.c b/mm/memory.c
index 6bf2b471e30c..7026f2146fcd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1108,6 +1108,82 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	return ret;
 }
 
+static unsigned long zap_one_pte(struct mmu_gather *tlb,
+				 struct vm_area_struct *vma, pte_t *pte,
+				 unsigned long *paddr, int *force_flush,
+				 int *rss, struct zap_details *details)
+{
+	unsigned long addr = *paddr;
+	struct mm_struct *mm = tlb->mm;
+	swp_entry_t entry;
+	pte_t ptent = *pte;
+
+	if (pte_present(ptent)) {
+		struct page *page;
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (unlikely(details) && page) {
+			/*
+			 * unmap_shared_mapping_pages() wants to
+			 * invalidate cache without truncating:
+			 * unmap shared but keep private pages.
+			 */
+			if (details->check_mapping &&
+			    details->check_mapping != page_rmapping(page))
+				return 0;
+		}
+		ptent = ptep_get_and_clear_full(mm, addr, pte,
+						tlb->fullmm);
+		tlb_remove_tlb_entry(tlb, pte, addr);
+		if (unlikely(!page))
+			return 0;
+
+		if (!PageAnon(page)) {
+			if (pte_dirty(ptent)) {
+				/*
+				 * oom_reaper cannot tear down dirty
+				 * pages
+				 */
+				if (unlikely(details && details->ignore_dirty))
+					return 0;
+				*force_flush = 1;
+				set_page_dirty(page);
+			}
+			if (pte_young(ptent) &&
+			    likely(!(vma->vm_flags & VM_SEQ_READ)))
+				mark_page_accessed(page);
+		}
+		rss[mm_counter(page)]--;
+		page_remove_rmap(page, false);
+		if (unlikely(page_mapcount(page) < 0))
+			print_bad_pte(vma, addr, ptent, page);
+		if (unlikely(__tlb_remove_page(tlb, page))) {
+			*force_flush = 1;
+			*paddr += PAGE_SIZE;
+			return 1;
+		}
+		return 0;
+	}
+	/* only check swap_entries if explicitly asked for in details */
+	if (unlikely(details && !details->check_swap_entries))
+		return 0;
+
+	entry = pte_to_swp_entry(ptent);
+	if (!non_swap_entry(entry))
+		rss[MM_SWAPENTS]--;
+	else if (is_migration_entry(entry)) {
+		struct page *page;
+
+		page = migration_entry_to_page(entry);
+		rss[mm_counter(page)]--;
+	}
+	if (unlikely(!free_swap_and_cache(entry)))
+		print_bad_pte(vma, addr, ptent, NULL);
+	pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
+
+	return 0;
+}
+
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
@@ -1119,7 +1195,6 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	spinlock_t *ptl;
 	pte_t *start_pte;
 	pte_t *pte;
-	swp_entry_t entry;
 
 	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
 again:
@@ -1128,73 +1203,12 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	pte = start_pte;
 	arch_enter_lazy_mmu_mode();
 	do {
-		pte_t ptent = *pte;
-		if (pte_none(ptent)) {
-			continue;
-		}
-
-		if (pte_present(ptent)) {
-			struct page *page;
-
-			page = vm_normal_page(vma, addr, ptent);
-			if (unlikely(details) && page) {
-				/*
-				 * unmap_shared_mapping_pages() wants to
-				 * invalidate cache without truncating:
-				 * unmap shared but keep private pages.
-				 */
-				if (details->check_mapping &&
-				    details->check_mapping != page_rmapping(page))
-					continue;
-			}
-			ptent = ptep_get_and_clear_full(mm, addr, pte,
-							tlb->fullmm);
-			tlb_remove_tlb_entry(tlb, pte, addr);
-			if (unlikely(!page))
-				continue;
-
-			if (!PageAnon(page)) {
-				if (pte_dirty(ptent)) {
-					/*
-					 * oom_reaper cannot tear down dirty
-					 * pages
-					 */
-					if (unlikely(details && details->ignore_dirty))
-						continue;
-					force_flush = 1;
-					set_page_dirty(page);
-				}
-				if (pte_young(ptent) &&
-				    likely(!(vma->vm_flags & VM_SEQ_READ)))
-					mark_page_accessed(page);
-			}
-			rss[mm_counter(page)]--;
-			page_remove_rmap(page, false);
-			if (unlikely(page_mapcount(page) < 0))
-				print_bad_pte(vma, addr, ptent, page);
-			if (unlikely(__tlb_remove_page(tlb, page))) {
-				force_flush = 1;
-				addr += PAGE_SIZE;
-				break;
-			}
-			continue;
-		}
-		/* only check swap_entries if explicitly asked for in details */
-		if (unlikely(details && !details->check_swap_entries))
+		if (pte_none(*pte))
 			continue;
 
-		entry = pte_to_swp_entry(ptent);
-		if (!non_swap_entry(entry))
-			rss[MM_SWAPENTS]--;
-		else if (is_migration_entry(entry)) {
-			struct page *page;
-
-			page = migration_entry_to_page(entry);
-			rss[mm_counter(page)]--;
-		}
-		if (unlikely(!free_swap_and_cache(entry)))
-			print_bad_pte(vma, addr, ptent, NULL);
-		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
+		if (unlikely(zap_one_pte(tlb, vma, pte, &addr, &force_flush,
+					 rss, details)))
+			break;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 
 	add_mm_rss_vec(mm, rss);
@@ -1445,6 +1459,321 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 }
 EXPORT_SYMBOL_GPL(zap_vma_ptes);
 
+static inline int
+dup_one_pte(struct mm_struct *dst_mm, struct vm_area_struct *dst_vma,
+	    struct mm_struct *src_mm, struct vm_area_struct *src_vma,
+	    struct mmu_gather *tlb, pte_t *dst_pte, pte_t *src_pte,
+	    unsigned long addr, int *force_flush, int *rss)
+{
+	unsigned long raddr = addr;
+	pte_t pte = *src_pte;
+	struct page *page;
+
+	/*
+	 * If the ptes are already exactly the same, we don't have to do
+	 * anything.
+	 */
+	if (likely(src_pte == dst_pte))
+		return 0;
+
+	/* Remove the old mapping first */
+	if (!pte_none(*dst_pte) &&
+	    unlikely(zap_one_pte(tlb, dst_vma, dst_pte, &raddr, force_flush,
+				 rss, NULL)))
+		return -ENOMEM;
+
+	/* pte contains position in swap or file, so copy. */
+	if (unlikely(!pte_present(pte))) {
+		swp_entry_t entry = pte_to_swp_entry(pte);
+
+		if (likely(!non_swap_entry(entry))) {
+			if (swap_duplicate(entry) < 0)
+				return entry.val;
+
+			/* make sure dst_mm is on swapoff's mmlist. */
+			if (unlikely(list_empty(&dst_mm->mmlist))) {
+				spin_lock(&mmlist_lock);
+				if (list_empty(&dst_mm->mmlist))
+					list_add(&dst_mm->mmlist,
+							&src_mm->mmlist);
+				spin_unlock(&mmlist_lock);
+			}
+			rss[MM_SWAPENTS]++;
+		} else if (is_migration_entry(entry)) {
+			page = migration_entry_to_page(entry);
+
+			rss[mm_counter(page)]++;
+		}
+		goto out_set_pte;
+	}
+
+	pte = pte_mkold(pte);
+
+	page = vm_normal_page(src_vma, addr, pte);
+	if (page) {
+		get_page(page);
+		page_dup_rmap(page, false);
+		rss[mm_counter(page)]++;
+	}
+
+out_set_pte:
+	if (!(dst_vma->vm_flags & VM_WRITE))
+		pte = pte_wrprotect(pte);
+
+	set_pte_at(dst_mm, addr, dst_pte, pte);
+	return 0;
+}
+
+static inline int
+dup_pte_range(struct mm_struct *dst_mm, struct vm_area_struct *dst_vma,
+	      struct mm_struct *src_mm, struct vm_area_struct *src_vma,
+	      struct mmu_gather *tlb, pmd_t *dst_pmd, pmd_t *src_pmd,
+	      unsigned long addr, unsigned long end)
+{
+	pte_t *orig_dst_pte, *orig_src_pte;
+	pte_t *dst_pte, *src_pte;
+	spinlock_t *dst_ptl, *src_ptl;
+	int force_flush = 0;
+	int progress = 0;
+	int rss[NR_MM_COUNTERS];
+	swp_entry_t entry = (swp_entry_t){0};
+
+again:
+	init_rss_vec(rss);
+
+	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
+	if (!dst_pte)
+		return -ENOMEM;
+	src_pte = pte_offset_map(src_pmd, addr);
+	src_ptl = pte_lockptr(src_mm, src_pmd);
+	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
+	orig_dst_pte = dst_pte;
+	orig_src_pte = src_pte;
+
+	arch_enter_lazy_mmu_mode();
+
+	do {
+		/* Make sure that we are not holding the looks too long. */
+		if (progress >= 32) {
+			progress = 0;
+			if (need_resched() || spin_needbreak(src_ptl) ||
+			    spin_needbreak(dst_ptl))
+				break;
+		}
+
+		if (pte_none(*src_pte) && pte_none(*dst_pte)) {
+			progress++;
+			continue;
+		} else if (pte_none(*src_pte)) {
+			unsigned long raddr = addr;
+			int ret;
+
+			ret = zap_one_pte(tlb, dst_vma, dst_pte, &raddr,
+					  &force_flush, rss, NULL);
+			pte_clear(dst_mm, addr, dst_pte);
+
+			progress += 8;
+			if (ret)
+				break;
+
+			continue;
+		}
+
+		entry.val = dup_one_pte(dst_mm, dst_vma, src_mm, src_vma,
+					tlb, dst_pte, src_pte, addr,
+					&force_flush, rss);
+
+		if (entry.val)
+			break;
+		progress += 8;
+	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
+
+	arch_leave_lazy_mmu_mode();
+	spin_unlock(src_ptl);
+	pte_unmap(orig_src_pte);
+	add_mm_rss_vec(dst_mm, rss);
+
+	/* Do the TLB flush before unlocking the destination ptl */
+	if (force_flush)
+		tlb_flush_mmu_tlbonly(tlb);
+	pte_unmap_unlock(orig_dst_pte, dst_ptl);
+
+	/* Sometimes we have to free all the batch memory as well. */
+	if (force_flush) {
+		force_flush = 0;
+		tlb_flush_mmu_free(tlb);
+	}
+
+	cond_resched();
+	if (entry.val) {
+		if (add_swap_count_continuation(entry, GFP_KERNEL) < 0)
+			return -ENOMEM;
+		progress = 0;
+	}
+	if (addr != end)
+		goto again;
+
+	return 0;
+}
+
+static inline int
+dup_pmd_range(struct mm_struct *dst_mm, struct vm_area_struct *dst_vma,
+	      struct mm_struct *src_mm, struct vm_area_struct *src_vma,
+	      struct mmu_gather *tlb, pud_t *dst_pud, pud_t *src_pud,
+	      unsigned long addr, unsigned long end)
+{
+	pmd_t *dst_pmd, *src_pmd;
+	unsigned long next;
+
+	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr);
+	if (!dst_pmd)
+		return -ENOMEM;
+	src_pmd = pmd_offset(src_pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+
+		if (pmd_none_or_clear_bad(src_pmd) &&
+		    pmd_none_or_clear_bad(dst_pmd)) {
+			continue;
+		} else if (pmd_none_or_clear_bad(src_pmd)) {
+			/* src unmapped, but dst not --> free dst too */
+			zap_pte_range(tlb, dst_vma, dst_pmd, addr, next, NULL);
+			free_pte_range(tlb, dst_pmd, addr);
+
+			continue;
+		} else if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
+			int err;
+
+			VM_BUG_ON(next-addr != HPAGE_PMD_SIZE);
+
+			/*
+			 * We may need to unmap the content of the destination
+			 * page table first. So check this here, because
+			 * inside dup_huge_pmd we cannot do it anymore.
+			 */
+			if (unlikely(!pmd_trans_huge(*dst_pmd) &&
+				     !pmd_devmap(*dst_pmd) &&
+				     !pmd_none_or_clear_bad(dst_pmd))) {
+				zap_pte_range(tlb, dst_vma, dst_pmd, addr, next,
+					      NULL);
+				free_pte_range(tlb, dst_pmd, addr);
+			}
+
+			err = dup_huge_pmd(dst_mm, dst_vma, src_mm, src_vma,
+					   tlb, dst_pmd, src_pmd, addr);
+
+			if (err == -ENOMEM)
+				return -ENOMEM;
+			if (!err)
+				continue;
+			/* explicit fall through */
+
+		}
+
+		if (unlikely(dup_pte_range(dst_mm, dst_vma, src_mm, src_vma,
+					   tlb, dst_pmd, src_pmd, addr, next)))
+			return -ENOMEM;
+	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
+
+	return 0;
+}
+
+static inline int
+dup_pud_range(struct mm_struct *dst_mm, struct vm_area_struct *dst_vma,
+	      struct mm_struct *src_mm, struct vm_area_struct *src_vma,
+	      struct mmu_gather *tlb, pgd_t *dst_pgd, pgd_t *src_pgd,
+	      unsigned long addr, unsigned long end)
+{
+	pud_t *dst_pud, *src_pud;
+	unsigned long next;
+
+	dst_pud = pud_alloc(dst_mm, dst_pgd, addr);
+	if (!dst_pud)
+		return -ENOMEM;
+	src_pud = pud_offset(src_pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(src_pud) &&
+		    pud_none_or_clear_bad(dst_pud)) {
+			continue;
+		} else if (pud_none_or_clear_bad(src_pud)) {
+			/* src is unmapped, but dst not --> free dst too */
+			zap_pmd_range(tlb, dst_vma, dst_pud, addr, next, NULL);
+			free_pmd_range(tlb, dst_pud, addr, next, addr, next);
+
+			continue;
+		}
+
+		if (unlikely(dup_pmd_range(dst_mm, dst_vma, src_mm, src_vma,
+					   tlb, dst_pud, src_pud, addr, next)))
+			return -ENOMEM;
+	} while (dst_pud++, src_pud++, addr = next, addr != end);
+
+	return 0;
+}
+
+/**
+ * One-to-one duplicate the page table entries of one memory map to another
+ * memory map. After this function, the destination memory map will have the
+ * exact same page table entries for the specified region as the source memory
+ * map. Preexisting mappings in the destination memory map will be removed
+ * before they are overwritten with the ones from the source memory map if they
+ * differ.
+ *
+ * The difference between this function and @copy_page_range is that
+ * 'copy_page_range' will copy the underlying memory pages if necessary (e.g.
+ * for anonymous memory) with the help of copy-on-write while 'dup_page_range'
+ * will only duplicate the page table entries and hence allow both memory maps
+ * to actually share the referenced memory pages.
+ **/
+int dup_page_range(struct mm_struct *dst_mm, struct vm_area_struct *dst_vma,
+		   struct mm_struct *src_mm, struct vm_area_struct *src_vma)
+{
+	pgd_t *dst_pgd, *src_pgd;
+	struct mmu_gather tlb;
+	unsigned long next;
+	unsigned long addr = src_vma->vm_start;
+	unsigned long end = src_vma->vm_end;
+	unsigned long mmu_start = dst_vma->vm_start;
+	unsigned long mmu_end = dst_vma->vm_end;
+	int ret = 0;
+
+	if (is_vm_hugetlb_page(src_vma))
+		return dup_hugetlb_page_range(dst_mm, dst_vma, src_mm,
+					      src_vma);
+
+	tlb_gather_mmu(&tlb, dst_mm, mmu_start, mmu_end);
+	mmu_notifier_invalidate_range_start(dst_mm, mmu_start, mmu_end);
+
+	dst_pgd = pgd_offset(dst_mm, addr);
+	src_pgd = pgd_offset(src_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(src_pgd) &&
+		    pgd_none_or_clear_bad(dst_pgd)) {
+			continue;
+		} else if (pgd_none_or_clear_bad(src_pgd)) {
+			/* src is unmapped, but dst not --> free dst too */
+			zap_pud_range(&tlb, dst_vma, dst_pgd, addr, next, NULL);
+			free_pud_range(&tlb, dst_pgd, addr, next, addr, next);
+
+			continue;
+		}
+
+		if (unlikely(dup_pud_range(dst_mm, dst_vma, src_mm, src_vma,
+					   &tlb, dst_pgd, src_pgd, addr,
+					   next))) {
+			ret = -ENOMEM;
+			break;
+		}
+	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+
+	mmu_notifier_invalidate_range_end(dst_mm, mmu_start, mmu_end);
+	tlb_finish_mmu(&tlb, mmu_start, mmu_end);
+
+	return ret;
+}
+
 pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			spinlock_t **ptl)
 {
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
