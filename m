Received: from taynzmail03.nz-tay.cpqcorp.net (taynzmail03.nz-tay.cpqcorp.net [16.47.4.103])
	by atlrel6.hp.com (Postfix) with ESMTP id 38C453509F
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 14:49:55 -0500 (EST)
Received: from anw.zk3.dec.com (alpha.zk3.dec.com [16.140.128.4])
	by taynzmail03.nz-tay.cpqcorp.net (Postfix) with ESMTP id D92DB67A5
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 14:49:54 -0500 (EST)
Subject: [PATCH/RFC] AutoPage Migration - V0.1 - 5/8 x64_64 check/notify
	internode migration
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:49:35 -0500
Message-Id: <1142020175.5204.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.1 - 5/8 x64_64 check/notify internode migration

Hook check for task memory migration for x86_64.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git6/arch/x86_64/kernel/signal.c
===================================================================
--- linux-2.6.16-rc5-git6.orig/arch/x86_64/kernel/signal.c	2006-01-02 22:21:10.000000000 -0500
+++ linux-2.6.16-rc5-git6/arch/x86_64/kernel/signal.c	2006-03-03 10:26:44.000000000 -0500
@@ -24,6 +24,8 @@
 #include <linux/stddef.h>
 #include <linux/personality.h>
 #include <linux/compiler.h>
+#include <linux/auto-mmigrate.h>
+
 #include <asm/ucontext.h>
 #include <asm/uaccess.h>
 #include <asm/i387.h>
@@ -497,6 +499,12 @@ void do_notify_resume(struct pt_regs *re
 		clear_thread_flag(TIF_SINGLESTEP);
 	}
 
+	/*
+	 * check for task memory migration before delivering
+	 * signals so that hander[s] use memory in new node.
+	 */
+	check_migrate_pending();
+
 	/* deal with pending signal delivery */
 	if (thread_info_flags & _TIF_SIGPENDING)
 		do_signal(regs,oldset);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
