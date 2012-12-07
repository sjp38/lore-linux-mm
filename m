Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 99C9D6B0085
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:18 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/49] mm: numa: define _PAGE_NUMA
Date: Fri,  7 Dec 2012 10:23:14 +0000
Message-Id: <1354875832-9700-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Andrea Arcangeli <aarcange@redhat.com>

The objective of _PAGE_NUMA is to be able to trigger NUMA hinting page
faults to identify the per NUMA node working set of the thread at
runtime.

Arming the NUMA hinting page fault mechanism works similarly to
setting up a mprotect(PROT_NONE) virtual range: the present bit is
cleared at the same time that _PAGE_NUMA is set, so when the fault
triggers we can identify it as a NUMA hinting page fault.

_PAGE_NUMA on x86 shares the same bit number of _PAGE_PROTNONE (but it
could also use a different bitflag, it's up to the architecture to
decide).

It would be confusing to call the "NUMA hinting page faults" as
"do_prot_none faults". They're different events and _PAGE_NUMA doesn't
alter the semantics of mprotect(PROT_NONE) in any way.

Sharing the same bitflag with _PAGE_PROTNONE in fact complicates
things: it requires us to ensure the code paths executed by
_PAGE_PROTNONE remains mutually exclusive to the code paths executed
by _PAGE_NUMA at all times, to avoid _PAGE_NUMA and _PAGE_PROTNONE to
step into each other toes.

Because we want to be able to set this bitflag in any established pte
or pmd (while clearing the present bit at the same time) without
losing information, this bitflag must never be set when the pte and
pmd are present, so the bitflag picked for _PAGE_NUMA usage, must not
be used by the swap entry format.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 arch/x86/include/asm/pgtable_types.h |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index ec8a1fc..3c32db8 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -64,6 +64,26 @@
 #define _PAGE_FILE	(_AT(pteval_t, 1) << _PAGE_BIT_FILE)
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
+/*
+ * _PAGE_NUMA indicates that this page will trigger a numa hinting
+ * minor page fault to gather numa placement statistics (see
+ * pte_numa()). The bit picked (8) is within the range between
+ * _PAGE_FILE (6) and _PAGE_PROTNONE (8) bits. Therefore, it doesn't
+ * require changes to the swp entry format because that bit is always
+ * zero when the pte is not present.
+ *
+ * The bit picked must be always zero when the pmd is present and not
+ * present, so that we don't lose information when we set it while
+ * atomically clearing the present bit.
+ *
+ * Because we shared the same bit (8) with _PAGE_PROTNONE this can be
+ * interpreted as _PAGE_NUMA only in places that _PAGE_PROTNONE
+ * couldn't reach, like handle_mm_fault() (see access_error in
+ * arch/x86/mm/fault.c, the vma protection must not be PROT_NONE for
+ * handle_mm_fault() to be invoked).
+ */
+#define _PAGE_NUMA	_PAGE_PROTNONE
+
 #define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
 			 _PAGE_ACCESSED | _PAGE_DIRTY)
 #define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
