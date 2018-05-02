Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 592736B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 09:27:55 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k186-v6so8610130oib.7
        for <linux-mm@kvack.org>; Wed, 02 May 2018 06:27:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b19-v6si4442609otb.277.2018.05.02.06.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 06:27:53 -0700 (PDT)
From: Florian Weimer <fweimer@redhat.com>
Date: Wed, 2 May 2018 15:26:22 +0200
Subject: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change signal
 semantics
Message-Id: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: dave.hansen@intel.com, linuxram@us.ibm.com

pkeys support for IBM POWER intends to inherited the access rights of
the current thread in signal handlers.  The advantage is that this
preserves access to memory regions associated with non-default keys,
enabling additional usage scenarios for memory protection keys which
currently do not work on x86 due to the unconditional reset to the
(configurable) default key in signal handlers.

Consequently, this commit updates the x86 implementation to preserve
the PKRU register value of the interrupted context in signal handlers.
If a key is allocated successfully with the PKEY_ALLOC_SIGNALINHERIT
flag, the application can assume this signal inheritance behavior.

This change does not affect the init_pkru optimization because if the
thread's PKRU register is zero due to the init_pkru setting, it will
remain zero in the signal handler through inheritance from the
interrupted context.

After this change, this program:

??=include <sys/syscall.h>
??=include <unistd.h>
??=include <stdio.h>
??=include <err.h>
??=include <signal.h>

??=define PKEY_ALLOC_SIGNALINHERIT 1
??=define PKEY_DISABLE_ACCESS 1
??=define PKEY_DISABLE_WRITE 2

static inline unsigned int
pkey_read (void)
{
  unsigned int result;
  __asm__ volatile (".byte 0x0f, 0x01, 0xee"
                    : "=a" (result) : "c" (0) : "rdx");
  return result;
}

static void
print_pkru (const char *where)
{
  printf ("PKRU (%s): %08x\n", where, pkey_read ());
}

static void
sigusr1 (int signo)
{
  print_pkru ("signal handler");
}

int
main (void)
{
  if (signal (SIGUSR1, sigusr1) == SIG_ERR)
    err (1, "signal");
  print_pkru ("main");
  raise (SIGUSR1);

  puts ("allocating key 1");
  int key1 = syscall (SYS_pkey_alloc, PKEY_ALLOC_SIGNALINHERIT, 0);
  if (key1 < 0)
    err (1, "pkey_alloc");
  print_pkru ("main");
  raise (SIGUSR1);

  puts ("allocating key 2");
  int key2 = syscall (SYS_pkey_alloc, PKEY_ALLOC_SIGNALINHERIT,
                      PKEY_DISABLE_ACCESS);
  if (key2 < 0)
    err (1, "pkey_alloc");
  print_pkru ("main");
  raise (SIGUSR1);

  puts ("allocating key 3");
  int key3 = syscall (SYS_pkey_alloc, PKEY_ALLOC_SIGNALINHERIT,
                      PKEY_DISABLE_WRITE);
  if (key3 < 0)
    err (1, "pkey_alloc");
  print_pkru ("main");
  raise (SIGUSR1);

  return 0;
}

should print:

PKRU (main): 55555554
PKRU (signal handler): 55555554
allocating key 1
PKRU (main): 55555550
PKRU (signal handler): 55555550
allocating key 2
PKRU (main): 55555550
PKRU (signal handler): 55555550
allocating key 3
PKRU (main): 55555590
PKRU (signal handler): 55555590

That is, the PKRU register value in the signal handler matches that of
the main thread, even if the access rights have been changed from the
system default.

Signed-off-by: Florian Weimer <fweimer@redhat.com>
---
 Documentation/x86/protection-keys.txt         |  9 ++++-
 arch/alpha/include/uapi/asm/mman.h            |  2 ++
 arch/mips/include/uapi/asm/mman.h             |  2 ++
 arch/parisc/include/uapi/asm/mman.h           |  2 ++
 arch/x86/include/asm/fpu/internal.h           |  1 +
 arch/x86/kernel/fpu/core.c                    | 47 +++++++++++++++++++++------
 arch/x86/kernel/signal.c                      |  2 +-
 arch/xtensa/include/uapi/asm/mman.h           |  2 ++
 include/uapi/asm-generic/mman-common.h        |  2 ++
 mm/mprotect.c                                 | 11 +++++--
 tools/include/uapi/asm-generic/mman-common.h  |  2 ++
 tools/testing/selftests/x86/protection_keys.c |  4 ++-
 12 files changed, 71 insertions(+), 15 deletions(-)

