Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 691D16B0549
	for <linux-mm@kvack.org>; Wed,  9 May 2018 13:19:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e20so26538080pff.14
        for <linux-mm@kvack.org>; Wed, 09 May 2018 10:19:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t127-v6si1047914pgc.519.2018.05.09.10.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 10:19:03 -0700 (PDT)
Subject: [PATCH 12/13] x86/pkeys/selftests: Add a test for pkey 0
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 09 May 2018 10:13:56 -0700
References: <20180509171336.76636D88@viggo.jf.intel.com>
In-Reply-To: <20180509171336.76636D88@viggo.jf.intel.com>
Message-Id: <20180509171356.9E40B254@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

Protection key 0 is the default key for all memory and will
not normally come back from pkey_alloc().  But, you might
still want pass it to mprotect_pkey().

This check ensures that you can use pkey 0.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuah@kernel.org>
---

 b/tools/testing/selftests/x86/protection_keys.c |   30 ++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff -puN tools/testing/selftests/x86/protection_keys.c~pkeys-update-selftests-with-pkey-0-test tools/testing/selftests/x86/protection_keys.c
--- a/tools/testing/selftests/x86/protection_keys.c~pkeys-update-selftests-with-pkey-0-test	2018-05-09 09:20:23.852698394 -0700
+++ b/tools/testing/selftests/x86/protection_keys.c	2018-05-09 09:20:23.855698394 -0700
@@ -1169,6 +1169,35 @@ void test_pkey_alloc_exhaust(int *ptr, u
 	}
 }
 
+/*
+ * pkey 0 is special.  It is allocated by default, so you do not
+ * have to call pkey_alloc() to use it first.  Make sure that it
+ * is usable.
+ */
+void test_mprotect_with_pkey_0(int *ptr, u16 pkey)
+{
+	long size;
+	int prot;
+
+	assert(pkey_last_malloc_record);
+	size = pkey_last_malloc_record->size;
+	/*
+	 * This is a bit of a hack.  But mprotect() requires
+	 * huge-page-aligned sizes when operating on hugetlbfs.
+	 * So, make sure that we use something that's a multiple
+	 * of a huge page when we can.
+	 */
+	if (size >= HPAGE_SIZE)
+		size = HPAGE_SIZE;
+	prot = pkey_last_malloc_record->prot;
+
+	/* Use pkey 0 */
+	mprotect_pkey(ptr, size, prot, 0);
+
+	/* Make sure that we can set it back to the original pkey. */
+	mprotect_pkey(ptr, size, prot, pkey);
+}
+
 void test_ptrace_of_child(int *ptr, u16 pkey)
 {
 	__attribute__((__unused__)) int peek_result;
@@ -1363,6 +1392,7 @@ void (*pkey_tests[])(int *ptr, u16 pkey)
 	test_kernel_gup_write_to_write_disabled_region,
 	test_executing_on_unreadable_memory,
 	test_implicit_mprotect_exec_only_memory,
+	test_mprotect_with_pkey_0,
 	test_ptrace_of_child,
 	test_pkey_syscalls_on_non_allocated_pkey,
 	test_pkey_syscalls_bad_args,
_
