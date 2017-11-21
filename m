Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BFB636B0261
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:44 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k100so8574863wrc.9
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p202sor551994wmd.56.2017.11.21.10.26.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:43 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 06/10] Creation of "pagefault_handler" LSM hook
Date: Tue, 21 Nov 2017 19:26:08 +0100
Message-Id: <1511288772-19308-7-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
References: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

Creation of a new hook to let LSM modules handle user-space pagefaults on
x86.
It can be used to avoid segfaulting the originating process.
If it's the case it can modify process registers before returning.
This is not a security feature by itself, it's a way to soften some
unwanted side-effects of restrictive security features.
In particular this is used by S.A.R.A. to implement what PaX call
"trampoline emulation" that, in practice, allows for some specific
code sequences to be executed even if they are in non executable memory.
This may look like a bad thing at first, but you have to consider
that:
- This allows for strict memory restrictions (e.g. W^X) to stay on even
  when they should be turned off. And, even if this emulation
  makes those features less effective, it's still better than having
  them turned off completely.
- The only code sequences emulated are trampolines used to make
  function calls. In many cases, when you have the chance to
  make arbitrary memory writes, you can already manipulate the
  control flow of the program by overwriting function pointers or
  return values. So, in many cases, "trampoline emulation"
  doesn't introduce new exploit vectors.
- It's a feature that can be turned on only if needed, on a per
  executable file basis.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 arch/Kconfig              |  6 ++++++
 arch/x86/Kconfig          |  1 +
 arch/x86/mm/fault.c       |  6 ++++++
 include/linux/lsm_hooks.h | 12 ++++++++++++
 include/linux/security.h  | 11 +++++++++++
 security/security.c       | 11 +++++++++++
 6 files changed, 47 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 400b9e1..5481cc6 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -230,6 +230,12 @@ config ARCH_HAS_FORTIFY_SOURCE
 	  An architecture should select this when it can successfully
 	  build and run with CONFIG_FORTIFY_SOURCE.
 
+config ARCH_HAS_LSM_PAGEFAULT
+	bool
+	help
+	  An architecture should select this if it supports
+	  "pagefault_handler" LSM hook.
+
 # Select if arch has all set_memory_ro/rw/x/nx() functions in asm/cacheflush.h
 config ARCH_HAS_SET_MEMORY
 	bool
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index df3276d..3f52f3d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -54,6 +54,7 @@ config X86
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_KCOV			if X86_64
+	select ARCH_HAS_LSM_PAGEFAULT
 	select ARCH_HAS_PMEM_API		if X86_64
 	# Causing hangs/crashes, see the commit that added this change for details.
 	select ARCH_HAS_REFCOUNT
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 78ca9a8..5443170 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -16,6 +16,7 @@
 #include <linux/prefetch.h>		/* prefetchw			*/
 #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
 #include <linux/uaccess.h>		/* faulthandler_disabled()	*/
+#include <linux/security.h>		/* security_pagefault_handler	*/
 
 #include <asm/cpufeature.h>		/* boot_cpu_has, ...		*/
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
@@ -1332,6 +1333,11 @@ static inline bool smap_violation(int error_code, struct pt_regs *regs)
 			local_irq_enable();
 	}
 
+	if (unlikely(security_pagefault_handler(regs,
+						error_code,
+						address)))
+		return;
+
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 
 	if (error_code & X86_PF_WRITE)
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 8d7ccbd..1ca405d 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -489,6 +489,14 @@
  *	@vmflags contains the requested vmflags.
  *	Return 0 if the operation is allowed to continue otherwise return
  *	the appropriate error code.
+ * @pagefault_handler:
+ *	Handle pagefaults on supported architectures, that is any architecture
+ *	which defines CONFIG_ARCH_HAS_LSM_PAGEFAULT.
+ *	@regs contains process' registers.
+ *	@error_code contains error code for the pagefault.
+ *	@address contains the address that caused the pagefault.
+ *	Return 0 to let the kernel handle the pagefault as usually, any other
+ *	value to let the process continue its execution.
  * @file_lock:
  *	Check permission before performing file locking operations.
  *	Note: this hook mediates both flock and fcntl style locks.
@@ -1531,6 +1539,9 @@
 	int (*file_mprotect)(struct vm_area_struct *vma, unsigned long reqprot,
 				unsigned long prot);
 	int (*check_vmflags)(vm_flags_t vmflags);
+	int (*pagefault_handler)(struct pt_regs *regs,
+				 unsigned long error_code,
+				 unsigned long address);
 	int (*file_lock)(struct file *file, unsigned int cmd);
 	int (*file_fcntl)(struct file *file, unsigned int cmd,
 				unsigned long arg);
@@ -1819,6 +1830,7 @@ struct security_hook_heads {
 	struct list_head mmap_file;
 	struct list_head file_mprotect;
 	struct list_head check_vmflags;
+	struct list_head pagefault_handler;
 	struct list_head file_lock;
 	struct list_head file_fcntl;
 	struct list_head file_set_fowner;
diff --git a/include/linux/security.h b/include/linux/security.h
index ac16262..ba018a3 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -312,6 +312,9 @@ int security_mmap_file(struct file *file, unsigned long prot,
 int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
 			   unsigned long prot);
 int security_check_vmflags(vm_flags_t vmflags);
+int __maybe_unused security_pagefault_handler(struct pt_regs *regs,
+					      unsigned long error_code,
+					      unsigned long address);
 int security_file_lock(struct file *file, unsigned int cmd);
 int security_file_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
 void security_file_set_fowner(struct file *file);
@@ -851,6 +854,14 @@ static inline int security_check_vmflags(vm_flags_t vmflags)
 	return 0;
 }
 
+static inline int __maybe_unused security_pagefault_handler(
+						struct pt_regs *regs,
+						unsigned long error_code,
+						unsigned long address)
+{
+	return 0;
+}
+
 static inline int security_file_lock(struct file *file, unsigned int cmd)
 {
 	return 0;
diff --git a/security/security.c b/security/security.c
index 0df8988..21cd07e 100644
--- a/security/security.c
+++ b/security/security.c
@@ -944,6 +944,17 @@ int security_check_vmflags(vm_flags_t vmflags)
 	return call_int_hook(check_vmflags, 0, vmflags);
 }
 
+int __maybe_unused security_pagefault_handler(struct pt_regs *regs,
+					      unsigned long error_code,
+					      unsigned long address)
+{
+	return call_int_hook(pagefault_handler,
+			     0,
+			     regs,
+			     error_code,
+			     address);
+}
+
 int security_file_lock(struct file *file, unsigned int cmd)
 {
 	return call_int_hook(file_lock, 0, file, cmd);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
