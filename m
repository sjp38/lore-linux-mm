Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 60AD56B0257
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 17:00:24 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id td3so23361095pab.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 14:00:24 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q62si851641pfi.214.2016.03.09.14.00.22
        for <linux-mm@kvack.org>;
        Wed, 09 Mar 2016 14:00:23 -0800 (PST)
Subject: [PATCH 9/9] x86, pkeys: add self-tests
From: Dave Hansen <dave@sr71.net>
Date: Wed, 09 Mar 2016 14:00:21 -0800
References: <20160309220008.D61AF421@viggo.jf.intel.com>
In-Reply-To: <20160309220008.D61AF421@viggo.jf.intel.com>
Message-Id: <20160309220021.36979F8C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, shuahkh@osg.samsung.com, linux-api@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This code should be a good demonstration of how to use the new
system calls as well as how to use protection keys in general.

This code shows how to:
1. Manipulate the Protection Keys Rights User (PKRU) register with
   sys_pkey_get/set()
2. Set a protection key on memory
3. Fetch and/or modify PKRU from the signal XSAVE state
4. Read the kernel-provided protection key in the siginfo
5. Set up an execute-only mapping

There are currently 13 tests:

        test_read_of_write_disabled_region
        test_read_of_access_disabled_region
        test_write_of_write_disabled_region
        test_write_of_access_disabled_region
        test_kernel_write_of_access_disabled_region
        test_kernel_write_of_write_disabled_region
        test_kernel_gup_of_access_disabled_region
        test_kernel_gup_write_to_write_disabled_region
        test_executing_on_unreadable_memory
        test_ptrace_of_child
        test_pkey_syscalls_on_non_allocated_pkey
        test_pkey_syscalls_bad_args
	test_pkey_alloc_exhaust

Each of the tests is run with plain memory (via mmap(MAP_ANON)),
transparent huge pages, and hugetlb.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: shuahkh@osg.samsung.com
Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
---

 b/tools/testing/selftests/x86/Makefile          |    2 
 b/tools/testing/selftests/x86/pkey-helpers.h    |  186 +++
 b/tools/testing/selftests/x86/protection_keys.c | 1199 ++++++++++++++++++++++++
 3 files changed, 1386 insertions(+), 1 deletion(-)

diff -puN tools/testing/selftests/x86/Makefile~pkeys-130-selftests tools/testing/selftests/x86/Makefile
--- a/tools/testing/selftests/x86/Makefile~pkeys-130-selftests	2016-03-09 13:55:34.878119189 -0800
+++ b/tools/testing/selftests/x86/Makefile	2016-03-09 13:55:34.882119370 -0800
@@ -5,7 +5,7 @@ include ../lib.mk
 .PHONY: all all_32 all_64 warn_32bit_failure clean
 
 TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs syscall_nt ptrace_syscall \
-			check_initial_reg_state sigreturn ldt_gdt
+			check_initial_reg_state sigreturn ldt_gdt protection_keys
 TARGETS_C_32BIT_ONLY := entry_from_vm86 syscall_arg_fault test_syscall_vdso unwind_vdso \
 			test_FCMOV test_FCOMI test_FISTTP \
 			vdso_restorer
