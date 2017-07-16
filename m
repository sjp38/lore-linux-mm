Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85C0B6B0635
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 00:00:22 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o3so57053115qto.15
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:22 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id e184si11389021qkd.126.2017.07.15.21.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 21:00:21 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id v31so14710672qtb.3
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:21 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 56/62] selftest/vm: detect no key violation on a freed key
Date: Sat, 15 Jul 2017 20:56:58 -0700
Message-Id: <1500177424-13695-57-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

a access-denied key should not trigger any key violation
after the key has been freed.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/protection_keys.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index bf27bcd..47c23cc 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -1026,6 +1026,30 @@ void test_read_of_access_disabled_region_with_page_already_mapped(int *ptr,
 	expected_pkey_fault(pkey);
 }
 
+void test_read_of_access_disabled_but_freed_key_region(int *ptr, u16 pkey)
+{
+	int ptr_contents;
+
+	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n",
+			 pkey, ptr);
+
+	/* read the content */
+	ptr_contents = read_ptr(ptr);
+	do_not_expect_pkey_fault();
+
+	/* deny key access */
+	pkey_access_deny(pkey);
+	ptr_contents = read_ptr(ptr);
+	dprintf1("*ptr: %d\n", ptr_contents);
+	expected_pkey_fault(pkey);
+
+	/* free the key without restoring access */
+	pkey_access_deny(pkey);
+	sys_pkey_free(pkey);
+	ptr_contents = read_ptr(ptr);
+	do_not_expect_pkey_fault();
+}
+
 void test_write_of_write_disabled_region(int *ptr, u16 pkey)
 {
 	dprintf1("disabling write access to PKEY[%02d], doing write\n", pkey);
@@ -1333,6 +1357,7 @@ void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
 	test_pkey_syscalls_on_non_allocated_pkey,
 	test_pkey_syscalls_bad_args,
 	test_pkey_alloc_exhaust,
+	test_read_of_access_disabled_but_freed_key_region,
 };
 
 void run_tests_once(void)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
