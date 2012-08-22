Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id AE6406B0070
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:01 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 04/36] autonuma: pte_numa() and pmd_numa()
Date: Wed, 22 Aug 2012 16:58:48 +0200
Message-Id: <1345647560-30387-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Implement pte_numa and pmd_numa.

We must atomically set the numa bit and clear the present bit to
define a pte_numa or pmd_numa.

Once a pte or pmd has been set as pte_numa or pmd_numa, the next time
a thread touches a virtual address in the corresponding virtual range,
a NUMA hinting page fault will trigger. The NUMA hinting page fault
will clear the NUMA bit and set the present bit again to resolve the
page fault.

NUMA hinting page faults are used:

1) to fill in the per-thread NUMA statistic stored for each thread in
   a current->task_autonuma data structure

2) to track the per-node last_nid information in the page structure to
   detect false sharing

3) to queue the page mapped by the pte_numa or pmd_numa for async
   migration if there have been enough NUMA hinting page faults on the
   page coming from remote CPUs

NUMA hinting page faults collect information and possibly add pages to
migrate queues. They are extremely quick, absolutely non-blocking and
do not allocate memory.

The generic implementation is used when CONFIG_AUTONUMA=n.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/include/asm/pgtable.h |   65 ++++++++++++++++++++++++++++++++++++++-
 include/asm-generic/pgtable.h  |   12 +++++++
 2 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index b49e70d..bfe42aa 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -405,7 +405,8 @@ static inline int pte_same(pte_t a, pte_t b)
 
 static inline int pte_present(pte_t a)
 {
-	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
+	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE |
+			       _PAGE_NUMA_PTE);
 }
 
 static inline int pte_hidden(pte_t pte)
@@ -421,7 +422,63 @@ static inline int pmd_present(pmd_t pmd)
 	 * the _PAGE_PSE flag will remain set at all times while the
 	 * _PAGE_PRESENT bit is clear).
 	 */
-	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE);
+	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE |
+				 _PAGE_NUMA_PMD);
+}
+
+#ifdef CONFIG_AUTONUMA
+/*
+ * _PAGE_NUMA_PTE and _PAGE_NUMA_PMD works identical to
+ * _PAGE_PROTNONE. They're set only when _PAGE_PRESET is not
+ * set and they're never set if _PAGE_PRESENT is set.
+ *
+ * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
+ * fault triggers on those regions if pte/pmd_numa returns true
+ * (because _PAGE_PRESENT is not set).
+ */
+static inline int pte_numa(pte_t pte)
+{
+	return (pte_flags(pte) &
+		(_PAGE_NUMA_PTE|_PAGE_PRESENT)) == _PAGE_NUMA_PTE;
+}
+
+static inline int pmd_numa(pmd_t pmd)
+{
+	return (pmd_flags(pmd) &
+		(_PAGE_NUMA_PMD|_PAGE_PRESENT)) == _PAGE_NUMA_PMD;
+}
+#endif
+
+/*
+ * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
+ * because they're called by the NUMA hinting minor page fault. If we
+ * wouldn't set the _PAGE_ACCESSED bitflag here, the TLB miss handler
+ * would be forced to set it later while filling the TLB after we
+ * return to userland. That would trigger a second write to memory
+ * that we optimize away by setting _PAGE_ACCESSED here.
+ */
+static inline pte_t pte_mknonnuma(pte_t pte)
+{
+	pte = pte_clear_flags(pte, _PAGE_NUMA_PTE);
+	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+
+static inline pmd_t pmd_mknonnuma(pmd_t pmd)
+{
+	pmd = pmd_clear_flags(pmd, _PAGE_NUMA_PMD);
+	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+
+static inline pte_t pte_mknuma(pte_t pte)
+{
+	pte = pte_set_flags(pte, _PAGE_NUMA_PTE);
+	return pte_clear_flags(pte, _PAGE_PRESENT);
+}
+
+static inline pmd_t pmd_mknuma(pmd_t pmd)
+{
+	pmd = pmd_set_flags(pmd, _PAGE_NUMA_PMD);
+	return pmd_clear_flags(pmd, _PAGE_PRESENT);
 }
 
 static inline int pmd_none(pmd_t pmd)
@@ -480,6 +537,10 @@ static inline pte_t *pte_offset_kernel(pmd_t *pmd, unsigned long address)
 
 static inline int pmd_bad(pmd_t pmd)
 {
+#ifdef CONFIG_AUTONUMA
+	if (pmd_numa(pmd))
+		return 0;
+#endif
 	return (pmd_flags(pmd) & ~_PAGE_USER) != _KERNPG_TABLE;
 }
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index ff4947b..0ff87ec 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -530,6 +530,18 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
+#ifndef CONFIG_AUTONUMA
+static inline int pte_numa(pte_t pte)
+{
+	return 0;
+}
+
+static inline int pmd_numa(pmd_t pmd)
+{
+	return 0;
+}
+#endif /* CONFIG_AUTONUMA */
+
 #endif /* CONFIG_MMU */
 
 #endif /* !__ASSEMBLY__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
