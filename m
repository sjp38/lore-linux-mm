Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9EC6B068F
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 00:00:15 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c18so59349459qkb.10
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:15 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id 19si12195420qtr.302.2017.07.15.21.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 21:00:14 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id v31so14710500qtb.3
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:14 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 53/62] selftest/vm: powerpc implementation for generic abstraction
Date: Sat, 15 Jul 2017 20:56:55 -0700
Message-Id: <1500177424-13695-54-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Introduce powerpc implementation for the various
abstactions.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   97 +++++++++++++++++++++++--
 tools/testing/selftests/vm/protection_keys.c |   33 +++++----
 2 files changed, 107 insertions(+), 23 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index 5211019..59172cc 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -17,27 +17,58 @@
 #define u16 uint16_t
 #define u32 uint32_t
 #define u64 uint64_t
-#define pkey_reg_t u32
 
-#ifdef __i386__
+#ifdef __i386__ /* arch */
+
 #define SYS_mprotect_key 380
 #define SYS_pkey_alloc	 381
 #define SYS_pkey_free	 382
 #define REG_IP_IDX REG_EIP
 #define si_pkey_offset 0x14
-#else
+
+#define NR_PKEYS		16
+#define NR_RESERVED_PKEYS	1
+#define PKEY_BITS_PER_PKEY	2
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define HPAGE_SIZE		(1UL<<21)
+#define pkey_reg_t u32
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
+#define PKEY_BITS_PER_PKEY	2
+#define PKEY_DISABLE_ACCESS	0x3  /* disable read and write */
+#define PKEY_DISABLE_WRITE	0x2
+#define HPAGE_SIZE		(1UL<<24)
+#define pkey_reg_t u64
+
+#else /* arch */
+
 #define SYS_mprotect_key 329
 #define SYS_pkey_alloc	 330
 #define SYS_pkey_free	 331
 #define REG_IP_IDX REG_RIP
 #define si_pkey_offset 0x20
-#endif
-
 #define NR_PKEYS 16
 #define PKEY_BITS_PER_PKEY 2
 #define PKEY_DISABLE_ACCESS    0x1
 #define PKEY_DISABLE_WRITE     0x2
 #define HPAGE_SIZE	(1UL<<21)
+	NOT SUPPORTED
+
+#endif /* arch */
 
 #ifndef DEBUG_LEVEL
 #define DEBUG_LEVEL 0
@@ -46,7 +77,11 @@
 
 static inline u32 pkey_to_shift(int pkey)
 {
+#ifdef __i386__ /* arch */
 	return pkey * PKEY_BITS_PER_PKEY;
+#elif __powerpc64__ /* arch */
+	return (NR_PKEYS - pkey - 1) * PKEY_BITS_PER_PKEY;
+#endif /* arch */
 }
 
 static inline pkey_reg_t reset_bits(int pkey, pkey_reg_t bits)
@@ -107,6 +142,7 @@ static inline void sigsafe_printf(const char *format, ...)
 extern pkey_reg_t shadow_pkey_reg;
 static inline pkey_reg_t __rdpkey_reg(void)
 {
+#ifdef __i386__ /* arch */
 	unsigned int eax, edx;
 	unsigned int ecx = 0;
 	pkey_reg_t pkey_reg;
@@ -114,7 +150,13 @@ static inline pkey_reg_t __rdpkey_reg(void)
 	asm volatile(".byte 0x0f,0x01,0xee\n\t"
 		     : "=a" (eax), "=d" (edx)
 		     : "c" (ecx));
-	pkey_reg = eax;
+#elif __powerpc64__ /* arch */
+	pkey_reg_t eax;
+	pkey_reg_t pkey_reg;
+
+	asm volatile("mfspr %0, 0xd" : "=r" ((pkey_reg_t)(eax)));
+#endif /* arch */
+	pkey_reg = (pkey_reg_t)eax;
 	return pkey_reg;
 }
 
@@ -134,6 +176,7 @@ static inline pkey_reg_t _rdpkey_reg(int line)
 static inline void __wrpkey_reg(pkey_reg_t pkey_reg)
 {
 	pkey_reg_t eax = pkey_reg;
+#ifdef __i386__ /* arch */
 	pkey_reg_t ecx = 0;
 	pkey_reg_t edx = 0;
 
@@ -142,6 +185,14 @@ static inline void __wrpkey_reg(pkey_reg_t pkey_reg)
 	asm volatile(".byte 0x0f,0x01,0xef\n\t"
 		     : : "a" (eax), "c" (ecx), "d" (edx));
 	assert(pkey_reg == __rdpkey_reg());
+
+#else /* arch */
+	dprintf4("%s() changing %llx to %llx\n",
+			 __func__, __rdpkey_reg(), pkey_reg);
+	asm volatile("mtspr 0xd, %0" : : "r" ((unsigned long)(eax)) : "memory");
+#endif /* arch */
+	dprintf4("%s() pkey register after changing %016lx to %016lx\n",
+			 __func__, __rdpkey_reg(), pkey_reg);
 }
 
 static inline void wrpkey_reg(pkey_reg_t pkey_reg)
@@ -188,6 +239,8 @@ static inline void __pkey_write_allow(int pkey, int do_allow_write)
 	dprintf4("pkey_reg now: %08x\n", rdpkey_reg());
 }
 
