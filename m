Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 313AD6B005A
	for <linux-mm@kvack.org>; Mon, 25 May 2009 17:31:17 -0400 (EDT)
Date: Mon, 25 May 2009 22:31:09 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Fw: [Bugme-new] [Bug 13366] New: About 80% of shutdowns fail
 (blocking)
In-Reply-To: <20090522214305.8e2d474a.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0905252215340.11747@sister.anvils>
References: <20090522214305.8e2d474a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Martin Bammer <mrb74@gmx.at>
Cc: linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

A git-bisect would indeed be worthwhile; but looking through the diff
between 2.6.30-rc5 and 2.6.30-rc7 didn't show any likely candidates -
I wonder if this will turn out to be something more elusive.

Is this an Acer Aspire One?  Looks rather like it: I tried building
your kernel (on openSUSE rather than Ubuntu) on mine, and running it:
no luck reproducing your issue here.

I doubt this has got much to do with mlockall() or lru_add_drain_all()
themselves: it looks rather as if an events thread has "gone away".

Would you mind applying the hacky patch below, and posting the
screenshot from shutdown?  I assume from the fact that you posted
a photo, that nothing useful gets out to the logs: so here I'm trying
to leave just the "events/0" and "events/1" stacktraces onscreen.

--- 2.6.30-rc7/kernel/hung_task.c	2009-04-08 14:59:26.000000000 +0100
+++ linux/kernel/hung_task.c	2009-05-25 18:45:11.000000000 +0100
@@ -98,7 +98,7 @@ static void check_hung_task(struct task_
 	printk(KERN_ERR "\"echo 0 > /proc/sys/kernel/hung_task_timeout_secs\""
 			" disables this message.\n");
 	sched_show_task(t);
-	__debug_show_held_locks(t);
+	show_state_filter(512);
 
 	touch_nmi_watchdog();
 
--- 2.6.30-rc7/kernel/sched.c	2009-05-09 09:24:35.000000000 +0100
+++ linux/kernel/sched.c	2009-05-25 19:08:05.000000000 +0100
@@ -6514,13 +6514,14 @@ void show_state_filter(unsigned long sta
 		 * console might take alot of time:
 		 */
 		touch_nmi_watchdog();
-		if (!state_filter || (p->state & state_filter))
+		if ((state_filter == 512 && !strncmp(p->comm, "events/", 7)) ||
+		    !state_filter || (p->state & state_filter))
 			sched_show_task(p);
 	} while_each_thread(g, p);
 
 	touch_all_softlockup_watchdogs();
 
-#ifdef CONFIG_SCHED_DEBUG
+#ifdef CONFIG_SCHED_DEBUG_NOT
 	sysrq_sched_debug_show();
 #endif
 	read_unlock(&tasklist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
