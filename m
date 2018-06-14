Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0B46B0269
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 20:46:58 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id x186-v6so3607221qkb.0
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 17:46:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g185-v6sor2067363qkf.141.2018.06.13.17.46.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 17:46:57 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v13 06/24] selftests/vm: typecast the pkey register
Date: Wed, 13 Jun 2018 17:44:57 -0700
Message-Id: <1528937115-10132-7-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

This is in preparation to accomadate a differing size register
across architectures.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   23 ++++---
 tools/testing/selftests/vm/pkey-x86.h        |   16 +++--
 tools/testing/selftests/vm/protection_keys.c |   87 +++++++++++++++----------
 3 files changed, 73 insertions(+), 53 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index 7f18a82..2a1a024 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -80,13 +80,14 @@ static inline void sigsafe_printf(const char *format, ...)
 #error Architecture not supported
 #endif /* arch */
 
-extern unsigned int shadow_pkey_reg;
+extern pkey_reg_t shadow_pkey_reg;
 
-static inline unsigned int _read_pkey_reg(int line)
+static inline pkey_reg_t _read_pkey_reg(int line)
 {
-	unsigned int pkey_reg = __read_pkey_reg();
+	pkey_reg_t pkey_reg = __read_pkey_reg();
 
-	dprintf4("read_pkey_reg(line=%d) pkey_reg: %x shadow: %x\n",
+	dprintf4("read_pkey_reg(line=%d) pkey_reg: "PKEY_REG_FMT
+			" shadow: "PKEY_REG_FMT"\n",
 			line, pkey_reg, shadow_pkey_reg);
 	assert(pkey_reg == shadow_pkey_reg);
 
@@ -95,15 +96,15 @@ static inline unsigned int _read_pkey_reg(int line)
 
 #define read_pkey_reg() _read_pkey_reg(__LINE__)
 
-static inline void write_pkey_reg(unsigned int pkey_reg)
+static inline void write_pkey_reg(pkey_reg_t pkey_reg)
 {
-	dprintf4("%s() changing %08x to %08x\n", __func__,
+	dprintf4("%s() changing "PKEY_REG_FMT" to "PKEY_REG_FMT"\n", __func__,
 			__read_pkey_reg(), pkey_reg);
 	/* will do the shadow check for us: */
 	read_pkey_reg();
 	__write_pkey_reg(pkey_reg);
 	shadow_pkey_reg = pkey_reg;
-	dprintf4("%s(%08x) pkey_reg: %08x\n", __func__,
+	dprintf4("%s("PKEY_REG_FMT") pkey_reg: "PKEY_REG_FMT"\n", __func__,
 			pkey_reg, __read_pkey_reg());
 }
 
@@ -113,7 +114,7 @@ static inline void write_pkey_reg(unsigned int pkey_reg)
  */
 static inline void __pkey_access_allow(int pkey, int do_allow)
 {
-	unsigned int pkey_reg = read_pkey_reg();
+	pkey_reg_t pkey_reg = read_pkey_reg();
 	int bit = pkey * 2;
 
 	if (do_allow)
@@ -121,13 +122,13 @@ static inline void __pkey_access_allow(int pkey, int do_allow)
 	else
 		pkey_reg |= (1<<bit);
 
-	dprintf4("pkey_reg now: %08x\n", read_pkey_reg());
+	dprintf4("pkey_reg now: "PKEY_REG_FMT"\n", read_pkey_reg());
 	write_pkey_reg(pkey_reg);
 }
 
 static inline void __pkey_write_allow(int pkey, int do_allow_write)
 {
-	long pkey_reg = read_pkey_reg();
+	pkey_reg_t pkey_reg = read_pkey_reg();
 	int bit = pkey * 2 + 1;
 
 	if (do_allow_write)
@@ -136,7 +137,7 @@ static inline void __pkey_write_allow(int pkey, int do_allow_write)
 		pkey_reg |= (1<<bit);
 
 	write_pkey_reg(pkey_reg);
-	dprintf4("pkey_reg now: %08x\n", read_pkey_reg());
+	dprintf4("pkey_reg now: "PKEY_REG_FMT"\n", read_pkey_reg());
 }
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
diff --git a/tools/testing/selftests/vm/pkey-x86.h b/tools/testing/selftests/vm/pkey-x86.h
index 2f04ade..5f40901 100644
--- a/tools/testing/selftests/vm/pkey-x86.h
+++ b/tools/testing/selftests/vm/pkey-x86.h
@@ -46,6 +46,8 @@
 #define HPAGE_SIZE		(1UL<<21)
 #define PAGE_SIZE		4096
 #define MB			(1<<20)
+#define pkey_reg_t		u32
+#define PKEY_REG_FMT		"%016x"
 
 static inline void __page_o_noops(void)
 {
@@ -53,11 +55,11 @@ static inline void __page_o_noops(void)
 	asm(".rept 512 ; nopl 0x7eeeeeee(%eax) ; .endr");
 }
 
-static inline unsigned int __read_pkey_reg(void)
+static inline pkey_reg_t __read_pkey_reg(void)
 {
 	unsigned int eax, edx;
 	unsigned int ecx = 0;
-	unsigned int pkey_reg;
+	pkey_reg_t pkey_reg;
 
 	asm volatile(".byte 0x0f,0x01,0xee\n\t"
 		     : "=a" (eax), "=d" (edx)
@@ -66,13 +68,13 @@ static inline unsigned int __read_pkey_reg(void)
 	return pkey_reg;
 }
 
-static inline void __write_pkey_reg(unsigned int pkey_reg)
+static inline void __write_pkey_reg(pkey_reg_t pkey_reg)
 {
-	unsigned int eax = pkey_reg;
-	unsigned int ecx = 0;
-	unsigned int edx = 0;
+	pkey_reg_t eax = pkey_reg;
+	pkey_reg_t ecx = 0;
+	pkey_reg_t edx = 0;
 
-	dprintf4("%s() changing %08x to %08x\n", __func__,
+	dprintf4("%s() changing "PKEY_REG_FMT" to "PKEY_REG_FMT"\n", __func__,
 			__read_pkey_reg(), pkey_reg);
 	asm volatile(".byte 0x0f,0x01,0xef\n\t"
 		     : : "a" (eax), "c" (ecx), "d" (edx));
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 99e4e1e..90b3a41 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -48,7 +48,7 @@
 int iteration_nr = 1;
 int test_nr;
 
-unsigned int shadow_pkey_reg;
+pkey_reg_t shadow_pkey_reg;
 int dprint_in_signal;
 char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
 
@@ -163,7 +163,7 @@ void dump_mem(void *dumpme, int len_bytes)
 
 	for (i = 0; i < len_bytes; i += sizeof(u64)) {
 		u64 *ptr = (u64 *)(c + i);
-		dprintf1("dump[%03d][@%p]: %016jx\n", i, ptr, *ptr);
+		dprintf1("dump[%03d][@%p]: %016lx\n", i, ptr, *ptr);
 	}
 }
 
@@ -197,7 +197,7 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	int trapno;
 	unsigned long ip;
 	char *fpregs;
-	u32 *pkey_reg_ptr;
+	pkey_reg_t *pkey_reg_ptr;
 	u64 siginfo_pkey;
 	u32 *si_pkey_ptr;
 	int pkey_reg_offset;
@@ -205,7 +205,8 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 
 	dprint_in_signal = 1;
 	dprintf1(">>>>===============SIGSEGV============================\n");
-	dprintf1("%s()::%d, pkey_reg: 0x%x shadow: %x\n", __func__, __LINE__,
+	dprintf1("%s()::%d, pkey_reg: "PKEY_REG_FMT" shadow: "PKEY_REG_FMT"\n",
+			__func__, __LINE__,
 			__read_pkey_reg(), shadow_pkey_reg);
 
 	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
@@ -213,8 +214,9 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	fpregset = uctxt->uc_mcontext.fpregs;
 	fpregs = (void *)fpregset;
 
-	dprintf2("%s() trapno: %d ip: 0x%lx info->si_code: %s/%d\n", __func__,
-			trapno, ip, si_code_str(si->si_code), si->si_code);
+	dprintf2("%s() trapno: %d ip: 0x%016lx info->si_code: %s/%d\n",
+			__func__, trapno, ip, si_code_str(si->si_code),
+			si->si_code);
 #ifdef __i386__
 	/*
 	 * 32-bit has some extra padding so that userspace can tell whether
@@ -251,12 +253,13 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	pkey_assert(siginfo_pkey < NR_PKEYS);
 	last_si_pkey = siginfo_pkey;
 
-	dprintf1("signal pkey_reg from xsave: %08x\n", *pkey_reg_ptr);
+	dprintf1("signal pkey_reg from xsave: "PKEY_REG_FMT"\n", *pkey_reg_ptr);
 	/*
 	 * need __read_pkey_reg() version so we do not do shadow_pkey_reg
 	 * checking
 	 */
-	dprintf1("signal pkey_reg from  pkey_reg: %08x\n", __read_pkey_reg());
+	dprintf1("signal pkey_reg from  pkey_reg: "PKEY_REG_FMT"\n",
+			__read_pkey_reg());
 	dprintf1("pkey from siginfo: %jx\n", siginfo_pkey);
 	*(u64 *)pkey_reg_ptr = 0x00000000;
 	dprintf1("WARNING: set PRKU=0 to allow faulting instruction to continue\n");
@@ -331,16 +334,17 @@ pid_t fork_lazy_child(void)
 static u32 hw_pkey_get(int pkey, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-	u32 pkey_reg = __read_pkey_reg();
-	u32 shifted_pkey_reg;
+	pkey_reg_t pkey_reg = __read_pkey_reg();
+	pkey_reg_t shifted_pkey_reg;
 	u32 masked_pkey_reg;
 
 	dprintf1("%s(pkey=%d, flags=%lx) = %x / %d\n",
 			__func__, pkey, flags, 0, 0);
-	dprintf2("%s() raw pkey_reg: %x\n", __func__, pkey_reg);
+	dprintf2("%s() raw pkey_reg: "PKEY_REG_FMT"\n", __func__, pkey_reg);
 
 	shifted_pkey_reg = (pkey_reg >> (pkey * PKEY_BITS_PER_PKEY));
-	dprintf2("%s() shifted_pkey_reg: %x\n", __func__, shifted_pkey_reg);
+	dprintf2("%s() shifted_pkey_reg: "PKEY_REG_FMT"\n", __func__,
+			shifted_pkey_reg);
 	masked_pkey_reg = shifted_pkey_reg & mask;
 	dprintf2("%s() masked  pkey_reg: %x\n", __func__, masked_pkey_reg);
 	/*
@@ -353,8 +357,8 @@ static u32 hw_pkey_get(int pkey, unsigned long flags)
 static int hw_pkey_set(int pkey, unsigned long rights, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-	u32 old_pkey_reg = __read_pkey_reg();
-	u32 new_pkey_reg;
+	pkey_reg_t old_pkey_reg = __read_pkey_reg();
+	pkey_reg_t new_pkey_reg;
 
 	/* make sure that 'rights' only contains the bits we expect: */
 	assert(!(rights & ~mask));
@@ -369,7 +373,7 @@ static int hw_pkey_set(int pkey, unsigned long rights, unsigned long flags)
 	__write_pkey_reg(new_pkey_reg);
 
 	dprintf3("%s(pkey=%d, rights=%lx, flags=%lx) = %x"
-	       " pkey_reg now: %x old_pkey_reg: %x\n",
+		" pkey_reg now: "PKEY_REG_FMT" old_pkey_reg: "PKEY_REG_FMT"\n",
 		__func__, pkey, rights, flags, 0, __read_pkey_reg(),
 		old_pkey_reg);
 	return 0;
@@ -380,7 +384,7 @@ void pkey_disable_set(int pkey, int flags)
 	unsigned long syscall_flags = 0;
 	int ret;
 	int pkey_rights;
-	u32 orig_pkey_reg = read_pkey_reg();
+	pkey_reg_t orig_pkey_reg = read_pkey_reg();
 
 	dprintf1("START->%s(%d, 0x%x)\n", __func__,
 		pkey, flags);
@@ -390,6 +394,7 @@ void pkey_disable_set(int pkey, int flags)
 
 	dprintf1("%s(%d) hw_pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
+
 	pkey_assert(pkey_rights >= 0);
 
 	pkey_rights |= flags;
@@ -398,7 +403,8 @@ void pkey_disable_set(int pkey, int flags)
 	assert(!ret);
 	/*pkey_reg and flags have the same format */
 	shadow_pkey_reg |= flags << (pkey * 2);
-	dprintf1("%s(%d) shadow: 0x%x\n", __func__, pkey, shadow_pkey_reg);
+	dprintf1("%s(%d) shadow: 0x"PKEY_REG_FMT"\n",
+		__func__, pkey, shadow_pkey_reg);
 
 	pkey_assert(ret >= 0);
 
@@ -406,7 +412,8 @@ void pkey_disable_set(int pkey, int flags)
 	dprintf1("%s(%d) hw_pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
-	dprintf1("%s(%d) pkey_reg: 0x%x\n", __func__, pkey, read_pkey_reg());
+	dprintf1("%s(%d) pkey_reg: 0x"PKEY_REG_FMT"\n",
+		__func__, pkey, read_pkey_reg());
 	if (flags)
 		pkey_assert(read_pkey_reg() > orig_pkey_reg);
 	dprintf1("END<---%s(%d, 0x%x)\n", __func__,
@@ -418,7 +425,7 @@ void pkey_disable_clear(int pkey, int flags)
 	unsigned long syscall_flags = 0;
 	int ret;
 	int pkey_rights = hw_pkey_get(pkey, syscall_flags);
-	u32 orig_pkey_reg = read_pkey_reg();
+	pkey_reg_t orig_pkey_reg = read_pkey_reg();
 
 	pkey_assert(flags & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
 
@@ -436,7 +443,8 @@ void pkey_disable_clear(int pkey, int flags)
 	dprintf1("%s(%d) hw_pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
-	dprintf1("%s(%d) pkey_reg: 0x%x\n", __func__, pkey, read_pkey_reg());
+	dprintf1("%s(%d) pkey_reg: 0x"PKEY_REG_FMT"\n", __func__,
+			pkey, read_pkey_reg());
 	if (flags)
 		assert(read_pkey_reg() > orig_pkey_reg);
 }
@@ -491,20 +499,22 @@ int alloc_pkey(void)
 	int ret;
 	unsigned long init_val = 0x0;
 
-	dprintf1("%s()::%d, pkey_reg: 0x%x shadow: %x\n", __func__,
-			__LINE__, __read_pkey_reg(), shadow_pkey_reg);
+	dprintf1("%s()::%d, pkey_reg: "PKEY_REG_FMT" shadow: "PKEY_REG_FMT"\n",
+			__func__, __LINE__, __read_pkey_reg(), shadow_pkey_reg);
 	ret = sys_pkey_alloc(0, init_val);
 	/*
 	 * pkey_alloc() sets PKEY register, so we need to reflect it in
 	 * shadow_pkey_reg:
 	 */
-	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
+			" shadow: 0x"PKEY_REG_FMT"\n",
 			__func__, __LINE__, ret, __read_pkey_reg(),
 			shadow_pkey_reg);
 	if (ret) {
 		/* clear both the bits: */
 		shadow_pkey_reg &= ~(0x3      << (ret * 2));
-		dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+		dprintf4("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
+				" shadow: 0x"PKEY_REG_FMT"\n",
 				__func__,
 				__LINE__, ret, __read_pkey_reg(),
 				shadow_pkey_reg);
@@ -514,13 +524,15 @@ int alloc_pkey(void)
 		 */
 		shadow_pkey_reg |=  (init_val << (ret * 2));
 	}
-	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
+			" shadow: 0x"PKEY_REG_FMT"\n",
 			__func__, __LINE__, ret, __read_pkey_reg(),
 			shadow_pkey_reg);
 	dprintf1("%s()::%d errno: %d\n", __func__, __LINE__, errno);
 	/* for shadow checking: */
 	read_pkey_reg();
-	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
+		 " shadow: 0x"PKEY_REG_FMT"\n",
 		__func__, __LINE__, ret, __read_pkey_reg(),
 		shadow_pkey_reg);
 	return ret;
@@ -573,7 +585,8 @@ int alloc_random_pkey(void)
 		free_ret = sys_pkey_free(alloced_pkeys[i]);
 		pkey_assert(!free_ret);
 	}
-	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n", __func__,
+	dprintf1("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
+			 " shadow: 0x"PKEY_REG_FMT"\n", __func__,
 			__LINE__, ret, __read_pkey_reg(), shadow_pkey_reg);
 	return ret;
 }
@@ -592,11 +605,13 @@ int mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot,
 		if (nr_iterations-- < 0)
 			break;
 
-		dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+		dprintf1("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
+			" shadow: 0x"PKEY_REG_FMT"\n",
 			__func__, __LINE__, ret, __read_pkey_reg(),
 			shadow_pkey_reg);
 		sys_pkey_free(rpkey);
-		dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+		dprintf1("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
+			" shadow: 0x"PKEY_REG_FMT"\n",
 			__func__, __LINE__, ret, __read_pkey_reg(),
 			shadow_pkey_reg);
 	}
@@ -606,7 +621,8 @@ int mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot,
 	dprintf1("mprotect_pkey(%p, %zx, prot=0x%lx, pkey=%ld) ret: %d\n",
 			ptr, size, orig_prot, pkey, ret);
 	pkey_assert(!ret);
-	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n", __func__,
+	dprintf1("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
+			" shadow: 0x"PKEY_REG_FMT"\n", __func__,
 			__LINE__, ret, __read_pkey_reg(), shadow_pkey_reg);
 	return ret;
 }
@@ -885,7 +901,7 @@ void expected_pkey_fault(int pkey)
 		pkey_assert(0);
 
 	__write_pkey_reg(shadow_pkey_reg);
-	dprintf1("%s() set pkey_reg=%x to restore state after signal "
+	dprintf1("%s() set pkey_reg="PKEY_REG_FMT" to restore state after signal "
 		       "nuked it\n", __func__, shadow_pkey_reg);
 	last_pkey_faults = pkey_faults;
 	last_si_pkey = -1;
@@ -1082,7 +1098,8 @@ void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
 		int new_pkey;
 		dprintf1("%s() alloc loop: %d\n", __func__, i);
 		new_pkey = alloc_pkey();
-		dprintf4("%s()::%d, err: %d pkey_reg: 0x%x shadow: 0x%x\n",
+		dprintf4("%s()::%d, err: %d pkey_reg: 0x"PKEY_REG_FMT
+				" shadow: 0x"PKEY_REG_FMT"\n",
 				__func__, __LINE__, err, __read_pkey_reg(),
 				shadow_pkey_reg);
 		read_pkey_reg(); /* for shadow checking */
@@ -1264,7 +1281,7 @@ void test_executing_on_unreadable_memory(int *ptr, u16 pkey)
 	pkey_assert(!ret);
 	pkey_access_deny(pkey);
 
-	dprintf2("pkey_reg: %x\n", read_pkey_reg());
+	dprintf2("pkey_reg: "PKEY_REG_FMT"\n", read_pkey_reg());
 
 	/*
 	 * Make sure this is an *instruction* fault
@@ -1295,7 +1312,7 @@ void test_implicit_mprotect_exec_only_memory(int *ptr, u16 pkey)
 	ret = mprotect(p1, PAGE_SIZE, PROT_EXEC);
 	pkey_assert(!ret);
 
-	dprintf2("pkru: %x\n", read_pkey_reg());
+	dprintf2("pkru: "PKEY_REG_FMT"\n", read_pkey_reg());
 
 	/* Make sure this is an *instruction* fault */
 	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
@@ -1412,7 +1429,7 @@ int main(void)
 	}
 
 	pkey_setup_shadow();
-	printf("startup pkey_reg: %x\n", read_pkey_reg());
+	printf("startup pkey_reg: 0x"PKEY_REG_FMT"\n", read_pkey_reg());
 	setup_hugetlbfs();
 
 	while (nr_iterations-- > 0)
-- 
1.7.1
