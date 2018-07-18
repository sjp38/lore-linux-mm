Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9F76B029A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s18-v6so1694998edr.15
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:37 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id s7-v6si330244eda.85.2018.07.18.02.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:36 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 29/39] x86/mm/pti: Introduce pti_finalize()
Date: Wed, 18 Jul 2018 11:41:06 +0200
Message-Id: <1531906876-13451-30-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Introduce a new function to finalize the kernel mappings for
the userspace page-table after all ro/nx protections have been
applied to the kernel mappings.

Also move the call to pti_clone_kernel_text() to that
function so that it will run on 32 bit kernels too.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pti.h |  3 +--
 arch/x86/mm/init_64.c      |  6 ------
 arch/x86/mm/pti.c          | 14 +++++++++++++-
 include/linux/pti.h        |  1 +
 init/main.c                |  7 +++++++
 5 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/pti.h b/arch/x86/include/asm/pti.h
index 38a17f1..5df09a0 100644
--- a/arch/x86/include/asm/pti.h
+++ b/arch/x86/include/asm/pti.h
@@ -6,10 +6,9 @@
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 extern void pti_init(void);
 extern void pti_check_boottime_disable(void);
-extern void pti_clone_kernel_text(void);
+extern void pti_finalize(void);
 #else
 static inline void pti_check_boottime_disable(void) { }
-static inline void pti_clone_kernel_text(void) { }
 #endif
 
 #endif /* __ASSEMBLY__ */
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a688617..9b19f9a 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1291,12 +1291,6 @@ void mark_rodata_ro(void)
 			(unsigned long) __va(__pa_symbol(_sdata)));
 
 	debug_checkwx();
-
-	/*
-	 * Do this after all of the manipulation of the
-	 * kernel text page tables are complete.
-	 */
-	pti_clone_kernel_text();
 }
 
 int kern_addr_valid(unsigned long addr)
diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index fc77054..1825f30 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -462,7 +462,7 @@ static inline bool pti_kernel_image_global_ok(void)
  * For some configurations, map all of kernel text into the user page
  * tables.  This reduces TLB misses, especially on non-PCID systems.
  */
-void pti_clone_kernel_text(void)
+static void pti_clone_kernel_text(void)
 {
 	/*
 	 * rodata is part of the kernel image and is normally
@@ -526,3 +526,15 @@ void __init pti_init(void)
 	pti_setup_espfix64();
 	pti_setup_vsyscall();
 }
+
+/*
+ * Finalize the kernel mappings in the userspace page-table.
+ */
+void pti_finalize(void)
+{
+	/*
+	 * Do this after all of the manipulation of the
+	 * kernel text page tables are complete.
+	 */
+	pti_clone_kernel_text();
+}
diff --git a/include/linux/pti.h b/include/linux/pti.h
index 0174883..1a941ef 100644
--- a/include/linux/pti.h
+++ b/include/linux/pti.h
@@ -6,6 +6,7 @@
 #include <asm/pti.h>
 #else
 static inline void pti_init(void) { }
+static inline void pti_finalize(void) { }
 #endif
 
 #endif
diff --git a/init/main.c b/init/main.c
index 3b4ada1..fcfef46 100644
--- a/init/main.c
+++ b/init/main.c
@@ -1065,6 +1065,13 @@ static int __ref kernel_init(void *unused)
 	jump_label_invalidate_initmem();
 	free_initmem();
 	mark_readonly();
+
+	/*
+	 * Kernel mappings are now finalized - update the userspace page-table
+	 * to finalize PTI.
+	 */
+	pti_finalize();
+
 	system_state = SYSTEM_RUNNING;
 	numa_default_policy();
 
-- 
2.7.4
