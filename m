Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 341A26B0092
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:25:56 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so432634eaa.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 08:25:55 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 10/19] mm/pgprot: Move the pgprot_modify() fallback definition to mm.h
Date: Fri, 16 Nov 2012 17:25:12 +0100
Message-Id: <1353083121-4560-11-git-send-email-mingo@kernel.org>
In-Reply-To: <1353083121-4560-1-git-send-email-mingo@kernel.org>
References: <1353083121-4560-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

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
Link: http://lkml.kernel.org/n/tip-nfvarGMj9gjavowroorkizb4@git.kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mm.h | 13 +++++++++++++
 mm/mprotect.c      |  7 -------
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fa06804..2a32cf8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
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
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a409926..e97b0d6 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
