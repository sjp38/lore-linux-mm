Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 44B0C6B006E
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 07:04:58 -0500 (EST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 16 Nov 2011 17:28:36 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAGBtLjq3817712
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 17:25:22 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAGBtLos012110
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 22:55:21 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v2] PM/Memory-hotplug: Avoid task freezing failures
Date: Wed, 16 Nov 2011 17:25:23 +0530
Message-ID: <20111116115515.25945.35368.stgit@srivatsabhat.in.ibm.com>
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
mutex_trylock() in a loop until the lock is acquired, instead of using
mutex_lock(), in order to avoid going to uninterruptible sleep.
Also, try_to_freeze() is called within the loop, so that we don't cause
freezing failures due to busy looping.

v2: Tejun pointed problems with using mutex_lock_interruptible() in a
    while loop, when signals not related to freezing are involved.
    So, replaced it with mutex_trylock().

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/suspend.h |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/linux/suspend.h b/include/linux/suspend.h
index 57a6924..c2b5aab 100644
--- a/include/linux/suspend.h
+++ b/include/linux/suspend.h
@@ -5,6 +5,7 @@
 #include <linux/notifier.h>
 #include <linux/init.h>
 #include <linux/pm.h>
+#include <linux/freezer.h>
 #include <linux/mm.h>
 #include <asm/errno.h>
 
@@ -380,7 +381,18 @@ static inline void unlock_system_sleep(void) {}
 
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
+	 * We should use try_to_freeze() in the while loop so that we don't
+	 * cause freezing failures due to busy looping.
+	 */
+	while (!mutex_trylock(&pm_mutex))
+		try_to_freeze();
 }
 
 static inline void unlock_system_sleep(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
