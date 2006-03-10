Received: from taynzmail03.nz-tay.cpqcorp.net (relay-1.dec.com [16.47.4.103])
	by atlrel9.hp.com (Postfix) with ESMTP id B948C39235
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 14:48:23 -0500 (EST)
Received: from anw.zk3.dec.com (wasted.zk3.dec.com [16.140.32.3])
	by taynzmail03.nz-tay.cpqcorp.net (Postfix) with ESMTP id 7E4CF6656
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 14:48:23 -0500 (EST)
Subject: [PATCH/RFC] AutoPage Migration - V0.1 - 4/8 ia64 check/notify
	internode migration
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:48:04 -0500
Message-Id: <1142020084.5204.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.1 - 4/8 ia64 check/notify internode migration

This patch hooks the check for task memory migration pending 
into the ia64 do_notify_resume() function.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git6/arch/ia64/kernel/process.c
===================================================================
--- linux-2.6.16-rc5-git6.orig/arch/ia64/kernel/process.c	2006-03-03 10:15:20.000000000 -0500
+++ linux-2.6.16-rc5-git6/arch/ia64/kernel/process.c	2006-03-03 10:21:35.000000000 -0500
@@ -31,6 +31,7 @@
 #include <linux/interrupt.h>
 #include <linux/delay.h>
 #include <linux/kprobes.h>
+#include <linux/auto-migrate.h>
 
 #include <asm/cpu.h>
 #include <asm/delay.h>
@@ -173,6 +174,12 @@ do_notify_resume_user (sigset_t *oldset,
 		pfm_handle_work();
 #endif
 
+	/*
+	 * check for task memory migration before delivering
+	 * signals so that hander[s] use memory in new node.
+	 */
+	check_migrate_pending();
+
 	/* deal with pending signal delivery */
 	if (test_thread_flag(TIF_SIGPENDING))
 		ia64_do_signal(oldset, scr, in_syscall);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
