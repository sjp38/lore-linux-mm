Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1B42082F61
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 15:38:01 -0400 (EDT)
Received: by qgdd90 with SMTP id d90so38256651qgd.3
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 12:38:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 143si5461876qhc.39.2015.08.13.12.37.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 12:37:59 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 06/15] HMM: mm add helper to update page table when migrating memory back v2.
Date: Thu, 13 Aug 2015 15:37:22 -0400
Message-Id: <1439494651-1255-7-git-send-email-jglisse@redhat.com>
In-Reply-To: <1439494651-1255-1-git-send-email-jglisse@redhat.com>
References: <1439494651-1255-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

To migrate memory back we first need to lock HMM special CPU page
table entry so we know no one else might try to migrate those entry
back. Helper also allocate new page where data will be copied back
from the device. Then we can proceed with the device DMA operation.

Once DMA is done we can update again the CPU page table to point to
the new page that holds the content copied back from device memory.

Note that we do not need to invalidate the range are we are only
modifying non present CPU page table entry.

Changed since v1:
  - Save memcg against which each page is precharge as it might
    change along the way.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/mm.h |  12 +++
 mm/memory.c        | 257 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 269 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 580fe65..eb1e9b2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2249,6 +2249,18 @@ static inline void hmm_mm_init(struct mm_struct *mm)
 {
 	mm->hmm = NULL;
 }
+
+int mm_hmm_migrate_back(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pte_t *new_pte,
+			unsigned long start,
+			unsigned long end);
+void mm_hmm_migrate_back_cleanup(struct mm_struct *mm,
+				 struct vm_area_struct *vma,
+				 pte_t *new_pte,
+				 dma_addr_t *hmm_pte,
+				 unsigned long start,
+				 unsigned long end);
 #else /* !CONFIG_HMM */
 static inline void hmm_mm_init(struct mm_struct *mm)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 33994a7..b2b3677 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3469,6 +3469,263 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 EXPORT_SYMBOL_GPL(handle_mm_fault);
 
