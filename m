Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA4F9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 14:10:57 -0400 (EDT)
Message-Id: <e213ea00900cba783f228eb4234ad929a05d4359.1317110948.git.mhocko@suse.cz>
In-Reply-To: <cover.1317110948.git.mhocko@suse.cz>
References: <cover.1317110948.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Tue, 27 Sep 2011 08:56:03 +0200
Subject: [PATCH 1/2] lguest: move process freezing before pending signals
 check
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

run_guest tries to freeze the current process after it has handled
pending interrupts and before it calls lguest_arch_run_guest.
This doesn't work nicely if the task has been killed while being frozen
and when we want to handle that signal as soon as possible.
Let's move try_to_freeze before we check for pending signal so that we
can get out of the loop as soon as possible.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/lguest/core.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/lguest/core.c b/drivers/lguest/core.c
index 2535933..e7dda91 100644
--- a/drivers/lguest/core.c
+++ b/drivers/lguest/core.c
@@ -232,6 +232,13 @@ int run_guest(struct lg_cpu *cpu, unsigned long __user *user)
 			}
 		}
 
+		/*
+		 * All long-lived kernel loops need to check with this horrible
+		 * thing called the freezer.  If the Host is trying to suspend,
+		 * it stops us.
+		 */
+		try_to_freeze();
+
 		/* Check for signals */
 		if (signal_pending(current))
 			return -ERESTARTSYS;
@@ -246,13 +253,6 @@ int run_guest(struct lg_cpu *cpu, unsigned long __user *user)
 			try_deliver_interrupt(cpu, irq, more);
 
 		/*
-		 * All long-lived kernel loops need to check with this horrible
-		 * thing called the freezer.  If the Host is trying to suspend,
-		 * it stops us.
-		 */
-		try_to_freeze();
-
-		/*
 		 * Just make absolutely sure the Guest is still alive.  One of
 		 * those hypercalls could have been fatal, for example.
 		 */
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
