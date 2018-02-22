Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9DB56B0260
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 20:57:12 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id y81so2789991qka.23
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:57:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 14sor607835qkp.91.2018.02.21.17.57.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 17:57:11 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v12 15/22] selftests/vm: powerpc implementation to check support for pkey
Date: Wed, 21 Feb 2018 17:55:34 -0800
Message-Id: <1519264541-7621-16-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

pkey subsystem is supported if the hardware and kernel has support.
We determine that by checking if allocation of a key succeeds or not.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   22 ++++++++++++++++------
 tools/testing/selftests/vm/protection_keys.c |    9 +++++----
 2 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index c47aead..88ef58f 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -258,7 +258,7 @@ static inline void __cpuid(unsigned int *eax, unsigned int *ebx,
 #define X86_FEATURE_PKU        (1<<3) /* Protection Keys for Userspace */
 #define X86_FEATURE_OSPKE      (1<<4) /* OS Protection Keys Enable */
 
-static inline int cpu_has_pku(void)
+static inline bool is_pkey_supported(void)
 {
 	unsigned int eax;
 	unsigned int ebx;
@@ -271,13 +271,13 @@ static inline int cpu_has_pku(void)
 
 	if (!(ecx & X86_FEATURE_PKU)) {
 		dprintf2("cpu does not have PKU\n");
-		return 0;
+		return false;
 	}
 	if (!(ecx & X86_FEATURE_OSPKE)) {
 		dprintf2("cpu does not have OSPKE\n");
-		return 0;
+		return false;
 	}
-	return 1;
+	return true;
 }
 
 #define XSTATE_PKEY_BIT	(9)
@@ -323,9 +323,19 @@ static inline void __page_o_noops(void)
 #elif __powerpc64__ /* arch */
 
 #define PAGE_SIZE (0x1UL << 16)
-static inline int cpu_has_pku(void)
+static inline bool is_pkey_supported(void)
 {
-	return 1;
+	/*
+	 * No simple way to determine this.
+	 * lets try allocating a key and see if it succeeds.
+	 */
+	int ret = sys_pkey_alloc(0, 0);
+
+	if (ret > 0) {
+		sys_pkey_free(ret);
+		return true;
+	}
+	return false;
 }
 
 /* 8-bytes of instruction * 16384bytes = 1 page */
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index e82bd88..58da5a0 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -1299,8 +1299,8 @@ void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
 	int size = PAGE_SIZE;
 	int sret;
 
-	if (cpu_has_pku()) {
-		dprintf1("SKIP: %s: no CPU support\n", __func__);
+	if (is_pkey_supported()) {
+		dprintf1("SKIP: %s: no CPU/kernel support\n", __func__);
 		return;
 	}
 
@@ -1362,12 +1362,13 @@ void run_tests_once(void)
 int main(void)
 {
 	int nr_iterations = 22;
+	int pkey_supported = is_pkey_supported();
 
 	setup_handlers();
 
-	printf("has pkey: %d\n", cpu_has_pku());
+	printf("has pkey: %s\n", pkey_supported ? "Yes" : "No");
 
-	if (!cpu_has_pku()) {
+	if (!pkey_supported) {
 		int size = PAGE_SIZE;
 		int *ptr;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
