Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1D7E6B0678
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:59:47 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g2so57151051qta.14
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:47 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id p28si2689079qta.70.2017.07.15.20.59.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:59:45 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id a66so16023138qkb.0
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:45 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 42/62] selftest/vm: rename all references to pkru to a generic name
Date: Sat, 15 Jul 2017 20:56:44 -0700
Message-Id: <1500177424-13695-43-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

some pkru references are named to pkey_reg
and some prku references are renamed to pkey

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   85 +++++-----
 tools/testing/selftests/vm/protection_keys.c |  227 ++++++++++++++------------
 2 files changed, 164 insertions(+), 148 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index b202939..2d9887a 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -13,7 +13,7 @@
 #include <sys/mman.h>
 
 #define NR_PKEYS 16
-#define PKRU_BITS_PER_PKEY 2
+#define PKEY_BITS_PER_PKEY 2
 
 #ifndef DEBUG_LEVEL
 #define DEBUG_LEVEL 0
@@ -53,85 +53,88 @@ static inline void sigsafe_printf(const char *format, ...)
 #define dprintf3(args...) dprintf_level(3, args)
 #define dprintf4(args...) dprintf_level(4, args)
 
-extern unsigned int shadow_pkru;
-static inline unsigned int __rdpkru(void)
+extern unsigned int shadow_pkey_reg;
+static inline unsigned int __rdpkey_reg(void)
 {
 	unsigned int eax, edx;
 	unsigned int ecx = 0;
-	unsigned int pkru;
+	unsigned int pkey_reg;
 
 	asm volatile(".byte 0x0f,0x01,0xee\n\t"
 		     : "=a" (eax), "=d" (edx)
 		     : "c" (ecx));
-	pkru = eax;
-	return pkru;
+	pkey_reg = eax;
+	return pkey_reg;
 }
 
-static inline unsigned int _rdpkru(int line)
+static inline unsigned int _rdpkey_reg(int line)
 {
-	unsigned int pkru = __rdpkru();
+	unsigned int pkey_reg = __rdpkey_reg();
 
-	dprintf4("rdpkru(line=%d) pkru: %x shadow: %x\n",
-			line, pkru, shadow_pkru);
-	assert(pkru == shadow_pkru);
+	dprintf4("rdpkey_reg(line=%d) pkey_reg: %x shadow: %x\n",
+			line, pkey_reg, shadow_pkey_reg);
+	assert(pkey_reg == shadow_pkey_reg);
 
-	return pkru;
+	return pkey_reg;
 }
 
-#define rdpkru() _rdpkru(__LINE__)
+#define rdpkey_reg() _rdpkey_reg(__LINE__)
 
-static inline void __wrpkru(unsigned int pkru)
+static inline void __wrpkey_reg(unsigned int pkey_reg)
 {
-	unsigned int eax = pkru;
+	unsigned int eax = pkey_reg;
 	unsigned int ecx = 0;
 	unsigned int edx = 0;
 
-	dprintf4("%s() changing %08x to %08x\n", __func__, __rdpkru(), pkru);
+	dprintf4("%s() changing %08x to %08x\n", __func__,
+			__rdpkey_reg(), pkey_reg);
 	asm volatile(".byte 0x0f,0x01,0xef\n\t"
 		     : : "a" (eax), "c" (ecx), "d" (edx));
-	assert(pkru == __rdpkru());
+	assert(pkey_reg == __rdpkey_reg());
 }
 
