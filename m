Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 483C66B0547
	for <linux-mm@kvack.org>; Wed,  9 May 2018 13:19:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c187so1913893pfa.20
        for <linux-mm@kvack.org>; Wed, 09 May 2018 10:19:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t127-v6si1047914pgc.519.2018.05.09.10.18.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 10:18:59 -0700 (PDT)
Subject: [PATCH 10/13] x86/pkeys/selftests: Fix pointer math
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 09 May 2018 10:13:52 -0700
References: <20180509171336.76636D88@viggo.jf.intel.com>
In-Reply-To: <20180509171336.76636D88@viggo.jf.intel.com>
Message-Id: <20180509171352.9BE09819@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

We dump out the entire area of the siginfo where the si_pkey_ptr is
supposed to be.  But, we do some math on the poitner, which is a u32.
We intended to do byte math, not u32 math on the pointer.

Cast it over to a u8* so it works.

Also, move this block of code to below th si_code check.  It doesn't
hurt anything, but the si_pkey field is gibberish for other signal
types.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuah@kernel.org>
---

 b/tools/testing/selftests/x86/protection_keys.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff -puN tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-fix-pointer-math tools/testing/selftests/x86/protection_keys.c
--- a/tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-fix-pointer-math	2018-05-09 09:20:22.825698397 -0700
+++ b/tools/testing/selftests/x86/protection_keys.c	2018-05-09 09:20:22.830698397 -0700
@@ -293,13 +293,6 @@ void signal_handler(int signum, siginfo_
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
@@ -307,6 +300,13 @@ void signal_handler(int signum, siginfo_
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
_
