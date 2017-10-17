Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C03696B0253
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 23:10:17 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o187so513294qke.1
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 20:10:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r20si4331qke.267.2017.10.16.20.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 20:10:16 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 1/2] mm/mmu_notifier: avoid double notification when it is useless v2
Date: Mon, 16 Oct 2017 23:10:02 -0400
Message-Id: <20171017031003.7481-2-jglisse@redhat.com>
In-Reply-To: <20171017031003.7481-1-jglisse@redhat.com>
References: <20171017031003.7481-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Donnellan <andrew.donnellan@au1.ibm.com>, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This patch only affects users of mmu_notifier->invalidate_range callback
which are device drivers related to ATS/PASID, CAPI, IOMMUv2, SVM ...
and it is an optimization for those users. Everyone else is unaffected
by it.

When clearing a pte/pmd we are given a choice to notify the event under
the page table lock (notify version of *_clear_flush helpers do call the
mmu_notifier_invalidate_range). But that notification is not necessary in
all cases.

This patches remove almost all cases where it is useless to have a call
to mmu_notifier_invalidate_range before mmu_notifier_invalidate_range_end.
It also adds documentation in all those cases explaining why.

Below is a more in depth analysis of why this is fine to do this:

For secondary TLB (non CPU TLB) like IOMMU TLB or device TLB (when device
use thing like ATS/PASID to get the IOMMU to walk the CPU page table to
access a process virtual address space). There is only 2 cases when you
need to notify those secondary TLB while holding page table lock when
clearing a pte/pmd:

  A) page backing address is free before mmu_notifier_invalidate_range_end
  B) a page table entry is updated to point to a new page (COW, write fault
     on zero page, __replace_page(), ...)

Case A is obvious you do not want to take the risk for the device to write
to a page that might now be used by something completely different.

Case B is more subtle. For correctness it requires the following sequence
to happen:
  - take page table lock
  - clear page table entry and notify (pmd/pte_huge_clear_flush_notify())
  - set page table entry to point to new page

If clearing the page table entry is not followed by a notify before setting
the new pte/pmd value then you can break memory model like C11 or C++11 for
the device.

Consider the following scenario (device use a feature similar to ATS/
PASID):

Two address addrA and addrB such that |addrA - addrB| >= PAGE_SIZE we
assume they are write protected for COW (other case of B apply too).

[Time N] -----------------------------------------------------------------
CPU-thread-0  {try to write to addrA}
CPU-thread-1  {try to write to addrB}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {read addrA and populate device TLB}
DEV-thread-2  {read addrB and populate device TLB}
[Time N+1] ---------------------------------------------------------------
CPU-thread-0  {COW_step0: {mmu_notifier_invalidate_range_start(addrA)}}
CPU-thread-1  {COW_step0: {mmu_notifier_invalidate_range_start(addrB)}}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+2] ---------------------------------------------------------------
CPU-thread-0  {COW_step1: {update page table point to new page for addrA}}
CPU-thread-1  {COW_step1: {update page table point to new page for addrB}}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+3] ---------------------------------------------------------------
CPU-thread-0  {preempted}
CPU-thread-1  {preempted}
CPU-thread-2  {write to addrA which is a write to new page}
CPU-thread-3  {}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+3] ---------------------------------------------------------------
CPU-thread-0  {preempted}
CPU-thread-1  {preempted}
CPU-thread-2  {}
CPU-thread-3  {write to addrB which is a write to new page}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+4] ---------------------------------------------------------------
CPU-thread-0  {preempted}
CPU-thread-1  {COW_step3: {mmu_notifier_invalidate_range_end(addrB)}}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {}
DEV-thread-2  {}
[Time N+5] ---------------------------------------------------------------
CPU-thread-0  {preempted}
CPU-thread-1  {}
CPU-thread-2  {}
CPU-thread-3  {}
DEV-thread-0  {read addrA from old page}
DEV-thread-2  {read addrB from new page}

So here because at time N+2 the clear page table entry was not pair with a
notification to invalidate the secondary TLB, the device see the new value
for addrB before seing the new value for addrA. This break total memory
ordering for the device.

When changing a pte to write protect or to point to a new write protected
page with same content (KSM) it is ok to delay invalidate_range callback to
mmu_notifier_invalidate_range_end() outside the page table lock. This is
true even if the thread doing page table update is preempted right after
releasing page table lock before calling mmu_notifier_invalidate_range_end

Changed since v1:
  - typos (thanks to Andrea)
  - Avoid unnecessary precaution in try_to_unmap() (Andrea)
  - Be more conservative in try_to_unmap_one()

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
Cc: Andrew Donnellan <andrew.donnellan@au1.ibm.com>

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
 mm/rmap.c                         | 59 ++++++++++++++++++++++---
 7 files changed, 198 insertions(+), 17 deletions(-)
 create mode 100644 Documentation/vm/mmu_notifier.txt

diff --git a/Documentation/vm/mmu_notifier.txt b/Documentation/vm/mmu_notifier.txt
new file mode 100644
index 000000000000..23b462566bb7
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
+a page that might now be used by some completely different task.
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
+is true even if the thread doing the page table update is preempted right after
+releasing page table lock but before call mmu_notifier_invalidate_range_end().
diff --git a/fs/dax.c b/fs/dax.c
index f3a44a7c14b3..9ec797424e4f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -614,6 +614,13 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
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
@@ -628,7 +635,6 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			pmd = pmd_wrprotect(pmd);
 			pmd = pmd_mkclean(pmd);
 			set_pmd_at(vma->vm_mm, address, pmdp, pmd);
