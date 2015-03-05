Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 510F46B006E
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 18:55:01 -0500 (EST)
Received: by wesw55 with SMTP id w55so2871585wes.3
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 15:55:00 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si15599366wjy.124.2015.03.05.15.54.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 15:54:58 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] mm: numa: Do not clear PTEs or PMDs for NUMA hinting faults
Date: Thu,  5 Mar 2015 23:54:52 +0000
Message-Id: <1425599692-32445-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1425599692-32445-1-git-send-email-mgorman@suse.de>
References: <1425599692-32445-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org, Mel Gorman <mgorman@suse.de>

Dave Chinner reported the following on https://lkml.org/lkml/2015/3/1/226

   Across the board the 4.0-rc1 numbers are much slower, and the
   degradation is far worse when using the large memory footprint
   configs. Perf points straight at the cause - this is from 4.0-rc1
   on the "-o bhash=101073" config:

   -   56.07%    56.07%  [kernel]            [k] default_send_IPI_mask_sequence_phys
      - default_send_IPI_mask_sequence_phys
         - 99.99% physflat_send_IPI_mask
            - 99.37% native_send_call_func_ipi
                 smp_call_function_many
               - native_flush_tlb_others
                  - 99.85% flush_tlb_page
                       ptep_clear_flush
                       try_to_unmap_one
                       rmap_walk
                       try_to_unmap
                       migrate_pages
                       migrate_misplaced_page
                     - handle_mm_fault
                        - 99.73% __do_page_fault
                             trace_do_page_fault
                             do_async_page_fault
                           + async_page_fault
              0.63% native_send_call_func_single_ipi
                 generic_exec_single
                 smp_call_function_single

This was bisected to commit 4d9424669946 ("mm: convert p[te|md]_mknonnuma
and remaining page table manipulations") which clears PTEs and PMDs to make
them PROT_NONE. This is tidy but tests on some benchmarks indicate that
there are many more hinting faults trapped resulting in excessive migration.
This is the result for the old autonuma benchmark for example.

autonumabench
                                           4.0.0-rc1             4.0.0-rc1                3.19.0
                                             vanilla            noclear-v1               vanilla
Time User-NUMA01                  32883.59 (  0.00%)    27401.21 ( 16.67%)    25695.96 ( 21.86%)
Time User-NUMA01_THEADLOCAL       17453.20 (  0.00%)    17491.98 ( -0.22%)    17404.36 (  0.28%)
Time User-NUMA02                   2063.70 (  0.00%)     2059.94 (  0.18%)     2037.65 (  1.26%)
Time User-NUMA02_SMT                983.70 (  0.00%)      967.95 (  1.60%)      981.02 (  0.27%)
Time System-NUMA01                  602.44 (  0.00%)      182.16 ( 69.76%)      194.70 ( 67.68%)
Time System-NUMA01_THEADLOCAL        78.10 (  0.00%)       84.84 ( -8.63%)       98.52 (-26.15%)
Time System-NUMA02                    6.47 (  0.00%)        9.74 (-50.54%)        9.28 (-43.43%)
Time System-NUMA02_SMT                5.06 (  0.00%)        3.97 ( 21.54%)        3.79 ( 25.10%)
Time Elapsed-NUMA01                 755.96 (  0.00%)      602.20 ( 20.34%)      558.84 ( 26.08%)
Time Elapsed-NUMA01_THEADLOCAL      382.22 (  0.00%)      384.98 ( -0.72%)      382.54 ( -0.08%)
Time Elapsed-NUMA02                  49.38 (  0.00%)       49.23 (  0.30%)       49.83 ( -0.91%)
Time Elapsed-NUMA02_SMT              47.70 (  0.00%)       46.82 (  1.84%)       46.59 (  2.33%)
Time CPU-NUMA01                    4429.00 (  0.00%)     4580.00 ( -3.41%)     4632.00 ( -4.58%)
Time CPU-NUMA01_THEADLOCAL         4586.00 (  0.00%)     4565.00 (  0.46%)     4575.00 (  0.24%)
Time CPU-NUMA02                    4191.00 (  0.00%)     4203.00 ( -0.29%)     4107.00 (  2.00%)
Time CPU-NUMA02_SMT                2072.00 (  0.00%)     2075.00 ( -0.14%)     2113.00 ( -1.98%)

Note the system CPU usage with the patch applied and how it's similar to
3.19-vanilla. The NUMA hinting activity is also restored to similar levels.

                             4.0.0-rc1   4.0.0-rc1      3.19.0
                               vanillanoclear-v1r13     vanilla
NUMA alloc hit                 1437560     1241466     1202922
NUMA alloc miss                      0           0           0
NUMA interleave hit                  0           0           0
NUMA alloc local               1436781     1240849     1200683
NUMA base PTE updates        304513172   223926293   222840103
NUMA huge PMD updates           594467      437025      434894
NUMA page range updates      608880276   447683093   445505831
NUMA hint faults                733491      598990      601358
NUMA hint local faults          511530      314936      371571
NUMA hint local percent             69          52          61
NUMA pages migrated           26366701     5424102     7073177

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/powerpc/include/asm/pgtable-ppc64.h | 16 ++++++++++++++++
 arch/x86/include/asm/pgtable.h           | 14 ++++++++++++++
 include/asm-generic/pgtable.h            | 19 +++++++++++++++++++
 mm/huge_memory.c                         | 19 ++++++++++++++++---
 mm/mprotect.c                            |  5 +++++
 5 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 43e6ad424c7f..bb654c192028 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -506,6 +506,22 @@ static inline pmd_t pmd_mkhuge(pmd_t pmd)
 	return pmd;
 }
 