-static inline void wrpkru(unsigned int pkru)
+static inline void wrpkey_reg(unsigned int pkey_reg)
 {
-	dprintf4("%s() changing %08x to %08x\n", __func__, __rdpkru(), pkru);
+	dprintf4("%s() changing %08x to %08x\n", __func__,
+			__rdpkey_reg(), pkey_reg);
 	/* will do the shadow check for us: */
-	rdpkru();
-	__wrpkru(pkru);
-	shadow_pkru = pkru;
-	dprintf4("%s(%08x) pkru: %08x\n", __func__, pkru, __rdpkru());
+	rdpkey_reg();
+	__wrpkey_reg(pkey_reg);
+	shadow_pkey_reg = pkey_reg;
+	dprintf4("%s(%08x) pkey_reg: %08x\n", __func__,
+			pkey_reg, __rdpkey_reg());
 }
 
 /*
  * These are technically racy. since something could
- * change PKRU between the read and the write.
+ * change PKEY register between the read and the write.
  */
 static inline void __pkey_access_allow(int pkey, int do_allow)
 {
-	unsigned int pkru = rdpkru();
+	unsigned int pkey_reg = rdpkey_reg();
 	int bit = pkey * 2;
 
 	if (do_allow)
-		pkru &= (1<<bit);
+		pkey_reg &= (1<<bit);
 	else
-		pkru |= (1<<bit);
+		pkey_reg |= (1<<bit);
 
-	dprintf4("pkru now: %08x\n", rdpkru());
-	wrpkru(pkru);
+	dprintf4("pkey_reg now: %08x\n", rdpkey_reg());
+	wrpkey_reg(pkey_reg);
 }
 
 static inline void __pkey_write_allow(int pkey, int do_allow_write)
 {
-	long pkru = rdpkru();
+	long pkey_reg = rdpkey_reg();
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
+	dprintf4("pkey_reg now: %08x\n", rdpkey_reg());
 }
 
 #define PROT_PKEY0     0x10            /* protection key value (bit 0) */
@@ -181,10 +184,10 @@ static inline int cpu_has_pku(void)
 	return 1;
 }
 
-#define XSTATE_PKRU_BIT	(9)
-#define XSTATE_PKRU	0x200
+#define XSTATE_PKEY_BIT	(9)
+#define XSTATE_PKEY	0x200
 
