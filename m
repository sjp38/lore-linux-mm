Received: from smtp1.fc.hp.com (smtp.fc.hp.com [15.15.136.127])
	by atlrel7.hp.com (Postfix) with ESMTP id 9116334C1C
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:38:57 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id 6982A109C3
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:38:57 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 46065138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:38:57 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 22880-05 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:38:55 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 26BA7138E3A
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:38:54 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 5/9] AutoPage Migration - V0.2 - x64_64
	check/notify internode migration
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441946.5198.52.camel@localhost.localdomain>
References: <1144441946.5198.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:40:18 -0400
Message-Id: <1144442418.5198.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.2 - 5/9 x64_64 check/notify internode migration

Hook check for task memory migration for x86_64.

V0.1 -> V0.2:  fix type in auto-migrate.h include.
		tested on quad-opteron platform

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-mm1/arch/x86_64/kernel/signal.c
===================================================================
--- linux-2.6.16-mm1.orig/arch/x86_64/kernel/signal.c	2006-03-23 11:00:44.000000000 -0500
+++ linux-2.6.16-mm1/arch/x86_64/kernel/signal.c	2006-03-23 16:50:04.000000000 -0500
@@ -24,6 +24,8 @@
 #include <linux/stddef.h>
 #include <linux/personality.h>
 #include <linux/compiler.h>
+#include <linux/auto-migrate.h>
+
 #include <asm/ucontext.h>
 #include <asm/uaccess.h>
 #include <asm/i387.h>
@@ -493,6 +495,12 @@ void do_notify_resume(struct pt_regs *re
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
