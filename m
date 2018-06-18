Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 621526B0270
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 04:37:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y26-v6so8317847pfn.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 01:37:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c18-v6si13497651pfn.245.2018.06.18.01.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 01:37:38 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 157/189] x86/pkeys/selftests: Remove dead debugging code, fix dprint_in_signal
Date: Mon, 18 Jun 2018 10:14:13 +0200
Message-Id: <20180618081215.543048765@linuxfoundation.org>
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

[ Upstream commit a50093d60464dd51d1ae0c2267b0abe9e1de77f3 ]

There is some noisy debug code at the end of the signal handler.  It was
disabled by an early, unconditional "return".  However, that return also
hid a dprint_in_signal=0, which kept dprint_in_signal=1 and effectively
locked us into permanent dprint_in_signal=1 behavior.

Remove the return and the dead code, fixing dprint_in_signal.

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
Link: http://lkml.kernel.org/r/20180509171342.846B9B2E@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/protection_keys.c |   16 ----------------
 1 file changed, 16 deletions(-)

--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -325,22 +325,6 @@ void signal_handler(int signum, siginfo_
 	dprintf1("WARNING: set PRKU=0 to allow faulting instruction to continue\n");
 	pkru_faults++;
 	dprintf1("<<<<==================================================\n");
-	return;
-	if (trapno == 14) {
-		fprintf(stderr,
-			"ERROR: In signal handler, page fault, trapno = %d, ip = %016lx\n",
-			trapno, ip);
-		fprintf(stderr, "si_addr %p\n", si->si_addr);
-		fprintf(stderr, "REG_ERR: %lx\n",
-				(unsigned long)uctxt->uc_mcontext.gregs[REG_ERR]);
-		exit(1);
-	} else {
-		fprintf(stderr, "unexpected trap %d! at 0x%lx\n", trapno, ip);
-		fprintf(stderr, "si_addr %p\n", si->si_addr);
-		fprintf(stderr, "REG_ERR: %lx\n",
-				(unsigned long)uctxt->uc_mcontext.gregs[REG_ERR]);
-		exit(2);
-	}
 	dprint_in_signal = 0;
 }
 