-int pkru_xstate_offset(void)
+int pkey_reg_xstate_offset(void)
 {
 	unsigned int eax;
 	unsigned int ebx;
@@ -195,21 +198,21 @@ int pkru_xstate_offset(void)
 	unsigned long XSTATE_CPUID = 0xd;
 	int leaf;
 
-	/* assume that XSTATE_PKRU is set in XCR0 */
-	leaf = XSTATE_PKRU_BIT;
+	/* assume that XSTATE_PKEY is set in XCR0 */
+	leaf = XSTATE_PKEY_BIT;
 	{
 		eax = XSTATE_CPUID;
 		ecx = leaf;
 		__cpuid(&eax, &ebx, &ecx, &edx);
 
-		if (leaf == XSTATE_PKRU_BIT) {
+		if (leaf == XSTATE_PKEY_BIT) {
 			xstate_offset = ebx;
 			xstate_size = eax;
 		}
 	}
 
 	if (xstate_size == 0) {
-		printf("could not find size/offset of PKRU in xsave state\n");
+		printf("could not find size/offset of PKEY in xsave state\n");
 		return 0;
 	}
 
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 3237bc0..2a237e2 100644
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
+ *  * how to set/clear bits in pkey registers (the rights register)
+ *  * how to handle SEGV_PKUERR signals and extract pkey-relevant
  *    information from the siginfo
  *
  * Things to add:
@@ -47,7 +47,7 @@
 int iteration_nr = 1;
 int test_nr;
 
-unsigned int shadow_pkru;
+unsigned int shadow_pkey_reg;
 
 #define HPAGE_SIZE	(1UL<<21)
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
@@ -229,7 +229,7 @@ void dump_mem(void *dumpme, int len_bytes)
 	return "UNKNOWN";
 }
 
-int pkru_faults;
+int pkey_faults;
 int last_si_pkey = -1;
 void signal_handler(int signum, siginfo_t *si, void *vucontext)
 {
@@ -237,16 +237,16 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	int trapno;
 	unsigned long ip;
 	char *fpregs;
-	u32 *pkru_ptr;
+	u32 *pkey_reg_ptr;
 	u64 si_pkey;
 	u32 *si_pkey_ptr;
-	int pkru_offset;
+	int pkey_reg_offset;
 	fpregset_t fpregset;
 
 	dprint_in_signal = 1;
 	dprintf1(">>>>===============SIGSEGV============================\n");
-	dprintf1("%s()::%d, pkru: 0x%x shadow: %x\n", __func__, __LINE__,
-			__rdpkru(), shadow_pkru);
+	dprintf1("%s()::%d, pkey_reg: 0x%x shadow: %x\n", __func__, __LINE__,
+			__rdpkey_reg(), shadow_pkey_reg);
 
 	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
 	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
@@ -263,19 +263,19 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 	 */
 	fpregs += 0x70;
 #endif
-	pkru_offset = pkru_xstate_offset();
-	pkru_ptr = (void *)(&fpregs[pkru_offset]);
+	pkey_reg_offset = pkey_reg_xstate_offset();
+	pkey_reg_ptr = (void *)(&fpregs[pkey_reg_offset]);
 
 	dprintf1("siginfo: %p\n", si);
 	dprintf1(" fpregs: %p\n", fpregs);
 	/*
-	 * If we got a PKRU fault, we *HAVE* to have at least one bit set in
+	 * If we got a PKEY fault, we *HAVE* to have at least one bit set in
 	 * here.
 	 */
-	dprintf1("pkru_xstate_offset: %d\n", pkru_xstate_offset());
+	dprintf1("pkey_reg_xstate_offset: %d\n", pkey_reg_xstate_offset());
 	if (DEBUG_LEVEL > 4)
-		dump_mem(pkru_ptr - 128, 256);
-	pkey_assert(*pkru_ptr);
+		dump_mem(pkey_reg_ptr - 128, 256);
+	pkey_assert(*pkey_reg_ptr);
 
 	si_pkey_ptr = (u32 *)(((u8 *)si) + si_pkey_offset);
 	dprintf1("si_pkey_ptr: %p\n", si_pkey_ptr);
@@ -291,13 +291,16 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 		exit(4);
 	}
 
-	dprintf1("signal pkru from xsave: %08x\n", *pkru_ptr);
-	/* need __rdpkru() version so we do not do shadow_pkru checking */
-	dprintf1("signal pkru from  pkru: %08x\n", __rdpkru());
+	dprintf1("signal pkey_reg from xsave: %08x\n", *pkey_reg_ptr);
+	/*
+	 * need __rdpkey_reg() version so we do not do shadow_pkey_reg
+	 * checking
+	 */
+	dprintf1("signal pkey_reg from  pkey_reg: %08x\n", __rdpkey_reg());
 	dprintf1("si_pkey from siginfo: %jx\n", si_pkey);
-	*(u64 *)pkru_ptr = 0x00000000;
+	*(u64 *)pkey_reg_ptr = 0x00000000;
 	dprintf1("WARNING: set PRKU=0 to allow faulting instruction to continue\n");
-	pkru_faults++;
+	pkey_faults++;
 	dprintf1("<<<<==================================================\n");
 	return;
 	if (trapno == 14) {
@@ -415,45 +418,47 @@ void dumpit(char *f)
 u32 pkey_get(int pkey, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-	u32 pkru = __rdpkru();
-	u32 shifted_pkru;
-	u32 masked_pkru;
+	u32 pkey_reg = __rdpkey_reg();
+	u32 shifted_pkey_reg;
+	u32 masked_pkey_reg;
 
 	dprintf1("%s(pkey=%d, flags=%lx) = %x / %d\n",
 			__func__, pkey, flags, 0, 0);
-	dprintf2("%s() raw pkru: %x\n", __func__, pkru);
+	dprintf2("%s() raw pkey_reg: %x\n", __func__, pkey_reg);
 
-	shifted_pkru = (pkru >> (pkey * PKRU_BITS_PER_PKEY));
-	dprintf2("%s() shifted_pkru: %x\n", __func__, shifted_pkru);
-	masked_pkru = shifted_pkru & mask;
-	dprintf2("%s() masked  pkru: %x\n", __func__, masked_pkru);
+	shifted_pkey_reg = (pkey_reg >> (pkey * PKEY_BITS_PER_PKEY));
+	dprintf2("%s() shifted_pkey_reg: %x\n", __func__, shifted_pkey_reg);
+	masked_pkey_reg = shifted_pkey_reg & mask;
+	dprintf2("%s() masked  pkey_reg: %x\n", __func__, masked_pkey_reg);
 	/*
 	 * shift down the relevant bits to the lowest two, then
 	 * mask off all the other high bits.
 	 */
-	return masked_pkru;
+	return masked_pkey_reg;
 }
 
 int pkey_set(int pkey, unsigned long rights, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-	u32 old_pkru = __rdpkru();
-	u32 new_pkru;
+	u32 old_pkey_reg = __rdpkey_reg();
+	u32 new_pkey_reg;
 
 	/* make sure that 'rights' only contains the bits we expect: */
 	assert(!(rights & ~mask));
 
-	/* copy old pkru */
-	new_pkru = old_pkru;
+	/* copy old pkey_reg */
+	new_pkey_reg = old_pkey_reg;
 	/* mask out bits from pkey in old value: */
-	new_pkru &= ~(mask << (pkey * PKRU_BITS_PER_PKEY));
+	new_pkey_reg &= ~(mask << (pkey * PKEY_BITS_PER_PKEY));
 	/* OR in new bits for pkey: */
-	new_pkru |= (rights << (pkey * PKRU_BITS_PER_PKEY));
+	new_pkey_reg |= (rights << (pkey * PKEY_BITS_PER_PKEY));
 
-	__wrpkru(new_pkru);
+	__wrpkey_reg(new_pkey_reg);
 
-	dprintf3("%s(pkey=%d, rights=%lx, flags=%lx) = %x pkru now: %x old_pkru: %x\n",
-			__func__, pkey, rights, flags, 0, __rdpkru(), old_pkru);
+	dprintf3("%s(pkey=%d, rights=%lx, flags=%lx) = %x"
+	       " pkey_reg now: %x old_pkey_reg: %x\n",
+		__func__, pkey, rights, flags, 0, __rdpkey_reg(),
+		old_pkey_reg);
 	return 0;
 }
 
@@ -462,7 +467,7 @@ void pkey_disable_set(int pkey, int flags)
 	unsigned long syscall_flags = 0;
 	int ret;
 	int pkey_rights;
-	u32 orig_pkru = rdpkru();
+	u32 orig_pkey_reg = rdpkey_reg();
 
 	dprintf1("START->%s(%d, 0x%x)\n", __func__,
 		pkey, flags);
@@ -478,9 +483,9 @@ void pkey_disable_set(int pkey, int flags)
 
 	ret = pkey_set(pkey, pkey_rights, syscall_flags);
 	assert(!ret);
-	/*pkru and flags have the same format */
-	shadow_pkru |= flags << (pkey * 2);
-	dprintf1("%s(%d) shadow: 0x%x\n", __func__, pkey, shadow_pkru);
+	/*pkey_reg and flags have the same format */
+	shadow_pkey_reg |= flags << (pkey * 2);
+	dprintf1("%s(%d) shadow: 0x%x\n", __func__, pkey, shadow_pkey_reg);
 
 	pkey_assert(ret >= 0);
 
@@ -488,9 +493,9 @@ void pkey_disable_set(int pkey, int flags)
 	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
-	dprintf1("%s(%d) pkru: 0x%x\n", __func__, pkey, rdpkru());
+	dprintf1("%s(%d) pkey_reg: 0x%x\n", __func__, pkey, rdpkey_reg());
 	if (flags)
-		pkey_assert(rdpkru() > orig_pkru);
+		pkey_assert(rdpkey_reg() > orig_pkey_reg);
 	dprintf1("END<---%s(%d, 0x%x)\n", __func__,
 		pkey, flags);
 }
@@ -500,7 +505,7 @@ void pkey_disable_clear(int pkey, int flags)
 	unsigned long syscall_flags = 0;
 	int ret;
 	int pkey_rights = pkey_get(pkey, syscall_flags);
-	u32 orig_pkru = rdpkru();
+	u32 orig_pkey_reg = rdpkey_reg();
 
 	pkey_assert(flags & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
 
@@ -511,17 +516,17 @@ void pkey_disable_clear(int pkey, int flags)
 	pkey_rights |= flags;
 
 	ret = pkey_set(pkey, pkey_rights, 0);
-	/* pkru and flags have the same format */
-	shadow_pkru &= ~(flags << (pkey * 2));
+	/* pkey_reg and flags have the same format */
+	shadow_pkey_reg &= ~(flags << (pkey * 2));
 	pkey_assert(ret >= 0);
 
 	pkey_rights = pkey_get(pkey, syscall_flags);
 	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
-	dprintf1("%s(%d) pkru: 0x%x\n", __func__, pkey, rdpkru());
+	dprintf1("%s(%d) pkey_reg: 0x%x\n", __func__, pkey, rdpkey_reg());
 	if (flags)
-		assert(rdpkru() > orig_pkru);
+		assert(rdpkey_reg() > orig_pkey_reg);
 }
 
 void pkey_write_allow(int pkey)
@@ -574,33 +579,38 @@ int alloc_pkey(void)
 	int ret;
 	unsigned long init_val = 0x0;
 
-	dprintf1("alloc_pkey()::%d, pkru: 0x%x shadow: %x\n",
-			__LINE__, __rdpkru(), shadow_pkru);
+	dprintf1("%s()::%d, pkey_reg: 0x%x shadow: %x\n", __func__,
+			__LINE__, __rdpkey_reg(), shadow_pkey_reg);
 	ret = sys_pkey_alloc(0, init_val);
 	/*
-	 * pkey_alloc() sets PKRU, so we need to reflect it in
-	 * shadow_pkru:
+	 * pkey_alloc() sets PKEY register, so we need to reflect it in
+	 * shadow_pkey_reg:
 	 */
-	dprintf4("alloc_pkey()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n",
-			__LINE__, ret, __rdpkru(), shadow_pkru);
+	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+			__func__, __LINE__, ret, __rdpkey_reg(),
+			shadow_pkey_reg);
 	if (ret) {
 		/* clear both the bits: */
-		shadow_pkru &= ~(0x3      << (ret * 2));
-		dprintf4("alloc_pkey()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n",
-				__LINE__, ret, __rdpkru(), shadow_pkru);
+		shadow_pkey_reg &= ~(0x3      << (ret * 2));
+		dprintf4("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n",
+				__func__,
+				__LINE__, ret, __rdpkey_reg(),
+				shadow_pkey_reg);
 		/*
 		 * move the new state in from init_val
-		 * (remember, we cheated and init_val == pkru format)
+		 * (remember, we cheated and init_val == pkey_reg format)
 		 */
-		shadow_pkru |=  (init_val << (ret * 2));
+		shadow_pkey_reg |=  (init_val << (ret * 2));
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
+		__func__, __LINE__, ret, __rdpkey_reg(),
+		shadow_pkey_reg);
 	return ret;
 }
 