-			mmu_notifier_invalidate_range(vma->vm_mm, start, end);
 unlock_pmd:
 			spin_unlock(ptl);
 #endif
@@ -643,7 +649,6 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			pte = pte_wrprotect(pte);
 			pte = pte_mkclean(pte);
 			set_pte_at(vma->vm_mm, address, ptep, pte);
-			mmu_notifier_invalidate_range(vma->vm_mm, start, end);
 unlock_pte:
 			pte_unmap_unlock(ptep, ptl);
 		}
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 6866e8126982..49c925c96b8a 100644
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
index c037d3d34950..ff5bc647b51d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1186,8 +1186,15 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 		goto out_free_pages;
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
+	/*
+	 * Leave pmd empty until pte is filled note we must notify here as
+	 * concurrent CPU thread might write to new page before the call to
+	 * mmu_notifier_invalidate_range_end() happens which can lead to a
+	 * device seeing memory write in different order than CPU.
+	 *
+	 * See Documentation/vm/mmu_notifier.txt
+	 */
 	pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
-	/* leave pmd empty until pte is filled */
 
 	pgtable = pgtable_trans_huge_withdraw(vma->vm_mm, vmf->pmd);
 	pmd_populate(vma->vm_mm, &_pmd, pgtable);
@@ -2026,8 +2033,15 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
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
index 1768efa4c501..63a63f1b536c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3254,9 +3254,14 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			set_huge_swap_pte_at(dst, addr, dst_pte, entry, sz);
 		} else {
 			if (cow) {
+				/*
+				 * No need to notify as we are downgrading page
+				 * table protection not changing it to point
+				 * to a new page.
+				 *
+				 * See Documentation/vm/mmu_notifier.txt
+				 */
 				huge_ptep_set_wrprotect(src, addr, src_pte);
-				mmu_notifier_invalidate_range(src, mmun_start,
-								   mmun_end);
 			}
 			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
@@ -4288,7 +4293,12 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
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
index 6cb60f46cce5..be8f4576f842 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1052,8 +1052,13 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		 * So we clear the pte and flush the tlb before the check
 		 * this assure us that no O_DIRECT can happen after the check
 		 * or in the middle of the check.
+		 *
+		 * No need to notify as we are downgrading page table to read
+		 * only not changing it to point to a new page.
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
+	 * No need to notify as we are replacing a read only page with another
+	 * read only page with the same content.
+	 *
+	 * See Documentation/vm/mmu_notifier.txt
+	 */
+	ptep_clear_flush(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, newpte);
 
 	page_remove_rmap(page, false);
diff --git a/mm/rmap.c b/mm/rmap.c
index 061826278520..6b5a0f219ac0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -937,10 +937,15 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
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
@@ -1424,6 +1429,10 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
 			set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
+			/*
+			 * No need to invalidate here it will synchronize on
+			 * against the special swap migration pte.
+			 */
 			goto discard;
 		}
 
@@ -1481,6 +1490,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			 * will take care of the rest.
 			 */
 			dec_mm_counter(mm, mm_counter(page));
+			/* We have to invalidate as we cleared the pte */
+			mmu_notifier_invalidate_range(mm, address,
+						      address + PAGE_SIZE);
 		} else if (IS_ENABLED(CONFIG_MIGRATION) &&
 				(flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
 			swp_entry_t entry;
@@ -1496,6 +1508,10 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
+			/*
+			 * No need to invalidate here it will synchronize on
+			 * against the special swap migration pte.
+			 */
 		} else if (PageAnon(page)) {
 			swp_entry_t entry = { .val = page_private(subpage) };
 			pte_t swp_pte;
@@ -1507,6 +1523,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				WARN_ON_ONCE(1);
 				ret = false;
 				/* We have to invalidate as we cleared the pte */
+				mmu_notifier_invalidate_range(mm, address,
+							address + PAGE_SIZE);
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1514,6 +1532,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			/* MADV_FREE page check */
 			if (!PageSwapBacked(page)) {
 				if (!PageDirty(page)) {
+					/* Invalidate as we cleared the pte */
+					mmu_notifier_invalidate_range(mm,
+						address, address + PAGE_SIZE);
 					dec_mm_counter(mm, MM_ANONPAGES);
 					goto discard;
 				}
@@ -1547,13 +1568,39 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
-		} else
+			/* Invalidate as we cleared the pte */
+			mmu_notifier_invalidate_range(mm, address,
+						      address + PAGE_SIZE);
+		} else {
+			/*
+			 * We should not need to notify here as we reach this
+			 * case only from freeze_page() itself only call from
+			 * split_huge_page_to_list() so everything below must
+			 * be true:
+			 *   - page is not anonymous
+			 *   - page is locked
+			 *
+			 * So as it is a locked file back page thus it can not
+			 * be remove from the page cache and replace by a new
+			 * page before mmu_notifier_invalidate_range_end so no
+			 * concurrent thread might update its page table to
+			 * point at new page while a device still is using this
+			 * page.
+			 *
+			 * See Documentation/vm/mmu_notifier.txt
+			 */
 			dec_mm_counter(mm, mm_counter_file(page));
+		}
 discard:
+		/*
+		 * No need to call mmu_notifier_invalidate_range() it has be
+		 * done above for all cases requiring it to happen under page
+		 * table lock before mmu_notifier_invalidate_range_end()
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
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
