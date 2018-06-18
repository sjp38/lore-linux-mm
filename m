Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC3E26B0010
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 04:28:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x25-v6so8296720pfn.21
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 01:28:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f21-v6si14803734pfh.33.2018.06.18.01.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 01:28:04 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.16 245/279] x86/pkeys/selftests: Fix pointer math
Date: Mon, 18 Jun 2018 10:13:50 +0200
Message-Id: <20180618080618.910985893@linuxfoundation.org>
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
