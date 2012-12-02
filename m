Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 848C46B006E
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:44:07 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1476612eek.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:44:07 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 05/52] mm/numa: Add pte_numa() and pmd_numa()
Date: Sun,  2 Dec 2012 19:42:57 +0100
Message-Id: <1354473824-19229-6-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>

From: Andrea Arcangeli <aarcange@redhat.com>

Implement pte_numa and pmd_numa.

We must atomically set the numa bit and clear the present bit to
define a pte_numa or pmd_numa.

Once a pte or pmd has been set as pte_numa or pmd_numa, the next
time a thread touches a virtual address in the corresponding
virtual range, a NUMA hinting page fault will trigger. The NUMA
hinting page fault will clear the NUMA bit and set the present
bit again to resolve the page fault.

The expectation is that a NUMA hinting page fault is used as
part of a placement policy that decides if a page should remain
on the current node or migrated to a different node.

[ Also add the Kconfig machinery that will be filled with
  more details of the NUMA balancing feature in later patches. ]

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Paul Turner <pjt@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Alex Shi <lkml.alex@gmail.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
[ various small fixes ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/sh/mm/Kconfig             |  1 +
 arch/x86/include/asm/pgtable.h | 11 +++++--
 include/asm-generic/pgtable.h  | 74 ++++++++++++++++++++++++++++++++++++++++++
 init/Kconfig                   | 33 +++++++++++++++++++
 4 files changed, 117 insertions(+), 2 deletions(-)

diff --git a/arch/sh/mm/Kconfig b/arch/sh/mm/Kconfig
index cb8f992..0f7c852 100644
--- a/arch/sh/mm/Kconfig
+++ b/arch/sh/mm/Kconfig
@@ -111,6 +111,7 @@ config VSYSCALL
 config NUMA
 	bool "Non Uniform Memory Access (NUMA) Support"
 	depends on MMU && SYS_SUPPORTS_NUMA && EXPERIMENTAL
+	select ARCH_WANT_NUMA_VARIABLE_LOCALITY
 	default n
 	help
 	  Some SH systems have many various memories scattered around
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5fe03aa..5199db2 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -404,7 +404,8 @@ static inline int pte_same(pte_t a, pte_t b)
 
 static inline int pte_present(pte_t a)
 {
-	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
+	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE |
+			       _PAGE_NUMA);
 }
 
 #define pte_accessible pte_accessible
@@ -426,7 +427,8 @@ static inline int pmd_present(pmd_t pmd)
 	 * the _PAGE_PSE flag will remain set at all times while the
 	 * _PAGE_PRESENT bit is clear).
 	 */
-	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE);
+	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE |
+				 _PAGE_NUMA);
 }
 
 static inline int pmd_none(pmd_t pmd)
@@ -485,6 +487,11 @@ static inline pte_t *pte_offset_kernel(pmd_t *pmd, unsigned long address)
 
 static inline int pmd_bad(pmd_t pmd)
 {
+#ifdef CONFIG_NUMA_BALANCING
+	/* pmd_numa check */
+	if ((pmd_flags(pmd) & (_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA)
+		return 0;
+#endif
 	return (pmd_flags(pmd) & ~_PAGE_USER) != _KERNPG_TABLE;
 }
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 48fc1dc..93deb5e 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -558,6 +558,80 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
+#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
+/*
+ * _PAGE_NUMA works identical to _PAGE_PROTNONE (it's actually the
+ * same bit too). It's set only when _PAGE_PRESET is not set and it's
+ * never set if _PAGE_PRESENT is set.
+ *
+ * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
+ * fault triggers on those regions if pte/pmd_numa returns true
+ * (because _PAGE_PRESENT is not set).
+ */
+#ifndef pte_numa
+static inline int pte_numa(pte_t pte)
+{
+	return (pte_flags(pte) &
+		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
+}
+#endif
+
+#ifndef pmd_numa
+static inline int pmd_numa(pmd_t pmd)
+{
+	return (pmd_flags(pmd) &
+		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
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
+#ifndef pte_mknonnuma
+static inline pte_t pte_mknonnuma(pte_t pte)
+{
+	pte = pte_clear_flags(pte, _PAGE_NUMA);
+	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+#endif
+
+#ifndef pmd_mknonnuma
+static inline pmd_t pmd_mknonnuma(pmd_t pmd)
+{
+	pmd = pmd_clear_flags(pmd, _PAGE_NUMA);
+	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+#endif
+
+#ifndef pte_mknuma
+static inline pte_t pte_mknuma(pte_t pte)
+{
+	pte = pte_set_flags(pte, _PAGE_NUMA);
+	return pte_clear_flags(pte, _PAGE_PRESENT);
+}
+#endif
+
+#ifndef pmd_mknuma
+static inline pmd_t pmd_mknuma(pmd_t pmd)
+{
+	pmd = pmd_set_flags(pmd, _PAGE_NUMA);
+	return pmd_clear_flags(pmd, _PAGE_PRESENT);
+}
+#endif
+#else
+static inline int pte_numa(pte_t pte) { return 0; }
+static inline int pmd_numa(pmd_t pmd) { return 0; }
+static inline pte_t pte_mknonnuma(pte_t pte) { return pte; }
+static inline pmd_t pmd_mknonnuma(pmd_t pmd) { return pmd; }
+static inline pte_t pte_mknuma(pte_t pte) { return pte; }
+static inline pmd_t pmd_mknuma(pmd_t pmd) { return pmd; }
+#endif /* CONFIG_ARCH_USES_NUMA_PROT_NONE */
+
 #endif /* CONFIG_MMU */
 
 #endif /* !__ASSEMBLY__ */
diff --git a/init/Kconfig b/init/Kconfig
index 6fdd6e3..37cd8d6 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -696,6 +696,39 @@ config LOG_BUF_SHIFT
 config HAVE_UNSTABLE_SCHED_CLOCK
 	bool
 
+#
+# For architectures that want to enable the support for NUMA-affine scheduler
+# balancing logic:
+#
+config ARCH_SUPPORTS_NUMA_BALANCING
+	bool
+
+# For architectures that (ab)use NUMA to represent different memory regions
+# all cpu-local but of different latencies, such as SuperH.
+#
+config ARCH_WANT_NUMA_VARIABLE_LOCALITY
+	bool
+
+#
+# For architectures that are willing to define _PAGE_NUMA as _PAGE_PROTNONE
+config ARCH_WANT_PROT_NUMA_PROT_NONE
+	bool
+
+config ARCH_USES_NUMA_PROT_NONE
+	bool
+	default y
+	depends on ARCH_WANT_PROT_NUMA_PROT_NONE
+	depends on NUMA_BALANCING
+
+config NUMA_BALANCING
+	bool "Memory placement aware NUMA scheduler"
+	default n
+	depends on ARCH_SUPPORTS_NUMA_BALANCING
+	depends on !ARCH_WANT_NUMA_VARIABLE_LOCALITY
+	depends on SMP && NUMA && MIGRATION
+	help
+	  This option adds support for automatic NUMA aware memory/task placement.
+
 menuconfig CGROUPS
 	boolean "Control Group support"
 	depends on EVENTFD
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
