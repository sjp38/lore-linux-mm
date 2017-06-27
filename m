Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF0F6B0343
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:12:49 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l55so10450379qtl.7
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:49 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id v70si2355303qkv.289.2017.06.27.03.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 03:12:46 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id w12so3166813qta.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:46 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v4 14/17] selftest: PowerPC specific test updates to memory protection keys
Date: Tue, 27 Jun 2017 03:11:56 -0700
Message-Id: <1498558319-32466-15-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Abstracted out the arch specific code into the header file, and
added powerpc specific changes.

a) added 4k-backed hpte, memory allocator, powerpc specific.
b) added three test case where the key is associated after the page is
	accessed/allocated/mapped.
c) cleaned up the code to make checkpatch.pl happy

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    | 230 +++++++++--
 tools/testing/selftests/vm/protection_keys.c | 567 ++++++++++++++++-----------
 2 files changed, 518 insertions(+), 279 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index b202939..69bfa89 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -12,13 +12,72 @@
 #include <ucontext.h>
 #include <sys/mman.h>
 
-#define NR_PKEYS 16
-#define PKRU_BITS_PER_PKEY 2
+/* Define some kernel-like types */
+#define  u8 uint8_t
+#define u16 uint16_t
+#define u32 uint32_t
+#define u64 uint64_t
+
+#ifdef __i386__ /* arch */
+
+#define SYS_mprotect_key 380
+#define SYS_pkey_alloc	 381
+#define SYS_pkey_free	 382
+#define REG_IP_IDX REG_EIP
+#define si_pkey_offset 0x14
+
+#define NR_PKEYS		16
+#define NR_RESERVED_PKEYS	1
+#define PKRU_BITS_PER_PKEY	2
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define HPAGE_SIZE		(1UL<<21)
+
+#define INIT_PRKU 0x0UL
+
+#elif __powerpc64__ /* arch */
+
+#define SYS_mprotect_key 386
+#define SYS_pkey_alloc	 384
+#define SYS_pkey_free	 385
+#define si_pkey_offset	0x20
+#define REG_IP_IDX PT_NIP
+#define REG_TRAPNO PT_TRAP
+#define REG_AMR		45
+#define gregs gp_regs
+#define fpregs fp_regs
+
+#define NR_PKEYS		32
+#define NR_RESERVED_PKEYS	3
+#define PKRU_BITS_PER_PKEY	2
+#define PKEY_DISABLE_ACCESS	0x3  /* disable read and write */
+#define PKEY_DISABLE_WRITE	0x2
+#define HPAGE_SIZE		(1UL<<24)
+
+#define INIT_PRKU 0x3UL
+#else /* arch */
+
+	NOT SUPPORTED
+
+#endif /* arch */
+
 
 #ifndef DEBUG_LEVEL
 #define DEBUG_LEVEL 0
 #endif
 #define DPRINT_IN_SIGNAL_BUF_SIZE 4096
+
+
+static inline u32 pkey_to_shift(int pkey)
+{
+#ifdef __i386__ /* arch */
+	return pkey * PKRU_BITS_PER_PKEY;
+#elif __powerpc64__ /* arch */
+	return (NR_PKEYS - pkey - 1) * PKRU_BITS_PER_PKEY;
+#endif /* arch */
+}
+
+
 extern int dprint_in_signal;
 extern char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
 static inline void sigsafe_printf(const char *format, ...)
@@ -53,53 +112,76 @@ static inline void sigsafe_printf(const char *format, ...)
 #define dprintf3(args...) dprintf_level(3, args)
 #define dprintf4(args...) dprintf_level(4, args)
 
-extern unsigned int shadow_pkru;
-static inline unsigned int __rdpkru(void)
+extern u64 shadow_pkey_reg;
+
+static inline u64 __rdpkey_reg(void)
 {
+#ifdef __i386__ /* arch */
 	unsigned int eax, edx;
 	unsigned int ecx = 0;
-	unsigned int pkru;
+	unsigned int pkey_reg;
 
 	asm volatile(".byte 0x0f,0x01,0xee\n\t"
 		     : "=a" (eax), "=d" (edx)
 		     : "c" (ecx));
-	pkru = eax;
-	return pkru;
+#elif __powerpc64__ /* arch */
+	u64 eax;
+	u64 pkey_reg;
+
+	asm volatile("mfspr %0, 0xd" : "=r" ((u64)(eax)));
+#endif /* arch */
+	pkey_reg = (u64)eax;
+	return pkey_reg;
 }
 
-static inline unsigned int _rdpkru(int line)
+static inline u64 _rdpkey_reg(int line)
 {
-	unsigned int pkru = __rdpkru();
+	u64 pkey_reg = __rdpkey_reg();
 
-	dprintf4("rdpkru(line=%d) pkru: %x shadow: %x\n",
-			line, pkru, shadow_pkru);
-	assert(pkru == shadow_pkru);
+	dprintf4("rdpkey_reg(line=%d) pkey_reg: %lx shadow: %lx\n",
+			line, pkey_reg, shadow_pkey_reg);
+	assert(pkey_reg == shadow_pkey_reg);
 
-	return pkru;
+	return pkey_reg;
 }
 
-#define rdpkru() _rdpkru(__LINE__)
+#define rdpkey_reg() _rdpkey_reg(__LINE__)
 
-static inline void __wrpkru(unsigned int pkru)
+static inline void __wrpkey_reg(u64 pkey_reg)
 {
-	unsigned int eax = pkru;
+#ifdef __i386__ /* arch */
+	unsigned int eax = pkey_reg;
 	unsigned int ecx = 0;
 	unsigned int edx = 0;
 
-	dprintf4("%s() changing %08x to %08x\n", __func__, __rdpkru(), pkru);
+	dprintf4("%s() changing %lx to %lx\n",
+			 __func__, __rdpkey_reg(), pkey_reg);
 	asm volatile(".byte 0x0f,0x01,0xef\n\t"
 		     : : "a" (eax), "c" (ecx), "d" (edx));
-	assert(pkru == __rdpkru());
+	dprintf4("%s() PKRUP after changing %lx to %lx\n",
+			__func__, __rdpkey_reg(), pkey_reg);
+#else /* arch */
+	u64 eax = pkey_reg;
+
+	dprintf4("%s() changing %llx to %llx\n",
+			 __func__, __rdpkey_reg(), pkey_reg);
+	asm volatile("mtspr 0xd, %0" : : "r" ((unsigned long)(eax)) : "memory");
+	dprintf4("%s() PKRUP after changing %llx to %llx\n",
+			 __func__, __rdpkey_reg(), pkey_reg);
+#endif /* arch */
+	assert(pkey_reg == __rdpkey_reg());
 }
 
