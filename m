Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F337E6B002A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:48:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u3so5266129pgp.13
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:48:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m11-v6si6775336pls.520.2018.03.16.14.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:48:34 -0700 (PDT)
Subject: [PATCH 3/3] x86, pkeys, selftests: add a test for pkey 0
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 16 Mar 2018 14:46:59 -0700
References: <20180316214654.895E24EC@viggo.jf.intel.com>
In-Reply-To: <20180316214654.895E24EC@viggo.jf.intel.com>
Message-Id: <20180316214659.FCFEF68B@viggo.jf.intel.com>
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
--- a/tools/testing/selftests/x86/protection_keys.c~pkeys-update-selftests-with-pkey-0-test	2018-03-16 14:46:40.121285473 -0700
+++ b/tools/testing/selftests/x86/protection_keys.c	2018-03-16 14:46:40.125285473 -0700
@@ -1197,6 +1197,35 @@ void test_pkey_alloc_exhaust(int *ptr, u
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
@@ -1334,6 +1363,7 @@ void (*pkey_tests[])(int *ptr, u16 pkey)
 	test_kernel_gup_of_access_disabled_region,
 	test_kernel_gup_write_to_write_disabled_region,
 	test_executing_on_unreadable_memory,
+	test_mprotect_with_pkey_0,
 	test_ptrace_of_child,
 	test_pkey_syscalls_on_non_allocated_pkey,
 	test_pkey_syscalls_bad_args,
_
