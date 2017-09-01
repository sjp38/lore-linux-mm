Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30D716B025F
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 13:30:20 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z14so1525846qtg.0
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 10:30:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k123si10606366qkc.372.2017.09.01.10.30.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Sep 2017 10:30:18 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/mmu_notifier: avoid double notification when it is useless
Date: Fri,  1 Sep 2017 13:30:11 -0400
Message-Id: <20170901173011.10745-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org

From: JA(C)rA'me Glisse <jglisse@redhat.com>

(Note that this is 4.15 material or 4.14 if people are extra confident. I
 am posting now to get people to test. To that effect maybe it would be a
 good idea to have that patch sit in linux-next for a while for testing.

 Other motivation is that the problem is fresh in everyone's memory

 Thanks to Andrea for thinking of a problematic scenario for COW)

When clearing a pte/pmd we are given a choice to notify the event through
(notify version of *_clear_flush call mmu_notifier_invalidate_range) under
the page table lock. But that notification is not necessary in all cases.

This patches remove almost all the case where it is useless to have a call to
mmu_notifier_invalidate_range() before mmu_notifier_invalidate_range_end().
It also adds documentation in all those case explaining why.

Below is a more in depth analysis of why this is fine to do this:

For secondary TLB (non CPU TLB) like IOMMU TLB or device TLB (when device use
thing like ATS/PASID to get the IOMMU to walk the CPU page table to access a
process virtual address space). There is only 2 cases when you need to notify
those secondary TLB while holding page table lock when clearing a pte/pmd:

  A) page backing address is free before mmu_notifier_invalidate_range_end()
  B) a page table entry is updated to point to a new page (COW, write fault
     on zero page, __replace_page(), ...)

Case A is obvious you do not want to take the risk for the device to write to
a page that might now be use by some completely different task.

Case B is more subtle. For correctness it requires the following sequence to
happen:
  - take page table lock
  - clear page table entry and notify ([pmd/pte]p_huge_clear_flush_notify())
  - set page table entry to point to new page

If clearing the page table entry is not followed by a notify before setting
the new pte/pmd value then you can break memory model like C11 or C++11 for
the device.

Consider the following scenario (device use a feature similar to ATS/PASID):

Two address addrA and addrB such that |addrA - addrB| >= PAGE_SIZE we assume
they are write protected for COW (other case of B apply too).

[Time N] --------------------------------------------------------------------
CPU-thread-0  {try to write to addrA}
CPU-thread-1  {try to write to addrB}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {read addrA and populate device TLB}
DEV-thread-2  {read addrB and populate device TLB}
[Time N+1] ------------------------------------------------------------------
CPU-thread-0  {COW_step0: {mmu_notifier_invalidate_range_start(addrA)}}
CPU-thread-1  {COW_step0: {mmu_notifier_invalidate_range_start(addrB)}}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+2] ------------------------------------------------------------------
CPU-thread-0  {COW_step1: {update page table to point to new page for addrA}}
CPU-thread-1  {COW_step1: {update page table to point to new page for addrB}}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+3] ------------------------------------------------------------------
CPU-thread-0  {preempted}
CPU-thread-1  {preempted}
CPU-thread-2  {write to addrA which is a write to new page}
CPU-thread-3  {}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+3] ------------------------------------------------------------------
CPU-thread-0  {preempted}
CPU-thread-1  {preempted}
CPU-thread-2  {}
CPU-thread-3  {write to addrB which is a write to new page}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+4] ------------------------------------------------------------------
CPU-thread-0  {preempted}
CPU-thread-1  {COW_step3: {mmu_notifier_invalidate_range_end(addrB)}}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+5] ------------------------------------------------------------------
CPU-thread-0  {preempted}
CPU-thread-1  {}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {read addrA from old page}
DEV-thread-2  {read addrB from new page}

So here because at time N+2 the clear page table entry was not pair with a
notification to invalidate the secondary TLB, the device see the new value for
addrB before seing the new value for addrA. This break total memory ordering
for the device.

When changing a pte to write protect or to point to a new write protected page
with same content (KSM) it is fine to delay the mmu_notifier_invalidate_range
call to mmu_notifier_invalidate_range_end() outside the page table lock. This
is true ven if the thread doing the page table update is preempted right after
releasing page table lock but before call mmu_notifier_invalidate_range_end().

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Alistair Popple <alistair@popple.id.au>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>