+#ifdef __i386__ /* arch */
+
 #define PAGE_SIZE 4096
 #define MB	(1<<20)
 
@@ -270,8 +323,18 @@ static inline void __page_o_noops(void)
 	/* 8-bytes of instruction * 512 bytes = 1 page */
 	asm(".rept 512 ; nopl 0x7eeeeeee(%eax) ; .endr");
 }
+#elif __powerpc64__ /* arch */
 
-#endif /* _PKEYS_HELPER_H */
+#define PAGE_SIZE (0x1UL << 16)
+static inline int cpu_has_pku(void)
+{
+	return 1;
+}
+
+/* 8-bytes of instruction * 16384bytes = 1 page */
+#define __page_o_noops() asm(".rept 16384 ; nop; .endr")
+
+#endif /* arch */
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
 #define ALIGN_UP(x, align_to)	(((x) + ((align_to)-1)) & ~((align_to)-1))
@@ -303,11 +366,29 @@ static inline void __page_o_noops(void)
 
 static inline int open_hugepage_file(int flag)
 {
-	return open("/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages",
+	int fd;
+
+#ifdef __i386__ /* arch */
+	fd = open("/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages",
 		 O_RDONLY);
+#elif __powerpc64__ /* arch */
+	fd = open("/sys/kernel/mm/hugepages/hugepages-16384kB/nr_hugepages",
+		O_RDONLY);
+#else /* arch */
+	NOT SUPPORTED
+#endif /* arch */
+	return fd;
 }
 
 static inline int get_start_key(void)
 {
+#ifdef __i386__ /* arch */
 	return 1;
+#elif __powerpc64__ /* arch */
+	return 0;
+#else /* arch */
+	NOT SUPPORTED
+#endif /* arch */
 }
+
+#endif /* _PKEYS_HELPER_H */
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index fd94449..1a28c88 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -186,6 +186,7 @@ void dump_mem(void *dumpme, int len_bytes)
 
 int pkey_faults;
 int last_si_pkey = -1;
+void pkey_access_allow(int pkey);
 void signal_handler(int signum, siginfo_t *si, void *vucontext)
 {
 	ucontext_t *uctxt = vucontext;
@@ -195,8 +196,6 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	pkey_reg_t *pkey_reg_ptr;
 	u32 si_pkey;
 	pkey_reg_t *si_pkey_ptr;
-	int pkey_reg_offset;
-	fpregset_t fpregset;
 
 	dprint_in_signal = 1;
 	dprintf1(">>>>===============SIGSEGV============================\n");
@@ -206,8 +205,7 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 
 	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
 	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
-	fpregset = uctxt->uc_mcontext.fpregs;
-	fpregs = (void *)fpregset;
+	fpregs = (char *) uctxt->uc_mcontext.fpregs;
 
 	dprintf2("%s() trapno: %d ip: 0x%016lx info->si_code: %s/%d\n",
 			__func__, trapno, ip, si_code_str(si->si_code),
@@ -219,19 +217,20 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	 * state.  We just assume that it is here.
 	 */
 	fpregs += 0x70;
-#endif
-	pkey_reg_offset = pkey_reg_xstate_offset();
-	pkey_reg_ptr = (void *)(&fpregs[pkey_reg_offset]);
-
-	dprintf1("siginfo: %p\n", si);
-	dprintf1(" fpregs: %p\n", fpregs);
+	pkey_reg_ptr = (void *)(&fpregs[pkru_xstate_offset()]);
 	/*
-	 * If we got a PKEY fault, we *HAVE* to have at least one bit set in
+	 * If we got a key fault, we *HAVE* to have at least one bit set in
 	 * here.
 	 */
-	dprintf1("pkey_reg_xstate_offset: %d\n", pkey_reg_xstate_offset());
+	dprintf1("pkru_xstate_offset: %d\n", pkru_xstate_offset());
 	if (DEBUG_LEVEL > 4)
 		dump_mem(pkey_reg_ptr - 128, 256);
+#elif __powerpc64__
+	pkey_reg_ptr = &uctxt->uc_mcontext.gregs[REG_AMR];
+#endif
+
+	dprintf1("siginfo: %p\n", si);
+	dprintf1(" fpregs: %p\n", fpregs);
 	pkey_assert(*pkey_reg_ptr);
 
 	si_pkey_ptr = (pkey_reg_t *)(((u8 *)si) + si_pkey_offset);
@@ -254,13 +253,17 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	 * checking
 	 */
 	dprintf1("signal pkey_reg from  pkey_reg: %016lx\n", __rdpkey_reg());
-	dprintf1("si_pkey from siginfo: %jx\n", si_pkey);
-	*(u64 *)pkey_reg_ptr = 0x00000000;
+	dprintf1("si_pkey from siginfo: %lx\n", si_pkey);
+#ifdef __i386__
+	*(u64 *)pkey_reg_ptr &= reset_bits(si_pkey, PKEY_DISABLE_ACCESS);
+#elif __powerpc64__
+	pkey_access_allow(si_pkey);
+#endif
+	shadow_pkey_reg &= reset_bits(si_pkey, PKEY_DISABLE_ACCESS);
 	dprintf1("WARNING: set PKEY_REG=0 to allow faulting instruction "
 			"to continue\n");
 	pkey_faults++;
 	dprintf1("<<<<==================================================\n");
-	return;
 }
 
 int wait_all_children(void)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
