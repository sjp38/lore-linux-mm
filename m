Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A90996B026F
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 04:38:11 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so9708339pld.23
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 01:38:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j6-v6si14530040pll.54.2018.06.18.01.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 01:38:10 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 159/189] x86/pkeys/selftests: Factor out "instruction page"
Date: Mon, 18 Jun 2018 10:14:15 +0200
Message-Id: <20180618081215.617261351@linuxfoundation.org>
In-Reply-To: <20180618081209.254234434@linuxfoundation.org>
References: <20180618081209.254234434@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellermen <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ram Pai <linuxram@us.ibm.com>, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@microsoft.com>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit 3fcd2b2d928904cbf30b01e2c5e4f1dd2f9ab262 ]

We currently have an execute-only test, but it is for
the explicit mprotect_pkey() interface.  We will soon
add a test for the implicit mprotect(PROT_EXEC)
enterface.  We need this code in both tests.

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
Link: http://lkml.kernel.org/r/20180509171347.C64AB733@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/protection_keys.c |   21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -1253,12 +1253,9 @@ void test_ptrace_of_child(int *ptr, u16
 	free(plain_ptr_unaligned);
 }
 
-void test_executing_on_unreadable_memory(int *ptr, u16 pkey)
+void *get_pointer_to_instructions(void)
 {
 	void *p1;
-	int scratch;
-	int ptr_contents;
-	int ret;
 
 	p1 = ALIGN_PTR_UP(&lots_o_noops_around_write, PAGE_SIZE);
 	dprintf3("&lots_o_noops: %p\n", &lots_o_noops_around_write);
@@ -1268,7 +1265,23 @@ void test_executing_on_unreadable_memory
 	/* Point 'p1' at the *second* page of the function: */
 	p1 += PAGE_SIZE;
 
+	/*
+	 * Try to ensure we fault this in on next touch to ensure
+	 * we get an instruction fault as opposed to a data one
+	 */
 	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
+
+	return p1;
+}
+
+void test_executing_on_unreadable_memory(int *ptr, u16 pkey)
+{
+	void *p1;
+	int scratch;
+	int ptr_contents;
+	int ret;
+
+	p1 = get_pointer_to_instructions();
 	lots_o_noops_around_write(&scratch);
 	ptr_contents = read_ptr(p1);
 	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