-static inline void wrpkru(unsigned int pkru)
+static inline void wrpkey_reg(u64 pkey_reg)
 {
-	dprintf4("%s() changing %08x to %08x\n", __func__, __rdpkru(), pkru);
+	dprintf4("%s() changing %lx to %lx\n",
+			__func__, __rdpkey_reg(), pkey_reg);
 	/* will do the shadow check for us: */
-	rdpkru();
-	__wrpkru(pkru);
-	shadow_pkru = pkru;
-	dprintf4("%s(%08x) pkru: %08x\n", __func__, pkru, __rdpkru());
+	rdpkey_reg();
+	__wrpkey_reg(pkey_reg);
+	shadow_pkey_reg = pkey_reg;
+	dprintf4("%s(%lx) pkey_reg: %lx\n",
+		__func__, pkey_reg, __rdpkey_reg());
 }
 
 /*
@@ -108,40 +190,37 @@ static inline void wrpkru(unsigned int pkru)
  */
 static inline void __pkey_access_allow(int pkey, int do_allow)
 {
-	unsigned int pkru = rdpkru();
+	u64 pkey_reg = rdpkey_reg();
 	int bit = pkey * 2;
 
 	if (do_allow)
-		pkru &= (1<<bit);
+		pkey_reg &= (1<<bit);
 	else
-		pkru |= (1<<bit);
+		pkey_reg |= (1<<bit);
 
-	dprintf4("pkru now: %08x\n", rdpkru());
-	wrpkru(pkru);
+	dprintf4("pkey_reg now: %lx\n", rdpkey_reg());
+	wrpkey_reg(pkey_reg);
 }
 
 static inline void __pkey_write_allow(int pkey, int do_allow_write)
 {
-	long pkru = rdpkru();
+	u64 pkey_reg = rdpkey_reg();
 	int bit = pkey * 2 + 1;
 
 	if (do_allow_write)
-		pkru &= (1<<bit);
+		pkey_reg &= (1<<bit);
 	else
-		pkru |= (1<<bit);
+		pkey_reg |= (1<<bit);
 
-	wrpkru(pkru);
-	dprintf4("pkru now: %08x\n", rdpkru());
+	wrpkey_reg(pkey_reg);
+	dprintf4("pkey_reg now: %lx\n", rdpkey_reg());
 }
 
-#define PROT_PKEY0     0x10            /* protection key value (bit 0) */
-#define PROT_PKEY1     0x20            /* protection key value (bit 1) */
-#define PROT_PKEY2     0x40            /* protection key value (bit 2) */
-#define PROT_PKEY3     0x80            /* protection key value (bit 3) */
-
-#define PAGE_SIZE 4096
 #define MB	(1<<20)
 
+#ifdef __i386__ /* arch */
+
+#define PAGE_SIZE 4096
 static inline void __cpuid(unsigned int *eax, unsigned int *ebx,
 		unsigned int *ecx, unsigned int *edx)
 {
@@ -159,7 +238,7 @@ static inline void __cpuid(unsigned int *eax, unsigned int *ebx,
 #define X86_FEATURE_PKU        (1<<3) /* Protection Keys for Userspace */
 #define X86_FEATURE_OSPKE      (1<<4) /* OS Protection Keys Enable */
 
-static inline int cpu_has_pku(void)
+static inline int cpu_has_pkey(void)
 {
 	unsigned int eax;
 	unsigned int ebx;
@@ -183,7 +262,6 @@ static inline int cpu_has_pku(void)
 
 #define XSTATE_PKRU_BIT	(9)
 #define XSTATE_PKRU	0x200
-
 int pkru_xstate_offset(void)
 {
 	unsigned int eax;
@@ -216,4 +294,72 @@ int pkru_xstate_offset(void)
 	return xstate_offset;
 }
 
+/* 8-bytes of instruction * 512 bytes = 1 page */
+#define __page_o_noops() asm(".rept 512 ; nopl 0x7eeeeeee(%eax) ; .endr")
+
+#elif __powerpc64__ /* arch */
+
+#define PAGE_SIZE (0x1UL << 16)
+static inline int cpu_has_pkey(void)
+{
+	return 1;
+}
+
+/* 8-bytes of instruction * 16384bytes = 1 page */
+#define __page_o_noops() asm(".rept 16384 ; nop; .endr")
+
+#endif /* arch */
+
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
+#define ALIGN_UP(x, align_to)	(((x) + ((align_to)-1)) & ~((align_to)-1))
+#define ALIGN_DOWN(x, align_to) ((x) & ~((align_to)-1))
+#define ALIGN_PTR_UP(p, ptr_align_to)	\
+		((typeof(p))ALIGN_UP((unsigned long)(p), ptr_align_to))
+#define ALIGN_PTR_DOWN(p, ptr_align_to) \
+	((typeof(p))ALIGN_DOWN((unsigned long)(p), ptr_align_to))
+#define __stringify_1(x...)     #x
+#define __stringify(x...)       __stringify_1(x)
+
+#define PTR_ERR_ENOTSUP ((void *)-ENOTSUP)
+
+extern void abort_hooks(void);
+#define pkey_assert(condition) do {		\
+	if (!(condition)) {			\
+		dprintf0("assert() at %s::%d test_nr: %d iteration: %d\n", \
+				__FILE__, __LINE__,	\
+				test_nr, iteration_nr);	\
+		dprintf0("errno at assert: %d", errno);	\
+		abort_hooks();			\
+		assert(condition);		\
+	}					\
+} while (0)
+#define raw_assert(cond) assert(cond)
+
+
+static inline int open_hugepage_file(int flag)
+{
+	int fd;
+#ifdef __i386__ /* arch */
+	fd = open("/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages",
+		 O_RDONLY);
+#elif __powerpc64__ /* arch */
+	fd = open("/sys/kernel/mm/hugepages/hugepages-16384kB/nr_hugepages",
+		O_RDONLY);
+#else /* arch */
+	NOT SUPPORTED
+#endif /* arch */
+	return fd;
+}
+
+static inline int get_start_key(void)
+{
+#ifdef __i386__ /* arch */
+	return 1;
+#elif __powerpc64__ /* arch */
+	return 0;
+#else /* arch */
+	NOT SUPPORTED
+#endif /* arch */
+}
+
 #endif /* _PKEYS_HELPER_H */
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 3237bc0..bba1857 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -1,10 +1,10 @@
 /*
- * Tests x86 Memory Protection Keys (see Documentation/x86/protection-keys.txt)
+ * Tests Memory Protection Keys (see Documentation/vm/protection-keys.txt)
  *
  * There are examples in here of:
  *  * how to set protection keys on memory
- *  * how to set/clear bits in PKRU (the rights register)
- *  * how to handle SEGV_PKRU signals and extract pkey-relevant
+ *  * how to set/clear bits in Protection Key registers (the rights register)
+ *  * how to handle SEGV_PKUERR signals and extract pkey-relevant
  *    information from the siginfo
  *
  * Things to add:
@@ -12,17 +12,23 @@
  *	prefault pages in at malloc, or not
  *	protect MPX bounds tables with protection keys?
  *	make sure VMA splitting/merging is working correctly
- *	OOMs can destroy mm->mmap (see exit_mmap()), so make sure it is immune to pkeys
- *	look for pkey "leaks" where it is still set on a VMA but "freed" back to the kernel
- *	do a plain mprotect() to a mprotect_pkey() area and make sure the pkey sticks
+ *	OOMs can destroy mm->mmap (see exit_mmap()),
+ *			so make sure it is immune to pkeys
+ *	look for pkey "leaks" where it is still set on a VMA
+ *			 but "freed" back to the kernel
+ *	do a plain mprotect() to a mprotect_pkey() area and make
+ *			 sure the pkey sticks
  *
  * Compile like this:
- *	gcc      -o protection_keys    -O2 -g -std=gnu99 -pthread -Wall protection_keys.c -lrt -ldl -lm
- *	gcc -m32 -o protection_keys_32 -O2 -g -std=gnu99 -pthread -Wall protection_keys.c -lrt -ldl -lm
+ *	gcc      -o protection_keys    -O2 -g -std=gnu99
+ *			 -pthread -Wall protection_keys.c -lrt -ldl -lm
+ *	gcc -m32 -o protection_keys_32 -O2 -g -std=gnu99
+ *			 -pthread -Wall protection_keys.c -lrt -ldl -lm
  */
 #define _GNU_SOURCE
 #include <errno.h>
 #include <linux/futex.h>
+#include <time.h>
 #include <sys/time.h>
 #include <sys/syscall.h>
 #include <string.h>
@@ -46,36 +52,11 @@
 
 int iteration_nr = 1;
 int test_nr;
-
-unsigned int shadow_pkru;
-
-#define HPAGE_SIZE	(1UL<<21)
-#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
-#define ALIGN_UP(x, align_to)	(((x) + ((align_to)-1)) & ~((align_to)-1))
-#define ALIGN_DOWN(x, align_to) ((x) & ~((align_to)-1))
-#define ALIGN_PTR_UP(p, ptr_align_to)	((typeof(p))ALIGN_UP((unsigned long)(p),	ptr_align_to))
-#define ALIGN_PTR_DOWN(p, ptr_align_to)	((typeof(p))ALIGN_DOWN((unsigned long)(p),	ptr_align_to))
-#define __stringify_1(x...)     #x
-#define __stringify(x...)       __stringify_1(x)
-
-#define PTR_ERR_ENOTSUP ((void *)-ENOTSUP)
+u64 shadow_pkey_reg;
 
 int dprint_in_signal;
 char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
 
-extern void abort_hooks(void);
-#define pkey_assert(condition) do {		\
-	if (!(condition)) {			\
-		dprintf0("assert() at %s::%d test_nr: %d iteration: %d\n", \
-				__FILE__, __LINE__,	\
-				test_nr, iteration_nr);	\
-		dprintf0("errno at assert: %d", errno);	\
-		abort_hooks();			\
-		assert(condition);		\
-	}					\
-} while (0)
-#define raw_assert(cond) assert(cond)
-
 void cat_into_file(char *str, char *file)
 {
 	int fd = open(file, O_RDWR);
@@ -153,11 +134,6 @@ void abort_hooks(void)
 #endif
 }
 
-static inline void __page_o_noops(void)
-{
-	/* 8-bytes of instruction * 512 bytes = 1 page */
-	asm(".rept 512 ; nopl 0x7eeeeeee(%eax) ; .endr");
-}
 
 /*
  * This attempts to have roughly a page of instructions followed by a few
@@ -181,26 +157,6 @@ void lots_o_noops_around_write(int *write_to_me)
 	dprintf3("%s() done\n", __func__);
 }
 
-/* Define some kernel-like types */
-#define  u8 uint8_t
-#define u16 uint16_t
-#define u32 uint32_t
-#define u64 uint64_t
-
-#ifdef __i386__
-#define SYS_mprotect_key 380
-#define SYS_pkey_alloc	 381
-#define SYS_pkey_free	 382
-#define REG_IP_IDX REG_EIP
-#define si_pkey_offset 0x14
-#else
-#define SYS_mprotect_key 329
-#define SYS_pkey_alloc	 330
-#define SYS_pkey_free	 331
-#define REG_IP_IDX REG_RIP
-#define si_pkey_offset 0x20
-#endif
-
 void dump_mem(void *dumpme, int len_bytes)
 {
 	char *c = (void *)dumpme;
@@ -208,6 +164,7 @@ void dump_mem(void *dumpme, int len_bytes)
 
 	for (i = 0; i < len_bytes; i += sizeof(u64)) {
 		u64 *ptr = (u64 *)(c + i);
+
 		dprintf1("dump[%03d][@%p]: %016jx\n", i, ptr, *ptr);
 	}
 }
@@ -229,29 +186,49 @@ static char *si_code_str(int si_code)
 	return "UNKNOWN";
 }
 
