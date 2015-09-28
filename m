Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7C85E82F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:24:36 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so182332217pac.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:24:36 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v11si30707405pbs.191.2015.09.28.12.18.27
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:27 -0700 (PDT)
Subject: [PATCH 24/25] x86, pkeys: add self-tests
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:27 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191827.150CCA1A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This code should be a good demonstration of how to use the new
mprotect_pkey() system call as well as how to use protection keys
in general.

This code shows how to:
1. Manipulate the Protection Keys Rights User (PKRU) register with
   wrpkru/rdpkru
2. Set a protection key on memory
3. Fetch and/or modify PKRU from the signal XSAVE state
4. Read the kernel-provided protection key in the siginfo

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/tools/testing/selftests/x86/Makefile          |    3 
 b/tools/testing/selftests/x86/pkey-helpers.h    |  182 +++++
 b/tools/testing/selftests/x86/protection_keys.c |  827 ++++++++++++++++++++++++
 3 files changed, 1011 insertions(+), 1 deletion(-)

diff -puN tools/testing/selftests/x86/Makefile~pkeys-40-selftests tools/testing/selftests/x86/Makefile
--- a/tools/testing/selftests/x86/Makefile~pkeys-40-selftests	2015-09-28 11:39:51.905453848 -0700
+++ b/tools/testing/selftests/x86/Makefile	2015-09-28 11:39:51.909454031 -0700
@@ -4,7 +4,8 @@ include ../lib.mk
 
 .PHONY: all all_32 all_64 warn_32bit_failure clean
 
-TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs ldt_gdt syscall_nt
+TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs ldt_gdt syscall_nt \
+			protection_keys
 TARGETS_C_32BIT_ONLY := entry_from_vm86 syscall_arg_fault sigreturn \
 			test_FCMOV test_FCOMI test_FISTTP
 
