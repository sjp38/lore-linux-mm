Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A51736B025E
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 23:10:19 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id b62so465995qkh.18
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 20:10:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h67si1294247qkc.426.2017.10.16.20.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 20:10:18 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 2/2] mm/mmu_notifier: avoid call to invalidate_range() in range_end()
Date: Mon, 16 Oct 2017 23:10:03 -0400
Message-Id: <20171017031003.7481-3-jglisse@redhat.com>
In-Reply-To: <20171017031003.7481-1-jglisse@redhat.com>
References: <20171017031003.7481-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Donnellan <andrew.donnellan@au1.ibm.com>, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This is an optimization patch that only affect mmu_notifier users which
rely on the invalidate_range() callback. This patch avoids calling that
callback twice in a row from inside __mmu_notifier_invalidate_range_end

Existing pattern (before this patch):
    mmu_notifier_invalidate_range_start()
        pte/pmd/pud_clear_flush_notify()
            mmu_notifier_invalidate_range()
    mmu_notifier_invalidate_range_end()
        mmu_notifier_invalidate_range()

New pattern (after this patch):
    mmu_notifier_invalidate_range_start()
        pte/pmd/pud_clear_flush_notify()
            mmu_notifier_invalidate_range()
    mmu_notifier_invalidate_range_only_end()

We call the invalidate_range callback after clearing the page table under
the page table lock and we skip the call to invalidate_range inside the
__mmu_notifier_invalidate_range_end() function.

Idea from Andrea Arcangeli

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
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
---
 include/linux/mmu_notifier.h | 17 ++++++++++++++--
 mm/huge_memory.c             | 46 ++++++++++++++++++++++++++++++++++++++++----
 mm/memory.c                  |  6 +++++-
 mm/migrate.c                 | 15 ++++++++++++---
 mm/mmu_notifier.c            | 11 +++++++++--
 5 files changed, 83 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 49c925c96b8a..6665c4624287 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -213,7 +213,8 @@ extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
+				  unsigned long start, unsigned long end,
+				  bool only_end);
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 
@@ -267,7 +268,14 @@ static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end);
+		__mmu_notifier_invalidate_range_end(mm, start, end, false);
+}
+
+static inline void mmu_notifier_invalidate_range_only_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_end(mm, start, end, true);
 }
 
 static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
@@ -438,6 +446,11 @@ static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 {
 }
 
+static inline void mmu_notifier_invalidate_range_only_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+}
+
 static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ff5bc647b51d..b2912305994f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1220,7 +1220,12 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 	page_remove_rmap(page, true);
 	spin_unlock(vmf->ptl);
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
+	/*
+	 * No need to double call mmu_notifier->invalidate_range() callback as
+	 * the above pmdp_huge_clear_flush_notify() did already call it.
+	 */
+	mmu_notifier_invalidate_range_only_end(vma->vm_mm, mmun_start,
+						mmun_end);
 
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
@@ -1369,7 +1374,12 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	}
 	spin_unlock(vmf->ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
+	/*
+	 * No need to double call mmu_notifier->invalidate_range() callback as
+	 * the above pmdp_huge_clear_flush_notify() did already call it.
+	 */
+	mmu_notifier_invalidate_range_only_end(vma->vm_mm, mmun_start,
+					       mmun_end);
 out:
 	return ret;
 out_unlock:
@@ -2021,7 +2031,12 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 
 out:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PUD_SIZE);
+	/*
+	 * No need to double call mmu_notifier->invalidate_range() callback as
+	 * the above pudp_huge_clear_flush_notify() did already call it.
+	 */
+	mmu_notifier_invalidate_range_only_end(mm, haddr, haddr +
+					       HPAGE_PUD_SIZE);
 }
 #endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 
@@ -2096,6 +2111,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
 		return;
 	} else if (is_huge_zero_pmd(*pmd)) {
+		/*
+		 * FIXME: Do we want to invalidate secondary mmu by calling
+		 * mmu_notifier_invalidate_range() see comments below inside
+		 * __split_huge_pmd() ?
+		 *
+		 * We are going from a zero huge page write protected to zero
+		 * small page also write protected so it does not seems useful
+		 * to invalidate secondary mmu at this time.
+		 */
 		return __split_huge_zero_page_pmd(vma, haddr, pmd);
 	}
 
@@ -2231,7 +2255,21 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
 out:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
+	/*
+	 * No need to double call mmu_notifier->invalidate_range() callback.
+	 * They are 3 cases to consider inside __split_huge_pmd_locked():
+	 *  1) pmdp_huge_clear_flush_notify() call invalidate_range() obvious
+	 *  2) __split_huge_zero_page_pmd() read only zero page and any write
+	 *    fault will trigger a flush_notify before pointing to a new page
+	 *    (it is fine if the secondary mmu keeps pointing to the old zero
+	 *    page in the meantime)
+	 *  3) Split a huge pmd into pte pointing to the same page. No need
+	 *     to invalidate secondary tlb entry they are all still valid.
+	 *     any further changes to individual pte will notify. So no need
+	 *     to call mmu_notifier->invalidate_range()
+	 */
+	mmu_notifier_invalidate_range_only_end(mm, haddr, haddr +
+					       HPAGE_PMD_SIZE);
 }
 
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
diff --git a/mm/memory.c b/mm/memory.c
index 47cdf4e85c2d..8a0c410037d2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2555,7 +2555,11 @@ static int wp_page_copy(struct vm_fault *vmf)
 		put_page(new_page);
 
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	/*
+	 * No need to double call mmu_notifier->invalidate_range() callback as
+	 * the above ptep_clear_flush_notify() did already call it.
+	 */
+	mmu_notifier_invalidate_range_only_end(mm, mmun_start, mmun_end);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/migrate.c b/mm/migrate.c
index e00814ca390e..2f0f8190cb6f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2088,7 +2088,11 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	set_page_owner_migrate_reason(new_page, MR_NUMA_MISPLACED);
 
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	/*
+	 * No need to double call mmu_notifier->invalidate_range() callback as
+	 * the above pmdp_huge_clear_flush_notify() did already call it.
+	 */
+	mmu_notifier_invalidate_range_only_end(mm, mmun_start, mmun_end);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
 	get_page(new_page);
@@ -2804,9 +2808,14 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
 	}
 
+	/*
+	 * No need to double call mmu_notifier->invalidate_range() callback as
+	 * the above ptep_clear_flush_notify() inside migrate_vma_insert_page()
+	 * did already call it.
+	 */
 	if (notified)
-		mmu_notifier_invalidate_range_end(mm, mmu_start,
-						  migrate->end);
+		mmu_notifier_invalidate_range_only_end(mm, mmu_start,
+						       migrate->end);
 }
 
 /*
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 314285284e6e..96edb33fd09a 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -190,7 +190,9 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					 unsigned long start,
+					 unsigned long end,
+					 bool only_end)
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -204,8 +206,13 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 		 * subsystem registers either invalidate_range_start()/end() or
 		 * invalidate_range(), so this will be no additional overhead
 		 * (besides the pointer check).
+		 *
+		 * We skip call to invalidate_range() if we know it is safe ie
+		 * call site use mmu_notifier_invalidate_range_only_end() which
+		 * is safe to do when we know that a call to invalidate_range()
+		 * already happen under page table lock.
 		 */
-		if (mn->ops->invalidate_range)
+		if (!only_end && mn->ops->invalidate_range)
 			mn->ops->invalidate_range(mn, mm, start, end);
 		if (mn->ops->invalidate_range_end)
 			mn->ops->invalidate_range_end(mn, mm, start, end);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
