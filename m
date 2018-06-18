Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37FE96B000A
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 04:26:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k193-v6so4962825pge.3
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 01:26:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v136-v6si14738077pfc.273.2018.06.18.01.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 01:26:20 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.16 235/279] x86/mpx/selftests: Adjust the self-test to fresh distros that export the MPX ABI
Date: Mon, 18 Jun 2018 10:13:40 +0200
Message-Id: <20180618080618.532433227@linuxfoundation.org>
In-Reply-To: <20180618080608.851973560@linuxfoundation.org>
References: <20180618080608.851973560@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org, linuxram@us.ibm.com, mpe@ellerman.id.au, shakeelb@google.com, shuah@kernel.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@microsoft.com>

4.16-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Ingo Molnar <mingo@kernel.org>

[ Upstream commit 73bb4d6cd192b8629c5125aaada9892d9fc986b6 ]

Fix this warning:

  mpx-mini-test.c:422:0: warning: "SEGV_BNDERR" redefined

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: akpm@linux-foundation.org
Cc: dave.hansen@intel.com
Cc: linux-mm@kvack.org
Cc: linuxram@us.ibm.com
Cc: mpe@ellerman.id.au
Cc: shakeelb@google.com
Cc: shuah@kernel.org
Link: http://lkml.kernel.org/r/20180514085908.GA12798@gmail.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/mpx-mini-test.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

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
@@ -419,8 +424,6 @@ void handler(int signum, siginfo_t *si,
 		br_count++;
 		dprintf1("#BR 0x%jx (total seen: %d)\n", status, br_count);
 
-#define SEGV_BNDERR     3  /* failed address bound checks */
-
 		dprintf2("Saw a #BR! status 0x%jx at %016lx br_reason: %jx\n",
 				status, ip, br_reason);
 		dprintf2("si_signo: %d\n", si->si_signo);