diff --git a/Documentation/x86/protection-keys.txt b/Documentation/x86/protection-keys.txt
index ecb0d2dadfb7..d46d8e501c3a 100644
--- a/Documentation/x86/protection-keys.txt
+++ b/Documentation/x86/protection-keys.txt
@@ -39,11 +39,18 @@ with a key.  In this example WRPKRU is wrapped by a C function
 called pkey_set().
 
 	int real_prot = PROT_READ|PROT_WRITE;
-	pkey = pkey_alloc(0, PKEY_DISABLE_WRITE);
+	pkey = pkey_alloc(PKEY_ALLOC_SIGNALINHERIT, PKEY_DISABLE_WRITE);
 	ptr = mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
 	ret = pkey_mprotect(ptr, PAGE_SIZE, real_prot, pkey);
 	... application runs here
 
+The PKEY_ALLOC_SIGNALINHERIT flag ensures the that key allocation
+fails if the kernel does not support access rights inheritance for
+signal handlers.  (Some kernel versions implement different semantics
+where signal handlers execute not with the access rights of the
+interrupted thread, but with some unspecified system default access
+rights.)
+
 Now, if the application needs to update the data at 'ptr', it can
 gain access, do the update, then remove its write access:
 
diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index f9d4e6b6d4bd..39468bf388a2 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -73,6 +73,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SIGNALINHERIT 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 3035ca499cd8..dfe6cd82403a 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -100,6 +100,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SIGNALINHERIT 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 870fbf8c7088..773c130c17db 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -70,6 +70,8 @@
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
 
+#define PKEY_ALLOC_SIGNALINHERIT 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
index a38bf5a1e37a..a87e99f72be6 100644
--- a/arch/x86/include/asm/fpu/internal.h
+++ b/arch/x86/include/asm/fpu/internal.h
@@ -33,6 +33,7 @@ extern int  fpu__restore_sig(void __user *buf, int ia32_frame);
 extern void fpu__drop(struct fpu *fpu);
 extern int  fpu__copy(struct fpu *dst_fpu, struct fpu *src_fpu);
 extern void fpu__clear(struct fpu *fpu);
+extern void fpu__clear_signal(struct fpu *fpu);
 extern int  fpu__exception_code(struct fpu *fpu, int trap_nr);
 extern int  dump_fpu(struct pt_regs *ptregs, struct user_i387_struct *fpstate);
 
diff --git a/arch/x86/kernel/fpu/core.c b/arch/x86/kernel/fpu/core.c
index f92a6593de1e..a3b304888af8 100644
--- a/arch/x86/kernel/fpu/core.c
+++ b/arch/x86/kernel/fpu/core.c
@@ -370,21 +370,16 @@ static inline void copy_init_fpstate_to_fpregs(void)
 		copy_kernel_to_fxregs(&init_fpstate.fxsave);
 	else
 		copy_kernel_to_fregs(&init_fpstate.fsave);
-
-	if (boot_cpu_has(X86_FEATURE_OSPKE))
-		copy_init_pkru_to_fpregs();
 }
 
-/*
- * Clear the FPU state back to init state.
- *
- * Called by sys_execve(), by the signal handler code and by various
- * error paths.
- */
-void fpu__clear(struct fpu *fpu)
+static void __fpu_clear(struct fpu *fpu, bool for_signal)
 {
+	u32 pkru;
+
 	WARN_ON_FPU(fpu != &current->thread.fpu); /* Almost certainly an anomaly */
 
+	if (for_signal)
+		pkru = read_pkru();
 	fpu__drop(fpu);
 
 	/*
@@ -395,10 +390,42 @@ void fpu__clear(struct fpu *fpu)
 		fpu__initialize(fpu);
 		user_fpu_begin();
 		copy_init_fpstate_to_fpregs();
+		if (boot_cpu_has(X86_FEATURE_OSPKE)) {
+			/* A signal handler inherits the original PKRU
+			 * value of the interrupted thread.
+			 */
+			if (for_signal)
+				__write_pkru(pkru);
+			else
+				copy_init_pkru_to_fpregs();
+		}
 		preempt_enable();
 	}
 }
 
