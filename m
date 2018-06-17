Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 181DE6B0286
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 07:49:41 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b65-v6so7198466plb.5
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 04:49:41 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z4-v6si12932750pfl.31.2018.06.17.04.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 04:49:40 -0700 (PDT)
Subject: Patch "x86/pkeys/selftests: Fix pointer math" has been added to the 4.16-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 17 Jun 2018 13:23:53 +0200
Message-ID: <152923463314434@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180509171352.9BE09819@viggo.jf.intel.com, akpm@linux-foundation.org, alexander.levin@microsoft.com, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys/selftests: Fix pointer math

to the 4.16-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-selftests-fix-pointer-math.patch
and it can be found in the queue-4.16 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun Jun 17 12:07:34 CEST 2018
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 9 May 2018 10:13:52 -0700
Subject: x86/pkeys/selftests: Fix pointer math

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit 3d64f4ed15c3c53dba4c514bf59c334464dee373 ]

We dump out the entire area of the siginfo where the si_pkey_ptr is
supposed to be.  But, we do some math on the poitner, which is a u32.
We intended to do byte math, not u32 math on the pointer.

Cast it over to a u8* so it works.

Also, move this block of code to below th si_code check.  It doesn't
hurt anything, but the si_pkey field is gibberish for other signal
types.

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
Link: http://lkml.kernel.org/r/20180509171352.9BE09819@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/protection_keys.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -303,13 +303,6 @@ void signal_handler(int signum, siginfo_
 		dump_mem(pkru_ptr - 128, 256);
 	pkey_assert(*pkru_ptr);
 
-	si_pkey_ptr = (u32 *)(((u8 *)si) + si_pkey_offset);
-	dprintf1("si_pkey_ptr: %p\n", si_pkey_ptr);
-	dump_mem(si_pkey_ptr - 8, 24);
-	siginfo_pkey = *si_pkey_ptr;
-	pkey_assert(siginfo_pkey < NR_PKEYS);
-	last_si_pkey = siginfo_pkey;
-
 	if ((si->si_code == SEGV_MAPERR) ||
 	    (si->si_code == SEGV_ACCERR) ||
 	    (si->si_code == SEGV_BNDERR)) {
@@ -317,6 +310,13 @@ void signal_handler(int signum, siginfo_
 		exit(4);
 	}
 
+	si_pkey_ptr = (u32 *)(((u8 *)si) + si_pkey_offset);
+	dprintf1("si_pkey_ptr: %p\n", si_pkey_ptr);
+	dump_mem((u8 *)si_pkey_ptr - 8, 24);
+	siginfo_pkey = *si_pkey_ptr;
+	pkey_assert(siginfo_pkey < NR_PKEYS);
+	last_si_pkey = siginfo_pkey;
+
 	dprintf1("signal pkru from xsave: %08x\n", *pkru_ptr);
 	/* need __rdpkru() version so we do not do shadow_pkru checking */
 	dprintf1("signal pkru from  pkru: %08x\n", __rdpkru());


Patches currently in stable-queue which might be from dave.hansen@linux.intel.com are

queue-4.16/x86-pkeys-selftests-factor-out-instruction-page.patch
queue-4.16/x86-pkeys-selftests-fix-pointer-math.patch
queue-4.16/x86-pkeys-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-pkeys-abi.patch
queue-4.16/x86-pkeys-selftests-add-a-test-for-pkey-0.patch
queue-4.16/x86-pkeys-selftests-stop-using-assert.patch
queue-4.16/x86-pkeys-selftests-save-off-prot-for-allocations.patch
queue-4.16/x86-pkeys-selftests-remove-dead-debugging-code-fix-dprint_in_signal.patch
queue-4.16/x86-mpx-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-mpx-abi.patch
queue-4.16/x86-pkeys-selftests-add-prot_exec-test.patch
queue-4.16/x86-pkeys-selftests-allow-faults-on-unknown-keys.patch
queue-4.16/x86-pkeys-selftests-give-better-unexpected-fault-error-messages.patch
queue-4.16/x86-pkeys-selftests-avoid-printf-in-signal-deadlocks.patch
queue-4.16/x86-pkeys-selftests-fix-pkey-exhaustion-test-off-by-one.patch
