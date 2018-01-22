Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00A04800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:53:03 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id r23so16046621qte.13
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 10:53:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g33sor12258586qtc.35.2018.01.22.10.53.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 10:53:02 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 05/24] selftests/vm: generic function to handle shadow key register
Date: Mon, 22 Jan 2018 10:51:58 -0800
Message-Id: <1516647137-11174-6-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516647137-11174-1-git-send-email-linuxram@us.ibm.com>
References: <1516647137-11174-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

helper functions to handler shadow pkey register

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   27 ++++++++++++++++++++
 tools/testing/selftests/vm/protection_keys.c |   34 ++++++++++++++++---------
 2 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index b6c2133..7c979ad 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -44,6 +44,33 @@
 #define DEBUG_LEVEL 0
 #endif
 #define DPRINT_IN_SIGNAL_BUF_SIZE 4096
+
+static inline u32 pkey_to_shift(int pkey)
+{
+	return pkey * PKEY_BITS_PER_PKEY;
+}
+
+static inline pkey_reg_t reset_bits(int pkey, pkey_reg_t bits)
+{
+	u32 shift = pkey_to_shift(pkey);
+
+	return ~(bits << shift);
+}
+
+static inline pkey_reg_t left_shift_bits(int pkey, pkey_reg_t bits)
+{
+	u32 shift = pkey_to_shift(pkey);
+
+	return (bits << shift);
+}
+
+static inline pkey_reg_t right_shift_bits(int pkey, pkey_reg_t bits)
+{
+	u32 shift = pkey_to_shift(pkey);
+
+	return (bits >> shift);
+}
+
 extern int dprint_in_signal;
 extern char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
 static inline void sigsafe_printf(const char *format, ...)
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 3ef2569..83216c5 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -374,7 +374,7 @@ u32 pkey_get(int pkey, unsigned long flags)
 			__func__, pkey, flags, 0, 0);
 	dprintf2("%s() raw pkey_reg: %x\n", __func__, pkey_reg);
 
-	shifted_pkey_reg = (pkey_reg >> (pkey * PKEY_BITS_PER_PKEY));
+	shifted_pkey_reg = right_shift_bits(pkey, pkey_reg);
 	dprintf2("%s() shifted_pkey_reg: %x\n", __func__, shifted_pkey_reg);
 	masked_pkey_reg = shifted_pkey_reg & mask;
 	dprintf2("%s() masked  pkey_reg: %x\n", __func__, masked_pkey_reg);
@@ -397,9 +397,9 @@ int pkey_set(int pkey, unsigned long rights, unsigned long flags)
 	/* copy old pkey_reg */
 	new_pkey_reg = old_pkey_reg;
 	/* mask out bits from pkey in old value: */
-	new_pkey_reg &= ~(mask << (pkey * PKEY_BITS_PER_PKEY));
+	new_pkey_reg &= reset_bits(pkey, mask);
 	/* OR in new bits for pkey: */
-	new_pkey_reg |= (rights << (pkey * PKEY_BITS_PER_PKEY));
+	new_pkey_reg |= left_shift_bits(pkey, rights);
 
 	__wrpkey_reg(new_pkey_reg);
 
@@ -430,7 +430,7 @@ void pkey_disable_set(int pkey, int flags)
 	ret = pkey_set(pkey, pkey_rights, syscall_flags);
 	assert(!ret);
 	/*pkey_reg and flags have the same format */
-	shadow_pkey_reg |= flags << (pkey * 2);
+	shadow_pkey_reg |= left_shift_bits(pkey, flags);
 	dprintf1("%s(%d) shadow: 0x%016lx\n",
 		__func__, pkey, shadow_pkey_reg);
 
@@ -465,7 +465,7 @@ void pkey_disable_clear(int pkey, int flags)
 
 	ret = pkey_set(pkey, pkey_rights, 0);
 	/* pkey_reg and flags have the same format */
-	shadow_pkey_reg &= ~(flags << (pkey * 2));
+	shadow_pkey_reg &= reset_bits(pkey, flags);
 	pkey_assert(ret >= 0);
 
 	pkey_rights = pkey_get(pkey, syscall_flags);
@@ -523,6 +523,21 @@ int sys_pkey_alloc(unsigned long flags, unsigned long init_val)
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
@@ -540,7 +555,7 @@ int alloc_pkey(void)
 			shadow_pkey_reg);
 	if (ret) {
 		/* clear both the bits: */
-		shadow_pkey_reg &= ~(0x3      << (ret * 2));
+		pkey_reset_shadow(ret);
 		dprintf4("%s()::%d, ret: %d pkey_reg: 0x%016lx "
 				"shadow: 0x%016lx\n",
 				__func__,
@@ -550,7 +565,7 @@ int alloc_pkey(void)
 		 * move the new state in from init_val
 		 * (remember, we cheated and init_val == pkey_reg format)
 		 */
-		shadow_pkey_reg |=  (init_val << (ret * 2));
+		pkey_set_shadow(ret, init_val);
 	}
 	dprintf4("%s()::%d, ret: %d pkey_reg: 0x%016lx shadow: 0x%016lx\n",
 			__func__, __LINE__, ret, __rdpkey_reg(),
@@ -1322,11 +1337,6 @@ void run_tests_once(void)
 	iteration_nr++;
 }
 
-void pkey_setup_shadow(void)
-{
-	shadow_pkey_reg = __rdpkey_reg();
-}
-
 int main(void)
 {
 	int nr_iterations = 22;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
