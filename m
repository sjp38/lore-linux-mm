Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 8C14B6B004A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 15:08:44 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 02/39] xen: document Xen is using an unused bit for the pagetables
Date: Mon, 26 Mar 2012 19:45:49 +0200
Message-Id: <1332783986-24195-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Xen has taken over the last reserved bit available for the pagetables
which is set through ioremap, this documents it and makes the code
more readable.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/include/asm/pgtable_types.h |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 013286a..b74cac9 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -17,7 +17,7 @@
 #define _PAGE_BIT_PAT		7	/* on 4KB pages */
 #define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
 #define _PAGE_BIT_UNUSED1	9	/* available for programmer */
-#define _PAGE_BIT_IOMAP		10	/* flag used to indicate IO mapping */
+#define _PAGE_BIT_UNUSED2	10
 #define _PAGE_BIT_HIDDEN	11	/* hidden by kmemcheck */
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
 #define _PAGE_BIT_SPECIAL	_PAGE_BIT_UNUSED1
@@ -41,7 +41,7 @@
 #define _PAGE_PSE	(_AT(pteval_t, 1) << _PAGE_BIT_PSE)
 #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
 #define _PAGE_UNUSED1	(_AT(pteval_t, 1) << _PAGE_BIT_UNUSED1)
-#define _PAGE_IOMAP	(_AT(pteval_t, 1) << _PAGE_BIT_IOMAP)
+#define _PAGE_UNUSED2	(_AT(pteval_t, 1) << _PAGE_BIT_UNUSED2)
 #define _PAGE_PAT	(_AT(pteval_t, 1) << _PAGE_BIT_PAT)
 #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
 #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
@@ -49,6 +49,13 @@
 #define _PAGE_SPLITTING	(_AT(pteval_t, 1) << _PAGE_BIT_SPLITTING)
 #define __HAVE_ARCH_PTE_SPECIAL
 
+/* flag used to indicate IO mapping */
+#ifdef CONFIG_XEN
+#define _PAGE_IOMAP	(_AT(pteval_t, 1) << _PAGE_BIT_UNUSED2)
+#else
+#define _PAGE_IOMAP	(_AT(pteval_t, 0))
+#endif
+
 #ifdef CONFIG_KMEMCHECK
 #define _PAGE_HIDDEN	(_AT(pteval_t, 1) << _PAGE_BIT_HIDDEN)
 #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
