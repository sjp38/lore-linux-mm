Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id D6CFE6B0195
	for <linux-mm@kvack.org>; Thu, 21 May 2015 16:23:33 -0400 (EDT)
Received: by qgew3 with SMTP id w3so48093952qge.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 13:23:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c1si1297061qcm.31.2015.05.21.13.23.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 13:23:32 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 21/36] HMM: mm add helper to update page table when migrating memory
Date: Thu, 21 May 2015 16:22:57 -0400
Message-Id: <1432239792-5002-2-git-send-email-jglisse@redhat.com>
In-Reply-To: <1432239792-5002-1-git-send-email-jglisse@redhat.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432239792-5002-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

For doing memory migration to remote memory we need to unmap range
of anonymous memory from CPU page table and replace page table entry
with special HMM entry.

This is a multi-stage process, first we save and replace page table
entry with special HMM entry, also flushing tlb in the process. If
we run into non allocated entry we either use the zero page or we
allocate new page. For swaped entry we try to swap them in.

Once we have set the page table entry to the special entry we check
the page backing each of the address to make sure that only page
table mappings are holding reference on the page, which means we
can safely migrate the page to device memory. Because the CPU page
table entry are special entry, no get_user_pages() can reference
the page anylonger. So we are safe from race on that front. Note
that the page can still be referenced by get_user_pages() from
other process but in that case the page is write protected and
as we do not drop the mapcount nor the page count we know that
all user of get_user_pages() are only doing read only access (on
write access they would allocate a new page).

Once we have identified all the page that are safe to migrate the
first function return and let HMM schedule the migration with the
device driver.

Finaly there is a cleanup function that will drop the mapcount and
reference count on all page that have been successfully migrated,
or restore the page table entry otherwise.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/mm.h |  14 ++
 mm/memory.c        | 470 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 484 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f512b8a..6761dfc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2206,6 +2206,20 @@ static inline void hmm_mm_init(struct mm_struct *mm)
 	mm->hmm = NULL;
 }
 
+int mm_hmm_migrate(struct mm_struct *mm,
+		   struct vm_area_struct *vma,
+		   pte_t *save_pte,
+		   bool *backoff,
+		   const void *mmu_notifier_exclude,
+		   unsigned long start,
+		   unsigned long end);
+void mm_hmm_migrate_cleanup(struct mm_struct *mm,
+			    struct vm_area_struct *vma,
+			    pte_t *save_pte,
+			    dma_addr_t *hmm_pte,
+			    unsigned long start,
+			    unsigned long end);
+
 int mm_hmm_migrate_back(struct mm_struct *mm,
 			struct vm_area_struct *vma,
 			pte_t *new_pte,
diff --git a/mm/memory.c b/mm/memory.c
index 4674d40..4bcd4d2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -54,6 +54,7 @@
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
 #include <linux/hmm.h>
+#include <linux/hmm_pt.h>
 #include <linux/kallsyms.h>
 #include <linux/swapops.h>
 #include <linux/elf.h>
@@ -3694,6 +3695,475 @@ void mm_hmm_migrate_back_cleanup(struct mm_struct *mm,
 	}
 }
 EXPORT_SYMBOL(mm_hmm_migrate_back_cleanup);
