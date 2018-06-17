Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3F1F6B026A
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 07:36:25 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t19-v6so8283858plo.9
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 04:36:25 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g61-v6si12583110plb.169.2018.06.17.04.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 04:36:24 -0700 (PDT)
Subject: Patch "x86/pkeys/selftests: Fix pkey exhaustion test off-by-one" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 17 Jun 2018 13:23:31 +0200
Message-ID: <1529234611245241@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180509171350.E1656B95@viggo.jf.intel.com, akpm@linux-foundation.org, alexander.levin@microsoft.com, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys/selftests: Fix pkey exhaustion test off-by-one

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-selftests-fix-pkey-exhaustion-test-off-by-one.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun Jun 17 12:13:49 CEST 2018
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 9 May 2018 10:13:50 -0700
Subject: x86/pkeys/selftests: Fix pkey exhaustion test off-by-one

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit f50b4878329ab61d8e05796f655adeb6f5fb57c6 ]

In our "exhaust all pkeys" test, we make sure that there
is the expected number available.  Turns out that the
test did not cover the execute-only key, but discussed
it anyway.  It did *not* discuss the test-allocated
key.

Now that we have a test for the mprotect(PROT_EXEC) case,
this off-by-one issue showed itself.  Correct the off-by-
one and add the explanation for the case we missed.

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
Link: http://lkml.kernel.org/r/20180509171350.E1656B95@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/protection_keys.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -1163,12 +1163,15 @@ void test_pkey_alloc_exhaust(int *ptr, u
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