diff -puN /dev/null tools/testing/selftests/x86/pkey-helpers.h
--- /dev/null	2016-03-01 16:49:31.662341041 -0800
+++ b/tools/testing/selftests/x86/pkey-helpers.h	2016-03-09 13:55:34.882119370 -0800
@@ -0,0 +1,186 @@
+#ifndef _PKEYS_HELPER_H
+#define _PKEYS_HELPER_H
+#define _GNU_SOURCE
+#include <string.h>
+#include <stdio.h>
+#include <stdint.h>
+#include <stdbool.h>
+#include <signal.h>
+#include <assert.h>
+#include <stdlib.h>
+#include <ucontext.h>
+#include <sys/mman.h>
+
+#define NR_PKEYS 16
+
+#ifndef DEBUG_LEVEL
+#define DEBUG_LEVEL 0
+#endif
+#define dprintf_level(level, args...) do { if(level <= DEBUG_LEVEL) printf(args); } while(0)
+#define dprintf1(args...) dprintf_level(1, args)
+#define dprintf2(args...) dprintf_level(2, args)
+#define dprintf3(args...) dprintf_level(3, args)
+#define dprintf4(args...) dprintf_level(4, args)
+
+extern unsigned int shadow_pkru;
+static inline unsigned int __rdpkru(void)
+{
+        unsigned int eax, edx;
+	unsigned int ecx = 0;
+	unsigned int pkru;
+
+        asm volatile(".byte 0x0f,0x01,0xee\n\t"
+                     : "=a" (eax), "=d" (edx)
+		     : "c" (ecx));
+	pkru = eax;
+	return pkru;
+}
+
+static inline unsigned int _rdpkru(int line)
+{
+	unsigned int pkru = __rdpkru();
+	dprintf4("rdpkru(line=%d) pkru: %x shadow: %x\n", line, pkru, shadow_pkru);
+	assert(pkru == shadow_pkru);
+	return pkru;
+}
+
+#define rdpkru() _rdpkru(__LINE__)
+
+static inline void __wrpkru(unsigned int pkru)
+{
+        unsigned int eax = pkru;
+	unsigned int ecx = 0;
+	unsigned int edx = 0;
+
+return;
+        asm volatile(".byte 0x0f,0x01,0xef\n\t"
+                     : : "a" (eax), "c" (ecx), "d" (edx));
+	assert(pkru == __rdpkru());
+}
+
+static inline void wrpkru(unsigned int pkru)
+{
+	dprintf4("%s() changing %08x to %08x\n", __func__, __rdpkru(), pkru);
+	// will do the shadow check for us:
+	rdpkru();
+	__wrpkru(pkru);
+	shadow_pkru = pkru;
+	dprintf4("%s(%08x) pkru: %08x\n", __func__, pkru, __rdpkru());
+}
+
+/*
+ * These are technically racy. since something could
+ * change PKRU between the read and the write.
+ */
+static inline void __pkey_access_allow(int pkey, int do_allow)
+{
+	unsigned int pkru = rdpkru();
+	int bit = pkey * 2;
+
+	if (do_allow)
+		pkru &= (1<<bit);
+	else
+		pkru |= (1<<bit);
+
+	dprintf4("pkru now: %08x\n", rdpkru());
+	wrpkru(pkru);
+}
+
+static inline void __pkey_write_allow(int pkey, int do_allow_write)
+{
+	long pkru = rdpkru();
+	int bit = pkey * 2 + 1;
+
+	if (do_allow_write)
+		pkru &= (1<<bit);
+	else
+		pkru |= (1<<bit);
+
+	wrpkru(pkru);
+	dprintf4("pkru now: %08x\n", rdpkru());
+}
+
+#define PROT_PKEY0     0x10            /* protection key value (bit 0) */
+#define PROT_PKEY1     0x20            /* protection key value (bit 1) */
+#define PROT_PKEY2     0x40            /* protection key value (bit 2) */
+#define PROT_PKEY3     0x80            /* protection key value (bit 3) */
+
+#define PAGE_SIZE 4096
+#define MB	(1<<20)
+
+static inline void __cpuid(unsigned int *eax, unsigned int *ebx,
+                                unsigned int *ecx, unsigned int *edx)
+{
+	/* ecx is often an input as well as an output. */
+	asm volatile(
+		"cpuid;"
+		: "=a" (*eax),
+		  "=b" (*ebx),
+		  "=c" (*ecx),
+		  "=d" (*edx)
+		: "0" (*eax), "2" (*ecx));
+}
+
+/* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx) */
+#define X86_FEATURE_PKU        (1<<3) /* Protection Keys for Userspace */
+#define X86_FEATURE_OSPKE      (1<<4) /* OS Protection Keys Enable */
+
+static inline int cpu_has_pku(void)
+{
+	unsigned int eax;
+	unsigned int ebx;
+	unsigned int ecx;
+	unsigned int edx;
+	eax = 0x7;
+	ecx = 0x0;
+	__cpuid(&eax, &ebx, &ecx, &edx);
+
+	if (!(ecx & X86_FEATURE_PKU)) {
+		dprintf2("cpu does not have PKU\n");
+		return 0;
+	}
+	if (!(ecx & X86_FEATURE_OSPKE)) {
+		dprintf2("cpu does not have OSPKE\n");
+		return 0;
+	}
+	return 1;
+}
+
+#define XSTATE_PKRU_BIT	(9)
+#define XSTATE_PKRU	0x200
+
+int pkru_xstate_offset(void)
+{
+	unsigned int eax;
+	unsigned int ebx;
+	unsigned int ecx;
+	unsigned int edx;
+	int xstate_offset;
+	int xstate_size;
+	unsigned long XSTATE_CPUID = 0xd;
+	int leaf;
+
+	// assume that XSTATE_PKRU is set in XCR0
+	leaf = XSTATE_PKRU_BIT;
+	{
+		eax = XSTATE_CPUID;
+		// 0x2 !??! from setup_xstate_features() in the kernel
+		ecx = leaf;
+		__cpuid(&eax, &ebx, &ecx, &edx);
+
+		//printf("leaf[%d] offset: %d size: %d\n", leaf, ebx, eax);
+		if (leaf == XSTATE_PKRU_BIT) {
+			xstate_offset = ebx;
+			xstate_size = eax;
+		}
+	}
+
+	if (xstate_size== 0) {
+		printf("could not find size/offset of PKRU in xsave state\n");
+		return 0;
+	}
+
+	return xstate_offset;
+}
+
+#endif /* _PKEYS_HELPER_H */
diff -puN /dev/null tools/testing/selftests/x86/protection_keys.c
--- /dev/null	2016-03-01 16:49:31.662341041 -0800
+++ b/tools/testing/selftests/x86/protection_keys.c	2016-03-09 13:55:34.883119415 -0800
@@ -0,0 +1,1199 @@
+/*
+ * Tests x86 Memory Protection Keys (see Documentation/x86/protection-keys.txt)
+ *
+ * There are examples in here of:
+ *  * how to set protection keys on memory
+ *  * how to set/clear bits in PKRU (the rights register)
+ *  * how to handle SEGV_PKRU signals and extract pkey-relevant
+ *    information from the siginfo
+ *
+ * Things to add:
+ *	make sure KSM and KSM COW breaking works
+ *	prefault pages in at malloc, or not
+ *	protect MPX bounds tables with protection keys?
+ *	make sure VMA splitting/merging is working correctly
+ *	OOMs can destroy mm->mmap (see exit_mmap()), so make sure it is immune to pkeys
+ *	look for pkey "leaks" where it is still set on a VMA but "freed" back to the kernel
+ *	do a plain mprotect() to a mprotect_pkey() area and make sure the pkey sticks
+ *
+ * Compile like this:
+ * 	gcc      -o protection_keys    -O2 -g -std=gnu99 -pthread -Wall protection_keys.c -lrt -ldl -lm
+ *	gcc -m32 -o protection_keys_32 -O2 -g -std=gnu99 -pthread -Wall protection_keys.c -lrt -ldl -lm
+ */
+#define _GNU_SOURCE
+#include <errno.h>
+#include <linux/futex.h>
+#include <sys/time.h>
+#include <sys/syscall.h>
+#include <string.h>
+#include <stdio.h>
+#include <stdint.h>
+#include <stdbool.h>
+#include <signal.h>
+#include <assert.h>
+#include <stdlib.h>
+#include <ucontext.h>
+#include <sys/mman.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <sys/ptrace.h>
+
+#include "pkey-helpers.h"
+
+int iteration_nr = 1;
+int test_nr;
+
+unsigned int shadow_pkru;
+
+#define HPAGE_SIZE	(1UL<<21)
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
+#define ALIGN(x, align_to)    (((x) + ((align_to)-1)) & ~((align_to)-1))
+#define ALIGN_PTR(p, ptr_align_to)    ((typeof(p))ALIGN((unsigned long)(p), ptr_align_to))
+
+extern void abort_hooks(void);
+#define pkey_assert(condition) do {		\
+	if (!(condition)) {			\
+		printf("assert() at %s::%d test_nr: %d iteration: %d\n", \
+				__FILE__, __LINE__,	\
+				test_nr, iteration_nr);	\
+		perror("errno at assert");	\
+		abort_hooks();			\
+		assert(condition);		\
+	}					\
+} while (0)
+#define raw_assert(cond) assert(cond)
+
+void cat_into_file(char *str, char *file)
+{
+	int fd = open(file, O_RDWR);
+	int ret;
+	/*
+	 * these need to be raw because they are called under
+	 * pkey_assert()
+	 */
+	raw_assert(fd >= 0);
+	ret = write(fd, str, strlen(str));
+	if (ret != strlen(str)) {
+		perror("write to file failed");
+		fprintf(stderr, "filename: '%s' str: '%s'\n", file, str);
+		raw_assert(0);
+	}
+	close(fd);
+}
+
+void tracing_on(void)
+{
+#ifdef CONTROL_TRACING
+	char pidstr[32];
+	sprintf(pidstr, "%d", getpid());
+	//cat_into_file("20000", "/sys/kernel/debug/tracing/buffer_size_kb");
+	cat_into_file("0", "/sys/kernel/debug/tracing/tracing_on");
+	cat_into_file("\n", "/sys/kernel/debug/tracing/trace");
+	if (1) {
+		cat_into_file("function_graph", "/sys/kernel/debug/tracing/current_tracer");
+		cat_into_file("1", "/sys/kernel/debug/tracing/options/funcgraph-proc");
+	} else {
+		cat_into_file("nop", "/sys/kernel/debug/tracing/current_tracer");
+	}
+	cat_into_file(pidstr, "/sys/kernel/debug/tracing/set_ftrace_pid");
+	cat_into_file("1", "/sys/kernel/debug/tracing/tracing_on");
+	dprintf1("enabled tracing\n");
+#endif
+}
+
+void tracing_off(void)
+{
+#ifdef CONTROL_TRACING
+	cat_into_file("0", "/sys/kernel/debug/tracing/tracing_on");
+#endif
+}
+
+void abort_hooks(void)
+{
+	fprintf(stderr, "running %s()...\n", __func__);
+	tracing_off();
+#ifdef SLEEP_ON_ABORT
+	sleep(SLEEP_ON_ABORT);
+#endif
+}
+
+void lots_o_noops(void)
+{
+	dprintf1("running %s()\n", __func__);
+	asm(".rept 65536 ; nopl 0x7eeeeeee(%eax) ; .endr");
+	dprintf1("%s() done\n", __func__);
+}
+
+// I'm addicted to the kernel types
+#define  u8 uint8_t
+#define u16 uint16_t
+#define u32 uint32_t
+#define u64 uint64_t
+
+#ifdef __i386__
+#define SYS_mprotect_key 378
+#define SYS_pkey_alloc	 379
+#define SYS_pkey_free	 380
+#define SYS_pkey_get	 381
+#define SYS_pkey_set	 382
+#define REG_IP_IDX REG_EIP
+#define si_pkey_offset 0x18
+#else
+#define SYS_mprotect_key 327
+#define SYS_pkey_alloc	 328
+#define SYS_pkey_free	 329
+#define SYS_pkey_get	 330
+#define SYS_pkey_set	 331
+#define REG_IP_IDX REG_RIP
+#define si_pkey_offset 0x20
+#endif
+
+void dump_mem(void *dumpme, int len_bytes)
+{
+	char *c = (void *)dumpme;
+	int i;
+	for (i = 0; i < len_bytes; i+= sizeof(u64)) {
+		u64 *ptr = (u64 *)(c + i);
+		dprintf1("dump[%03d][@%p]: %016jx\n", i, ptr, *ptr);
+	}
+}
+
+#define __SI_FAULT      (3 << 16)
+#define SEGV_BNDERR     (__SI_FAULT|3)  /* failed address bound checks */
+#define SEGV_PKUERR     (__SI_FAULT|4)
+
+static char *si_code_str(int si_code)
+{
+	if (si_code & SEGV_MAPERR)
+		return "SEGV_MAPERR";
+	if (si_code & SEGV_ACCERR)
+		return "SEGV_ACCERR";
+	if (si_code & SEGV_BNDERR)
+		return "SEGV_BNDERR";
+	if (si_code & SEGV_PKUERR)
+		return "SEGV_PKUERR";
+	return "UNKNOWN";
+}
+
+int pkru_faults = 0;
+int last_si_pkey = -1;
+void signal_handler(int signum, siginfo_t* si, void* vucontext)
+{
+	ucontext_t* uctxt = vucontext;
+	int trapno;
+	unsigned long ip;
+	char *fpregs;
+	u32 *pkru_ptr;
+	u64 si_pkey;
+	u32* si_pkey_ptr;
+	int pkru_offset;
+
+	dprintf1(">>>>===============SIGSEGV============================\n");
+	dprintf1("%s()::%d, pkru: 0x%x shadow: %x\n", __func__, __LINE__, __rdpkru(), shadow_pkru);
+
+	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
+	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
+	fpregset_t fpregset = uctxt->uc_mcontext.fpregs;
+	fpregs = (void *)fpregset;
+
+	dprintf2("%s() trapno: %d ip: 0x%lx info->si_code: %s/%d\n", __func__, trapno, ip,
+			si_code_str(si->si_code), si->si_code);
+#ifdef __i386__
+	/*
+	 * 32-bit has some extra padding so that userspace can tell whether
+	 * the XSTATE header is present in addition to the "legacy" FPU
+	 * state.  We just assume that it is here.
+	 */
+	fpregs += 0x70;
+#endif
+	pkru_offset = pkru_xstate_offset();
+	pkru_ptr = (void *)(&fpregs[pkru_offset]);
+
+	dprintf1("siginfo: %p\n", si);
+	dprintf1(" fpregs: %p\n", fpregs);
+	/*
+	 * If we got a PKRU fault, we *HAVE* to have at least one bit set in
+	 * here.
+	 */
+	dprintf1("pkru_xstate_offset: %d\n", pkru_xstate_offset());
+	//dump_mem(pkru_ptr - 128, 256);
+	pkey_assert(*pkru_ptr);
+
+	si_pkey_ptr = (u32 *)(((u8 *)si) + si_pkey_offset);
+	dprintf1("si_pkey_ptr: %p\n", si_pkey_ptr);
+	dump_mem(si_pkey_ptr - 8, 24);
+	si_pkey = *si_pkey_ptr;
+	pkey_assert(si_pkey < NR_PKEYS);
+	last_si_pkey = si_pkey;
+
+	if ((si->si_code == SEGV_MAPERR) ||
+	    (si->si_code == SEGV_ACCERR) ||
+	    (si->si_code == SEGV_BNDERR)) {
+		printf("non-PK si_code, exiting...\n");
+		exit(4);
+	}
+
+	//printf("pkru_xstate_offset(): %d\n", pkru_xstate_offset());
+	dprintf1("signal pkru from xsave: %08x\n", *pkru_ptr);
+	// need __ version so we do not do shadow_pkru checking
+	dprintf1("signal pkru from  pkru: %08x\n", __rdpkru());
+	dprintf1("si_pkey from siginfo: %jx\n", si_pkey);
+	*(u64 *)pkru_ptr = 0x00000000;
+	dprintf1("WARNING: set PRKU=0 to allow faulting instruction to continue\n");
+	pkru_faults++;
+	dprintf1("<<<<==================================================\n");
+	return;
+	if (trapno == 14) {
+		fprintf(stderr,
+			"ERROR: In signal handler, page fault, trapno = %d, ip = %016lx\n",
+			trapno, ip);
+		fprintf(stderr, "si_addr %p\n", si->si_addr);
+		fprintf(stderr, "REG_ERR: %lx\n", (unsigned long)uctxt->uc_mcontext.gregs[REG_ERR]);
+		//sleep(999);
+		exit(1);
+	} else {
+		fprintf(stderr,"unexpected trap %d! at 0x%lx\n", trapno, ip);
+		fprintf(stderr, "si_addr %p\n", si->si_addr);
+		fprintf(stderr, "REG_ERR: %lx\n", (unsigned long)uctxt->uc_mcontext.gregs[REG_ERR]);
+		exit(2);
+	}
+}
+
+int wait_all_children()
+{
+        int status;
+        return waitpid(-1, &status, 0);
+}
+
+void sig_chld(int x)
+{
+        dprintf2("[%d] SIGCHLD: %d\n", getpid(), x);
+}
+
+void setup_sigsegv_handler()
+{
+	int r,rs;
+	struct sigaction newact;
+	struct sigaction oldact;
+
+	/* #PF is mapped to sigsegv */
+	int signum  = SIGSEGV;
+
+	newact.sa_handler = 0;   /* void(*)(int)*/
+	newact.sa_sigaction = signal_handler; /* void (*)(int, siginfo_t*, void*) */
+
+	/*sigset_t - signals to block while in the handler */
+	/* get the old signal mask. */
+	rs = sigprocmask(SIG_SETMASK, 0, &newact.sa_mask);
+	pkey_assert(rs == 0);
+
+	/* call sa_sigaction, not sa_handler*/
+	newact.sa_flags = SA_SIGINFO;
+
+	newact.sa_restorer = 0;  /* void(*)(), obsolete */
+	r = sigaction(signum, &newact, &oldact);
+	r = sigaction(SIGALRM, &newact, &oldact);
+	pkey_assert(r == 0);
+}
+
+void setup_handlers(void)
+{
+	signal(SIGCHLD, &sig_chld);
+	setup_sigsegv_handler();
+}
+
+pid_t fork_lazy_child(void)
+{
+	pid_t forkret;
+
+	forkret = fork();
+	pkey_assert(forkret >= 0);
+	dprintf3("[%d] fork() ret: %d\n", getpid(), forkret);
+
+	if (!forkret) {
+		/* in the child */
+		while (1) {
+			dprintf1("child sleeping...\n");
+			sleep(30);
+		}
+	}
+	return forkret;
+}
+
+void davecmp(void *_a, void *_b, int len)
+{
+	int i;
+	unsigned long *a = _a;
+	unsigned long *b = _b;
+	for (i = 0; i < len / sizeof(*a); i++) {
+		if (a[i] == b[i])
+			continue;
+
+		dprintf3("[%3d]: a: %016lx b: %016lx\n", i, a[i], b[i]);
+	}
+}
+
+void dumpit(char *f)
+{
+	int fd = open(f, O_RDONLY);
+	char buf[100];
+	int nr_read;
+
+	dprintf2("maps fd: %d\n", fd);
+	do {
+		nr_read = read(fd, &buf[0], sizeof(buf));
+		write(1, buf, nr_read);
+	} while (nr_read > 0);
+	close(fd);
+}
+
+#define PKEY_DISABLE_ACCESS    0x1
+#define PKEY_DISABLE_WRITE     0x2
+
+int sys_pkey_get(int pkey, unsigned long flags)
+{
+	int ret = syscall(SYS_pkey_get, pkey);
+	dprintf1("%s(pkey=%d, flags=%lx) = %x / %d\n", __func__, pkey, flags, ret, ret);
+	return ret;
+}
+
+int sys_pkey_set(int pkey, unsigned long rights, unsigned long flags)
+{
+	int ret = syscall(SYS_pkey_set, pkey, rights, flags);
+	dprintf3("%s(pkey=%d, rights=%lx, flags=%lx) = %x pkru now: %x\n", __func__,
+			pkey, rights, flags, ret, __rdpkru());
+	return ret;
+}
+
+void pkey_disable_set(int pkey, int flags)
+{
+	unsigned long syscall_flags = 0;
+	int ret;
+	int pkey_rights = sys_pkey_get(pkey, syscall_flags);
+	u32 orig_pkru = rdpkru();
+
+	pkey_assert(flags & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
+
+	dprintf1("%s(%d) sys_pkey_get(%d): %x\n", __func__, pkey, pkey, pkey_rights);
+	pkey_assert(pkey_rights >= 0) ;
+
+	pkey_rights |= flags;
+
+	ret = sys_pkey_set(pkey, pkey_rights, syscall_flags);
+	/*pkru and flags have the same format */
+	shadow_pkru |= flags << (pkey * 2);
+	dprintf1("%s(%d) shadow: 0x%x\n", __func__, pkey, shadow_pkru);
+
+	pkey_assert(ret >= 0);
+
+	pkey_rights = sys_pkey_get(pkey, syscall_flags);
+	dprintf1("%s(%d) sys_pkey_get(%d): %x\n", __func__, pkey, pkey, pkey_rights);
+
+	dprintf1("%s(%d) pkru: 0x%x\n", __func__, pkey, rdpkru());
+	if (flags)
+		pkey_assert(rdpkru() > orig_pkru);
+}
+
+void pkey_disable_clear(int pkey, int flags)
+{
+	unsigned long syscall_flags = 0;
+	int ret;
+	int pkey_rights = sys_pkey_get(pkey, syscall_flags);
+	u32 orig_pkru = rdpkru();
+
+	pkey_assert(flags & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
+
+	dprintf1("%s(%d) sys_pkey_get(%d): %x\n", __func__, pkey, pkey, pkey_rights);
+	pkey_assert(pkey_rights >= 0) ;
+
+	pkey_rights |= flags;
+
+	ret = syscall(SYS_pkey_set, pkey, pkey_rights);
+	/* pkru and flags have the same format */
+	shadow_pkru &= ~(flags << (pkey * 2));
+	pkey_assert(ret >= 0);
+
+	pkey_rights = sys_pkey_get(pkey, syscall_flags);
+	dprintf1("%s(%d) sys_pkey_get(%d): %x\n", __func__, pkey, pkey, pkey_rights);
+
+	dprintf1("%s(%d) pkru: 0x%x\n", __func__, pkey, rdpkru());
+	if (flags)
+		assert(rdpkru() > orig_pkru);
+}
+
+void pkey_write_allow(int pkey)
+{
+	pkey_disable_clear(pkey, PKEY_DISABLE_WRITE);
+}
+void pkey_write_deny(int pkey)
+{
+	pkey_disable_set(pkey, PKEY_DISABLE_WRITE);
+}
+void pkey_access_allow(int pkey)
+{
+	pkey_disable_clear(pkey, PKEY_DISABLE_ACCESS);
+}
+void pkey_access_deny(int pkey)
+{
+	pkey_disable_set(pkey, PKEY_DISABLE_ACCESS);
+}
+
+int sys_mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot, unsigned long pkey)
+{
+	int sret;
+
+	dprintf2("%s(0x%p, %zx, prot=%lx, pkey=%lx)\n", __func__,
+			ptr, size, orig_prot, pkey);
+
+	errno = 0;
+	sret = syscall(SYS_mprotect_key, ptr, size, orig_prot, pkey);
+	if (errno) {
+		dprintf2("SYS_mprotect_key sret: %d\n", sret);
+		dprintf2("SYS_mprotect_key prot: 0x%lx\n", orig_prot);
+		dprintf2("SYS_mprotect_key failed, errno: %d\n", errno);
+		if (DEBUG_LEVEL >= 2)
+			perror("SYS_mprotect_pkey");
+	}
+	return sret;
+}
+
+int sys_pkey_alloc(unsigned long flags, unsigned long init_val)
+{
+	int ret = syscall(SYS_pkey_alloc, flags, init_val);
+	dprintf1("%s(flags=%lx, init_val=%lx) syscall ret: %d errno: %d\n", __func__,
+			flags, init_val, ret, errno);
+	return ret;
+}
+
+int alloc_pkey(void)
+{
+	int ret;
+	unsigned long init_val = 0x0;
+
+	dprintf1("alloc_pkey()::%d, pkru: 0x%x shadow: %x\n", __LINE__, __rdpkru(), shadow_pkru);
+	ret = sys_pkey_alloc(0, init_val);
+	/*
+	 * pkey_alloc() sets PKRU, so we need to reflect it in
+	 * shadow_pkru:
+	 */
+	if (ret) {
+		// clear both the bits:
+		shadow_pkru &= ~(0x3      << (ret * 2));
+		// move the new state in from init_val
+		// (remember, we cheated and init_val == pkru format)
+		shadow_pkru |=  (init_val << (ret * 2));
+	}
+	dprintf1("alloc_pkey()::%d, pkru: 0x%x shadow: %x\n", __LINE__, __rdpkru(), shadow_pkru);
+	dprintf1("alloc_pkey()::%d errno: %d\n", __LINE__, errno);
+	rdpkru(); // for shadow checking
+	return ret;
+}
+
+int sys_pkey_free(unsigned long pkey)
+{
+	int ret = syscall(SYS_pkey_free, pkey);
+	dprintf1("%s(pkey=%ld) syscall ret: %d\n", __func__, pkey, ret);
+	return ret;
+}
+
+/*
+ * I had a bug where pkey bits could be set by mprotect() but
+ * not cleared.  This ensures we get lots of random bit sets
+ * and clears on the vma and pte pkey bits.
+ */
+int alloc_random_pkey(void)
+{
+	int max_nr_pkey_allocs;
+	int ret;
+	int i;
+	int alloced_pkeys[NR_PKEYS];
+	int nr_alloced = 0;
+	int random_index;
+	memset(alloced_pkeys, 0, sizeof(alloced_pkeys));
+
+	/* allocate every possible key and make a note of which ones we got */
+	max_nr_pkey_allocs = NR_PKEYS;
+	max_nr_pkey_allocs = 1;
+	for (i = 0; i < max_nr_pkey_allocs; i++) {
+		int new_pkey = alloc_pkey();
+		if (new_pkey < 0)
+			break;
+		alloced_pkeys[nr_alloced++] = new_pkey;
+	}
+
+	pkey_assert(nr_alloced > 0);
+	/* select a random one out of the allocated ones */
+	random_index = rand() % nr_alloced;
+	ret = alloced_pkeys[random_index];
+	/* now zero it out so we don't free it next */
+	alloced_pkeys[random_index] = 0;
+
+	/* go through the allocated ones that we did not want and free them */
+	for (i = 0; i < nr_alloced; i++) {
+		int free_ret;
+		if (!alloced_pkeys[i])
+			continue;
+		free_ret = sys_pkey_free(alloced_pkeys[i]);
+		pkey_assert(!free_ret);
+	}
+	return ret;
+}
+
+int mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot, unsigned long pkey)
+{
+	int nr_iterations = 0; // random() % 100;
+	int ret;
+
+	while (0) {
+		int rpkey = alloc_random_pkey();
+		ret = sys_mprotect_pkey(ptr, size, orig_prot, pkey);
+		dprintf1("sys_mprotect_pkey(%p, %zx, prot=0x%lx, pkey=%ld) ret: %d\n",
+				ptr, size, orig_prot, pkey, ret);
+		if (nr_iterations-- < 0)
+			break;
+
+		sys_pkey_free(rpkey);
+	}
+	pkey_assert(pkey < NR_PKEYS);
+
+	ret = sys_mprotect_pkey(ptr, size, orig_prot, pkey);
+	dprintf1("mprotect_pkey(%p, %zx, prot=0x%lx, pkey=%ld) ret: %d\n", ptr, size, orig_prot, pkey, ret);
+	pkey_assert(!ret);
+	return ret;
+}
+
+struct pkey_malloc_record {
+	void *ptr;
+	long size;
+};
+struct pkey_malloc_record *pkey_malloc_records;
+long nr_pkey_malloc_records;
+void record_pkey_malloc(void *ptr, long size)
+{
+	long i;
+	struct pkey_malloc_record *rec = NULL;
+
+	for (i = 0; i < nr_pkey_malloc_records; i++) {
+		rec = &pkey_malloc_records[i];
+		// find a free record
+		if (rec)
+			break;
+	}
+	if (!rec) {
+		// every record is full
+		size_t old_nr_records = nr_pkey_malloc_records;
+		size_t new_nr_records = (nr_pkey_malloc_records * 2 + 1);
+		size_t new_size = new_nr_records * sizeof(struct pkey_malloc_record);
+		dprintf2("new_nr_records: %zd\n", new_nr_records);
+		dprintf2("new_size: %zd\n", new_size);
+		pkey_malloc_records = realloc(pkey_malloc_records, new_size);
+		pkey_assert(pkey_malloc_records != NULL);
+		rec = &pkey_malloc_records[nr_pkey_malloc_records];
+		// realloc() does not initalize memory, so zero it from
+		// the first new record all the way to the end.
+		for (i = 0; i < new_nr_records - old_nr_records; i++)
+			memset(rec + i, 0, sizeof(*rec));
+	}
+	dprintf3("filling malloc record[%d/%p]: {%p, %ld}\n",
+		(int)(rec - pkey_malloc_records), rec, ptr, size);
+	rec->ptr = ptr;
+	rec->size = size;
+	nr_pkey_malloc_records++;
+}
+
+void free_pkey_malloc(void *ptr)
+{
+	long i;
+	int ret;
+	dprintf3("%s(%p)\n", __func__, ptr);
+	for (i = 0; i < nr_pkey_malloc_records; i++) {
+		struct pkey_malloc_record *rec = &pkey_malloc_records[i];
+		dprintf4("looking for ptr %p at record[%ld/%p]: {%p, %ld}\n",
+				ptr, i, rec, rec->ptr, rec->size);
+		if ((ptr <  rec->ptr) ||
+		    (ptr >= rec->ptr + rec->size))
+			continue;
+
+		dprintf3("found ptr %p at record[%ld/%p]: {%p, %ld}\n",
+				ptr, i, rec, rec->ptr, rec->size);
+		nr_pkey_malloc_records--;
+		ret = munmap(rec->ptr, rec->size);
+		dprintf3("munmap ret: %d\n", ret);
+		pkey_assert(!ret);
+		dprintf3("clearing rec->ptr, rec: %p\n", rec);
+		rec->ptr = NULL;
+		dprintf3("done clearing rec->ptr, rec: %p\n", rec);
+		return;
+	}
+	pkey_assert(false);
+}
+
+
+void *malloc_pkey_with_mprotect(long size, int prot, u16 pkey)
+{
+	void *ptr;
+	int ret;
+
+	rdpkru();
+	dprintf1("doing %s(size=%ld, prot=0x%x, pkey=%d)\n", __func__, size, prot, pkey);
+	pkey_assert(pkey < NR_PKEYS);
+	ptr = mmap(NULL, size, prot, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+	pkey_assert(ptr != (void *)-1);
+	ret = mprotect_pkey((void *)ptr, PAGE_SIZE, prot, pkey);
+	pkey_assert(!ret);
+	record_pkey_malloc(ptr, size);
+	rdpkru();
+
+	dprintf1("%s() for pkey %d @ %p\n", __func__, pkey, ptr);
+	return ptr;
+}
+
+void *malloc_pkey_anon_huge(long size, int prot, u16 pkey)
+{
+	int ret;
+	void *ptr;
+
+	dprintf1("doing %s(size=%ld, prot=0x%x, pkey=%d)\n", __func__, size, prot, pkey);
+	// Guarantee we can fit at least one huge page in the resulting
+	// allocation by allocating space for 2:
+	size = ALIGN(size, HPAGE_SIZE * 2);
+	ptr = mmap(NULL, size, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+	pkey_assert(ptr != (void *)-1);
+	record_pkey_malloc(ptr, size);
+	mprotect_pkey(ptr, size, prot, pkey);
+
+	dprintf1("unaligned ptr: %p\n", ptr);
+	ptr = ALIGN_PTR(ptr, HPAGE_SIZE);
+	dprintf1("  aligned ptr: %p\n", ptr);
+	ret = madvise(ptr, HPAGE_SIZE, MADV_HUGEPAGE);
+	dprintf1("MADV_HUGEPAGE ret: %d\n", ret);
+	ret = madvise(ptr, HPAGE_SIZE, MADV_WILLNEED);
+	dprintf1("MADV_WILLNEED ret: %d\n", ret);
+	memset(ptr, 0, HPAGE_SIZE);
+
+	dprintf1("mmap()'d thp for pkey %d @ %p\n", pkey, ptr);
+	return ptr;
+}
+
+void *malloc_pkey_hugetlb(long size, int prot, u16 pkey)
+{
+	void *ptr;
+	int flags = MAP_ANONYMOUS|MAP_PRIVATE|MAP_HUGETLB;
+
+	dprintf1("doing %s(%ld, %x, %x)\n", __func__, size, prot, pkey);
+	size = ALIGN(size, HPAGE_SIZE * 2);
+	pkey_assert(pkey < NR_PKEYS);
+	ptr = mmap(NULL, size, PROT_NONE, flags, -1, 0);
+	pkey_assert(ptr != (void *)-1);
+	mprotect_pkey(ptr, size, prot, pkey);
+
+	record_pkey_malloc(ptr, size);
+
+	dprintf1("mmap()'d hugetlbfs for pkey %d @ %p\n", pkey, ptr);
+	return ptr;
+}
+
+void *malloc_pkey_mmap_dax(long size, int prot, u16 pkey)
+{
+	void *ptr;
+	int fd;
+
+	dprintf1("doing %s(size=%ld, prot=0x%x, pkey=%d)\n", __func__, size, prot, pkey);
+	pkey_assert(pkey < NR_PKEYS);
+	fd = open("/dax/foo", O_RDWR);
+	pkey_assert(fd >= 0);
+
+	ptr = mmap(0, size, prot, MAP_SHARED, fd, 0);
+	pkey_assert(ptr != (void *)-1);
+
+	mprotect_pkey(ptr, size, prot, pkey);
+
+	record_pkey_malloc(ptr, size);
+
+	dprintf1("mmap()'d for pkey %d @ %p\n", pkey, ptr);
+	close(fd);
+	return ptr;
+}
+
+//void *malloc_pkey_with_mprotect(long size, int prot, u16 pkey)
+void *(*pkey_malloc[])(long size, int prot, u16 pkey) = {
+
+	malloc_pkey_with_mprotect,
+	malloc_pkey_anon_huge,
+	malloc_pkey_hugetlb,
+// can not do direct with the mprotect_pkey() API
+//	malloc_pkey_mmap_direct,
+//	malloc_pkey_mmap_dax,
+};
+
+void *malloc_pkey(long size, int prot, u16 pkey)
+{
+	void *ret;
+	static int malloc_type = 0;
+	int nr_malloc_types = ARRAY_SIZE(pkey_malloc);
+
+	pkey_assert(pkey < NR_PKEYS);
+	pkey_assert(malloc_type < nr_malloc_types);
+	ret = pkey_malloc[malloc_type](size, prot, pkey);
+	pkey_assert(ret != (void *)-1);
+	malloc_type++;
+	if (malloc_type >= nr_malloc_types)
+		malloc_type = (random()%nr_malloc_types);
+
+	dprintf3("%s(%ld, prot=%x, pkey=%x) returning: %p\n", __func__, size, prot, pkey, ret);
+	return ret;
+}
+
+int last_pkru_faults = 0;
+void expected_pk_fault(int pkey)
+{
+	dprintf2("%s(): last_pkru_faults: %d pkru_faults: %d\n",
+			__func__, last_pkru_faults, pkru_faults);
+	dprintf2("%s(%d): last_si_pkey: %d\n", __func__, pkey, last_si_pkey);
+	pkey_assert(last_pkru_faults + 1 == pkru_faults);
+	pkey_assert(last_si_pkey == pkey);
+	/*
+	 * The signal handler shold have cleared out PKRU to let the
+	 * test program continue.  We now have to restore it.
+	 */
+	if (__rdpkru() != 0) {
+		pkey_assert(0);
+	}
+	__wrpkru(shadow_pkru);
+	dprintf1("%s() set PKRU=%x to restore state after signal nuked it\n",
+			__func__, shadow_pkru);
+	last_pkru_faults = pkru_faults;
+	last_si_pkey = -1;
+}
+
+void do_not_expect_pk_fault(void)
+{
+	pkey_assert(last_pkru_faults == pkru_faults);
+}
+
+int test_fds[10] = { -1 };
+int nr_test_fds;
+void __save_test_fd(int fd)
+{
+	pkey_assert(fd >= 0);
+	pkey_assert(nr_test_fds < ARRAY_SIZE(test_fds));
+	test_fds[nr_test_fds] = fd;
+	nr_test_fds++;
+}
+
+int get_test_read_fd(void)
+{
+	int test_fd = open("/etc/passwd", O_RDONLY);
+	__save_test_fd(test_fd);
+	return test_fd;
+}
+
+void close_test_fds(void)
+{
+	int i;
+
+	for (i = 0; i < nr_test_fds; i++) {
+		if (test_fds[i] < 0)
+			continue;
+		close(test_fds[i]);
+		test_fds[i] = -1;
+	}
+	nr_test_fds = 0;
+}
+
+#define barrier() __asm__ __volatile__("": : :"memory")
+__attribute__((noinline)) int read_ptr(int *ptr)
+{
+	/*
+	 * Keep GCC from optimizing this away somehow
+	 */
+	barrier();
+	return *ptr;
+}
+
+void test_read_of_write_disabled_region(int *ptr, u16 pkey)
+{
+	int ptr_contents;
+	dprintf1("disabling write access to PKEY[1], doing read\n");
+	pkey_write_deny(pkey);
+	ptr_contents = read_ptr(ptr);
+	dprintf1("*ptr: %d\n", ptr_contents);
+	dprintf1("\n");
+}
+void test_read_of_access_disabled_region(int *ptr, u16 pkey)
+{
+	int ptr_contents;
+	rdpkru();
+	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n", pkey, ptr);
+	pkey_access_deny(pkey);
+	ptr_contents = read_ptr(ptr);
+	dprintf1("*ptr: %d\n", ptr_contents);
+	expected_pk_fault(pkey);
+}
+void test_write_of_write_disabled_region(int *ptr, u16 pkey)
+{
+	dprintf1("disabling write access to PKEY[%02d], doing write\n", pkey);
+	pkey_write_deny(pkey);
+	*ptr = __LINE__;
+	expected_pk_fault(pkey);
+}
+void test_write_of_access_disabled_region(int *ptr, u16 pkey)
+{
+	dprintf1("disabling access to PKEY[%02d], doing write\n", pkey);
+	pkey_access_deny(pkey);
+	*ptr = __LINE__;
+	expected_pk_fault(pkey);
+}
+void test_kernel_write_of_access_disabled_region(int *ptr, u16 pkey)
+{
+	int ret;
+	int test_fd = get_test_read_fd();
+
+	dprintf1("disabling access to PKEY[%02d], having kernel read() to buffer\n", pkey);
+	pkey_access_deny(pkey);
+	ret = read(test_fd, ptr, 1);
+	dprintf1("read ret: %d\n", ret);
+	pkey_assert(ret);
+}
+void test_kernel_write_of_write_disabled_region(int *ptr, u16 pkey)
+{
+	int ret;
+	int test_fd = get_test_read_fd();
+
+	pkey_write_deny(pkey);
+	ret = read(test_fd, ptr, 100);
+	dprintf1("read ret: %d\n", ret);
+	if (ret < 0 && (DEBUG_LEVEL > 0))
+		perror("read");
+	pkey_assert(ret);
+}
+
+void test_kernel_gup_of_access_disabled_region(int *ptr, u16 pkey)
+{
+	int pipe_ret, vmsplice_ret;
+	struct iovec iov;
+	int pipe_fds[2];
+
+	pipe_ret = pipe(pipe_fds);
+
+	pkey_assert(pipe_ret == 0);
+	dprintf1("disabling access to PKEY[%02d], having kernel vmsplice from buffer\n", pkey);
+	pkey_access_deny(pkey);
+	iov.iov_base = ptr;
+	iov.iov_len = PAGE_SIZE;
+	vmsplice_ret = vmsplice(pipe_fds[1], &iov, 1, SPLICE_F_GIFT);
+	dprintf1("vmsplice() ret: %d\n", vmsplice_ret);
+	pkey_assert(vmsplice_ret == -1);
+
+	close(pipe_fds[0]);
+	close(pipe_fds[1]);
+}
+
+void test_kernel_gup_write_to_write_disabled_region(int *ptr, u16 pkey)
+{
+	int ignored = 0xdada;
+	int futex_ret;
+	int some_int = __LINE__;
+
+	dprintf1("disabling write to PKEY[%02d], doing futex gunk in buffer\n", pkey);
+	*ptr = some_int;
+	pkey_write_deny(pkey);
+	futex_ret = syscall(SYS_futex, ptr, FUTEX_WAIT, some_int-1, NULL, &ignored, ignored);
+	if (DEBUG_LEVEL > 0)
+		perror("futex");
+	dprintf1("futex() ret: %d\n", futex_ret);
+	//pkey_assert(vmsplice_ret == -1);
+}
+
+/* Assumes that all pkeys other than 'pkey' are unallocated */
+void test_pkey_syscalls_on_non_allocated_pkey(int *ptr, u16 pkey)
+{
+	int err;
+	int i;
+
+	/* Note: 0 is the default pkey, so don't mess with it */
+	for (i = 1; i < NR_PKEYS; i++) {
+		if (pkey == i)
+			continue;
+
+		dprintf1("trying get/set/free to non-allocated pkey: %2d\n", i);
+		err = sys_pkey_free(i);
+		pkey_assert(err);
+
+		err = sys_pkey_get(i, 0);
+		pkey_assert(err < 0);
+
+		err = sys_pkey_free(i);
+		pkey_assert(err);
+
+		err = sys_mprotect_pkey(ptr, PAGE_SIZE, PROT_READ, i);
+		pkey_assert(err);
+	}
+}
+
+/* Assumes that all pkeys other than 'pkey' are unallocated */
+void test_pkey_syscalls_bad_args(int *ptr, u16 pkey)
+{
+	int err;
+	int bad_flag = (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE) + 1;
+	int bad_pkey = NR_PKEYS+99;
+
+	err = sys_pkey_get(bad_pkey, bad_flag);
+	pkey_assert(err < 0);
+
+	/* pass a known-invalid pkey in: */
+	err = sys_mprotect_pkey(ptr, PAGE_SIZE, PROT_READ, bad_pkey);
+	pkey_assert(err);
+}
+
+/* Assumes that all pkeys other than 'pkey' are unallocated */
+void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
+{
+	unsigned long flags;
+	unsigned long init_val;
+	int err;
+	int allocated_pkeys[NR_PKEYS] = {0};
+	int nr_allocated_pkeys = 0;
+	int i;
+
+	for (i = 0; i < NR_PKEYS*2; i++) {
+		int new_pkey;
+		dprintf1("%s() alloc loop: %d\n", __func__, i);
+		flags = 0;
+		init_val = 0;
+		pkey_assert(!flags);
+		pkey_assert(!init_val);
+		new_pkey = sys_pkey_alloc(flags, init_val);
+		dprintf2("%s() errno: %d ENOSPC: %d\n", __func__, errno, ENOSPC);
+		if ((new_pkey == -1) && (errno == ENOSPC)) {
+			dprintf2("%s() failed to allocate pkey after %d tries with ENOSPC\n",
+				__func__, nr_allocated_pkeys);
+			break;
+		}
+		pkey_assert(nr_allocated_pkeys < NR_PKEYS);
+		allocated_pkeys[nr_allocated_pkeys++] = new_pkey;
+	}
+
+	dprintf1("%s()::%d\n", __func__, __LINE__);
+
+	/*
+	 * ensure it did not reach the end of the loop without
+	 * failure:
+	 * */
+	pkey_assert(i < NR_PKEYS*2);
+
+	/*
+	 * There are 16 pkeys suported in hardware.  One is taken
+	 * up for the default (0) and another can be taken up by
+	 * an execute-only mapping.  Ensure that we can allocate
+	 * at least 14 (16-2).
+	 */
+	pkey_assert(i >= NR_PKEYS-2);
+
+	for (i = 0; i < nr_allocated_pkeys; i++) {
+		err = sys_pkey_free(allocated_pkeys[i]);
+		pkey_assert(!err);
+	}
+}
+
+void test_ptrace_of_child(int *ptr, u16 pkey)
+{
+	__attribute__((__unused__)) int peek_result;
+	pid_t child_pid;
+	void *ignored = 0;
+	long ret;
+	int status;
+	/*
+	 * This is the "control" for our little expermient.  Make sure
+	 * we can always access it when ptracing.
+	 */
+	int *plain_ptr_unaligned = malloc(HPAGE_SIZE);
+	int *plain_ptr = ALIGN_PTR(plain_ptr_unaligned, PAGE_SIZE);
+
+	/*
+	 * Fork a child which is an exact copy of this process, of course.
+	 * That means we can do all of our tests via ptrace() and then plain
+	 * memory access and ensure they work differently.
+	 */
+	child_pid = fork_lazy_child();
+	dprintf1("[%d] child pid: %d\n", getpid(), child_pid);
+
+	ret = ptrace(PTRACE_ATTACH, child_pid, ignored, ignored);
+	if (ret)
+		perror("attach");
+	dprintf1("[%d] attach ret: %ld %d\n", getpid(), ret, __LINE__);
+	pkey_assert(ret != -1);
+	ret = waitpid(child_pid, &status, WUNTRACED);
+	if ((ret != child_pid) || !(WIFSTOPPED(status)) ) {
+		fprintf(stderr, "weird waitpid result %ld stat %x\n", ret, status);
+		pkey_assert(0);
+	}
+	dprintf2("waitpid ret: %ld\n", ret);
+	dprintf2("waitpid status: %d\n", status);
+
+	pkey_access_deny(pkey);
+	pkey_write_deny(pkey);
+
+	/* Write access, untested for now:
+	ret = ptrace(PTRACE_POKEDATA, child_pid, peek_at, data);
+	pkey_assert(ret != -1);
+	dprintf1("poke at %p: %ld\n", peek_at, ret);
+	*/
+
+	/*
+	 * Try to access the pkey-protected "ptr" via ptrace:
+	 */
+	ret = ptrace(PTRACE_PEEKDATA, child_pid, ptr, ignored);
+	/* expect it to work, without an error: */
+	pkey_assert(ret != -1);
+	/* Now access from the current task, and expect an exception: */
+	peek_result = read_ptr(ptr);
+	expected_pk_fault(pkey);
+
+	/*
+	 * Try to access the NON-pkey-protected "ptr" via ptrace:
+	 */
+	ret = ptrace(PTRACE_PEEKDATA, child_pid, plain_ptr, ignored);
+	/* expect it to work, without an error: */
+	pkey_assert(ret != -1);
+	/* Now access from the current task, and expect NO exception: */
+	peek_result = read_ptr(ptr);
+	do_not_expect_pk_fault();
+
+	ret = ptrace(PTRACE_DETACH, child_pid, ignored, 0);
+	pkey_assert(ret != -1);
+
+	ret = kill(child_pid, SIGKILL);
+	pkey_assert(ret != -1);
+
+	free(plain_ptr_unaligned);
+}
+
+void test_executing_on_unreadable_memory(int *ptr, u16 pkey)
+{
+	void *p1;
+	int ptr_contents;
+	int ret;
+
+	p1 = ALIGN_PTR(&lots_o_noops, PAGE_SIZE);
+
+	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
+	lots_o_noops();
+	ptr_contents = read_ptr(p1);
+	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
+
+	ret = mprotect_pkey(p1, PAGE_SIZE, PROT_EXEC, (u64)pkey);
+	pkey_assert(!ret);
+	pkey_access_deny(pkey);
+
+	dprintf2("pkru: %x\n", rdpkru());
+
+	/*
+	 * Make sure this is an *instruction* fault
+	 */
+	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
+	lots_o_noops();
+	do_not_expect_pk_fault();
+	ptr_contents = read_ptr(p1);
+	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
+	expected_pk_fault(pkey);
+}
+
+void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
+{
+	int size = PAGE_SIZE;
+	int sret;
+
+	if (cpu_has_pku()) {
+		dprintf1("SKIP: %s: no CPU support\n", __func__);
+		return;
+	}
+
+	sret = syscall(SYS_mprotect_key, ptr, size, PROT_READ, pkey);
+	pkey_assert(sret < 0);
+}
+
+void (*pkey_tests[])(int *ptr, u16 pkey) = {
+	test_read_of_write_disabled_region,
+	test_read_of_access_disabled_region,
+	test_write_of_write_disabled_region,
+	test_write_of_access_disabled_region,
+	test_kernel_write_of_access_disabled_region,
+	test_kernel_write_of_write_disabled_region,
+	test_kernel_gup_of_access_disabled_region,
+	test_kernel_gup_write_to_write_disabled_region,
+	test_executing_on_unreadable_memory,
+	test_ptrace_of_child,
+	test_pkey_syscalls_on_non_allocated_pkey,
+	test_pkey_syscalls_bad_args,
+	test_pkey_alloc_exhaust,
+};
+
+void run_tests_once(void)
+{
+	int *ptr;
+	int prot = PROT_READ|PROT_WRITE;
+
+	for (test_nr = 0; test_nr < ARRAY_SIZE(pkey_tests); test_nr++) {
+		int pkey;
+		int orig_pkru_faults = pkru_faults;
+
+		dprintf1("======================\n");
+		dprintf1("test %d starting...\n", test_nr);
+
+		tracing_on();
+		pkey = alloc_random_pkey();
+		dprintf1("test %d starting with pkey: %d\n", test_nr, pkey);
+		ptr = malloc_pkey(PAGE_SIZE, prot, pkey);
+		//dumpit("/proc/self/maps");
+		pkey_tests[test_nr](ptr, pkey);
+		//sleep(999);
+		dprintf1("freeing test memory: %p\n", ptr);
+		free_pkey_malloc(ptr);
+		sys_pkey_free(pkey);
+
+		dprintf1("pkru_faults: %d\n", pkru_faults);
+		dprintf1("orig_pkru_faults: %d\n", orig_pkru_faults);
+
+		tracing_off();
+		close_test_fds();
+
+		printf("test %2d PASSED (itertation %d)\n", test_nr, iteration_nr);
+		dprintf1("======================\n\n");
+	}
+	iteration_nr++;
+}
+
+int main()
+{
+	int nr_iterations = 22;
+	setup_handlers();
+
+	printf("has pku: %d\n", cpu_has_pku());
+
+	if (!cpu_has_pku()) {
+		int size = PAGE_SIZE;
+		int *ptr;
+
+		printf("running PKEY tests for unsupported CPU/OS\n");
+
+		ptr  = mmap(NULL, size, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+		assert(ptr != (void *)-1);
+		test_mprotect_pkey_on_unsupported_cpu(ptr, 1);
+		exit(0);
+	}
+
+	printf("pkru: %x\n", rdpkru());
+	pkey_assert(!rdpkru());
+	cat_into_file("10", "/proc/sys/vm/nr_hugepages");
+
+	while (nr_iterations-- > 0)
+		run_tests_once();
+
+	printf("done (all tests OK)\n");
+	return 0;
+}
+
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
