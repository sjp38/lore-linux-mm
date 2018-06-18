Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDAB26B0276
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 04:38:30 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x2-v6so9799654plv.0
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 01:38:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 184-v6si11564088pgd.343.2018.06.18.01.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 01:38:29 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 155/189] x86/pkeys/selftests: Give better unexpected fault error messages
Date: Mon, 18 Jun 2018 10:14:11 +0200
Message-Id: <20180618081215.462194707@linuxfoundation.org>
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

[ Upstream commit 55556b0b2016806b2e16a20b62d143383983a34a ]

do_not_expect_pk_fault() is a helper that we call when we do not expect
a PK fault to have occurred.  But, it is a function, which means that
it obscures the line numbers from pkey_assert().  It also gives no
details.

Replace it with an implementation that gives nice line numbers and
also lets callers pass in a more descriptive message about what
happened that caused the unexpected fault.

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
Link: http://lkml.kernel.org/r/20180509171338.55D13B64@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/protection_keys.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -954,10 +954,11 @@ void expected_pk_fault(int pkey)
 	last_si_pkey = -1;
 }
 
-void do_not_expect_pk_fault(void)
-{
-	pkey_assert(last_pkru_faults == pkru_faults);
-}
+#define do_not_expect_pk_fault(msg)	do {			\
+	if (last_pkru_faults != pkru_faults)			\
+		dprintf0("unexpected PK fault: %s\n", msg);	\
+	pkey_assert(last_pkru_faults == pkru_faults);		\
+} while (0)
 
 int test_fds[10] = { -1 };
 int nr_test_fds;
@@ -1243,7 +1244,7 @@ void test_ptrace_of_child(int *ptr, u16
 	pkey_assert(ret != -1);
 	/* Now access from the current task, and expect NO exception: */
 	peek_result = read_ptr(plain_ptr);
-	do_not_expect_pk_fault();
+	do_not_expect_pk_fault("read plain pointer after ptrace");
 
 	ret = ptrace(PTRACE_DETACH, child_pid, ignored, 0);
 	pkey_assert(ret != -1);
@@ -1287,7 +1288,7 @@ void test_executing_on_unreadable_memory
 	 */
 	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
 	lots_o_noops_around_write(&scratch);
-	do_not_expect_pk_fault();
+	do_not_expect_pk_fault("executing on PROT_EXEC memory");
 	ptr_contents = read_ptr(p1);
 	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
 	expected_pk_fault(pkey);
