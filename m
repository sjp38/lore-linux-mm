Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 678324403DD
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:59:58 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id y23so6821062qkb.2
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:59:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z22sor8277274qti.85.2017.11.06.00.59.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:59:57 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 35/51] selftest/vm: typecast the pkey register
Date: Mon,  6 Nov 2017 00:57:27 -0800
Message-Id: <1509958663-18737-36-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

This is in preparation to accomadate a differing size register
across architectures.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   27 +++++-----
 tools/testing/selftests/vm/protection_keys.c |   71 ++++++++++++++------------
 2 files changed, 52 insertions(+), 46 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index 1b15b54..b03f7e5 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -18,6 +18,7 @@
 #define u16 uint16_t
 #define u32 uint32_t
 #define u64 uint64_t
+#define pkey_reg_t u32
 
 #ifdef __i386__
 #define SYS_mprotect_key 380
@@ -77,12 +78,12 @@ static inline void sigsafe_printf(const char *format, ...)
 #define dprintf3(args...) dprintf_level(3, args)
 #define dprintf4(args...) dprintf_level(4, args)
 
-extern unsigned int shadow_pkey_reg;
-static inline unsigned int __rdpkey_reg(void)
+extern pkey_reg_t shadow_pkey_reg;
+static inline pkey_reg_t __rdpkey_reg(void)
 {
 	unsigned int eax, edx;
 	unsigned int ecx = 0;
-	unsigned int pkey_reg;
+	pkey_reg_t pkey_reg;
 
 	asm volatile(".byte 0x0f,0x01,0xee\n\t"
 		     : "=a" (eax), "=d" (edx)
@@ -91,11 +92,11 @@ static inline unsigned int __rdpkey_reg(void)
 	return pkey_reg;
 }
 
-static inline unsigned int _rdpkey_reg(int line)
+static inline pkey_reg_t _rdpkey_reg(int line)
 {
-	unsigned int pkey_reg = __rdpkey_reg();
+	pkey_reg_t pkey_reg = __rdpkey_reg();
 
-	dprintf4("rdpkey_reg(line=%d) pkey_reg: %x shadow: %x\n",
+	dprintf4("rdpkey_reg(line=%d) pkey_reg: %016lx shadow: %016lx\n",
 			line, pkey_reg, shadow_pkey_reg);
 	assert(pkey_reg == shadow_pkey_reg);
 
@@ -104,11 +105,11 @@ static inline unsigned int _rdpkey_reg(int line)
 
 #define rdpkey_reg() _rdpkey_reg(__LINE__)
 
-static inline void __wrpkey_reg(unsigned int pkey_reg)
+static inline void __wrpkey_reg(pkey_reg_t pkey_reg)
 {
-	unsigned int eax = pkey_reg;
-	unsigned int ecx = 0;
-	unsigned int edx = 0;
+	pkey_reg_t eax = pkey_reg;
+	pkey_reg_t ecx = 0;
+	pkey_reg_t edx = 0;
 
 	dprintf4("%s() changing %08x to %08x\n", __func__,
 			__rdpkey_reg(), pkey_reg);
@@ -117,7 +118,7 @@ static inline void __wrpkey_reg(unsigned int pkey_reg)
 	assert(pkey_reg == __rdpkey_reg());
 }
 
-static inline void wrpkey_reg(unsigned int pkey_reg)
+static inline void wrpkey_reg(pkey_reg_t pkey_reg)
 {
 	dprintf4("%s() changing %08x to %08x\n", __func__,
 			__rdpkey_reg(), pkey_reg);
@@ -135,7 +136,7 @@ static inline void wrpkey_reg(unsigned int pkey_reg)
  */
 static inline void __pkey_access_allow(int pkey, int do_allow)
 {
-	unsigned int pkey_reg = rdpkey_reg();
+	pkey_reg_t pkey_reg = rdpkey_reg();
 	int bit = pkey * 2;
 
 	if (do_allow)
@@ -149,7 +150,7 @@ static inline void __pkey_access_allow(int pkey, int do_allow)
 
 static inline void __pkey_write_allow(int pkey, int do_allow_write)
 {
-	long pkey_reg = rdpkey_reg();
+	pkey_reg_t pkey_reg = rdpkey_reg();
 	int bit = pkey * 2 + 1;
 
 	if (do_allow_write)
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index dec05e0..2e8de01 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -48,7 +48,7 @@
 int iteration_nr = 1;
 int test_nr;
 
-unsigned int shadow_pkey_reg;
+pkey_reg_t shadow_pkey_reg;
 int dprint_in_signal;
 char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
 
@@ -158,7 +158,7 @@ void dump_mem(void *dumpme, int len_bytes)
 
 	for (i = 0; i < len_bytes; i += sizeof(u64)) {
 		u64 *ptr = (u64 *)(c + i);
-		dprintf1("dump[%03d][@%p]: %016jx\n", i, ptr, *ptr);
+		dprintf1("dump[%03d][@%p]: %016lx\n", i, ptr, *ptr);
 	}
 }
 
@@ -186,15 +186,16 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	int trapno;
 	unsigned long ip;
 	char *fpregs;
-	u32 *pkey_reg_ptr;
-	u64 si_pkey;
+	pkey_reg_t *pkey_reg_ptr;
+	u32 si_pkey;
 	u32 *si_pkey_ptr;
 	int pkey_reg_offset;
 	fpregset_t fpregset;
 
 	dprint_in_signal = 1;
 	dprintf1(">>>>===============SIGSEGV============================\n");
-	dprintf1("%s()::%d, pkey_reg: 0x%x shadow: %x\n", __func__, __LINE__,
+	dprintf1("%s()::%d, pkey_reg: 0x%016lx shadow: %016lx\n",
+			__func__, __LINE__,
 			__rdpkey_reg(), shadow_pkey_reg);
 
 	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
@@ -202,8 +203,9 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
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
@@ -240,12 +242,12 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 		exit(4);
 	}
 
-	dprintf1("signal pkey_reg from xsave: %08x\n", *pkey_reg_ptr);
+	dprintf1("signal pkey_reg from xsave: %016lx\n", *pkey_reg_ptr);
 	/*
 	 * need __rdpkey_reg() version so we do not do shadow_pkey_reg
 	 * checking
 	 */
-	dprintf1("signal pkey_reg from  pkey_reg: %08x\n", __rdpkey_reg());
+	dprintf1("signal pkey_reg from  pkey_reg: %016lx\n", __rdpkey_reg());
 	dprintf1("si_pkey from siginfo: %jx\n", si_pkey);
 	*(u64 *)pkey_reg_ptr = 0x00000000;
 	dprintf1("WARNING: set PRKU=0 to allow faulting instruction to continue\n");
@@ -364,8 +366,8 @@ void dumpit(char *f)
 u32 pkey_get(int pkey, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-	u32 pkey_reg = __rdpkey_reg();
-	u32 shifted_pkey_reg;
+	pkey_reg_t pkey_reg = __rdpkey_reg();
+	pkey_reg_t shifted_pkey_reg;
 	u32 masked_pkey_reg;
 
 	dprintf1("%s(pkey=%d, flags=%lx) = %x / %d\n",
@@ -386,8 +388,8 @@ u32 pkey_get(int pkey, unsigned long flags)
 int pkey_set(int pkey, unsigned long rights, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-	u32 old_pkey_reg = __rdpkey_reg();
-	u32 new_pkey_reg;
+	pkey_reg_t old_pkey_reg = __rdpkey_reg();
+	pkey_reg_t new_pkey_reg;
 
 	/* make sure that 'rights' only contains the bits we expect: */
 	assert(!(rights & ~mask));
@@ -401,10 +403,10 @@ int pkey_set(int pkey, unsigned long rights, unsigned long flags)
 
 	__wrpkey_reg(new_pkey_reg);
 
-	dprintf3("%s(pkey=%d, rights=%lx, flags=%lx) = %x"
-	       " pkey_reg now: %x old_pkey_reg: %x\n",
-		__func__, pkey, rights, flags, 0, __rdpkey_reg(),
-		old_pkey_reg);
+	dprintf3("%s(pkey=%d, rights=%lx, flags=%lx) = %x "
+			"pkey_reg now: %016lx old_pkey_reg: %016lx\n",
+			__func__, pkey, rights, flags,
+			0, __rdpkey_reg(), old_pkey_reg);
 	return 0;
 }
 
@@ -413,7 +415,7 @@ void pkey_disable_set(int pkey, int flags)
 	unsigned long syscall_flags = 0;
 	int ret;
 	int pkey_rights;
-	u32 orig_pkey_reg = rdpkey_reg();
+	pkey_reg_t orig_pkey_reg = rdpkey_reg();
 
 	dprintf1("START->%s(%d, 0x%x)\n", __func__,
 		pkey, flags);
@@ -421,8 +423,6 @@ void pkey_disable_set(int pkey, int flags)
 
 	pkey_rights = pkey_get(pkey, syscall_flags);
 
-	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
-			pkey, pkey, pkey_rights);
 	pkey_assert(pkey_rights >= 0);
 
 	pkey_rights |= flags;
@@ -431,7 +431,8 @@ void pkey_disable_set(int pkey, int flags)
 	assert(!ret);
 	/*pkey_reg and flags have the same format */
 	shadow_pkey_reg |= flags << (pkey * 2);
-	dprintf1("%s(%d) shadow: 0x%x\n", __func__, pkey, shadow_pkey_reg);
+	dprintf1("%s(%d) shadow: 0x%016lx\n",
+		__func__, pkey, shadow_pkey_reg);
 
 	pkey_assert(ret >= 0);
 
@@ -439,7 +440,8 @@ void pkey_disable_set(int pkey, int flags)
 	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
-	dprintf1("%s(%d) pkey_reg: 0x%x\n", __func__, pkey, rdpkey_reg());
+	dprintf1("%s(%d) pkey_reg: 0x%lx\n",
+		__func__, pkey, rdpkey_reg());
 	if (flags)
 		pkey_assert(rdpkey_reg() > orig_pkey_reg);
 	dprintf1("END<---%s(%d, 0x%x)\n", __func__,
@@ -451,7 +453,7 @@ void pkey_disable_clear(int pkey, int flags)
 	unsigned long syscall_flags = 0;
 	int ret;
 	int pkey_rights = pkey_get(pkey, syscall_flags);
-	u32 orig_pkey_reg = rdpkey_reg();
+	pkey_reg_t orig_pkey_reg = rdpkey_reg();
 
 	pkey_assert(flags & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
 
@@ -470,7 +472,8 @@ void pkey_disable_clear(int pkey, int flags)
 	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
-	dprintf1("%s(%d) pkey_reg: 0x%x\n", __func__, pkey, rdpkey_reg());
+	dprintf1("%s(%d) pkey_reg: 0x%016lx\n", __func__,
+			pkey, rdpkey_reg());
 	if (flags)
 		assert(rdpkey_reg() > orig_pkey_reg);
 }
@@ -525,20 +528,21 @@ int alloc_pkey(void)
 	int ret;
 	unsigned long init_val = 0x0;
 
-	dprintf1("%s()::%d, pkey_reg: 0x%x shadow: %x\n", __func__,
+	dprintf1("%s()::%d, pkey_reg: 0x%016lx shadow: %016lx\n", __func__,
 			__LINE__, __rdpkey_reg(), shadow_pkey_reg);
 	ret = sys_pkey_alloc(0, init_val);
 	/*
 	 * pkey_alloc() sets PKEY register, so we need to reflect it in
 	 * shadow_pkey_reg:
 	 */
-	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%016lx shadow: 0x%016lx\n",
 			__func__, __LINE__, ret, __rdpkey_reg(),
 			shadow_pkey_reg);
 	if (ret) {
 		/* clear both the bits: */
 		shadow_pkey_reg &= ~(0x3      << (ret * 2));
-		dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+		dprintf4("%s()::%d, ret: %d pkey_reg: 0x%016lx "
+				"shadow: 0x%016lx\n",
 				__func__,
 				__LINE__, ret, __rdpkey_reg(),
 				shadow_pkey_reg);
@@ -548,13 +552,13 @@ int alloc_pkey(void)
 		 */
 		shadow_pkey_reg |=  (init_val << (ret * 2));
 	}
-	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%016lx shadow: 0x%016lx\n",
 			__func__, __LINE__, ret, __rdpkey_reg(),
 			shadow_pkey_reg);
 	dprintf1("%s()::%d errno: %d\n", __func__, __LINE__, errno);
 	/* for shadow checking: */
 	rdpkey_reg();
-	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%016lx shadow: 0x%016lx\n",
 		__func__, __LINE__, ret, __rdpkey_reg(),
 		shadow_pkey_reg);
 	return ret;
@@ -1103,9 +1107,10 @@ void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
 		int new_pkey;
 		dprintf1("%s() alloc loop: %d\n", __func__, i);
 		new_pkey = alloc_pkey();
-		dprintf4("%s()::%d, err: %d pkey_reg: 0x%x shadow: 0x%x\n",
-				__func__, __LINE__, err, __rdpkey_reg(),
-				shadow_pkey_reg);
+		dprintf4("%s()::%d, err: %d pkey_reg: 0x%016lx "
+				"shadow: 0x%016lx\n",
+			__func__, __LINE__, err, __rdpkey_reg(),
+			shadow_pkey_reg);
 		rdpkey_reg(); /* for shadow checking */
 		dprintf2("%s() errno: %d ENOSPC: %d\n", __func__, errno, ENOSPC);
 		if ((new_pkey == -1) && (errno == ENOSPC)) {
@@ -1343,7 +1348,7 @@ int main(void)
 	}
 
 	pkey_setup_shadow();
-	printf("startup pkey_reg: %x\n", rdpkey_reg());
+	printf("startup pkey_reg: 0x%016lx\n", rdpkey_reg());
 	setup_hugetlbfs();
 
 	while (nr_iterations-- > 0)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
