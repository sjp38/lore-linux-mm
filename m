Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A14596B0280
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 07:49:32 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id i1-v6so8240255pld.11
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 04:49:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n11-v6si12517427plg.230.2018.06.17.04.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 04:49:31 -0700 (PDT)
Subject: Patch "x86/pkeys/selftests: Avoid printf-in-signal deadlocks" has been added to the 4.16-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 17 Jun 2018 13:23:53 +0200
Message-ID: <152923463324762@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180509171344.C53FD2F3@viggo.jf.intel.com, akpm@linux-foundation.org, alexander.levin@microsoft.com, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys/selftests: Avoid printf-in-signal deadlocks

to the 4.16-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-selftests-avoid-printf-in-signal-deadlocks.patch
and it can be found in the queue-4.16 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun Jun 17 12:07:34 CEST 2018
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 9 May 2018 10:13:44 -0700
Subject: x86/pkeys/selftests: Avoid printf-in-signal deadlocks

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit caf9eb6b4c82fc6cbd03697052ff22d97b0c377b ]

printf() and friends are unusable in signal handlers.  They deadlock.
The pkey selftest does not do any normal printing in signal handlers,
only extra debugging.  So, just print the format string so we get
*some* output when debugging.

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
Link: http://lkml.kernel.org/r/20180509171344.C53FD2F3@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/pkey-helpers.h |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

--- a/tools/testing/selftests/x86/pkey-helpers.h
+++ b/tools/testing/selftests/x86/pkey-helpers.h
@@ -26,30 +26,26 @@ static inline void sigsafe_printf(const
 {
 	va_list ap;
 
-	va_start(ap, format);
 	if (!dprint_in_signal) {
+		va_start(ap, format);
 		vprintf(format, ap);
+		va_end(ap);
 	} else {
 		int ret;
-		int len = vsnprintf(dprint_in_signal_buffer,
-				    DPRINT_IN_SIGNAL_BUF_SIZE,
-				    format, ap);
 		/*
-		 * len is amount that would have been printed,
-		 * but actual write is truncated at BUF_SIZE.
+		 * No printf() functions are signal-safe.
+		 * They deadlock easily. Write the format
+		 * string to get some output, even if
+		 * incomplete.
 		 */
-		if (len > DPRINT_IN_SIGNAL_BUF_SIZE)
-			len = DPRINT_IN_SIGNAL_BUF_SIZE;
-		ret = write(1, dprint_in_signal_buffer, len);
+		ret = write(1, format, strlen(format));
 		if (ret < 0)
-			abort();
+			exit(1);
 	}
-	va_end(ap);
 }
 #define dprintf_level(level, args...) do {	\
 	if (level <= DEBUG_LEVEL)		\
 		sigsafe_printf(args);		\
-	fflush(NULL);				\
 } while (0)
 #define dprintf0(args...) dprintf_level(0, args)
 #define dprintf1(args...) dprintf_level(1, args)


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
