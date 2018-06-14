Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 465DF6B027C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 20:47:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id s133-v6so3521662qke.21
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 17:47:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 54-v6sor2333666qtm.0.2018.06.13.17.47.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 17:47:14 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v13 15/24] selftests/vm: powerpc implementation for generic abstraction
Date: Wed, 13 Jun 2018 17:45:06 -0700
Message-Id: <1528937115-10132-16-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

Introduce powerpc implementation for the various
abstractions.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   16 ++++-
 tools/testing/selftests/vm/pkey-powerpc.h    |   91 ++++++++++++++++++++++++++
 tools/testing/selftests/vm/pkey-x86.h        |   15 ++++
 tools/testing/selftests/vm/protection_keys.c |   62 ++++++++++--------
 4 files changed, 156 insertions(+), 28 deletions(-)
 create mode 100644 tools/testing/selftests/vm/pkey-powerpc.h

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index 52a1152..321bbbd 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -74,8 +74,13 @@ static inline void sigsafe_printf(const char *format, ...)
 	}					\
 } while (0)
 
+__attribute__((noinline)) int read_ptr(int *ptr);
+void expected_pkey_fault(int pkey);
+
 #if defined(__i386__) || defined(__x86_64__) /* arch */
 #include "pkey-x86.h"
+#elif defined(__powerpc64__) /* arch */
+#include "pkey-powerpc.h"
 #else /* arch */
 #error Architecture not supported
 #endif /* arch */
@@ -186,7 +191,16 @@ static inline int open_hugepage_file(int flag)
 
 static inline int get_start_key(void)
 {
-	return 1;
+	return 0;
+}
+
+static inline u32 *siginfo_get_pkey_ptr(siginfo_t *si)
+{
+#ifdef si_pkey
+	return &si->si_pkey;
+#else
+	return (u32 *)(((u8 *)si) + si_pkey_offset);
+#endif
 }
 
 #endif /* _PKEYS_HELPER_H */
diff --git a/tools/testing/selftests/vm/pkey-powerpc.h b/tools/testing/selftests/vm/pkey-powerpc.h
new file mode 100644
index 0000000..ec6f5d7
--- /dev/null
+++ b/tools/testing/selftests/vm/pkey-powerpc.h
@@ -0,0 +1,91 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+#ifndef _PKEYS_POWERPC_H
+#define _PKEYS_POWERPC_H
+
+#ifndef SYS_mprotect_key
+# define SYS_mprotect_key	386
+#endif
+#ifndef SYS_pkey_alloc
+# define SYS_pkey_alloc		384
+# define SYS_pkey_free		385
+#endif
+#define REG_IP_IDX		PT_NIP
+#define REG_TRAPNO		PT_TRAP
+#define gregs			gp_regs
+#define fpregs			fp_regs
+#define si_pkey_offset		0x20
+
+#ifndef PKEY_DISABLE_ACCESS
+# define PKEY_DISABLE_ACCESS	0x3  /* disable read and write */
+#endif
+
+#ifndef PKEY_DISABLE_WRITE
+# define PKEY_DISABLE_WRITE	0x2
+#endif
+
+#define NR_PKEYS		32
+#define NR_RESERVED_PKEYS_4K	26
+#define NR_RESERVED_PKEYS_64K	3
+#define PKEY_BITS_PER_PKEY	2
+#define HPAGE_SIZE		(1UL << 24)
+#define PAGE_SIZE		(1UL << 16)
+#define pkey_reg_t		u64
+#define PKEY_REG_FMT		"%016lx"
+#define HUGEPAGE_FILE		"/sys/kernel/mm/hugepages/hugepages-16384kB/nr_hugepages"
+
+static inline u32 pkey_bit_position(int pkey)
+{
+	return (NR_PKEYS - pkey - 1) * PKEY_BITS_PER_PKEY;
+}
+
+static inline pkey_reg_t __read_pkey_reg(void)
+{
+	pkey_reg_t pkey_reg;
+
+	asm volatile("mfspr %0, 0xd" : "=r" (pkey_reg));
+
+	return pkey_reg;
+}
+
+static inline void __write_pkey_reg(pkey_reg_t pkey_reg)
+{
+	pkey_reg_t eax = pkey_reg;
+
+	dprintf4("%s() changing "PKEY_REG_FMT" to "PKEY_REG_FMT"\n",
+			 __func__, __read_pkey_reg(), pkey_reg);
+
+	asm volatile("mtspr 0xd, %0" : : "r" ((unsigned long)(eax)) : "memory");
+
+	dprintf4("%s() pkey register after changing "PKEY_REG_FMT" to "
+			PKEY_REG_FMT"\n", __func__, __read_pkey_reg(),
+			pkey_reg);
+}
+
+static inline int cpu_has_pku(void)
+{
+	return 1;
+}
+
+static inline int arch_reserved_keys(void)
+{
+	if (sysconf(_SC_PAGESIZE) == 4096)
+		return NR_RESERVED_PKEYS_4K;
+	else
+		return NR_RESERVED_PKEYS_64K;
+}
+
+void expect_fault_on_read_execonly_key(void *p1, u16 pkey)
+{
+	/* powerpc does not allow userspace to change permissions of exec-only
+	 * keys since those keys are not allocated by userspace. The signal
+	 * handler wont be able to reset the permissions, which means the code
+	 * will infinitely continue to segfault here.
+	 */
+	return;
+}
+
+/* 8-bytes of instruction * 16384bytes = 1 page */
+#define __page_o_noops() asm(".rept 16384 ; nop; .endr")
+
+#endif /* _PKEYS_POWERPC_H */
diff --git a/tools/testing/selftests/vm/pkey-x86.h b/tools/testing/selftests/vm/pkey-x86.h
index d5fa299..95ee952 100644
--- a/tools/testing/selftests/vm/pkey-x86.h
+++ b/tools/testing/selftests/vm/pkey-x86.h
@@ -42,6 +42,7 @@
 #endif
 
 #define NR_PKEYS		16