Cc: iommu@lists.linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-next@vger.kernel.org
---
 Documentation/vm/mmu_notifier.txt | 93 +++++++++++++++++++++++++++++++++++++++
 fs/dax.c                          |  9 +++-
 include/linux/mmu_notifier.h      |  3 +-
 mm/huge_memory.c                  | 20 +++++++--
 mm/hugetlb.c                      | 16 +++++--
 mm/ksm.c                          | 15 ++++++-
 mm/rmap.c                         | 47 +++++++++++++++++---
 7 files changed, 186 insertions(+), 17 deletions(-)
 create mode 100644 Documentation/vm/mmu_notifier.txt

diff --git a/Documentation/vm/mmu_notifier.txt b/Documentation/vm/mmu_notifier.txt
new file mode 100644
index 000000000000..84c808ce10f3
--- /dev/null
+++ b/Documentation/vm/mmu_notifier.txt
@@ -0,0 +1,93 @@
+When do you need to notify inside page table lock ?
+
+When clearing a pte/pmd we are given a choice to notify the event through
+(notify version of *_clear_flush call mmu_notifier_invalidate_range) under
+the page table lock. But that notification is not necessary in all cases.
+
+For secondary TLB (non CPU TLB) like IOMMU TLB or device TLB (when device use
+thing like ATS/PASID to get the IOMMU to walk the CPU page table to access a
+process virtual address space). There is only 2 cases when you need to notify
+those secondary TLB while holding page table lock when clearing a pte/pmd:
+
+  A) page backing address is free before mmu_notifier_invalidate_range_end()
+  B) a page table entry is updated to point to a new page (COW, write fault
+     on zero page, __replace_page(), ...)
+
+Case A is obvious you do not want to take the risk for the device to write to
+a page that might now be use by some completely different task.
+
+Case B is more subtle. For correctness it requires the following sequence to
+happen:
+  - take page table lock
+  - clear page table entry and notify ([pmd/pte]p_huge_clear_flush_notify())
+  - set page table entry to point to new page
+
+If clearing the page table entry is not followed by a notify before setting
+the new pte/pmd value then you can break memory model like C11 or C++11 for
+the device.
+
+Consider the following scenario (device use a feature similar to ATS/PASID):
+
+Two address addrA and addrB such that |addrA - addrB| >= PAGE_SIZE we assume
+they are write protected for COW (other case of B apply too).
+
+[Time N] --------------------------------------------------------------------
+CPU-thread-0  {try to write to addrA}
+CPU-thread-1  {try to write to addrB}
+CPU-thread-2  {}
+CPU-thread-3  {}
+DEV-thread-0  {read addrA and populate device TLB}
+DEV-thread-2  {read addrB and populate device TLB}
+[Time N+1] ------------------------------------------------------------------
+CPU-thread-0  {COW_step0: {mmu_notifier_invalidate_range_start(addrA)}}
+CPU-thread-1  {COW_step0: {mmu_notifier_invalidate_range_start(addrB)}}
+CPU-thread-2  {}
+CPU-thread-3  {}
+DEV-thread-0  {}
+DEV-thread-2  {}
+[Time N+2] ------------------------------------------------------------------
+CPU-thread-0  {COW_step1: {update page table to point to new page for addrA}}
+CPU-thread-1  {COW_step1: {update page table to point to new page for addrB}}
+CPU-thread-2  {}
+CPU-thread-3  {}
+DEV-thread-0  {}
+DEV-thread-2  {}
+[Time N+3] ------------------------------------------------------------------
+CPU-thread-0  {preempted}
+CPU-thread-1  {preempted}
+CPU-thread-2  {write to addrA which is a write to new page}
+CPU-thread-3  {}
+DEV-thread-0  {}
+DEV-thread-2  {}
+[Time N+3] ------------------------------------------------------------------
+CPU-thread-0  {preempted}
+CPU-thread-1  {preempted}
+CPU-thread-2  {}
+CPU-thread-3  {write to addrB which is a write to new page}
+DEV-thread-0  {}
+DEV-thread-2  {}
+[Time N+4] ------------------------------------------------------------------
+CPU-thread-0  {preempted}
+CPU-thread-1  {COW_step3: {mmu_notifier_invalidate_range_end(addrB)}}
+CPU-thread-2  {}
+CPU-thread-3  {}
+DEV-thread-0  {}
+DEV-thread-2  {}
+[Time N+5] ------------------------------------------------------------------
+CPU-thread-0  {preempted}
+CPU-thread-1  {}
+CPU-thread-2  {}
+CPU-thread-3  {}
+DEV-thread-0  {read addrA from old page}
+DEV-thread-2  {read addrB from new page}
+
+So here because at time N+2 the clear page table entry was not pair with a
+notification to invalidate the secondary TLB, the device see the new value for
+addrB before seing the new value for addrA. This break total memory ordering
+for the device.
+
+When changing a pte to write protect or to point to a new write protected page
+with same content (KSM) it is fine to delay the mmu_notifier_invalidate_range
+call to mmu_notifier_invalidate_range_end() outside the page table lock. This
+is true ven if the thread doing the page table update is preempted right after
+releasing page table lock but before call mmu_notifier_invalidate_range_end().
diff --git a/fs/dax.c b/fs/dax.c
index ab925dc6647a..cd307b6c6183 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -666,6 +666,13 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 		if (follow_pte_pmd(vma->vm_mm, address, &start, &end, &ptep, &pmdp, &ptl))
 			continue;
 
