Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA086B0269
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 04:28:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b65-v6so8688271plb.5
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 01:28:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r5-v6si14108162pls.518.2018.06.18.01.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 01:28:10 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.16 247/279] x86/pkeys/selftests: Add a test for pkey 0
Date: Mon, 18 Jun 2018 10:13:52 +0200
Message-Id: <20180618080618.983261598@linuxfoundation.org>
In-Reply-To: <20180618080608.851973560@linuxfoundation.org>
References: <20180618080608.851973560@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellermen <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ram Pai <linuxram@us.ibm.com>, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@microsoft.com>

4.16-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit 3488a600d90bcaf061b104dbcfbdc8d99b398312 ]

Protection key 0 is the default key for all memory and will
not normally come back from pkey_alloc().  But, you might
still want pass it to mprotect_pkey().

This check ensures that you can use pkey 0.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Shuah Khan <shuah@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20180509171356.9E40B254@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/protection_keys.c |   30 ++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -1184,6 +1184,35 @@ void test_pkey_alloc_exhaust(int *ptr, u
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
@@ -1378,6 +1407,7 @@ void (*pkey_tests[])(int *ptr, u16 pkey)
 	test_kernel_gup_write_to_write_disabled_region,
 	test_executing_on_unreadable_memory,
 	test_implicit_mprotect_exec_only_memory,
+	test_mprotect_with_pkey_0,
 	test_ptrace_of_child,
 	test_pkey_syscalls_on_non_allocated_pkey,
 	test_pkey_syscalls_bad_args,
