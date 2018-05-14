Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C56CD6B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:59:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id d4-v6so9120413wrn.15
        for <linux-mm@kvack.org>; Mon, 14 May 2018 01:59:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e193-v6sor1489662wmd.66.2018.05.14.01.59.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 01:59:11 -0700 (PDT)
Date: Mon, 14 May 2018 10:59:08 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH] x86/mpx/selftests: Adjust the self-test to fresh distros
 that export the MPX ABI
Message-ID: <20180514085908.GA12798@gmail.com>
References: <20180509171336.76636D88@viggo.jf.intel.com>
 <20180514082918.GA21574@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180514082918.GA21574@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com

Fix this warning:

  mpx-mini-test.c:422:0: warning: "SEGV_BNDERR" redefined

Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 tools/testing/selftests/x86/mpx-mini-test.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/x86/mpx-mini-test.c b/tools/testing/selftests/x86/mpx-mini-test.c
index 9c0325e1ea68..50f7e9272481 100644
--- a/tools/testing/selftests/x86/mpx-mini-test.c
+++ b/tools/testing/selftests/x86/mpx-mini-test.c
@@ -368,6 +368,11 @@ static int expected_bnd_index = -1;
 uint64_t shadow_plb[NR_MPX_BOUNDS_REGISTERS][2]; /* shadow MPX bound registers */
 unsigned long shadow_map[NR_MPX_BOUNDS_REGISTERS];
 
+/* Failed address bound checks: */
+#ifndef SEGV_BNDERR
+# define SEGV_BNDERR	3
+#endif
+
 /*
  * The kernel is supposed to provide some information about the bounds
  * exception in the siginfo.  It should match what we have in the bounds
@@ -419,8 +424,6 @@ void handler(int signum, siginfo_t *si, void *vucontext)
 		br_count++;
 		dprintf1("#BR 0x%jx (total seen: %d)\n", status, br_count);
 
-#define SEGV_BNDERR     3  /* failed address bound checks */
-
 		dprintf2("Saw a #BR! status 0x%jx at %016lx br_reason: %jx\n",
 				status, ip, br_reason);
 		dprintf2("si_signo: %d\n", si->si_signo);