-int pkru_faults;
+int pkey_faults;
 int last_si_pkey = -1;
+
+u64 reset_bits(int pkey, u64 bits)
+{
+	u32 shift = pkey_to_shift(pkey);
+
+	return ~(bits << shift);
+}
+
+u64 left_shift_bits(int pkey, u64 bits)
+{
+	u32 shift = pkey_to_shift(pkey);
+
+	return (bits << shift);
+}
+
+u64 right_shift_bits(int pkey, u64 bits)
+{
+	u32 shift = pkey_to_shift(pkey);
+
+	return (bits >> shift);
+}
+
+void pkey_access_allow(int pkey);
 void signal_handler(int signum, siginfo_t *si, void *vucontext)
 {
 	ucontext_t *uctxt = vucontext;
 	int trapno;
 	unsigned long ip;
 	char *fpregs;
-	u32 *pkru_ptr;
+	u64 *pkey_reg_ptr;
 	u64 si_pkey;
 	u32 *si_pkey_ptr;
-	int pkru_offset;
-	fpregset_t fpregset;
 
 	dprint_in_signal = 1;
 	dprintf1(">>>>===============SIGSEGV============================\n");
-	dprintf1("%s()::%d, pkru: 0x%x shadow: %x\n", __func__, __LINE__,
-			__rdpkru(), shadow_pkru);
+	dprintf1("%s()::%d, pkey_reg: 0x%lx shadow: %lx\n", __func__, __LINE__,
+			__rdpkey_reg(), shadow_pkey_reg);
 
 	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
 	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
-	fpregset = uctxt->uc_mcontext.fpregs;
-	fpregs = (void *)fpregset;
+	fpregs = (char *) uctxt->uc_mcontext.fpregs;
 
 	dprintf2("%s() trapno: %d ip: 0x%lx info->si_code: %s/%d\n", __func__,
 			trapno, ip, si_code_str(si->si_code), si->si_code);
@@ -262,20 +239,22 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	 * state.  We just assume that it is here.
 	 */
 	fpregs += 0x70;
-#endif
-	pkru_offset = pkru_xstate_offset();
-	pkru_ptr = (void *)(&fpregs[pkru_offset]);
-
-	dprintf1("siginfo: %p\n", si);
-	dprintf1(" fpregs: %p\n", fpregs);
+	pkey_reg_ptr = (void *)(&fpregs[pkru_xstate_offset()]);
 	/*
-	 * If we got a PKRU fault, we *HAVE* to have at least one bit set in
+	 * If we got a key fault, we *HAVE* to have at least one bit set in
 	 * here.
 	 */
 	dprintf1("pkru_xstate_offset: %d\n", pkru_xstate_offset());
 	if (DEBUG_LEVEL > 4)
-		dump_mem(pkru_ptr - 128, 256);
-	pkey_assert(*pkru_ptr);
+		dump_mem(pkey_reg_ptr - 128, 256);
+#elif __powerpc64__
+	pkey_reg_ptr = &uctxt->uc_mcontext.gregs[REG_AMR];
+#endif
+
+
+	dprintf1("siginfo: %p\n", si);
+	dprintf1(" fpregs: %p\n", fpregs);
+	pkey_assert(*pkey_reg_ptr);
 
 	si_pkey_ptr = (u32 *)(((u8 *)si) + si_pkey_offset);
 	dprintf1("si_pkey_ptr: %p\n", si_pkey_ptr);
@@ -291,36 +270,29 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 		exit(4);
 	}
 