diff -puN /dev/null tools/testing/selftests/x86/pkey-helpers.h
--- /dev/null	2015-07-13 14:24:11.435656502 -0700
+++ b/tools/testing/selftests/x86/pkey-helpers.h	2015-09-28 11:39:51.909454031 -0700
@@ -0,0 +1,182 @@
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
+static inline unsigned int rdpkru(void)
+{
+	unsigned int pkru = __rdpkru();
+	dprintf4("pkru: %x shadow: %x\n", pkru, shadow_pkru);
+	assert(pkru == shadow_pkru);
+	return pkru;
+}
+
+static inline void __wrpkru(unsigned int pkru)
+{
+        unsigned int eax = pkru;
+	unsigned int ecx = 0;
+	unsigned int edx = 0;
+
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
+#define pkey_access_allow(pkey) __pkey_access_allow(pkey, 1)
+#define pkey_access_deny(pkey)  __pkey_access_allow(pkey, 0)
+#define pkey_write_allow(pkey)  __pkey_write_allow(pkey, 1)
+#define pkey_write_deny(pkey)   __pkey_write_allow(pkey, 0)
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
+		printf("cpu does not have PKU\n");
+		return 0;
+	}
+	if (!(ecx & X86_FEATURE_OSPKE)) {
+		printf("cpu does not have OSPKE\n");
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
diff -puN /dev/null tools/testing/selftests/x86/protection_keys.c
--- /dev/null	2015-07-13 14:24:11.435656502 -0700
+++ b/tools/testing/selftests/x86/protection_keys.c	2015-09-28 11:39:51.910454076 -0700
@@ -0,0 +1,827 @@
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
+		abort_hooks();			\
+		perror("errno at assert");	\
+		assert(condition);		\
+	}					\
+} while (0)
+#define raw_assert(cond) assert(cond)
+
+
+#define __SI_FAULT      (3 << 16)
+#define SEGV_BNDERR     (__SI_FAULT|3)  /* failed address bound checks */
+#define SEGV_PKUERR     (__SI_FAULT|4)
+
+void cat_into_file(char *str, char *file)
+{
+	int fd = open(file, O_RDWR);
+	int ret;
+	// these need to be raw because they are called under
+	// pkey_assert()
+	raw_assert(fd >= 0);
+	ret = write(fd, str, strlen(str));
+	if (ret != strlen(str)) {
+		perror("write to file failed");
+		fprintf(stderr, "filename: '%s'\n", file);
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
+}
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
+// I'm addicted to the kernel types
+#define  u8 uint8_t
+#define u16 uint16_t
+#define u32 uint32_t
+#define u64 uint64_t
+
+#ifdef __i386__
+#define SYS_mprotect_key 376
+#define REG_IP_IDX REG_EIP
+#define si_pkey_offset 0x08
+#else
+#define SYS_mprotect_key 325
+#define REG_IP_IDX REG_RIP
+#define si_pkey_offset 0x20
+#endif
+
+void dump_mem(void *dumpme, int len_bytes)
+{
+	char *c = (void *)dumpme;
+	int i;
+	for (i = 0; i < len_bytes; i+= sizeof(u64)) {
+		dprintf1("dump[%03d]: %016jx\n", i, *(u64 *)(c + i));
+	}
+}
+
+
+int pkru_faults = 0;
+int last_si_pkey = -1;
+void handler(int signum, siginfo_t* si, void* vucontext)
+{
+	ucontext_t* uctxt = vucontext;
+	int trapno;
+	unsigned long ip;
+	char *fpregs;
+	u32 *pkru_ptr;
+	u64 si_pkey;
+	int pkru_offset;
+
+	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
+	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
+	fpregset_t fpregset = uctxt->uc_mcontext.fpregs;
+	fpregs = (void *)fpregset;
+	pkru_offset = pkru_xstate_offset();
+	pkru_ptr = (void *)(&fpregs[pkru_offset]);
+
+	/*
+	 * If we got a PKRU fault, we *HAVE* to have at least one bit set in
+	 * here.
+	 */
+	dprintf1("pkru_xstate_offset: %d\n", pkru_xstate_offset());
+	dump_mem(pkru_ptr - 8, 24);
+	assert(*pkru_ptr);
+
+	si_pkey = *(u64 *)(((u8 *)si) + si_pkey_offset);
+	last_si_pkey = si_pkey;
+
+	dprintf1("\n===================SIGSEGV============================\n");
+	dprintf2("%s() trapno: %d ip: 0x%lx info->si_code: %s/%d\n", __func__, trapno, ip,
+			si_code_str(si->si_code), si->si_code);
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
+	*pkru_ptr = 0;
+	dprintf1("WARNING: set PRKU=0 to allow faulting instruction to continue\n");
+	pkru_faults++;
+	dprintf1("======================================================\n\n");
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
+	newact.sa_sigaction = handler; /* void (*)(int, siginfo_t*, void*) */
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
+void tag_each_buffer_page(void *buf, int nr_pages, unsigned long tag)
+{
+	int i;
+
+	for (i = 0; i < nr_pages; i++) {
+		unsigned long *tag_at = (buf + i * PAGE_SIZE);
+		*tag_at = tag;
+	}
+}
+
+pid_t fork_lazy_child(void *buf)
+{
+	pid_t forkret;
+
+	// Tag the buffers in both parent and child
+	tag_each_buffer_page(buf, NR_PKEYS, 0xDEADBEEFUL);
+
+	forkret = fork();
+	pkey_assert(forkret >= 0);
+	dprintf3("[%d] fork() ret: %d\n", getpid(), forkret);
+
+	// Tag the buffers in both parent and child
+	tag_each_buffer_page(buf, NR_PKEYS, getpid());
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
+int mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot, unsigned long pkey)
+{
+	int sret;
+	pkey_assert(pkey < NR_PKEYS);
+
+	// do not let 'prot' protection key bits be set here
+	assert(orig_prot < 0x10);
+	errno = 0;
+	sret = syscall(SYS_mprotect_key, ptr, size, orig_prot, pkey);
+	if (errno) {
+		dprintf1("SYS_mprotect_key sret: %d\n", sret);
+		dprintf1("SYS_mprotect_key prot: 0x%lx\n", orig_prot);
+		dprintf1("SYS_mprotect_key failed, errno: %d\n", errno);
+		assert(0);
+	}
+	return sret;
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
+		dprintf1("new_nr_records: %zd\n", new_nr_records);
+		dprintf1("new_size: %zd\n", new_size);
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
+	dprintf1("doing %s(size=%ld, prot=0x%x, pkey=%d)\n", __func__, size, prot, pkey);
+	pkey_assert(pkey < NR_PKEYS);
+	ptr = mmap(NULL, size, prot, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+	pkey_assert(ptr != (void *)-1);
+	ret = mprotect_pkey((void *)ptr, PAGE_SIZE, prot, pkey);
+	pkey_assert(!ret);
+	record_pkey_malloc(ptr, size);
+
+	dprintf1("%s() for pkey %d @ %p\n", __func__, pkey, ptr);
+	return ptr;
+}
+
+
+void *malloc_pkey_mmap_direct(long size, int prot, u16 pkey)
+{
+	void *ptr;
+
+	dprintf1("doing %s(size=%ld, prot=0x%x, pkey=%d)\n", __func__, size, prot, pkey);
+	pkey_assert(pkey < NR_PKEYS);
+	prot = prot_add_pkey(prot, pkey);
+	ptr = mmap(NULL, size, prot, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+	pkey_assert(ptr != (void *)-1);
+
+	record_pkey_malloc(ptr, size);
+
+	dprintf1("mmap()'d for pkey %d @ %p\n", pkey, ptr);
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
+	assert(fd >= 0);
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
+void* malloc_one_page_of_each_pkey(void)
+{
+	int prot = PROT_READ|PROT_WRITE;
+	void *ret;
+	int i;
+
+	ret = mmap(NULL, PAGE_SIZE * NR_PKEYS, prot, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+	pkey_assert(ret != (void *)-1);
+	for (i = 0; i < NR_PKEYS; i++) {
+		int mprotect_ret;
+		mprotect_ret = mprotect_pkey(ret + i * PAGE_SIZE, PAGE_SIZE, prot, i);
+		pkey_assert(!mprotect_ret);
+	}
+	return ret;
+}
+
+__attribute__((noinline)) int read_ptr(int *ptr)
+{
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
+void test_ptrace_of_child(int *ptr, u16 pkey)
+{
+	void *buf = malloc_one_page_of_each_pkey();
+	pid_t child_pid = fork_lazy_child(buf);
+	void *ignored = 0;
+	long ret;
+	int i;
+	int status;
+
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
+	//if (0)
+	for (i = 1; i < NR_PKEYS; i++) {
+		pkey_access_deny(i);
+		pkey_write_deny(i);
+	}
+	for (i = 0; i < NR_PKEYS; i++) {
+		void *peek_at = buf + i * PAGE_SIZE;
+		long peek_result;
+
+		//ret = ptrace(PTRACE_POKEDATA, child_pid, peek_at, data);
+		//pkey_assert(ret != -1);
+		//printf("poke at %p: %ld\n", peek_at, ret);
+
+		ret = ptrace(PTRACE_PEEKDATA, child_pid, peek_at, ignored);
+		pkey_assert(ret != -1);
+
+		peek_result = *(long *)peek_at;
+		// for the *peek_at access
+		if (i >= 1) // did not disable access to pkey 0
+			expected_pk_fault(i);
+
+		dprintf1("peek at pkey[%2d] @ %p: %lx (local: %ld) pkru: %08x\n", i, peek_at, ret, peek_result, rdpkru());
+	}
+	ret = ptrace(PTRACE_DETACH, child_pid, ignored, 0);
+	pkey_assert(ret != -1);
+
+	ret = kill(child_pid, SIGKILL);
+	pkey_assert(ret != -1);
+
+	ret = munmap(buf, PAGE_SIZE * NR_PKEYS);
+	pkey_assert(!ret);
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
+//	test_ptrace_of_child,
+};
+
+void run_tests_once(void)
+{
+	static int iteration_nr = 1;
+	int *ptr;
+	int prot = PROT_READ|PROT_WRITE;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(pkey_tests); i++) {
+		int orig_pkru_faults = pkru_faults;
+		// reset pkru:
+		wrpkru(0);
+
+		static u16 pkey;
+		pkey = 1 + (rand() % 15);
+		dprintf1("================\n");
+		dprintf1("test %d starting with pkey: %d\n", i, pkey);
+		tracing_on();
+		ptr = malloc_pkey(PAGE_SIZE, prot, pkey);
+		//dumpit("/proc/self/maps");
+		pkey_tests[i](ptr, pkey);
+		//sleep(999);
+		dprintf1("freeing test memory: %p\n", ptr);
+		free_pkey_malloc(ptr);
+
+		dprintf1("pkru_faults: %d\n", pkru_faults);
+		dprintf1("orig_pkru_faults: %d\n", orig_pkru_faults);
+
+		tracing_off();
+		close_test_fds();
+		//system("dmesg -c");
+		//sleep(2);
+		printf("test %d PASSED (itertation %d)\n", i, iteration_nr);
+		dprintf1("================\n\n");
+	}
+	iteration_nr++;
+}
+
+int main()
+{
+	int nr_iterations = 5;
+	setup_handlers();
+	printf("has pku: %d\n", cpu_has_pku());
+	printf("pkru: %x\n", rdpkru());
+	pkey_assert(cpu_has_pku());
+	pkey_assert(!rdpkru());
+
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