@@ -651,8 +661,8 @@ int alloc_random_pkey(void)
 		free_ret = sys_pkey_free(alloced_pkeys[i]);
 		pkey_assert(!free_ret);
 	}
-	dprintf1("%s()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n", __func__,
-			__LINE__, ret, __rdpkru(), shadow_pkru);
+	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n", __func__,
+			__LINE__, ret, __rdpkey_reg(), shadow_pkey_reg);
 	return ret;
 }
 
@@ -670,11 +680,13 @@ int mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot,
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
 
@@ -682,8 +694,8 @@ int mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot,
 	dprintf1("mprotect_pkey(%p, %zx, prot=0x%lx, pkey=%ld) ret: %d\n",
 			ptr, size, orig_prot, pkey, ret);
 	pkey_assert(!ret);
-	dprintf1("%s()::%d, ret: %d pkru: 0x%x shadow: 0x%x\n", __func__,
-			__LINE__, ret, __rdpkru(), shadow_pkru);
+	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n", __func__,
+			__LINE__, ret, __rdpkey_reg(), shadow_pkey_reg);
 	return ret;
 }
 
@@ -761,7 +773,7 @@ void free_pkey_malloc(void *ptr)
 	void *ptr;
 	int ret;
 
-	rdpkru();
+	rdpkey_reg();
 	dprintf1("doing %s(size=%ld, prot=0x%x, pkey=%d)\n", __func__,
 			size, prot, pkey);
 	pkey_assert(pkey < NR_PKEYS);