-	dprintf1("signal pkru from xsave: %08x\n", *pkru_ptr);
-	/* need __rdpkru() version so we do not do shadow_pkru checking */
-	dprintf1("signal pkru from  pkru: %08x\n", __rdpkru());
+	dprintf1("signal pkey_reg : %08x\n", *pkey_reg_ptr);
+	/*
+	 * need __rdpkey_reg() version so we do not do
+	 * shadow_pkey_reg checking
+	 */
+	dprintf1("signal pkey_reg from  pkey_reg: %08x\n", __rdpkey_reg());
 	dprintf1("si_pkey from siginfo: %jx\n", si_pkey);
-	*(u64 *)pkru_ptr = 0x00000000;
-	dprintf1("WARNING: set PRKU=0 to allow faulting instruction to continue\n");
-	pkru_faults++;
+#ifdef __i386__
+	*(u64 *)pkey_reg_ptr &= reset_bits(si_pkey, PKEY_DISABLE_ACCESS);
+#elif __powerpc64__
+	pkey_access_allow(si_pkey);
+#endif
+	shadow_pkey_reg &= reset_bits(si_pkey, PKEY_DISABLE_ACCESS);
+	dprintf1("WARNING: set PRKU=0 to allow faulting instruction "
+			"to continue\n");
+	pkey_faults++;
 	dprintf1("<<<<==================================================\n");
-	return;
-	if (trapno == 14) {
-		fprintf(stderr,
-			"ERROR: In signal handler, page fault, trapno = %d, ip = %016lx\n",
-			trapno, ip);
-		fprintf(stderr, "si_addr %p\n", si->si_addr);
-		fprintf(stderr, "REG_ERR: %lx\n",
-				(unsigned long)uctxt->uc_mcontext.gregs[REG_ERR]);
-		exit(1);
-	} else {
-		fprintf(stderr, "unexpected trap %d! at 0x%lx\n", trapno, ip);
-		fprintf(stderr, "si_addr %p\n", si->si_addr);
-		fprintf(stderr, "REG_ERR: %lx\n",
-				(unsigned long)uctxt->uc_mcontext.gregs[REG_ERR]);
-		exit(2);
-	}
-	dprint_in_signal = 0;
 }
 
 int wait_all_children(void)
 {
 	int status;
+
 	return waitpid(-1, &status, 0);
 }
 
@@ -409,51 +381,50 @@ void dumpit(char *f)
 	close(fd);
 }
 
-#define PKEY_DISABLE_ACCESS    0x1
-#define PKEY_DISABLE_WRITE     0x2
-
-u32 pkey_get(int pkey, unsigned long flags)
+u64 pkey_get(int pkey, unsigned long flags)
 {
-	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-	u32 pkru = __rdpkru();
-	u32 shifted_pkru;
-	u32 masked_pkru;
+	u64 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
+	u64 pkey_reg = __rdpkey_reg();
+	u64 shifted_pkey_reg;
+	u64 masked_pkey_reg;
 
 	dprintf1("%s(pkey=%d, flags=%lx) = %x / %d\n",
 			__func__, pkey, flags, 0, 0);
-	dprintf2("%s() raw pkru: %x\n", __func__, pkru);
+	dprintf2("%s() raw pkey_reg: %lx\n", __func__, pkey_reg);
 
-	shifted_pkru = (pkru >> (pkey * PKRU_BITS_PER_PKEY));
-	dprintf2("%s() shifted_pkru: %x\n", __func__, shifted_pkru);
-	masked_pkru = shifted_pkru & mask;
-	dprintf2("%s() masked  pkru: %x\n", __func__, masked_pkru);
+	shifted_pkey_reg = right_shift_bits(pkey, pkey_reg);
+	dprintf2("%s() shifted_pkey_reg: %lx\n", __func__, shifted_pkey_reg);
+	masked_pkey_reg = shifted_pkey_reg & mask;
+	dprintf2("%s() masked  pkey_reg: %lx\n", __func__, masked_pkey_reg);
 	/*
 	 * shift down the relevant bits to the lowest two, then
 	 * mask off all the other high bits.
 	 */
-	return masked_pkru;
+	return masked_pkey_reg;
 }
 
 int pkey_set(int pkey, unsigned long rights, unsigned long flags)
 {
-	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-	u32 old_pkru = __rdpkru();
-	u32 new_pkru;
+	u64 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
+	u64 old_pkey_reg = __rdpkey_reg();
+	u64 new_pkey_reg;
 
 	/* make sure that 'rights' only contains the bits we expect: */
 	assert(!(rights & ~mask));
 
-	/* copy old pkru */
-	new_pkru = old_pkru;
+	/* copy old pkey_reg */
+	new_pkey_reg = old_pkey_reg;
 	/* mask out bits from pkey in old value: */
-	new_pkru &= ~(mask << (pkey * PKRU_BITS_PER_PKEY));
+	new_pkey_reg &= reset_bits(pkey, mask);
 	/* OR in new bits for pkey: */
-	new_pkru |= (rights << (pkey * PKRU_BITS_PER_PKEY));
+	new_pkey_reg |= left_shift_bits(pkey, rights);
 
-	__wrpkru(new_pkru);
+	__wrpkey_reg(new_pkey_reg);
 
-	dprintf3("%s(pkey=%d, rights=%lx, flags=%lx) = %x pkru now: %x old_pkru: %x\n",
-			__func__, pkey, rights, flags, 0, __rdpkru(), old_pkru);
+	dprintf3("%s(pkey=%d, rights=%lx, flags=%lx) = %x "
+			"pkey_reg now: %x old_pkey_reg: %x\n",
+			__func__, pkey, rights, flags,
+			0, __rdpkey_reg(), old_pkey_reg);
 	return 0;
 }
 
@@ -461,8 +432,8 @@ void pkey_disable_set(int pkey, int flags)
 {
 	unsigned long syscall_flags = 0;
 	int ret;
-	int pkey_rights;
-	u32 orig_pkru = rdpkru();
+	u64 pkey_rights;
+	u64 orig_pkey_reg = rdpkey_reg();
 
 	dprintf1("START->%s(%d, 0x%x)\n", __func__,
 		pkey, flags);
@@ -474,23 +445,28 @@ void pkey_disable_set(int pkey, int flags)
 			pkey, pkey, pkey_rights);
 	pkey_assert(pkey_rights >= 0);
 
