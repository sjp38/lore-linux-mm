Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 7B7236B00EB
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:18:49 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 03/39] autonuma: define _PAGE_NUMA_PTE and _PAGE_NUMA_PMD
Date: Mon, 26 Mar 2012 19:45:50 +0200
Message-Id: <1332783986-24195-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

We will set these bitflags only when the pmd and pte is non present.

They work like PROT_NONE but they identify a request for the numa
hinting page fault to trigger.

Because we want to be able to set these bitflag in any established pte
or pmd (while clearing the present bit at the same time) without
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
but it's never used on pmds so there's no risk of collision with Xen.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/include/asm/pgtable_types.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index b74cac9..6e2d954 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -71,6 +71,17 @@
 #define _PAGE_FILE	(_AT(pteval_t, 1) << _PAGE_BIT_FILE)
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
+/*
+ * Cannot be set on pte. The fact it's in between _PAGE_FILE and
+ * _PAGE_PROTNONE avoids having to alter the swp entries.
+ */
+#define _PAGE_NUMA_PTE	_PAGE_PSE
+/*
+ * Cannot be set on pmd, if transparent hugepages will be swapped out
+ * the swap entry offset must start above it.
+ */
+#define _PAGE_NUMA_PMD	_PAGE_UNUSED2
+
 #define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
 			 _PAGE_ACCESSED | _PAGE_DIRTY)
 #define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