+		/*
+		 * No need to call mmu_notifier_invalidate_range() as we are
+		 * downgrading page table protection not changing it to point
+		 * to a new page.
+		 *
+		 * See Documentation/vm/mmu_notifier.txt
+		 */
 		if (pmdp) {
 #ifdef CONFIG_FS_DAX_PMD
 			pmd_t pmd;
@@ -680,7 +687,6 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			pmd = pmd_wrprotect(pmd);
 			pmd = pmd_mkclean(pmd);
 			set_pmd_at(vma->vm_mm, address, pmdp, pmd);
-			mmu_notifier_invalidate_range(vma->vm_mm, start, end);
 unlock_pmd:
 			spin_unlock(ptl);
 #endif
@@ -695,7 +701,6 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			pte = pte_wrprotect(pte);
 			pte = pte_mkclean(pte);
 			set_pte_at(vma->vm_mm, address, ptep, pte);
-			mmu_notifier_invalidate_range(vma->vm_mm, start, end);
 unlock_pte:
 			pte_unmap_unlock(ptep, ptl);
 		}
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 7b2e31b1745a..e55b2f318fcb 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -155,7 +155,8 @@ struct mmu_notifier_ops {
 	 * shared page-tables, it not necessary to implement the
 	 * invalidate_range_start()/end() notifiers, as
 	 * invalidate_range() alread catches the points in time when an
-	 * external TLB range needs to be flushed.
+	 * external TLB range needs to be flushed. For more in depth
+	 * discussion on this see Documentation/vm/mmu_notifier.txt
 	 *
 	 * The invalidate_range() function is called under the ptl
 	 * spin-lock and not allowed to sleep.
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 90731e3b7e58..5706252b828a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1167,8 +1167,15 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 		goto out_free_pages;
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
+	/*
+	 * Leave pmd empty until pte is filled note we must notify here as
+	 * concurrent CPU thread might write to new page before the call to
+	 * mmu_notifier_invalidate_range_end() happen which can lead to a
+	 * device seeing memory write in different order than CPU.
+	 *
+	 * See Documentation/vm/mmu_notifier.txt
+	 */
 	pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
-	/* leave pmd empty until pte is filled */
 
 	pgtable = pgtable_trans_huge_withdraw(vma->vm_mm, vmf->pmd);
 	pmd_populate(vma->vm_mm, &_pmd, pgtable);
@@ -1929,8 +1936,15 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	pmd_t _pmd;
 	int i;
 
-	/* leave pmd empty until pte is filled */
-	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+	/*
+	 * Leave pmd empty until pte is filled note that it is fine to delay
+	 * notification until mmu_notifier_invalidate_range_end() as we are
+	 * replacing a zero pmd write protected page with a zero pte write
+	 * protected page.
+	 *
+	 * See Documentation/vm/mmu_notifier.txt
+	 */
+	pmdp_huge_clear_flush(vma, haddr, pmd);
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 31e207cb399b..421b816a7216 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3249,9 +3249,14 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			set_huge_swap_pte_at(dst, addr, dst_pte, entry, sz);
 		} else {
 			if (cow) {
+				/*
+				 * No need to notify as we downgrading page
+				 * table protection not changing it to point
+				 * to a new page.
+	 			 *
+				 * See Documentation/vm/mmu_notifier.txt
+				 */
 				huge_ptep_set_wrprotect(src, addr, src_pte);
-				mmu_notifier_invalidate_range(src, mmun_start,
-								   mmun_end);
 			}
 			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
@@ -4283,7 +4288,12 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * and that page table be reused and filled with junk.
 	 */
 	flush_hugetlb_tlb_range(vma, start, end);
-	mmu_notifier_invalidate_range(mm, start, end);
+	/*
+	 * No need to call mmu_notifier_invalidate_range() we are downgrading
+	 * page table protection not changing it to point to a new page.
+	 *
+	 * See Documentation/vm/mmu_notifier.txt
+	 */
 	i_mmap_unlock_write(vma->vm_file->f_mapping);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 
diff --git a/mm/ksm.c b/mm/ksm.c
index db20f8436bc3..bbb5a9482f50 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1052,8 +1052,13 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		 * So we clear the pte and flush the tlb before the check
 		 * this assure us that no O_DIRECT can happen after the check
 		 * or in the middle of the check.
+		 *
+		 * No need to notify as we downgrading page table to read only
+		 * not changing it to point to a new page.
+		 *
+		 * See Documentation/vm/mmu_notifier.txt
 		 */
-		entry = ptep_clear_flush_notify(vma, pvmw.address, pvmw.pte);
+		entry = ptep_clear_flush(vma, pvmw.address, pvmw.pte);
 		/*
 		 * Check that no O_DIRECT or similar I/O is in progress on the
 		 * page
@@ -1136,7 +1141,13 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	}
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
-	ptep_clear_flush_notify(vma, addr, ptep);
+	/*
+	 * No need to notify as we replacing a read only page with another
+	 * read only page with the same content.
+	 *
+	 * See Documentation/vm/mmu_notifier.txt
+	 */
+	ptep_clear_flush(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, newpte);
 
 	page_remove_rmap(page, false);
diff --git a/mm/rmap.c b/mm/rmap.c
index c570f82e6827..d8ee4644e9a9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -938,10 +938,15 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 #endif
 		}
 
