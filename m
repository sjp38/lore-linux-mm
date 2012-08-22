Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 6C3FA6B0072
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:35 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 03/36] autonuma: define _PAGE_NUMA_PTE and _PAGE_NUMA_PMD
Date: Wed, 22 Aug 2012 16:58:47 +0200
Message-Id: <1345647560-30387-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

We will set these bitflags only when the pmd or pte is not present.

They work like PROTNONE but they identify a request for the numa
hinting page fault to trigger.

Because we want to be able to set these bitflags in any established
pte or pmd (while clearing the present bit at the same time) without
losing information, these bitflags must never be set when the pte and
pmd are present.

For _PAGE_NUMA_PTE the pte bitflag used is _PAGE_PSE, which cannot be
set on ptes and it also fits in between _PAGE_FILE and _PAGE_PROTNONE
which avoids having to alter the swp entries format.

For _PAGE_NUMA_PMD, we use a reserved bitflag. pmds never contain
swap_entries but if in the future we'll swap transparent hugepages, we
must keep in mind not to use the _PAGE_UNUSED2 bitflag in the swap
entry format and to start the swap entry offset above it.

PAGE_UNUSED2 is used by Xen but only on ptes established by ioremap,
never on pmds so there's no risk of collision with Xen.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/include/asm/pgtable_types.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 013286a..400d771 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -64,6 +64,34 @@
 #define _PAGE_FILE	(_AT(pteval_t, 1) << _PAGE_BIT_FILE)
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
+/*
+ * _PAGE_NUMA_PTE indicates that this page will trigger a numa hinting
+ * minor page fault to gather autonuma statistics (see
+ * pte_numa()). The bit picked (7) is purposefully in between the
+ * _PAGE_FILE (6) and _PAGE_PROTNONE (8) bits. Therefore, it doesn't
+ * require changes to the swp entry format because that bit is always
+ * zero when the pte is not present. It is also always zero when the
+ * pte is present (_PAGE_PAT (7) is never set on the pte according to
+ * arch/x86/mm/pat.c).
+ *
+ * The bit picked must be always zero when the pmd is present and not
+ * present, so that we don't lose information when we set it while
+ * atomically clearing the present bit.
+ */
+#define _PAGE_NUMA_PTE	_PAGE_PSE
+/*
+ * _PAGE_NUMA_PMD indicates that this page will trigger a numa hinting
+ * minor page fault to gather autonuma statistics (see
+ * pmd_numa())._PAGE_IOMAP is used by Xen but only on the pte, never
+ * on the pmd. If transparent hugepages will be swapped out natively,
+ * the swap entry offset will have to start above _PAGE_IOMAP.
+ *
+ * The bit picked must be always zero when the pmd is present and not
+ * present, so that we don't lose information when we set it while
+ * atomically clearing the present bit.
+ */
+#define _PAGE_NUMA_PMD	_PAGE_IOMAP
+
 #define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
 			 _PAGE_ACCESSED | _PAGE_DIRTY)
 #define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
