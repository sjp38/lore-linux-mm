Received: from smtp1.fc.hp.com (smtp.fc.hp.com [15.15.136.127])
	by atlrel7.hp.com (Postfix) with ESMTP id 9931D344DC
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:38:04 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id 6360A109C3
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:38:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 42908138E39
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:38:04 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 22731-08 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:38:02 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 14354138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:38:02 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 4/9] AutoPage Migration - V0.2 - ia64
	check/notify internode migration
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441946.5198.52.camel@localhost.localdomain>
References: <1144441946.5198.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:39:26 -0400
Message-Id: <1144442366.5198.60.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.2 - 4/9 ia64 check/notify internode migration

V0.2 - refresh only

This patch hooks the check for task memory migration pending 
into the ia64 do_notify_resume() function.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-mm1/arch/ia64/kernel/process.c
===================================================================
--- linux-2.6.16-mm1.orig/arch/ia64/kernel/process.c	2006-03-23 11:00:43.000000000 -0500
+++ linux-2.6.16-mm1/arch/ia64/kernel/process.c	2006-03-23 16:49:58.000000000 -0500
@@ -30,6 +30,7 @@
 #include <linux/efi.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
+#include <linux/auto-migrate.h>
 
 #include <asm/cpu.h>
 #include <asm/delay.h>
@@ -172,6 +173,12 @@ do_notify_resume_user (sigset_t *oldset,
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
