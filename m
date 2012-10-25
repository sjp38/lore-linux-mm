Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 4DF576B0080
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:08 -0400 (EDT)
Message-Id: <20121025124833.161298145@chello.nl>
Date: Thu, 25 Oct 2012 14:16:26 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 09/31] mm/pgprot: Move the pgprot_modify() fallback definition to mm.h
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0009-mm-pgprot-Move-the-pgprot_modify-fallback-definition.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Ingo Molnar <mingo@kernel.org>

From: Ingo Molnar <mingo@kernel.org>

pgprot_modify() is available on x86, but on other architectures it only
gets defined in mm/mprotect.c - breaking the build if anything outside
of mprotect.c tries to make use of this function.

Move it to the generic pgprot area in mm.h, so that an upcoming patch
can make use of it.

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>
Cc: Paul Turner <pjt@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mm.h |   13 +++++++++++++
 mm/mprotect.c      |    7 -------
 2 files changed, 13 insertions(+), 7 deletions(-)

Index: tip/include/linux/mm.h
===================================================================
--- tip.orig/include/linux/mm.h
+++ tip/include/linux/mm.h
@@ -164,6 +164,19 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_TRIED	0x40	/* second try */
 
 /*
+ * Some architectures (such as x86) may need to preserve certain pgprot
+ * bits, without complicating generic pgprot code.
+ *
+ * Most architectures don't care:
+ */
+#ifndef pgprot_modify
+static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
+{
+	return newprot;
+}
+#endif
+
+/*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
  * ->fault function. The vma's ->fault is responsible for returning a bitmask
  * of VM_FAULT_xxx flags that give details about how the fault was handled.
Index: tip/mm/mprotect.c
===================================================================
--- tip.orig/mm/mprotect.c
+++ tip/mm/mprotect.c
@@ -28,13 +28,6 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-#ifndef pgprot_modify
-static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
-{
-	return newprot;
-}
-#endif
-
 static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
