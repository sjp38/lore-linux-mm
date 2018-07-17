Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B46A6B0275
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:50:36 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j9-v6so717812qtn.22
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:50:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j14-v6sor481306qvo.105.2018.07.17.06.50.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 06:50:35 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v14 15/22] selftests/vm: powerpc implementation to check support for pkey
Date: Tue, 17 Jul 2018 06:49:18 -0700
Message-Id: <1531835365-32387-16-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

pkey subsystem is supported if the hardware and kernel has support.
We determine that by checking if allocation of a key succeeds or not.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |    2 ++
 tools/testing/selftests/vm/pkey-powerpc.h    |   14 ++++++++++++--
 tools/testing/selftests/vm/pkey-x86.h        |    8 ++++----
 tools/testing/selftests/vm/protection_keys.c |    9 +++++----
 4 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index 321bbbd..288ccff 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -76,6 +76,8 @@ static inline void sigsafe_printf(const char *format, ...)
 
 __attribute__((noinline)) int read_ptr(int *ptr);
 void expected_pkey_fault(int pkey);
+int sys_pkey_alloc(unsigned long flags, u64 init_val);
+int sys_pkey_free(unsigned long pkey);
 
 #if defined(__i386__) || defined(__x86_64__) /* arch */
 #include "pkey-x86.h"
diff --git a/tools/testing/selftests/vm/pkey-powerpc.h b/tools/testing/selftests/vm/pkey-powerpc.h
index b0d1abe..b649e85 100644
--- a/tools/testing/selftests/vm/pkey-powerpc.h
+++ b/tools/testing/selftests/vm/pkey-powerpc.h
@@ -64,9 +64,19 @@ static inline void __write_pkey_reg(pkey_reg_t pkey_reg)
 			pkey_reg);
 }
 
-static inline int cpu_has_pku(void)
+static inline bool is_pkey_supported(void)
 {
-	return 1;
+	/*
+	 * No simple way to determine this.
+	 * Lets try allocating a key and see if it succeeds.
+	 */
+	int ret = sys_pkey_alloc(0, 0);
+
+	if (ret > 0) {
+		sys_pkey_free(ret);
+		return true;
+	}
+	return false;
 }
 
 static inline int arch_reserved_keys(void)
diff --git a/tools/testing/selftests/vm/pkey-x86.h b/tools/testing/selftests/vm/pkey-x86.h
index f5d0ff2..887acf2 100644
--- a/tools/testing/selftests/vm/pkey-x86.h
+++ b/tools/testing/selftests/vm/pkey-x86.h
@@ -105,7 +105,7 @@ static inline void __cpuid(unsigned int *eax, unsigned int *ebx,
 #define X86_FEATURE_PKU        (1<<3) /* Protection Keys for Userspace */
 #define X86_FEATURE_OSPKE      (1<<4) /* OS Protection Keys Enable */
 
-static inline int cpu_has_pku(void)
+static inline bool is_pkey_supported(void)
 {
 	unsigned int eax;
 	unsigned int ebx;
@@ -118,13 +118,13 @@ static inline int cpu_has_pku(void)
 
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
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 18e1bb7..d27fa5e 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -1389,8 +1389,8 @@ void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
 	int size = PAGE_SIZE;
 	int sret;
 
-	if (cpu_has_pku()) {
-		dprintf1("SKIP: %s: no CPU support\n", __func__);
+	if (is_pkey_supported()) {
+		dprintf1("SKIP: %s: no CPU/kernel support\n", __func__);
 		return;
 	}
 
@@ -1454,12 +1454,13 @@ void run_tests_once(void)
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