@@ -770,7 +782,7 @@ void free_pkey_malloc(void *ptr)
 	ret = mprotect_pkey((void *)ptr, PAGE_SIZE, prot, pkey);
 	pkey_assert(!ret);
 	record_pkey_malloc(ptr, size);
-	rdpkru();
+	rdpkey_reg();
 
 	dprintf1("%s() for pkey %d @ %p\n", __func__, pkey, ptr);
 	return ptr;
@@ -933,31 +945,31 @@ void setup_hugetlbfs(void)
 	return ret;
 }
 
-int last_pkru_faults;
-void expected_pk_fault(int pkey)
+int last_pkey_faults;
+void expected_pkey_fault(int pkey)
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
+	 * The signal handler shold have cleared out PKEY register to let the
 	 * test program continue.  We now have to restore it.
 	 */
-	if (__rdpkru() != 0)
+	if (__rdpkey_reg() != 0)
 		pkey_assert(0);
 
-	__wrpkru(shadow_pkru);
-	dprintf1("%s() set PKRU=%x to restore state after signal nuked it\n",
-			__func__, shadow_pkru);
-	last_pkru_faults = pkru_faults;
+	__wrpkey_reg(shadow_pkey_reg);
+	dprintf1("%s() set pkey_reg=%x to restore state after signal "
+		       "nuked it\n", __func__, shadow_pkey_reg);
+	last_pkey_faults = pkey_faults;
 	last_si_pkey = -1;
 }
 
