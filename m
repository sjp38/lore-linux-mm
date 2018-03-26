Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 919756B0022
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:29:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e18so3291663pfi.23
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:29:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l1-v6si15294339pld.312.2018.03.26.10.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 10:29:42 -0700 (PDT)
Subject: [PATCH 5/9] x86, pkeys, selftests: fix pointer math
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 26 Mar 2018 10:27:29 -0700
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
In-Reply-To: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
Message-Id: <20180326172729.A555C761@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

We dump out the entire area of the siginfo where the
si_pkey_ptr is supposed to be.  But, we do some math
on the poitner, which is a u32.  We intended to do
byte math, not u32 math on the pointer.

Cast it over to a u8* so it works.

Also, move this block of code to below th si_code
check.  It doesn't hurt anything, but the si_pkey
field is gibberish for other signal types.

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
--- a/tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-fix-pointer-math	2018-03-26 10:22:35.940170191 -0700
+++ b/tools/testing/selftests/x86/protection_keys.c	2018-03-26 10:22:35.944170191 -0700
@@ -289,13 +289,6 @@ void signal_handler(int signum, siginfo_
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
@@ -303,6 +296,13 @@ void signal_handler(int signum, siginfo_
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