+
+/* mm_hmm_migrate() - unmap range and set special HMM pte for it.
+ *
+ * @mm: The mm struct.
+ * @vma: The vm area struct the range is in.
+ * @save_pte: array where to save current CPU page table entry value.
+ * @backoff: Pointer toward a boolean indicating that we need to stop.
+ * @exclude: The mmu_notifier listener to exclude from mmu_notifier callback.
+ * @start: Start address of the range (inclusive).
+ * @end: End address of the range (exclusive).
+ * Returns: 0 on success, -EINVAL if some argument where invalid, -ENOMEM if
+ * it failed allocating memory for performing the operation, -EFAULT if some
+ * memory backing the range is in bad state, -EAGAIN if backoff flag turned
+ * to true.
+ *
+ * The process of memory migration is bit involve, first we must set all CPU
+ * page table entry to the special HMM locked entry ensuring us exclusive
+ * control over the page table entry (ie no other process can change the page
+ * table but us).
+ *
+ * While doing that we must handle empty and swaped entry. For empty entry we
+ * either use the zero page or allocate a new page. For swap entry we call
+ * __handle_mm_fault() to try to faultin the page (swap entry can be a number
+ * of thing).
+ *
+ * Once we have unmapped we need to check that we can effectively migrate the
+ * page, by testing that no one is holding a reference on the page beside the
+ * reference taken by each page mapping.
+ *
+ * On success every valid entry inside save_pte array is an entry that can be
+ * migrated.
+ *
+ * Note that this function does not free any of the page, nor does it updates
+ * the various memcg counter (exception being for accounting new allocation).
+ * This happen inside the mm_hmm_migrate_cleanup() function.
+ *
+ */
+int mm_hmm_migrate(struct mm_struct *mm,
+		   struct vm_area_struct *vma,
+		   pte_t *save_pte,
+		   bool *backoff,
+		   const void *mmu_notifier_exclude,
+		   unsigned long start,
+		   unsigned long end)
+{
+	pte_t hmm_entry = swp_entry_to_pte(make_hmm_entry_locked());
+	struct mmu_notifier_range range = {
+		.start = start,
+		.end = end,
+		.event = MMU_MIGRATE,
+	};
+	unsigned long addr = start, i;
+	struct mmu_gather tlb;
+	int ret = 0;
+
+	/* Only allow anonymous mapping and sanity check arguments. */
+	if (vma->vm_ops || unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)))
+		return -EINVAL;
+	start &= PAGE_MASK;
+	end = PAGE_ALIGN(end);
+	if (start >= end || end > vma->vm_end)
+		return -EINVAL;
+
+	/* Only need to test on the last address of the range. */
+	if (check_stack_guard_page(vma, end) < 0)
+		return -EFAULT;
+
+	/* Try to fail early on. */
+	if (unlikely(anon_vma_prepare(vma)))
+		return -ENOMEM;
+
+retry:
+	lru_add_drain();
+	tlb_gather_mmu(&tlb, mm, range.start, range.end);
+	update_hiwater_rss(mm);
+	mmu_notifier_invalidate_range_start_excluding(mm, &range,
+						      mmu_notifier_exclude);
+	tlb_start_vma(&tlb, vma);
+	for (addr = range.start, i = 0; addr < end && !ret;) {
+		unsigned long cstart, next, npages = 0;
+		spinlock_t *ptl;
+		pgd_t *pgdp;
+		pud_t *pudp;
+		pmd_t *pmdp;
+		pte_t *ptep;
+
+		/*
+		 * Pretty much the exact same logic as __handle_mm_fault(),
+		 * exception being the handling of huge pmd.
+		 */
+		pgdp = pgd_offset(mm, addr);
+		pudp = pud_alloc(mm, pgdp, addr);
+		if (!pudp) {
+			ret = -ENOMEM;
+			break;
+		}
+		pmdp = pmd_alloc(mm, pudp, addr);
+		if (!pmdp) {
+			ret = -ENOMEM;
+			break;
+		}
+		if (unlikely(pmd_trans_splitting(*pmdp))) {
+			wait_split_huge_page(vma->anon_vma, pmdp);
+			ret = -EAGAIN;
+			break;
+		}
+		if (unlikely(pmd_bad(*pmdp))) {
+			ret = -EFAULT;
+			break;
+		}
+		if (unlikely(pmd_none(*pmdp)) &&
+		    unlikely(__pte_alloc(mm, vma, pmdp, addr))) {
+			ret = -ENOMEM;
+			break;
+		}
+		/*
+		 * If an huge pmd materialized from under us split it and break
+		 * out of the loop to retry.
+		 */
+		if (unlikely(pmd_trans_huge(*pmdp))) {
+			split_huge_page_pmd(vma, addr, pmdp);
+			ret = -EAGAIN;
+			break;
+		}
+
+		/*
+		 * A regular pmd is established and it can't morph into a huge pmd
+		 * from under us anymore at this point because we hold the mmap_sem
+		 * read mode and khugepaged takes it in write mode. So now it's
+		 * safe to run pte_offset_map().
+		 */
+		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+		for (i = (addr - start) >> PAGE_SHIFT, cstart = addr,
+		     next = min((addr + PMD_SIZE) & PMD_MASK, end);
+		     addr < next; addr += PAGE_SIZE, ptep++, i++) {
+			save_pte[i] = ptep_get_and_clear(mm, addr, ptep);
+			tlb_remove_tlb_entry(&tlb, ptep, addr);
+			set_pte_at(mm, addr, ptep, hmm_entry);
+
+			if (pte_present(save_pte[i]))
+				continue;
+
+			if (!pte_none(save_pte[i])) {
+				set_pte_at(mm, addr, ptep, save_pte[i]);
+				ret = -ENOENT;
+				ptep++;
+				break;
+			}
+			/*
+			 * TODO: This mm_forbids_zeropage() really does not
+			 * apply to us. First it seems only S390 have it set,
+			 * second we are not even using the zero page entry
+			 * to populate the CPU page table, thought on error
+			 * we might use the save_pte entry to set the CPU
+			 * page table entry.
+			 *
+			 * Live with that oddity for now.
+			 */
+			if (!mm_forbids_zeropage(mm)) {
+				pte_clear(mm, addr, &save_pte[i]);
+				npages++;
+				continue;
+			}
+			save_pte[i] = pte_mkspecial(pfn_pte(my_zero_pfn(addr),
+						    vma->vm_page_prot));
+		}
+		pte_unmap_unlock(ptep - 1, ptl);
+
+		/*
+		 * So we must allocate pages before checking for error, which
+		 * here indicate that one entry is a swap entry. We need to
+		 * allocate first because otherwise there is no easy way to
+		 * know on retry or in error code path wether the CPU page
+		 * table locked HMM entry is ours or from some other thread.
+		 */
+
+		if (!npages)
+			continue;
+
+		for (next = addr, addr = cstart,
+		     i = (addr - start) >> PAGE_SHIFT;
+		     addr < next; addr += PAGE_SIZE, i++) {
+			struct mem_cgroup *memcg;
+			struct page * page;
+
+			if (pte_present(save_pte[i]) || !pte_none(save_pte[i]))
+				continue;
+
+			page = alloc_zeroed_user_highpage_movable(vma, addr);
+			if (!page) {
+				ret = -ENOMEM;
+				break;
+			}
+			__SetPageUptodate(page);
+			if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg)) {
+				page_cache_release(page);
+				ret = -ENOMEM;
+				break;
+			}
+			save_pte[i] = mk_pte(page, vma->vm_page_prot);
+			if (vma->vm_flags & VM_WRITE)
+				save_pte[i] = pte_mkwrite(save_pte[i]);
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
+			/*
+			 * Because we set the page table entry to the special
+			 * HMM locked entry we know no other process might do
+			 * anything with it and thus we can safely account the
+			 * page without holding any lock at this point.
+			 */
+			page_add_new_anon_rmap(page, vma, addr);
+			mem_cgroup_commit_charge(page, memcg, false);
+			lru_cache_add_active_or_unevictable(page, vma);
+		}
+	}
+	tlb_end_vma(&tlb, vma);
+	mmu_notifier_invalidate_range_end_excluding(mm, &range,
+						    mmu_notifier_exclude);
+	tlb_finish_mmu(&tlb, range.start, range.end);
+
+	if (backoff && *backoff) {
+		/* Stick to the range we updated. */
+		ret = -EAGAIN;
+		end = addr;
+		goto out;
+	}
+
+	/* Check if something is missing or something went wrong. */
+	if (ret == -ENOENT) {
+		int flags = FAULT_FLAG_ALLOW_RETRY;
+
+		do {
+			/*
+			 * Using __handle_mm_fault() as current->mm != mm ie we
+			 * might have been call from a kernel thread on behalf
+			 * of a driver and all accounting handle_mm_fault() is
+			 * pointless in our case.
+			 */
+			ret = __handle_mm_fault(mm, vma, addr, flags);
+			flags |= FAULT_FLAG_TRIED;
+		} while ((ret & VM_FAULT_RETRY));
+		if ((ret & VM_FAULT_ERROR)) {
+			/* Stick to the range we updated. */
+			end = addr;
+			ret = -EFAULT;
+			goto out;
+		}
+		range.start = addr;
+		goto retry;
+	}
+	if (ret == -EAGAIN) {
+		range.start = addr;
+		goto retry;
+	}
+	if (ret)
+		/* Stick to the range we updated. */
+		end = addr;
+
+	/*
+	 * At this point no one else can take a reference on the page from this
+	 * process CPU page table. So we can safely check wether we can migrate
+	 * or not the page.
+	 */
+
+out:
+	for (addr = start, i = 0; addr < end;) {
+		unsigned long next;
+		spinlock_t *ptl;
+		pgd_t *pgdp;
+		pud_t *pudp;
+		pmd_t *pmdp;
+		pte_t *ptep;
+
+		/*
+		 * We know for certain that we did set special swap entry for
+		 * the range and HMM entry are mark as locked so it means that
+		 * no one beside us can modify them which apply that all level
+		 * of the CPU page table are valid.
+		 */
+		pgdp = pgd_offset(mm, addr);
+		pudp = pud_offset(pgdp, addr);
+		VM_BUG_ON(!pudp);
+		pmdp = pmd_offset(pudp, addr);
+		VM_BUG_ON(!pmdp || pmd_bad(*pmdp) || pmd_none(*pmdp) ||
+			  pmd_trans_huge(*pmdp));
+
+		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+		for (next = min((addr + PMD_SIZE) & PMD_MASK, end),
+		     i = (addr - start) >> PAGE_SHIFT; addr < next;
+		     addr += PAGE_SIZE, ptep++, i++) {
+			struct page *page;
+			swp_entry_t entry;
+			int swapped;
+
+			entry = pte_to_swp_entry(save_pte[i]);
+			if (is_hmm_entry(entry)) {
+				/*
+				 * Logic here is pretty involve. If save_pte is
+				 * an HMM special swap entry then it means that
+				 * we failed to swap in that page so error must
+				 * be set.
+				 *
+				 * If that's not the case than it means we are
+				 * seriously screw.
+				 */
+				VM_BUG_ON(!ret);
+				continue;
+			}
+
+			/*
+			 * This can not happen, no one else can replace our
+			 * special entry and as range end is re-ajusted on
+			 * error.
+			 */
+			entry = pte_to_swp_entry(*ptep);
+			VM_BUG_ON(!is_hmm_entry_locked(entry));
+
+			/* On error or backoff restore all the saved pte. */
+			if (ret)
+				goto restore;
+
+			page = vm_normal_page(vma, addr, save_pte[i]);
+			/* The zero page is fine to migrate. */
+			if (!page)
+				continue;
+
+			/*
+			 * Check that only CPU mapping hold a reference on the
+			 * page. To make thing simpler we just refuse bail out
+			 * if page_mapcount() != page_count() (also accounting
+			 * for swap cache).
+			 *
+			 * There is a small window here where wp_page_copy()
+			 * might have decremented mapcount but have not yet
+			 * decremented the page count. This is not an issue as
+			 * we backoff in that case.
+			 */
+			swapped = PageSwapCache(page);
+			if (page_mapcount(page) + swapped == page_count(page))
+				continue;
+
+restore:
+			/* Ok we have to restore that page. */
+			set_pte_at(mm, addr, ptep, save_pte[i]);
+			/*
+			 * No need to invalidate - it was non-present
+			 * before.
+			 */
+			update_mmu_cache(vma, addr, ptep);
+			pte_clear(mm, addr, &save_pte[i]);
+		}
+		pte_unmap_unlock(ptep - 1, ptl);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(mm_hmm_migrate);
+
+/* mm_hmm_migrate_cleanup() - unmap range cleanup.
+ *
+ * @mm: The mm struct.
+ * @vma: The vm area struct the range is in.
+ * @save_pte: Array where to save current CPU page table entry value.
+ * @hmm_pte: Array of HMM table entry indicating if migration was successfull.
+ * @start: Start address of the range (inclusive).
+ * @end: End address of the range (exclusive).
+ *
+ * This is call after mm_hmm_migrate() and after effective migration. It will
+ * restore CPU page table entry for page that not been migrated or in case of
+ * failure.
+ *
+ * It will free pages that have been migrated and updates appropriate counters,
+ * it will also "unlock" special HMM pte entry.
+ */
+void mm_hmm_migrate_cleanup(struct mm_struct *mm,
+			    struct vm_area_struct *vma,
+			    pte_t *save_pte,
+			    dma_addr_t *hmm_pte,
+			    unsigned long start,
+			    unsigned long end)
+{
+	pte_t hmm_entry = swp_entry_to_pte(make_hmm_entry());
+	struct page *pages[MMU_GATHER_BUNDLE];
+	unsigned long addr, c, i;
+
+	for (addr = start, i = 0; addr < end;) {
+		unsigned long next;
+		spinlock_t *ptl;
+		pgd_t *pgdp;
+		pud_t *pudp;
+		pmd_t *pmdp;
+		pte_t *ptep;
+
+		/*
+		 * We know for certain that we did set special swap entry for
+		 * the range and HMM entry are mark as locked so it means that
+		 * no one beside us can modify them which apply that all level
+		 * of the CPU page table are valid.
+		 */
+		pgdp = pgd_offset(mm, addr);
+		pudp = pud_offset(pgdp, addr);
+		VM_BUG_ON(!pudp);
+		pmdp = pmd_offset(pudp, addr);
+		VM_BUG_ON(!pmdp || pmd_bad(*pmdp) || pmd_none(*pmdp) ||
+			  pmd_trans_huge(*pmdp));
+
+		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+		for (next = min((addr + PMD_SIZE) & PMD_MASK, end),
+		     i = (addr - start) >> PAGE_SHIFT; addr < next;
+		     addr += PAGE_SIZE, ptep++, i++) {
+			struct page *page;
+			swp_entry_t entry;
+
+			/*
+			 * This can't happen no one else can replace our
+			 * precious special entry.
+			 */
+			entry = pte_to_swp_entry(*ptep);
+			VM_BUG_ON(!is_hmm_entry_locked(entry));
+
+			if (!hmm_pte_test_valid_dev(&hmm_pte[i])) {
+				/* Ok we have to restore that page. */
+				set_pte_at(mm, addr, ptep, save_pte[i]);
+				/*
+				 * No need to invalidate - it was non-present
+				 * before.
+				 */
+				update_mmu_cache(vma, addr, ptep);
+				pte_clear(mm, addr, &save_pte[i]);
+				continue;
+			}
+
+			/* Set unlocked entry. */
+			set_pte_at(mm, addr, ptep, hmm_entry);
+			/*
+			 * No need to invalidate - it was non-present
+			 * before.
+			 */
+			update_mmu_cache(vma, addr, ptep);
+
+			page = vm_normal_page(vma, addr, save_pte[i]);
+			/* The zero page is fine to migrate. */
+			if (!page)
+				continue;
+
+			page_remove_rmap(page);
+			dec_mm_counter_fast(mm, MM_ANONPAGES);
+		}
+		pte_unmap_unlock(ptep - 1, ptl);
+	}
+
+	/* Free pages. */
+	for (addr = start, i = 0, c = 0; addr < end; i++, addr += PAGE_SIZE) {
+		if (pte_none(save_pte[i]))
+			continue;
+		if (c >= MMU_GATHER_BUNDLE) {
+			/*
+			 * TODO: What we really want to do is keep the memory
+			 * accounted inside the memory group and inside rss
+			 * while still freeing the page. So that migration
+			 * back from device memory will not fail because we
+			 * go over memory group limit.
+			 */
+			free_pages_and_swap_cache(pages, c);
+			c = 0;
+		}
+		pages[c] = vm_normal_page(vma, addr, save_pte[i]);
+		c = pages[c] ? c + 1 : c;
+	}
+}
+EXPORT_SYMBOL(mm_hmm_migrate_cleanup);
 #endif
 
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
