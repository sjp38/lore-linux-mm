Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF4D6B026D
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 07:36:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a13-v6so7084786pfo.22
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 04:36:31 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j12-v6si9951391pgv.574.2018.06.17.04.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 04:36:30 -0700 (PDT)
Subject: Patch "x86/pkeys/selftests: Give better unexpected fault error messages" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 17 Jun 2018 13:23:31 +0200
Message-ID: <1529234611222244@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180509171338.55D13B64@viggo.jf.intel.com, akpm@linux-foundation.org, alexander.levin@microsoft.com, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys/selftests: Give better unexpected fault error messages

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-selftests-give-better-unexpected-fault-error-messages.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun Jun 17 12:13:49 CEST 2018
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 9 May 2018 10:13:38 -0700
Subject: x86/pkeys/selftests: Give better unexpected fault error messages

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


Patches currently in stable-queue which might be from dave.hansen@linux.intel.com are

queue-4.14/x86-pkeys-selftests-factor-out-instruction-page.patch
queue-4.14/x86-pkeys-selftests-fix-pointer-math.patch
queue-4.14/x86-pkeys-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-pkeys-abi.patch
queue-4.14/x86-pkeys-selftests-add-a-test-for-pkey-0.patch
queue-4.14/x86-pkeys-selftests-stop-using-assert.patch
queue-4.14/x86-pkeys-selftests-save-off-prot-for-allocations.patch
queue-4.14/x86-pkeys-selftests-remove-dead-debugging-code-fix-dprint_in_signal.patch
queue-4.14/x86-mpx-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-mpx-abi.patch
queue-4.14/x86-pkeys-selftests-add-prot_exec-test.patch
queue-4.14/x86-pkeys-selftests-allow-faults-on-unknown-keys.patch
queue-4.14/x86-pkeys-selftests-give-better-unexpected-fault-error-messages.patch
queue-4.14/x86-pkeys-selftests-fix-pkey-exhaustion-test-off-by-one.patch
