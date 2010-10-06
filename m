Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A83C56B0087
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 16:49:16 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 2/4] HWPOISON: Copy si_addr_lsb to user
Date: Wed,  6 Oct 2010 22:48:59 +0200
Message-Id: <1286398141-13749-3-git-send-email-andi@firstfloor.org>
In-Reply-To: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@linux.intel.com>

The original hwpoison code added a new siginfo field si_addr_lsb to
pass the granuality of the fault address to user space. Unfortunately
this field was never copied to user space. Fix this here.

I added explicit checks for the MCEERR codes to avoid having
to patch all potential callers to initialize the field.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 kernel/signal.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index bded651..919562c 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2215,6 +2215,14 @@ int copy_siginfo_to_user(siginfo_t __user *to, siginfo_t *from)
 #ifdef __ARCH_SI_TRAPNO
 		err |= __put_user(from->si_trapno, &to->si_trapno);
 #endif
+#ifdef BUS_MCEERR_AO
+		/* 
+		 * Other callers might not initialize the si_lsb field,
+	 	 * so check explicitely for the right codes here.
+		 */
+		if (from->si_code == BUS_MCEERR_AR || from->si_code == BUS_MCEERR_AO)
+			err |= __put_user(from->si_addr_lsb, &to->si_addr_lsb);
+#endif
 		break;
 	case __SI_CHLD:
 		err |= __put_user(from->si_pid, &to->si_pid);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