+#define pte_mkprotnone pte_mkprotnone
+static inline pte_t pte_mkprotnone(pte_t pte)
+{
+	pte_val(pte) &= ~_PAGE_PRESENT;
+	pte_val(pte) |= _PAGE_USER;
+	return pte;
+}
+
+#define pmd_mkprotnone pmd_mkprotnone
+static inline pmd_t pmd_mkprotnone(pmd_t pmd)
+{
+	pmd_val(pmd) &= ~_PAGE_PRESENT;
+	pmd_val(pmd) |= _PAGE_USER;
+	return pmd;
+}
+
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
 	pmd_val(pmd) &= ~_PAGE_PRESENT;
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index a0c35bf6cb92..5524fa6f7e8e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -292,6 +292,20 @@ static inline pmd_t pmd_mkwrite(pmd_t pmd)
 	return pmd_set_flags(pmd, _PAGE_RW);
 }
 
+#define pte_mkprotnone pte_mkprotnone
+static inline pte_t pte_mkprotnone(pte_t pte)
+{
+	pte = pte_clear_flags(pte, _PAGE_PRESENT);
+	return pte_set_flags(pte, _PAGE_PROTNONE);
+}
+
+#define pmd_mkprotnone pmd_mkprotnone
+static inline pmd_t pmd_mkprotnone(pmd_t pmd)
+{
+	pmd = pmd_clear_flags(pmd, _PAGE_PRESENT);
+	return pmd_set_flags(pmd, _PAGE_PROTNONE);
+}
+
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
 	return pmd_clear_flags(pmd, _PAGE_PRESENT | _PAGE_PROTNONE);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 4d46085c1b90..837dbde26662 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -669,6 +669,25 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
+#ifndef pte_mkprotnone
+/*
+ * Only automatic NUMA balancing needs this so arches that support it must
+ * define pte_mknotpresent.
+ */
+static inline pte_mkprotnone(pte_t pte)
+{
+	BUG();
+}
+#endif
+
+#ifndef pmd_mkprotnone
+static inline pmd_mkprotnone(pmd_t pmd)
+{
+	BUG();
+}
+#endif
+
+
 #ifndef CONFIG_NUMA_BALANCING
 /*
  * Technically a PTE can be PROTNONE even when not doing NUMA balancing but
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 194c0f019774..d9d5a2045d10 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1495,11 +1495,24 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		}
 
 		if (!prot_numa || !pmd_protnone(*pmd)) {
-			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
-			entry = pmd_modify(entry, newprot);
+			/*
+			 * NUMA hinting update can avoid a clear and defer the
+			 * flush as it is not a functional correctness issue if
+			 * access occurs after the update and this avoids
+			 * spurious faults.
+			 */
+			if (prot_numa) {
+				entry = *pmd;
+				entry = pmd_mkprotnone(entry);
+			} else {
+				entry = pmdp_get_and_clear_notify(mm, addr,
+								  pmd);
+				entry = pmd_modify(entry, newprot);
+				BUG_ON(pmd_write(entry));
+			}
+
 			ret = HPAGE_PMD_NR;
 			set_pmd_at(mm, addr, pmd, entry);
-			BUG_ON(pmd_write(entry));
 		}
 		spin_unlock(ptl);
 	}
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 44727811bf4c..aa97d5cab6ce 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -90,6 +90,11 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				/* Avoid TLB flush if possible */
 				if (pte_protnone(oldpte))
 					continue;
+
+				ptent = pte_mkprotnone(oldpte);
+				set_pte_at(mm, addr, pte, ptent);
+				pages++;
+				continue;
 			}
 
 			ptent = ptep_modify_prot_start(mm, addr, pte);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
