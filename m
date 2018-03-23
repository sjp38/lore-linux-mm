Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 499106B0282
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 14:11:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id c16so6295330pgv.8
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:11:21 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id u8-v6si9395744plr.50.2018.03.23.11.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 11:11:20 -0700 (PDT)
Subject: [PATCH 8/9] x86, pkeys, selftests: add allow faults on unknown keys
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 23 Mar 2018 11:09:17 -0700
References: <20180323180903.33B17168@viggo.jf.intel.com>
In-Reply-To: <20180323180903.33B17168@viggo.jf.intel.com>
Message-Id: <20180323180917.DFF35209@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The exec-only pkey is allocated inside the kernel and userspace
is not told what it is.  So, allow PK faults to occur that have
an unknown key.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuah@kernel.org>
---

 b/tools/testing/selftests/x86/protection_keys.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff -puN tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-unknown-exec-only-key tools/testing/selftests/x86/protection_keys.c
--- a/tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-unknown-exec-only-key	2018-03-21 15:47:51.985198917 -0700
+++ b/tools/testing/selftests/x86/protection_keys.c	2018-03-21 15:47:51.988198917 -0700
@@ -922,13 +922,21 @@ void *malloc_pkey(long size, int prot, u
 }
 
 int last_pkru_faults;
+#define UNKNOWN_PKEY -2
 void expected_pk_fault(int pkey)
 {
 	dprintf2("%s(): last_pkru_faults: %d pkru_faults: %d\n",
 			__func__, last_pkru_faults, pkru_faults);
 	dprintf2("%s(%d): last_si_pkey: %d\n", __func__, pkey, last_si_pkey);
 	pkey_assert(last_pkru_faults + 1 == pkru_faults);
-	pkey_assert(last_si_pkey == pkey);
+
+       /*
+	* For exec-only memory, we do not know the pkey in
+	* advance, so skip this check.
+	*/
+	if (pkey != UNKNOWN_PKEY)
+		pkey_assert(last_si_pkey == pkey);
+
 	/*
 	 * The signal handler shold have cleared out PKRU to let the
 	 * test program continue.  We now have to restore it.
_
