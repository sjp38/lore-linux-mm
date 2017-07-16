Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC3486B0698
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 00:00:26 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i128so40176924qkc.11
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:26 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id v18si12227804qtv.88.2017.07.15.21.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 21:00:26 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id q66so17065760qki.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:26 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 58/62] selftest/vm: detect no write key-violation on a freed key
Date: Sat, 15 Jul 2017 20:57:00 -0700
Message-Id: <1500177424-13695-59-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

a write-denied key should not trigger any key violation
after the key has been freed.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/protection_keys.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index e35cef5..07df8cf 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -1068,6 +1068,23 @@ void test_write_of_write_disabled_region(int *ptr, u16 pkey)
 	*ptr = __LINE__;
 	expected_pkey_fault(pkey);
 }
+
+void test_write_of_write_disabled_but_freed_key_region(int *ptr, u16 pkey)
+{
+	dprintf1("disabling write access to PKEY[%02d], doing write\n", pkey);
+	*ptr = __LINE__;
+	do_not_expect_pkey_fault();
+
+	pkey_write_deny(pkey);
+	*ptr = __LINE__;
+	expected_pkey_fault(pkey);
+
+	pkey_write_deny(pkey);
+	sys_pkey_free(pkey);
+	*ptr = __LINE__;
+	do_not_expect_pkey_fault();
+}
+
 void test_write_of_access_disabled_region(int *ptr, u16 pkey)
 {
 	dprintf1("disabling access to PKEY[%02d], doing write\n", pkey);
@@ -1370,6 +1387,7 @@ void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
 	test_pkey_syscalls_bad_args,
 	test_pkey_alloc_exhaust,
 	test_read_of_access_disabled_but_freed_key_region,
+	test_write_of_write_disabled_but_freed_key_region,
 };
 
 void run_tests_once(void)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