-	pkey_rights |= flags;
+	/* process flags only if they have some new bits enabled */
+	if (flags && !(pkey_rights & flags)) {
+		pkey_rights |= flags;
 
-	ret = pkey_set(pkey, pkey_rights, syscall_flags);
-	assert(!ret);
-	/*pkru and flags have the same format */
-	shadow_pkru |= flags << (pkey * 2);
-	dprintf1("%s(%d) shadow: 0x%x\n", __func__, pkey, shadow_pkru);
+		ret = pkey_set(pkey, pkey_rights, syscall_flags);
+		assert(!ret);
+		/*pkey_reg and flags have the same format */
+		shadow_pkey_reg |= left_shift_bits(pkey, flags);
+		dprintf1("%s(%d) shadow: 0x%x\n",
+			__func__, pkey, shadow_pkey_reg);
 
-	pkey_assert(ret >= 0);
+		pkey_assert(ret >= 0);
 
-	pkey_rights = pkey_get(pkey, syscall_flags);
-	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
-			pkey, pkey, pkey_rights);
+		pkey_rights = pkey_get(pkey, syscall_flags);
+		dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
+				pkey, pkey, pkey_rights);
 
-	dprintf1("%s(%d) pkru: 0x%x\n", __func__, pkey, rdpkru());
-	if (flags)
-		pkey_assert(rdpkru() > orig_pkru);
+		dprintf1("%s(%d) pkey_reg: 0x%lx\n",
+			__func__, pkey, rdpkey_reg());
+		if (flags)
+			pkey_assert(rdpkey_reg() > orig_pkey_reg);
+	}
 	dprintf1("END<---%s(%d, 0x%x)\n", __func__,
 		pkey, flags);
 }
@@ -499,8 +475,8 @@ void pkey_disable_clear(int pkey, int flags)
 {
 	unsigned long syscall_flags = 0;
 	int ret;
-	int pkey_rights = pkey_get(pkey, syscall_flags);
-	u32 orig_pkru = rdpkru();
+	u64 pkey_rights = pkey_get(pkey, syscall_flags);
+	u64 orig_pkey_reg = rdpkey_reg();
 
 	pkey_assert(flags & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
 
@@ -508,20 +484,21 @@ void pkey_disable_clear(int pkey, int flags)
 			pkey, pkey, pkey_rights);
 	pkey_assert(pkey_rights >= 0);
 
-	pkey_rights |= flags;
+	pkey_rights &= ~flags;
 
 	ret = pkey_set(pkey, pkey_rights, 0);
-	/* pkru and flags have the same format */
-	shadow_pkru &= ~(flags << (pkey * 2));
+	/* pkey_reg and flags have the same format */
+	shadow_pkey_reg &= reset_bits(pkey, flags);
 	pkey_assert(ret >= 0);
 
 	pkey_rights = pkey_get(pkey, syscall_flags);
 	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
-	dprintf1("%s(%d) pkru: 0x%x\n", __func__, pkey, rdpkru());
+	dprintf1("%s(%d) pkey_reg: 0x%x\n",
+			__func__, pkey, rdpkey_reg());
 	if (flags)
-		assert(rdpkru() > orig_pkru);
+		assert(rdpkey_reg() > orig_pkey_reg);
 }
 
 void pkey_write_allow(int pkey)
@@ -564,49 +541,72 @@ int sys_mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot,
 int sys_pkey_alloc(unsigned long flags, unsigned long init_val)
 {
 	int ret = syscall(SYS_pkey_alloc, flags, init_val);
+
 	dprintf1("%s(flags=%lx, init_val=%lx) syscall ret: %d errno: %d\n",
 			__func__, flags, init_val, ret, errno);
 	return ret;
 }
 
+void pkey_setup_shadow(void)
+{
+	shadow_pkey_reg = __rdpkey_reg();
+}
+
+void pkey_reset_shadow(u32 key)
+{
+	shadow_pkey_reg &= reset_bits(key, 0x3);
+}
+
+void pkey_set_shadow(u32 key, u64 init_val)
+{
+	shadow_pkey_reg |=  left_shift_bits(key, init_val);
+}
+
 int alloc_pkey(void)
 {
 	int ret;
-	unsigned long init_val = 0x0;
+	u64 init_val = 0x0;
 
-	dprintf1("alloc_pkey()::%d, pkru: 0x%x shadow: %x\n",
-			__LINE__, __rdpkru(), shadow_pkru);
+	dprintf1("%s()::%d, pkey_reg: 0x%x shadow: %x\n",
+			__func__, __LINE__, __rdpkey_reg(),
+			shadow_pkey_reg);
 	ret = sys_pkey_alloc(0, init_val);
 	/*
-	 * pkey_alloc() sets PKRU, so we need to reflect it in
-	 * shadow_pkru:
+	 * pkey_alloc() sets pkey register, so we need to reflect it in
+	 * shadow_pkey_reg:
 	 */
-	dprintf4("alloc_pkey()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n",
-			__LINE__, ret, __rdpkru(), shadow_pkru);
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+		__func__, __LINE__, ret, __rdpkey_reg(),
+		shadow_pkey_reg);
 	if (ret) {
 		/* clear both the bits: */
-		shadow_pkru &= ~(0x3      << (ret * 2));
-		dprintf4("alloc_pkey()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n",
-				__LINE__, ret, __rdpkru(), shadow_pkru);
+		pkey_reset_shadow(ret);
+		dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow:"
+				" 0x%x\n",
+			__func__, __LINE__, ret,
+			__rdpkey_reg(), shadow_pkey_reg);
 		/*
 		 * move the new state in from init_val
-		 * (remember, we cheated and init_val == pkru format)
+		 * (remember, we cheated and init_val == pkey_reg format)
 		 */
-		shadow_pkru |=  (init_val << (ret * 2));
+		pkey_set_shadow(ret, init_val);
 	}
-	dprintf4("alloc_pkey()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n",
-			__LINE__, ret, __rdpkru(), shadow_pkru);
-	dprintf1("alloc_pkey()::%d errno: %d\n", __LINE__, errno);
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+			__func__, __LINE__, ret, __rdpkey_reg(),
+			shadow_pkey_reg);
+	dprintf1("%s()::%d errno: %d\n", __func__, __LINE__, errno);
 	/* for shadow checking: */
-	rdpkru();
-	dprintf4("alloc_pkey()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n",
-			__LINE__, ret, __rdpkru(), shadow_pkru);
+	rdpkey_reg();
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+			__func__, __LINE__, ret, __rdpkey_reg(),
+			shadow_pkey_reg);
 	return ret;
 }
 
 int sys_pkey_free(unsigned long pkey)
 {
 	int ret = syscall(SYS_pkey_free, pkey);
+
 	dprintf1("%s(pkey=%ld) syscall ret: %d\n", __func__, pkey, ret);
 	return ret;
 }
@@ -624,13 +624,15 @@ int alloc_random_pkey(void)
 	int alloced_pkeys[NR_PKEYS];
 	int nr_alloced = 0;
 	int random_index;
+
 	memset(alloced_pkeys, 0, sizeof(alloced_pkeys));
+	srand((unsigned int)time(NULL));
 
 	/* allocate every possible key and make a note of which ones we got */
 	max_nr_pkey_allocs = NR_PKEYS;
