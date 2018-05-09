Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 166EF6B053D
	for <linux-mm@kvack.org>; Wed,  9 May 2018 13:18:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x21so9815844pfn.23
        for <linux-mm@kvack.org>; Wed, 09 May 2018 10:18:46 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id k16-v6si28983657pli.171.2018.05.09.10.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 10:18:44 -0700 (PDT)
Subject: [PATCH 01/13] x86/pkeys/selftests: Give better unexpected fault error messages
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 09 May 2018 10:13:38 -0700
References: <20180509171336.76636D88@viggo.jf.intel.com>
In-Reply-To: <20180509171336.76636D88@viggo.jf.intel.com>
Message-Id: <20180509171338.55D13B64@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

do_not_expect_pk_fault() is a helper that we call when we do not expect
a PK fault to have occurred.  But, it is a function, which means that
it obscures the line numbers from pkey_assert().  It also gives no
details.

Replace it with an implementation that gives nice line numbers and
also lets callers pass in a more descriptive message about what
happened that caused the unexpected fault.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuah@kernel.org>
---

 b/tools/testing/selftests/x86/protection_keys.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff -puN tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-give-better-pkey-fault-errors tools/testing/selftests/x86/protection_keys.c
--- a/tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-give-better-pkey-fault-errors	2018-05-09 09:20:18.202698408 -0700
+++ b/tools/testing/selftests/x86/protection_keys.c	2018-05-09 09:20:18.205698408 -0700
@@ -939,10 +939,11 @@ void expected_pk_fault(int pkey)
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
@@ -1228,7 +1229,7 @@ void test_ptrace_of_child(int *ptr, u16
 	pkey_assert(ret != -1);
 	/* Now access from the current task, and expect NO exception: */
 	peek_result = read_ptr(plain_ptr);
-	do_not_expect_pk_fault();
+	do_not_expect_pk_fault("read plain pointer after ptrace");
 
 	ret = ptrace(PTRACE_DETACH, child_pid, ignored, 0);
 	pkey_assert(ret != -1);
@@ -1272,7 +1273,7 @@ void test_executing_on_unreadable_memory
 	 */
 	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
 	lots_o_noops_around_write(&scratch);
-	do_not_expect_pk_fault();
+	do_not_expect_pk_fault("executing on PROT_EXEC memory");
 	ptr_contents = read_ptr(p1);
 	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
 	expected_pk_fault(pkey);
_
