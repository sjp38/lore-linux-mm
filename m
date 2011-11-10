Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9E99C6B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 11:58:25 -0500 (EST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 10 Nov 2011 22:14:15 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAGgjvt2183274
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 22:12:45 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAGgjGb005078
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 22:12:45 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH] PM/Memory-hotplug: Avoid task freezing failures
Date: Thu, 10 Nov 2011 22:12:43 +0530
Message-ID: <20111110163825.4321.56320.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl
Cc: pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

The lock_system_sleep() function is used in the memory hotplug code at
several places in order to implement mutual exclusion with hibernation.
However, this function tries to acquire the 'pm_mutex' lock using
mutex_lock() and hence blocks in TASK_UNINTERRUPTIBLE state if it doesn't
get the lock. This would lead to task freezing failures and hence
hibernation failure as a consequence, even though the hibernation call path
successfully acquired the lock.

This patch fixes this issue by modifying lock_system_sleep() to use
mutex_lock_interruptible() instead of mutex_lock(), so that it blocks in the
TASK_INTERRUPTIBLE state. This would allow the freezer to freeze the blocked
task. Also, since the freezer could use signals to freeze tasks, it is quite
likely that mutex_lock_interruptible() returns -EINTR (and fails to acquire
the lock). Hence we keep retrying in a loop until we acquire the lock. Also,
we call try_to_freeze() within the loop, so that we don't cause freezing
failures due to busy looping.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/suspend.h |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/include/linux/suspend.h b/include/linux/suspend.h
index 57a6924..02a0d09 100644
--- a/include/linux/suspend.h
+++ b/include/linux/suspend.h
@@ -5,6 +5,7 @@
 #include <linux/notifier.h>
 #include <linux/init.h>
 #include <linux/pm.h>
+#include <linux/freezer.h>
 #include <linux/mm.h>
 #include <asm/errno.h>
 
@@ -380,7 +381,22 @@ static inline void unlock_system_sleep(void) {}
 
 static inline void lock_system_sleep(void)
 {
-	mutex_lock(&pm_mutex);
+	/*
+	 * We should not use mutex_lock() here because, in case we fail to
+	 * acquire the lock, it would put us to sleep in TASK_UNINTERRUPTIBLE
+	 * state, which would lead to task freezing failures. As a
+	 * consequence, hibernation would fail (even though it had acquired
+	 * the 'pm_mutex' lock).
+	 *
+	 * Note that mutex_lock_interruptible() returns -EINTR if we happen
+	 * to get a signal when we are waiting to acquire the lock (and this
+	 * is very likely here because the freezer could use signals to freeze
+	 * tasks). Hence we have to keep retrying until we get the lock. But
+	 * we have to use try_to_freeze() in the loop, so that we don't cause
+	 * freezing failures due to busy looping.
+	 */
+	while (mutex_lock_interruptible(&pm_mutex))
+		try_to_freeze();
 }
 
 static inline void unlock_system_sleep(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