-	max_nr_pkey_allocs = 1;
 	for (i = 0; i < max_nr_pkey_allocs; i++) {
 		int new_pkey = alloc_pkey();
+
 		if (new_pkey < 0)
 			break;
 		alloced_pkeys[nr_alloced++] = new_pkey;
@@ -646,13 +648,14 @@ int alloc_random_pkey(void)
 	/* go through the allocated ones that we did not want and free them */
 	for (i = 0; i < nr_alloced; i++) {
 		int free_ret;
+
 		if (!alloced_pkeys[i])
 			continue;
 		free_ret = sys_pkey_free(alloced_pkeys[i]);
 		pkey_assert(!free_ret);
 	}
-	dprintf1("%s()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n", __func__,
-			__LINE__, ret, __rdpkru(), shadow_pkru);
+	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n", __func__,
+			__LINE__, ret, __rdpkey_reg(), shadow_pkey_reg);
 	return ret;
 }
 
@@ -664,17 +667,22 @@ int mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot,
 
 	while (0) {
 		int rpkey = alloc_random_pkey();
+
 		ret = sys_mprotect_pkey(ptr, size, orig_prot, pkey);
-		dprintf1("sys_mprotect_pkey(%p, %zx, prot=0x%lx, pkey=%ld) ret: %d\n",
+
+		dprintf1("sys_mprotect_pkey(%p, %zx, prot=0x%lx, pkey=%ld) "
+				"ret: %d\n",
 				ptr, size, orig_prot, pkey, ret);
 		if (nr_iterations-- < 0)
 			break;
 
-		dprintf1("%s()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n", __func__,
-			__LINE__, ret, __rdpkru(), shadow_pkru);
+		dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+			__func__, __LINE__, ret, __rdpkey_reg(),
+			shadow_pkey_reg);
 		sys_pkey_free(rpkey);
-		dprintf1("%s()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n", __func__,
-			__LINE__, ret, __rdpkru(), shadow_pkru);
+		dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+			__func__, __LINE__, ret, __rdpkey_reg(),
+			shadow_pkey_reg);
 	}
 	pkey_assert(pkey < NR_PKEYS);
 
@@ -682,8 +690,8 @@ int mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot,
 	dprintf1("mprotect_pkey(%p, %zx, prot=0x%lx, pkey=%ld) ret: %d\n",
 			ptr, size, orig_prot, pkey, ret);
 	pkey_assert(!ret);
-	dprintf1("%s()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n", __func__,
-			__LINE__, ret, __rdpkru(), shadow_pkru);
+	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n", __func__,
+			__LINE__, ret, __rdpkey_reg(), shadow_pkey_reg);
 	return ret;
 }
 
@@ -708,7 +716,9 @@ void record_pkey_malloc(void *ptr, long size)
 		/* every record is full */
 		size_t old_nr_records = nr_pkey_malloc_records;
 		size_t new_nr_records = (nr_pkey_malloc_records * 2 + 1);
-		size_t new_size = new_nr_records * sizeof(struct pkey_malloc_record);
+		size_t new_size = new_nr_records *
+				sizeof(struct pkey_malloc_record);
+
 		dprintf2("new_nr_records: %zd\n", new_nr_records);
 		dprintf2("new_size: %zd\n", new_size);
 		pkey_malloc_records = realloc(pkey_malloc_records, new_size);