-		if (ret) {
-			mmu_notifier_invalidate_range(vma->vm_mm, cstart, cend);
+		/*
+		 * No need to call mmu_notifier_invalidate_range() as we are
+		 * downgrading page table protection not changing it to point
+		 * to a new page.
+		 *
+		 * See Documentation/vm/mmu_notifier.txt
+		 */
+		if (ret)
 			(*cleaned)++;
-		}
 	}
 
 	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
@@ -1510,13 +1515,43 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
-		} else
+		} else {
+			/*
+			 * We should not need to notify here as we reach this
+			 * case only from freeze_page() itself only call from
+			 * split_huge_page_to_list() so everything below must
+			 * be true:
+			 *   - page is not anonymous
+			 *   - page is locked
+			 *
+			 * So as it is a shared page and it is locked, it can
+			 * not be remove from the page cache and replace by
+			 * a new page before mmu_notifier_invalidate_range_end
+			 * so no concurrent thread might update its page table
+			 * to point at new page while a device still is using
+			 * this page.
+			 *
+			 * But we can not assume that new user of try_to_unmap
+			 * will have that in mind so just to be safe here call
+			 * mmu_notifier_invalidate_range()
+			 *
+			 * See Documentation/vm/mmu_notifier.txt
+			 */
 			dec_mm_counter(mm, mm_counter_file(page));
+			mmu_notifier_invalidate_range(mm, address,
+						      address + PAGE_SIZE);
+		}
 discard:
+		/*
+		 * No need to call mmu_notifier_invalidate_range() as we are
+		 * either replacing a present pte with non present one (either
+		 * a swap or special one). We handling the clearing pte case
+		 * above.
+		 *
+		 * See Documentation/vm/mmu_notifier.txt
+		 */
 		page_remove_rmap(subpage, PageHuge(page));
 		put_page(page);
-		mmu_notifier_invalidate_range(mm, address,
-					      address + PAGE_SIZE);
 	}
 
 	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