-void do_not_expect_pk_fault(void)
+void do_not_expect_pkey_fault(void)
 {
-	pkey_assert(last_pkru_faults == pkru_faults);
+	pkey_assert(last_pkey_faults == pkey_faults);
 }
 
 int test_fds[10] = { -1 };
@@ -1015,25 +1027,25 @@ void test_read_of_access_disabled_region(int *ptr, u16 pkey)
 	int ptr_contents;
 
 	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n", pkey, ptr);
-	rdpkru();
+	rdpkey_reg();
 	pkey_access_deny(pkey);
 	ptr_contents = read_ptr(ptr);
 	dprintf1("*ptr: %d\n", ptr_contents);
-	expected_pk_fault(pkey);
+	expected_pkey_fault(pkey);
 }
 void test_write_of_write_disabled_region(int *ptr, u16 pkey)
 {
 	dprintf1("disabling write access to PKEY[%02d], doing write\n", pkey);
 	pkey_write_deny(pkey);
 	*ptr = __LINE__;
-	expected_pk_fault(pkey);
+	expected_pkey_fault(pkey);
 }
 void test_write_of_access_disabled_region(int *ptr, u16 pkey)
 {
 	dprintf1("disabling access to PKEY[%02d], doing write\n", pkey);
 	pkey_access_deny(pkey);
 	*ptr = __LINE__;
-	expected_pk_fault(pkey);
+	expected_pkey_fault(pkey);
 }
 void test_kernel_write_of_access_disabled_region(int *ptr, u16 pkey)
 {
@@ -1145,9 +1157,10 @@ void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
 		int new_pkey;
 		dprintf1("%s() alloc loop: %d\n", __func__, i);
 		new_pkey = alloc_pkey();
-		dprintf4("%s()::%d, err: %d pkru: 0x%x shadow: 0x%x\n", __func__,
-				__LINE__, err, __rdpkru(), shadow_pkru);
-		rdpkru(); /* for shadow checking */
+		dprintf4("%s()::%d, err: %d pkey_reg: 0x%x shadow: 0x%x\n",
+				__func__, __LINE__, err, __rdpkey_reg(),
+				shadow_pkey_reg);
+		rdpkey_reg(); /* for shadow checking */
 		dprintf2("%s() errno: %d ENOSPC: %d\n", __func__, errno, ENOSPC);
 		if ((new_pkey == -1) && (errno == ENOSPC)) {
 			dprintf2("%s() failed to allocate pkey after %d tries\n",
@@ -1177,7 +1190,7 @@ void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
 	for (i = 0; i < nr_allocated_pkeys; i++) {
 		err = sys_pkey_free(allocated_pkeys[i]);
 		pkey_assert(!err);
-		rdpkru(); /* for shadow checking */
+		rdpkey_reg(); /* for shadow checking */
 	}
 }
 
@@ -1234,7 +1247,7 @@ void test_ptrace_of_child(int *ptr, u16 pkey)
 	pkey_assert(ret != -1);
 	/* Now access from the current task, and expect an exception: */
 	peek_result = read_ptr(ptr);
-	expected_pk_fault(pkey);
+	expected_pkey_fault(pkey);
 
 	/*
 	 * Try to access the NON-pkey-protected "plain_ptr" via ptrace:
@@ -1244,7 +1257,7 @@ void test_ptrace_of_child(int *ptr, u16 pkey)
 	pkey_assert(ret != -1);
 	/* Now access from the current task, and expect NO exception: */
 	peek_result = read_ptr(plain_ptr);
-	do_not_expect_pk_fault();
+	do_not_expect_pkey_fault();
 
 	ret = ptrace(PTRACE_DETACH, child_pid, ignored, 0);
 	pkey_assert(ret != -1);
@@ -1281,17 +1294,17 @@ void test_executing_on_unreadable_memory(int *ptr, u16 pkey)
 	pkey_assert(!ret);
 	pkey_access_deny(pkey);
 
-	dprintf2("pkru: %x\n", rdpkru());
+	dprintf2("pkey_reg: %x\n", rdpkey_reg());
 
 	/*
 	 * Make sure this is an *instruction* fault
 	 */
 	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
 	lots_o_noops_around_write(&scratch);
-	do_not_expect_pk_fault();
+	do_not_expect_pkey_fault();
 	ptr_contents = read_ptr(p1);
 	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
-	expected_pk_fault(pkey);
+	expected_pkey_fault(pkey);
 }
 
 void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
@@ -1331,7 +1344,7 @@ void run_tests_once(void)
 
 	for (test_nr = 0; test_nr < ARRAY_SIZE(pkey_tests); test_nr++) {
 		int pkey;
-		int orig_pkru_faults = pkru_faults;
+		int orig_pkey_faults = pkey_faults;
 
 		dprintf1("======================\n");
 		dprintf1("test %d preparing...\n", test_nr);
@@ -1346,8 +1359,8 @@ void run_tests_once(void)
 		free_pkey_malloc(ptr);
 		sys_pkey_free(pkey);
 
-		dprintf1("pkru_faults: %d\n", pkru_faults);
-		dprintf1("orig_pkru_faults: %d\n", orig_pkru_faults);
+		dprintf1("pkey_faults: %d\n", pkey_faults);
+		dprintf1("orig_pkey_faults: %d\n", orig_pkey_faults);
 
 		tracing_off();
 		close_test_fds();
@@ -1360,7 +1373,7 @@ void run_tests_once(void)
 
 void pkey_setup_shadow(void)
 {
-	shadow_pkru = __rdpkru();
+	shadow_pkey_reg = __rdpkey_reg();
 }
 
 int main(void)
@@ -1384,7 +1397,7 @@ int main(void)
 	}
 
 	pkey_setup_shadow();
-	printf("startup pkru: %x\n", rdpkru());
+	printf("startup pkey_reg: %x\n", rdpkey_reg());
 	setup_hugetlbfs();
 
 	while (nr_iterations-- > 0)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
