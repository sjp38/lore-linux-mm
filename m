Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5C04403DD
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 04:00:26 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id 10so6535192qty.10
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 01:00:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor7383725qkl.121.2017.11.06.01.00.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 01:00:25 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 45/51] selftest/vm: fix an assertion in test_pkey_alloc_exhaust()
Date: Mon,  6 Nov 2017 00:57:37 -0800
Message-Id: <1509958663-18737-46-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

The maximum number of keys that can be allocated has to
take into consideration, that some keys are reserved by
the architecture for   specific   purpose. Hence cannot
be allocated.

Fix the assertion in test_pkey_alloc_exhaust()

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   14 ++++++++++++++
 tools/testing/selftests/vm/protection_keys.c |    9 ++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index f764d66..3ea3e06 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -388,4 +388,18 @@ static inline int get_start_key(void)
 #endif /* arch */
 }
 
+static inline int arch_reserved_keys(void)
+{
+#if defined(__i386__) || defined(__x86_64__) /* arch */
+	return NR_RESERVED_PKEYS;
+#elif __powerpc64__ /* arch */
+	if (sysconf(_SC_PAGESIZE) == 4096)
+		return NR_RESERVED_PKEYS_4K;
+	else
+		return NR_RESERVED_PKEYS_64K;
+#else /* arch */
+	NOT SUPPORTED
+#endif /* arch */
+}
+
 #endif /* _PKEYS_HELPER_H */
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 4fe42cc..8f0dd94 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -1166,12 +1166,11 @@ void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
 	pkey_assert(i < NR_PKEYS*2);
 
 	/*
-	 * There are 16 pkeys supported in hardware.  One is taken
-	 * up for the default (0) and another can be taken up by
-	 * an execute-only mapping.  Ensure that we can allocate
-	 * at least 14 (16-2).
+	 * There are NR_PKEYS pkeys supported in hardware. arch_reserved_keys()
+	 * are reserved. One   can   be   taken   up by an execute-only mapping.
+	 * Ensure that we can allocate at least the remaining.
 	 */
-	pkey_assert(i >= NR_PKEYS-2);
+	pkey_assert(i >= (NR_PKEYS-arch_reserved_keys()-1));
 
 	for (i = 0; i < nr_allocated_pkeys; i++) {
 		err = sys_pkey_free(allocated_pkeys[i]);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