+
+#ifdef CONFIG_HMM
+/* mm_hmm_migrate_back() - lock HMM CPU page table entry and allocate new page.
+ *
+ * @mm: The mm struct.
+ * @vma: The vm area struct the range is in.
+ * @new_pte: Array of new CPU page table entry value.
+ * @start: Start address of the range (inclusive).
+ * @end: End address of the range (exclusive).
+ *
+ * This function will lock HMM page table entry and allocate new page for entry
+ * it successfully locked.
+ */
+int mm_hmm_migrate_back(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pte_t *new_pte,
+			unsigned long start,
+			unsigned long end)
+{
+	pte_t hmm_entry = swp_entry_to_pte(make_hmm_entry_locked());
+	unsigned long addr, i;
+	int ret = 0;
+
+	VM_BUG_ON(vma->vm_ops || (vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+
+	if (unlikely(anon_vma_prepare(vma)))
+		return -ENOMEM;
+
+	start &= PAGE_MASK;
+	end = PAGE_ALIGN(end);
+	memset(new_pte, 0, sizeof(pte_t) * ((end - start) >> PAGE_SHIFT));
+
+	for (addr = start; addr < end;) {
+		unsigned long cstart, next;
+		spinlock_t *ptl;
+		pgd_t *pgdp;
+		pud_t *pudp;
+		pmd_t *pmdp;
+		pte_t *ptep;
+
+		pgdp = pgd_offset(mm, addr);
+		pudp = pud_offset(pgdp, addr);
+		/*
+		 * Some other thread might already have migrated back the entry
+		 * and freed the page table. Unlikely thought.
+		 */
+		if (unlikely(!pudp)) {
+			addr = min((addr + PUD_SIZE) & PUD_MASK, end);
+			continue;
+		}
+		pmdp = pmd_offset(pudp, addr);
+		if (unlikely(!pmdp || pmd_bad(*pmdp) || pmd_none(*pmdp) ||
+			     pmd_trans_huge(*pmdp))) {
+			addr = min((addr + PMD_SIZE) & PMD_MASK, end);
+			continue;
+		}
+		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+		for (cstart = addr, i = (addr - start) >> PAGE_SHIFT,
+		     next = min((addr + PMD_SIZE) & PMD_MASK, end);
+		     addr < next; addr += PAGE_SIZE, ptep++, i++) {
+			swp_entry_t entry;
+
+			entry = pte_to_swp_entry(*ptep);
+			if (pte_none(*ptep) || pte_present(*ptep) ||
+			    !is_hmm_entry(entry) ||
+			    is_hmm_entry_locked(entry))
+				continue;
+
+			set_pte_at(mm, addr, ptep, hmm_entry);
+			new_pte[i] = pte_mkspecial(pfn_pte(my_zero_pfn(addr),
+						   vma->vm_page_prot));
+		}
+		pte_unmap_unlock(ptep - 1, ptl);
+
+		for (addr = cstart, i = (addr - start) >> PAGE_SHIFT;
+		     addr < next; addr += PAGE_SIZE, i++) {
+			struct mem_cgroup *memcg;
+			struct page *page;
+
+			if (!pte_present(new_pte[i]))
+				continue;
+
+			page = alloc_zeroed_user_highpage_movable(vma, addr);
+			if (!page) {
+				ret = -ENOMEM;
+				break;
+			}
+			__SetPageUptodate(page);
+			if (mem_cgroup_try_charge(page, mm, GFP_KERNEL,
+						  &memcg)) {
+				page_cache_release(page);
+				ret = -ENOMEM;
+				break;
+			}
+			/*
+			 * We can safely reuse the s_mem/mapping field of page
+			 * struct to store the memcg as the page is only seen
+			 * by HMM at this point and we can clear it before it
+			 * is public see mm_hmm_migrate_back_cleanup().
+			 */
+			page->s_mem = memcg;
+			new_pte[i] = mk_pte(page, vma->vm_page_prot);
+			if (vma->vm_flags & VM_WRITE) {
+				new_pte[i] = pte_mkdirty(new_pte[i]);
+				new_pte[i] = pte_mkwrite(new_pte[i]);
+			}
+		}
+
+		if (!ret)
+			continue;
+
+		hmm_entry = swp_entry_to_pte(make_hmm_entry());
+		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+		for (addr = cstart, i = (addr - start) >> PAGE_SHIFT;
+		     addr < next; addr += PAGE_SIZE, ptep++, i++) {
+			unsigned long pfn = pte_pfn(new_pte[i]);
+
+			if (!pte_present(new_pte[i]) || !is_zero_pfn(pfn))
+				continue;
+
+			set_pte_at(mm, addr, ptep, hmm_entry);
+			pte_clear(mm, addr, &new_pte[i]);
+		}
+		pte_unmap_unlock(ptep - 1, ptl);
+		break;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(mm_hmm_migrate_back);
+
+/* mm_hmm_migrate_back_cleanup() - set CPU page table entry to new page.
+ *
+ * @mm: The mm struct.
+ * @vma: The vm area struct the range is in.
+ * @new_pte: Array of new CPU page table entry value.
+ * @hmm_pte: Array of HMM table entry indicating if migration was successful.
+ * @start: Start address of the range (inclusive).
+ * @end: End address of the range (exclusive).
+ *
+ * This is call after mm_hmm_migrate_back() and after effective migration. It
+ * will set CPU page table entry to new value pointing to newly allocated page
+ * where the data was effectively copied back from device memory.
+ *
+ * Any failure will trigger a bug on.
+ *
+ * TODO: For copy failure we might simply set a new value for the HMM special
+ * entry indicating poisonous entry.
+ */
+void mm_hmm_migrate_back_cleanup(struct mm_struct *mm,
+				 struct vm_area_struct *vma,
+				 pte_t *new_pte,
+				 dma_addr_t *hmm_pte,
+				 unsigned long start,
+				 unsigned long end)
+{
+	pte_t hmm_poison = swp_entry_to_pte(make_hmm_entry_poisonous());
+	unsigned long addr, i;
+
+	for (addr = start; addr < end;) {
+		unsigned long cstart, next, free_pages;
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
+		     cstart = addr, i = (addr - start) >> PAGE_SHIFT,
+		     free_pages = 0; addr < next; addr += PAGE_SIZE,
+		     ptep++, i++) {
+			struct mem_cgroup *memcg;
+			swp_entry_t entry;
+			struct page *page;
+
+			if (!pte_present(new_pte[i]))
+				continue;
+
+			entry = pte_to_swp_entry(*ptep);
+
+			/*
+			 * Sanity catch all the things that could go wrong but
+			 * should not, no plan B here.
+			 */
+			VM_BUG_ON(pte_none(*ptep));
+			VM_BUG_ON(pte_present(*ptep));
+			VM_BUG_ON(!is_hmm_entry_locked(entry));
+
+			if (!hmm_pte_test_valid_dma(&hmm_pte[i]) &&
+			    !hmm_pte_test_valid_pfn(&hmm_pte[i])) {
+				set_pte_at(mm, addr, ptep, hmm_poison);
+				free_pages++;
+				continue;
+			}
+
+			page = pte_page(new_pte[i]);
+
+			/*
+			 * Up to now the s_mem/mapping field stored the memcg
+			 * against which the page was pre-charged. Save it and
+			 * clear field so PageAnon() return false.
+			 */
+			memcg = page->s_mem;
+			page->s_mem = NULL;
+
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
+			page_add_new_anon_rmap(page, vma, addr);
+			mem_cgroup_commit_charge(page, memcg, false);
+			lru_cache_add_active_or_unevictable(page, vma);
+			set_pte_at(mm, addr, ptep, new_pte[i]);
+			update_mmu_cache(vma, addr, ptep);
+			pte_clear(mm, addr, &new_pte[i]);
+		}
+		pte_unmap_unlock(ptep - 1, ptl);
+
+		if (!free_pages)
+			continue;
+
+		for (addr = cstart, i = (addr - start) >> PAGE_SHIFT;
+		     addr < next; addr += PAGE_SIZE, i++) {
+			struct mem_cgroup *memcg;
+			struct page *page;
+
+			if (!pte_present(new_pte[i]))
+				continue;
+
+			page = pte_page(new_pte[i]);
+
+			/*
+			 * Up to now the s_mem/mapping field stored the memcg
+			 * against which the page was pre-charged.
+			 */
+			memcg = page->s_mem;
+			page->s_mem = NULL;
+
+			mem_cgroup_cancel_charge(page, memcg);
+			page_cache_release(page);
+		}
+	}
+}
+EXPORT_SYMBOL(mm_hmm_migrate_back_cleanup);
+#endif
+
+
 #ifndef __PAGETABLE_PUD_FOLDED
 /*
  * Allocate page upper directory.
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
