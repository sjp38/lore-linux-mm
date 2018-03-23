Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A39D6B002B
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 14:11:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j8so7056315pfh.13
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:11:17 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e23si7061448pfn.228.2018.03.23.11.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 11:11:16 -0700 (PDT)
Subject: [PATCH 6/9] x86, pkeys, selftests: fix pkey exhaustion test off-by-one
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 23 Mar 2018 11:09:14 -0700
References: <20180323180903.33B17168@viggo.jf.intel.com>
In-Reply-To: <20180323180903.33B17168@viggo.jf.intel.com>
Message-Id: <20180323180914.58B68408@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

In our "exhaust all pkeys" test, we make sure that there
is the expected number available.  Turns out that the
test did not cover the execute-only key, but discussed
it anyway.  It did *not* discuss the test-allocated
key.

Now that we have a test for the mprotect(PROT_EXEC) case,
this off-by-one issue showed itself.  Correct the off-by-
one and add the explanation for the case we missed.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuah@kernel.org>
---

 b/tools/testing/selftests/x86/protection_keys.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff -puN tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-exhaust-off-by-one tools/testing/selftests/x86/protection_keys.c
--- a/tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-exhaust-off-by-one	2018-03-21 15:47:50.910198920 -0700
+++ b/tools/testing/selftests/x86/protection_keys.c	2018-03-21 15:47:50.914198920 -0700
@@ -1155,12 +1155,15 @@ void test_pkey_alloc_exhaust(int *ptr, u
 	pkey_assert(i < NR_PKEYS*2);
 
 	/*
-	 * There are 16 pkeys supported in hardware.  One is taken
-	 * up for the default (0) and another can be taken up by
-	 * an execute-only mapping.  Ensure that we can allocate
-	 * at least 14 (16-2).
+	 * There are 16 pkeys supported in hardware.  Three are
+	 * allocated by the time we get here:
+	 *   1. The default key (0)
+	 *   2. One possibly consumed by an execute-only mapping.
+	 *   3. One allocated by the test code and passed in via
+	 *      'pkey' to this function.
+	 * Ensure that we can allocate at least another 13 (16-3).
 	 */
-	pkey_assert(i >= NR_PKEYS-2);
+	pkey_assert(i >= NR_PKEYS-3);
 
 	for (i = 0; i < nr_allocated_pkeys; i++) {
 		err = sys_pkey_free(allocated_pkeys[i]);
_
