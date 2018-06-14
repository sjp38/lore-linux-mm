Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03E276B026A
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 20:47:00 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 12-v6so3292389qtq.8
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 17:46:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a10-v6sor2280424qta.57.2018.06.13.17.46.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 17:46:58 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v13 07/24] selftests/vm: generic function to handle shadow key register
Date: Wed, 13 Jun 2018 17:44:58 -0700
Message-Id: <1528937115-10132-8-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

helper functions to handler shadow pkey register

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   29 ++++++++++++++++++++++
 tools/testing/selftests/vm/pkey-x86.h        |    5 ++++
 tools/testing/selftests/vm/protection_keys.c |   34 ++++++++++++++++---------
 3 files changed, 56 insertions(+), 12 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index 2a1a024..ada0146 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -80,6 +80,35 @@ static inline void sigsafe_printf(const char *format, ...)
 #error Architecture not supported
 #endif /* arch */
 
+static inline pkey_reg_t clear_pkey_flags(int pkey, pkey_reg_t flags)
+{
+	u32 shift = pkey_bit_position(pkey);
+
+	return ~(flags << shift);
+}
+
+/*
+ * Takes pkey flags and puts them at the right bit position for the given key so
+ * that the result can be ORed into the register.
+ */
+static inline pkey_reg_t left_shift_bits(int pkey, pkey_reg_t bits)
+{
+	u32 shift = pkey_bit_position(pkey);
+
+	return (bits << shift);
+}
+
+/*
+ * Takes pkey register values and puts the flags for the given pkey at the least
+ * significant bits of the returned value.
+ */
+static inline pkey_reg_t right_shift_bits(int pkey, pkey_reg_t bits)
+{
+	u32 shift = pkey_bit_position(pkey);
+
+	return (bits >> shift);
+}
+
 extern pkey_reg_t shadow_pkey_reg;
 
 static inline pkey_reg_t _read_pkey_reg(int line)
diff --git a/tools/testing/selftests/vm/pkey-x86.h b/tools/testing/selftests/vm/pkey-x86.h
index 5f40901..2b3780d 100644
--- a/tools/testing/selftests/vm/pkey-x86.h
+++ b/tools/testing/selftests/vm/pkey-x86.h
@@ -49,6 +49,11 @@
 #define pkey_reg_t		u32
 #define PKEY_REG_FMT		"%016x"
 
+static inline u32 pkey_bit_position(int pkey)
+{
+	return pkey * PKEY_BITS_PER_PKEY;
+}
+
 static inline void __page_o_noops(void)
 {
 	/* 8-bytes of instruction * 512 bytes = 1 page */
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 90b3a41..57340b3 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -342,7 +342,7 @@ static u32 hw_pkey_get(int pkey, unsigned long flags)
 			__func__, pkey, flags, 0, 0);
 	dprintf2("%s() raw pkey_reg: "PKEY_REG_FMT"\n", __func__, pkey_reg);
 
-	shifted_pkey_reg = (pkey_reg >> (pkey * PKEY_BITS_PER_PKEY));
+	shifted_pkey_reg = right_shift_bits(pkey, pkey_reg);
 	dprintf2("%s() shifted_pkey_reg: "PKEY_REG_FMT"\n", __func__,
 			shifted_pkey_reg);
 	masked_pkey_reg = shifted_pkey_reg & mask;
@@ -366,9 +366,9 @@ static int hw_pkey_set(int pkey, unsigned long rights, unsigned long flags)
 	/* copy old pkey_reg */
 	new_pkey_reg = old_pkey_reg;
 	/* mask out bits from pkey in old value: */
-	new_pkey_reg &= ~(mask << (pkey * PKEY_BITS_PER_PKEY));
+	new_pkey_reg &= clear_pkey_flags(pkey, mask);
 	/* OR in new bits for pkey: */
-	new_pkey_reg |= (rights << (pkey * PKEY_BITS_PER_PKEY));
+	new_pkey_reg |= left_shift_bits(pkey, rights);
 
 	__write_pkey_reg(new_pkey_reg);
 
@@ -402,7 +402,7 @@ void pkey_disable_set(int pkey, int flags)
 	ret = hw_pkey_set(pkey, pkey_rights, syscall_flags);
 	assert(!ret);
 	/*pkey_reg and flags have the same format */
-	shadow_pkey_reg |= flags << (pkey * 2);
+	shadow_pkey_reg |= left_shift_bits(pkey, flags);
 	dprintf1("%s(%d) shadow: 0x"PKEY_REG_FMT"\n",
 		__func__, pkey, shadow_pkey_reg);
 
@@ -436,7 +436,7 @@ void pkey_disable_clear(int pkey, int flags)
 	pkey_rights |= flags;
 
 	ret = hw_pkey_set(pkey, pkey_rights, 0);
-	shadow_pkey_reg &= ~(flags << (pkey * 2));
+	shadow_pkey_reg &= clear_pkey_flags(pkey, flags);
 	pkey_assert(ret >= 0);
 
 	pkey_rights = hw_pkey_get(pkey, syscall_flags);
@@ -494,6 +494,21 @@ int sys_pkey_alloc(unsigned long flags, unsigned long init_val)
 	return ret;
 }
 
+void pkey_setup_shadow(void)
+{
+	shadow_pkey_reg = __read_pkey_reg();
+}
+
+void pkey_reset_shadow(u32 key)
+{
+	shadow_pkey_reg &= clear_pkey_flags(key, 0x3);
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
@@ -512,7 +527,7 @@ int alloc_pkey(void)
 			shadow_pkey_reg);
 	if (ret) {
 		/* clear both the bits: */
-		shadow_pkey_reg &= ~(0x3      << (ret * 2));
+		pkey_reset_shadow(ret);
 		dprintf4("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
 				" shadow: 0x"PKEY_REG_FMT"\n",
 				__func__,
@@ -522,7 +537,7 @@ int alloc_pkey(void)
 		 * move the new state in from init_val
 		 * (remember, we cheated and init_val == pkey_reg format)
 		 */
-		shadow_pkey_reg |=  (init_val << (ret * 2));
+		pkey_set_shadow(ret, init_val);
 	}
 	dprintf4("%s()::%d, ret: %d pkey_reg: 0x"PKEY_REG_FMT
 			" shadow: 0x"PKEY_REG_FMT"\n",
@@ -1403,11 +1418,6 @@ void run_tests_once(void)
 	iteration_nr++;
 }
 
-void pkey_setup_shadow(void)
-{
-	shadow_pkey_reg = __read_pkey_reg();
-}
-
 int main(void)
 {
 	int nr_iterations = 22;
-- 
1.7.1