@@ -732,9 +742,11 @@ void free_pkey_malloc(void *ptr)
 {
 	long i;
 	int ret;
+
 	dprintf3("%s(%p)\n", __func__, ptr);
 	for (i = 0; i < nr_pkey_malloc_records; i++) {
 		struct pkey_malloc_record *rec = &pkey_malloc_records[i];
+
 		dprintf4("looking for ptr %p at record[%ld/%p]: {%p, %ld}\n",
 				ptr, i, rec, rec->ptr, rec->size);
 		if ((ptr <  rec->ptr) ||
@@ -761,16 +773,46 @@ void *malloc_pkey_with_mprotect(long size, int prot, u16 pkey)
 	void *ptr;
 	int ret;
 
-	rdpkru();
+	rdpkey_reg();
+	dprintf1("doing %s(size=%ld, prot=0x%x, pkey=%d)\n", __func__,
+			size, prot, pkey);
+	pkey_assert(pkey < NR_PKEYS);
+	ptr = mmap(NULL, size, prot, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+	pkey_assert(ptr != (void *)-1);
+	ret = mprotect_pkey((void *)ptr, PAGE_SIZE, prot, pkey);
+	pkey_assert(!ret);
+	record_pkey_malloc(ptr, size);
+	rdpkey_reg();
+
+	dprintf1("%s() for pkey %d @ %p\n", __func__, pkey, ptr);
+	return ptr;
+}
+
+void *malloc_pkey_with_mprotect_subpage(long size, int prot, u16 pkey)
+{
+	void *ptr;
+	int ret;
+
+#ifndef __powerpc64__
+	return PTR_ERR_ENOTSUP;
+#endif /*  __powerpc64__ */
+	rdpkey_reg();
 	dprintf1("doing %s(size=%ld, prot=0x%x, pkey=%d)\n", __func__,
 			size, prot, pkey);
 	pkey_assert(pkey < NR_PKEYS);
 	ptr = mmap(NULL, size, prot, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
 	pkey_assert(ptr != (void *)-1);
+
+	ret = syscall(__NR_subpage_prot, ptr, size, NULL);
+	if (ret) {
+		perror("subpage_perm");
+		return PTR_ERR_ENOTSUP;
+	}
+
 	ret = mprotect_pkey((void *)ptr, PAGE_SIZE, prot, pkey);
 	pkey_assert(!ret);
 	record_pkey_malloc(ptr, size);
-	rdpkru();
+	rdpkey_reg();
 
 	dprintf1("%s() for pkey %d @ %p\n", __func__, pkey, ptr);
 	return ptr;
@@ -815,17 +857,19 @@ void setup_hugetlbfs(void)
 	char buf[] = "123";
 
 	if (geteuid() != 0) {
-		fprintf(stderr, "WARNING: not run as root, can not do hugetlb test\n");
+		fprintf(stderr,
+			"WARNING: not run as root, can not do hugetlb test\n");
 		return;
 	}
 
-	cat_into_file(__stringify(GET_NR_HUGE_PAGES), "/proc/sys/vm/nr_hugepages");
+	cat_into_file(__stringify(GET_NR_HUGE_PAGES),
+			"/proc/sys/vm/nr_hugepages");
 
 	/*
 	 * Now go make sure that we got the pages and that they
 	 * are 2M pages.  Someone might have made 1G the default.
 	 */
-	fd = open("/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages", O_RDONLY);
+	fd = open_hugepage_file(O_RDONLY);
 	if (fd < 0) {
 		perror("opening sysfs 2M hugetlb config");
 		return;
@@ -840,7 +884,8 @@ void setup_hugetlbfs(void)
 	}
 
 	if (atoi(buf) != GET_NR_HUGE_PAGES) {
-		fprintf(stderr, "could not confirm 2M pages, got: '%s' expected %d\n",
+		fprintf(stderr, "could not confirm 2M pages, got:"
+				" '%s' expected %d\n",
 			buf, GET_NR_HUGE_PAGES);
 		return;
 	}
@@ -895,12 +940,13 @@ void *malloc_pkey_mmap_dax(long size, int prot, u16 pkey)
 void *(*pkey_malloc[])(long size, int prot, u16 pkey) = {
 
 	malloc_pkey_with_mprotect,
+	malloc_pkey_with_mprotect_subpage,
 	malloc_pkey_anon_huge,
 	malloc_pkey_hugetlb
 /* can not do direct with the pkey_mprotect() API:
-	malloc_pkey_mmap_direct,
-	malloc_pkey_mmap_dax,
-*/
+ * malloc_pkey_mmap_direct,
+ * malloc_pkey_mmap_dax,
+ */
 };
 
 void *malloc_pkey(long size, int prot, u16 pkey)
@@ -933,31 +979,32 @@ void *malloc_pkey(long size, int prot, u16 pkey)
 	return ret;
 }
 
-int last_pkru_faults;
-void expected_pk_fault(int pkey)
+int last_pkey_faults;
+void expected_pkey_faults(int pkey)
 {
-	dprintf2("%s(): last_pkru_faults: %d pkru_faults: %d\n",
-			__func__, last_pkru_faults, pkru_faults);
+	dprintf2("%s(): last_pkey_faults: %d pkey_faults: %d\n",
+			__func__, last_pkey_faults, pkey_faults);
 	dprintf2("%s(%d): last_si_pkey: %d\n", __func__, pkey, last_si_pkey);
-	pkey_assert(last_pkru_faults + 1 == pkru_faults);
+	pkey_assert(last_pkey_faults + 1 == pkey_faults);
 	pkey_assert(last_si_pkey == pkey);
 	/*
-	 * The signal handler shold have cleared out PKRU to let the
+	 * The signal handler shold have cleared out pkey-register to let the
 	 * test program continue.  We now have to restore it.
 	 */
-	if (__rdpkru() != 0)
+	if (__rdpkey_reg() != shadow_pkey_reg)
 		pkey_assert(0);
 
-	__wrpkru(shadow_pkru);
-	dprintf1("%s() set PKRU=%x to restore state after signal nuked it\n",
-			__func__, shadow_pkru);
-	last_pkru_faults = pkru_faults;
+	__wrpkey_reg(shadow_pkey_reg);
+	dprintf1("%s() set pkey-register=%x to restore state "
+			" after signal nuked it\n",
+			__func__, shadow_pkey_reg);
+	last_pkey_faults = pkey_faults;
 	last_si_pkey = -1;
 }
 
 void do_not_expect_pk_fault(void)
 {
-	pkey_assert(last_pkru_faults == pkru_faults);
+	pkey_assert(last_pkey_faults == pkey_faults);
 }
 
 int test_fds[10] = { -1 };
@@ -973,6 +1020,7 @@ void __save_test_fd(int fd)
 int get_test_read_fd(void)
 {
 	int test_fd = open("/etc/passwd", O_RDONLY);
+
 	__save_test_fd(test_fd);
 	return test_fd;
 }
@@ -1009,32 +1057,76 @@ void test_read_of_write_disabled_region(int *ptr, u16 pkey)
 	ptr_contents = read_ptr(ptr);
 	dprintf1("*ptr: %d\n", ptr_contents);
 	dprintf1("\n");
+	do_not_expect_pk_fault();
 }
+
 void test_read_of_access_disabled_region(int *ptr, u16 pkey)
 {
 	int ptr_contents;
 
-	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n", pkey, ptr);
-	rdpkru();
+	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n",
+			 pkey, ptr);
+	rdpkey_reg();
+	pkey_access_deny(pkey);
+	ptr_contents = read_ptr(ptr);
+	dprintf1("*ptr: %d\n", ptr_contents);
+	expected_pkey_faults(pkey);
+}
+
+void test_read_of_access_disabled_region_with_page_already_mapped(int *ptr,
+		u16 pkey)
+{
+	int ptr_contents;
+
+	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n",
+				pkey, ptr);
+	ptr_contents = read_ptr(ptr);
+	dprintf1("reading ptr before disabling the read : %d\n",
+			ptr_contents);
+	rdpkey_reg();
 	pkey_access_deny(pkey);
 	ptr_contents = read_ptr(ptr);
 	dprintf1("*ptr: %d\n", ptr_contents);
-	expected_pk_fault(pkey);
+	expected_pkey_faults(pkey);
 }
+
+void test_write_of_write_disabled_region_with_page_already_mapped(int *ptr,
+		u16 pkey)
+{
+	*ptr = __LINE__;
+	dprintf1("disabling write access; after accessing the page, "
+		"to PKEY[%02d], doing write\n", pkey);
+	pkey_write_deny(pkey);
+	*ptr = __LINE__;
+	expected_pkey_faults(pkey);
+}
+
 void test_write_of_write_disabled_region(int *ptr, u16 pkey)
 {
 	dprintf1("disabling write access to PKEY[%02d], doing write\n", pkey);
 	pkey_write_deny(pkey);
 	*ptr = __LINE__;
-	expected_pk_fault(pkey);
+	expected_pkey_faults(pkey);
 }
 void test_write_of_access_disabled_region(int *ptr, u16 pkey)
 {
 	dprintf1("disabling access to PKEY[%02d], doing write\n", pkey);
 	pkey_access_deny(pkey);
 	*ptr = __LINE__;
-	expected_pk_fault(pkey);
+	expected_pkey_faults(pkey);
+}
+
+void test_write_of_access_disabled_region_with_page_already_mapped(int *ptr,
+			u16 pkey)
+{
+	*ptr = __LINE__;
+	dprintf1("disabling access; after accessing the page, "
+		" to PKEY[%02d], doing write\n", pkey);
+	pkey_access_deny(pkey);
+	*ptr = __LINE__;
+	expected_pkey_faults(pkey);
 }
+
 void test_kernel_write_of_access_disabled_region(int *ptr, u16 pkey)
 {
 	int ret;
@@ -1103,10 +1195,10 @@ void test_kernel_gup_write_to_write_disabled_region(int *ptr, u16 pkey)
 void test_pkey_syscalls_on_non_allocated_pkey(int *ptr, u16 pkey)
 {
 	int err;
-	int i;
+	int i = get_start_key();
 
 	/* Note: 0 is the default pkey, so don't mess with it */
-	for (i = 1; i < NR_PKEYS; i++) {
+	for (; i < NR_PKEYS; i++) {
 		if (pkey == i)
 			continue;
 
@@ -1126,7 +1218,7 @@ void test_pkey_syscalls_on_non_allocated_pkey(int *ptr, u16 pkey)
 void test_pkey_syscalls_bad_args(int *ptr, u16 pkey)
 {
 	int err;
-	int bad_pkey = NR_PKEYS+99;
+	int bad_pkey = NR_PKEYS+pkey;
 
 	/* pass a known-invalid pkey in: */
 	err = sys_mprotect_pkey(ptr, PAGE_SIZE, PROT_READ, bad_pkey);
@@ -1136,21 +1228,24 @@ void test_pkey_syscalls_bad_args(int *ptr, u16 pkey)
 /* Assumes that all pkeys other than 'pkey' are unallocated */
 void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
 {
-	int err;
+	int err = 0;
 	int allocated_pkeys[NR_PKEYS] = {0};
 	int nr_allocated_pkeys = 0;
 	int i;
 
 	for (i = 0; i < NR_PKEYS*2; i++) {
 		int new_pkey;
+
 		dprintf1("%s() alloc loop: %d\n", __func__, i);
 		new_pkey = alloc_pkey();
-		dprintf4("%s()::%d, err: %d pkru: 0x%x shadow: 0x%x\n", __func__,
-				__LINE__, err, __rdpkru(), shadow_pkru);
-		rdpkru(); /* for shadow checking */
-		dprintf2("%s() errno: %d ENOSPC: %d\n", __func__, errno, ENOSPC);
+		dprintf4("%s()::%d, err: %d pkey_reg: 0x%x shadow: 0x%x\n",
+			__func__, __LINE__, err, __rdpkey_reg(),
+			shadow_pkey_reg);
+		rdpkey_reg(); /* for shadow checking */
+		dprintf2("%s() errno: %d ENOSPC: %d\n", __func__, errno,
+			ENOSPC);
 		if ((new_pkey == -1) && (errno == ENOSPC)) {
-			dprintf2("%s() failed to allocate pkey after %d tries\n",
+			dprintf2("%s() allocate failed pkey after %d tries\n",
 				__func__, nr_allocated_pkeys);
 			break;
 		}
@@ -1165,19 +1260,17 @@ void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
 	 * failure:
 	 */
 	pkey_assert(i < NR_PKEYS*2);
-
 	/*
-	 * There are 16 pkeys supported in hardware.  One is taken
-	 * up for the default (0) and another can be taken up by
-	 * an execute-only mapping.  Ensure that we can allocate
-	 * at least 14 (16-2).
+	 * There are NR_PKEYS pkeys supported in hardware.  NR_RESERVED_KEYS
+	 * are reserved. One can be taken up by an execute-only mapping.
+	 * Ensure that we can allocate at least the remaining.
 	 */
-	pkey_assert(i >= NR_PKEYS-2);
+	pkey_assert(i >= (NR_PKEYS-NR_RESERVED_PKEYS-1));
 
 	for (i = 0; i < nr_allocated_pkeys; i++) {
 		err = sys_pkey_free(allocated_pkeys[i]);
 		pkey_assert(!err);
-		rdpkru(); /* for shadow checking */
+		rdpkey_reg(); /* for shadow checking */
 	}
 }
 
@@ -1221,10 +1314,10 @@ void test_ptrace_of_child(int *ptr, u16 pkey)
 	pkey_write_deny(pkey);
 
 	/* Write access, untested for now:
-	ret = ptrace(PTRACE_POKEDATA, child_pid, peek_at, data);
-	pkey_assert(ret != -1);
-	dprintf1("poke at %p: %ld\n", peek_at, ret);
-	*/
+	 * ret = ptrace(PTRACE_POKEDATA, child_pid, peek_at, data);
+	 * pkey_assert(ret != -1);
+	 * dprintf1("poke at %p: %ld\n", peek_at, ret);
+	 */
 
 	/*
 	 * Try to access the pkey-protected "ptr" via ptrace:
@@ -1234,7 +1327,7 @@ void test_ptrace_of_child(int *ptr, u16 pkey)
 	pkey_assert(ret != -1);
 	/* Now access from the current task, and expect an exception: */
 	peek_result = read_ptr(ptr);
-	expected_pk_fault(pkey);
+	expected_pkey_faults(pkey);
 
 	/*
 	 * Try to access the NON-pkey-protected "plain_ptr" via ptrace:
@@ -1281,7 +1374,7 @@ void test_executing_on_unreadable_memory(int *ptr, u16 pkey)
 	pkey_assert(!ret);
 	pkey_access_deny(pkey);
 
-	dprintf2("pkru: %x\n", rdpkru());
+	dprintf2("pkey_reg: %x\n", rdpkey_reg());
 
 	/*
 	 * Make sure this is an *instruction* fault
@@ -1291,7 +1384,7 @@ void test_executing_on_unreadable_memory(int *ptr, u16 pkey)
 	do_not_expect_pk_fault();
 	ptr_contents = read_ptr(p1);
 	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
-	expected_pk_fault(pkey);
+	expected_pkey_faults(pkey);
 }
 
 void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
@@ -1299,7 +1392,7 @@ void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
 	int size = PAGE_SIZE;
 	int sret;
 
-	if (cpu_has_pku()) {
+	if (cpu_has_pkey()) {
 		dprintf1("SKIP: %s: no CPU support\n", __func__);
 		return;
 	}
@@ -1311,8 +1404,11 @@ void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
 void (*pkey_tests[])(int *ptr, u16 pkey) = {
 	test_read_of_write_disabled_region,
 	test_read_of_access_disabled_region,
+	test_read_of_access_disabled_region_with_page_already_mapped,
 	test_write_of_write_disabled_region,
+	test_write_of_write_disabled_region_with_page_already_mapped,
 	test_write_of_access_disabled_region,
+	test_write_of_access_disabled_region_with_page_already_mapped,
 	test_kernel_write_of_access_disabled_region,
 	test_kernel_write_of_write_disabled_region,
 	test_kernel_gup_of_access_disabled_region,
@@ -1331,7 +1427,7 @@ void run_tests_once(void)
 
 	for (test_nr = 0; test_nr < ARRAY_SIZE(pkey_tests); test_nr++) {
 		int pkey;
-		int orig_pkru_faults = pkru_faults;
+		int orig_pkey_faults = pkey_faults;
 
 		dprintf1("======================\n");
 		dprintf1("test %d preparing...\n", test_nr);
@@ -1346,45 +1442,42 @@ void run_tests_once(void)
 		free_pkey_malloc(ptr);
 		sys_pkey_free(pkey);
 
-		dprintf1("pkru_faults: %d\n", pkru_faults);
-		dprintf1("orig_pkru_faults: %d\n", orig_pkru_faults);
+		dprintf1("pkey_faults: %d\n", pkey_faults);
+		dprintf1("orig_pkey_faults: %d\n", orig_pkey_faults);
 
 		tracing_off();
 		close_test_fds();
 
-		printf("test %2d PASSED (iteration %d)\n", test_nr, iteration_nr);
+		printf("test %2d PASSED (iteration %d)\n",
+				test_nr, iteration_nr);
 		dprintf1("======================\n\n");
 	}
 	iteration_nr++;
 }
 
-void pkey_setup_shadow(void)
-{
-	shadow_pkru = __rdpkru();
-}
-
 int main(void)
 {
 	int nr_iterations = 22;
 
 	setup_handlers();
 
-	printf("has pku: %d\n", cpu_has_pku());
+	printf("has pkey support: %d\n", cpu_has_pkey());
 
-	if (!cpu_has_pku()) {
+	if (!cpu_has_pkey()) {
 		int size = PAGE_SIZE;
 		int *ptr;
 
 		printf("running PKEY tests for unsupported CPU/OS\n");
 
-		ptr  = mmap(NULL, size, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+		ptr  = mmap(NULL, size, PROT_NONE,
+				MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
 		assert(ptr != (void *)-1);
 		test_mprotect_pkey_on_unsupported_cpu(ptr, 1);
 		exit(0);
 	}
 
 	pkey_setup_shadow();
-	printf("startup pkru: %x\n", rdpkru());
+	printf("startup pkey_reg: %lx\n", rdpkey_reg());
 	setup_hugetlbfs();
 
 	while (nr_iterations-- > 0)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