+/*
+ * Clear the FPU state back to init state.
+ *
+ * Called by sys_execve(), the signal handler return code, and by
+ * various error paths.
+ */
+void fpu__clear(struct fpu *fpu)
+{
+	return __fpu_clear(fpu, false);
+}
+
+/*
+ * Prepare the FPU for invoking a signal handler.
+ *
+ * This is like fpu__clear(), but some CPU registers are inherited
+ * from the current thread and not restored to their initial values,
+ * to match behavior on other architectures.
+ */
+void fpu__clear_signal(struct fpu *fpu)
+{
+	return __fpu_clear(fpu, true);
+}
+
 /*
  * x87 math exception handling:
  */
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index da270b95fe4d..b3c1f6f3df66 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -758,7 +758,7 @@ handle_signal(struct ksignal *ksig, struct pt_regs *regs)
 		 * Ensure the signal handler starts with the new fpu state.
 		 */
 		if (fpu->initialized)
-			fpu__clear(fpu);
+			fpu__clear_signal(fpu);
 	}
 	signal_setup_done(failed, ksig, stepping);
 }
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 58f29a9d895d..741b5d39882f 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -112,6 +112,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SIGNALINHERIT 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index e7ee32861d51..18f6c1ebe2bb 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -69,6 +69,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SIGNALINHERIT 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 625608bc8962..ec82728774af 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -539,14 +539,21 @@ SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 	return do_mprotect_pkey(start, len, prot, pkey);
 }
 
+#define PKEY_ALLOC_FLAGS ((unsigned long) (PKEY_ALLOC_SIGNALINHERIT))
+
 SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 {
 	int pkey;
 	int ret;
 
-	/* No flags supported yet. */
-	if (flags)
+	/* Check for unsupported flags. No further action for
+	 * PKEY_ALLOC_SIGNALINHERIT is required; this flag merely
+	 * provides a way for applications to detect that allocated
+	 * keys support inheriting access rights in signal handler.
+	 */
+	if (flags & ~PKEY_ALLOC_FLAGS)
 		return -EINVAL;
+
 	/* check for unsupported init values */
 	if (init_val & ~PKEY_ACCESS_MASK)
 		return -EINVAL;
diff --git a/tools/include/uapi/asm-generic/mman-common.h b/tools/include/uapi/asm-generic/mman-common.h
index e7ee32861d51..18f6c1ebe2bb 100644
--- a/tools/include/uapi/asm-generic/mman-common.h
+++ b/tools/include/uapi/asm-generic/mman-common.h
@@ -69,6 +69,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SIGNALINHERIT 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/tools/testing/selftests/x86/protection_keys.c b/tools/testing/selftests/x86/protection_keys.c
index f15aa5a76fe3..e651c83e09aa 100644
--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -393,6 +393,8 @@ pid_t fork_lazy_child(void)
 	return forkret;
 }
 
+#define PKEY_ALLOC_SIGNALINHERIT 0x1
+
 #define PKEY_DISABLE_ACCESS    0x1
 #define PKEY_DISABLE_WRITE     0x2
 
@@ -560,7 +562,7 @@ int alloc_pkey(void)
 
 	dprintf1("alloc_pkey()::%d, pkru: 0x%x shadow: %x\n",
 			__LINE__, __rdpkru(), shadow_pkru);
-	ret = sys_pkey_alloc(0, init_val);
+	ret = sys_pkey_alloc(PKEY_ALLOC_SIGNALINHERIT, init_val);
 	/*
 	 * pkey_alloc() sets PKRU, so we need to reflect it in
 	 * shadow_pkru:
-- 
2.14.3