+#define NR_RESERVED_PKEYS	1
 #define PKEY_BITS_PER_PKEY	2
 #define HPAGE_SIZE		(1UL<<21)
 #define PAGE_SIZE		4096
@@ -161,4 +162,18 @@ int pkey_reg_xstate_offset(void)
 	return xstate_offset;
 }
 
+static inline int arch_reserved_keys(void)
+{
+	return NR_RESERVED_PKEYS;
+}
+
+void expect_fault_on_read_execonly_key(void *p1, u16 pkey)
+{
+	int ptr_contents;
+
+	ptr_contents = read_ptr(p1);
+	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
+	expected_pkey_fault(pkey);
+}
+
 #endif /* _PKEYS_X86_H */
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index f43a319..88dfa40 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -197,17 +197,18 @@ void dump_mem(void *dumpme, int len_bytes)
 
 int pkey_faults;
 int last_si_pkey = -1;
+void pkey_access_allow(int pkey);
 void signal_handler(int signum, siginfo_t *si, void *vucontext)
 {
 	ucontext_t *uctxt = vucontext;
 	int trapno;
 	unsigned long ip;
 	char *fpregs;
+#if defined(__i386__) || defined(__x86_64__) /* arch */
 	pkey_reg_t *pkey_reg_ptr;
-	u64 siginfo_pkey;
+#endif /* defined(__i386__) || defined(__x86_64__) */
+	u32 siginfo_pkey;
 	u32 *si_pkey_ptr;
-	int pkey_reg_offset;
-	fpregset_t fpregset;
 
 	dprint_in_signal = 1;
 	dprintf1(">>>>===============SIGSEGV============================\n");
@@ -217,12 +218,14 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 
 	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
 	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
-	fpregset = uctxt->uc_mcontext.fpregs;
-	fpregs = (void *)fpregset;
+	fpregs = (char *) uctxt->uc_mcontext.fpregs;
 
 	dprintf2("%s() trapno: %d ip: 0x%016lx info->si_code: %s/%d\n",
 			__func__, trapno, ip, si_code_str(si->si_code),
 			si->si_code);
+
+#if defined(__i386__) || defined(__x86_64__) /* arch */
+
 #ifdef __i386__
 	/*
 	 * 32-bit has some extra padding so that userspace can tell whether
@@ -230,20 +233,28 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	 * state.  We just assume that it is here.
 	 */
 	fpregs += 0x70;
-#endif
-	pkey_reg_offset = pkey_reg_xstate_offset();
-	pkey_reg_ptr = (void *)(&fpregs[pkey_reg_offset]);
+#endif /* __i386__ */
 
-	dprintf1("siginfo: %p\n", si);
-	dprintf1(" fpregs: %p\n", fpregs);
+	pkey_reg_ptr = (void *)(&fpregs[pkey_reg_xstate_offset()]);
 	/*
-	 * If we got a PKEY fault, we *HAVE* to have at least one bit set in
+	 * If we got a key fault, we *HAVE* to have at least one bit set in
 	 * here.
 	 */
 	dprintf1("pkey_reg_xstate_offset: %d\n", pkey_reg_xstate_offset());
 	if (DEBUG_LEVEL > 4)
 		dump_mem(pkey_reg_ptr - 128, 256);
 	pkey_assert(*pkey_reg_ptr);
+#endif /* defined(__i386__) || defined(__x86_64__) */
+
+	dprintf1("siginfo: %p\n", si);
+	dprintf1(" fpregs: %p\n", fpregs);
+
+	si_pkey_ptr = siginfo_get_pkey_ptr(si);
+	dprintf1("si_pkey_ptr: %p\n", si_pkey_ptr);
+	dump_mem(si_pkey_ptr - 8, 24);
+	siginfo_pkey = *si_pkey_ptr;
+	pkey_assert(siginfo_pkey < NR_PKEYS);
+	last_si_pkey = siginfo_pkey;
 
 	if ((si->si_code == SEGV_MAPERR) ||
 	    (si->si_code == SEGV_ACCERR) ||
@@ -252,22 +263,21 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 		exit(4);
 	}
 
-	si_pkey_ptr = (u32 *)(((u8 *)si) + si_pkey_offset);
-	dprintf1("si_pkey_ptr: %p\n", si_pkey_ptr);
-	dump_mem((u8 *)si_pkey_ptr - 8, 24);
-	siginfo_pkey = *si_pkey_ptr;
-	pkey_assert(siginfo_pkey < NR_PKEYS);
-	last_si_pkey = siginfo_pkey;
-
-	dprintf1("signal pkey_reg from xsave: "PKEY_REG_FMT"\n", *pkey_reg_ptr);
 	/*
 	 * need __read_pkey_reg() version so we do not do shadow_pkey_reg
 	 * checking
 	 */
 	dprintf1("signal pkey_reg from  pkey_reg: "PKEY_REG_FMT"\n",
 			__read_pkey_reg());
-	dprintf1("pkey from siginfo: %jx\n", siginfo_pkey);
-	*(u64 *)pkey_reg_ptr = 0x00000000;
+#if defined(__i386__) || defined(__x86_64__) /* arch */
+	dprintf1("signal pkey_reg from xsave: "PKEY_REG_FMT"\n", *pkey_reg_ptr);
+	*(u64 *)pkey_reg_ptr &= clear_pkey_flags(siginfo_pkey,
+			PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE);
+#elif __powerpc64__
+	pkey_access_allow(siginfo_pkey);
+#endif
+	shadow_pkey_reg &= clear_pkey_flags(siginfo_pkey,
+			PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE);
 	dprintf1("WARNING: set PKEY_REG=0 to allow faulting instruction "
 			"to continue\n");
 	pkey_faults++;
@@ -1331,9 +1341,8 @@ void test_executing_on_unreadable_memory(int *ptr, u16 pkey)
 	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
 	lots_o_noops_around_write(&scratch);
 	do_not_expect_pkey_fault("executing on PROT_EXEC memory");
-	ptr_contents = read_ptr(p1);
-	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
-	expected_pkey_fault(pkey);
+
+	expect_fault_on_read_execonly_key(p1, pkey);
 }
 
 void test_implicit_mprotect_exec_only_memory(int *ptr, u16 pkey)
@@ -1360,9 +1369,8 @@ void test_implicit_mprotect_exec_only_memory(int *ptr, u16 pkey)
 	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
 	lots_o_noops_around_write(&scratch);
 	do_not_expect_pkey_fault("executing on PROT_EXEC memory");
-	ptr_contents = read_ptr(p1);
-	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
-	expected_pkey_fault(UNKNOWN_PKEY);
+
+	expect_fault_on_read_execonly_key(p1, UNKNOWN_PKEY);
 
 	/*
 	 * Put the memory back to non-PROT_EXEC.  Should clear the
-- 
1.7.1
