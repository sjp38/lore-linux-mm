Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id AEFC86B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 12:29:53 -0500 (EST)
Date: Wed, 9 Nov 2011 18:29:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
Message-ID: <20111109172942.GJ5075@redhat.com>
References: <4EB8E969.6010502@suse.cz>
 <1320766151-2619-1-git-send-email-aarcange@redhat.com>
 <1320766151-2619-2-git-send-email-aarcange@redhat.com>
 <4EB98A83.3040101@linux.vnet.ibm.com>
 <4EBA75F2.4080800@linux.vnet.ibm.com>
 <20111109155342.GA1260@google.com>
 <20111109165201.GI5075@redhat.com>
 <20111109165925.GC1260@google.com>
 <20111109170248.GD1260@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111109170248.GD1260@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Nov 09, 2011 at 09:02:48AM -0800, Tejun Heo wrote:
> On Wed, Nov 09, 2011 at 08:59:25AM -0800, Tejun Heo wrote:
> > Freezer depends on the usual "set_current_state(INTERRUPTIBLE); check
> > freezing; schedule(); check freezing" construct and sends
> > INTERRUPTIBLE wake up after setting freezing state.  The
> > synchronization hasn't been completely clear but recently been cleaned
> > up, so as long as freezing condition is tested after INTERRUPTIBLE is
> > set before going to sleep, the event won't go missing.
> 
> Just in case, it's scheduled for the next merge window but TIF_FREEZE
> is gone now.  There is freezing() helper which tests all pending
> freezing conditions and the freezer guarantees there's mb between
> assertion of freezing() and sending interruptible wakeups to target
> tasks.

My point is if what happens is:

   freezer CPU		   khugepaged
   ------
   assert freezing
   wake_up(interruptible)
			   __set_current_state(interruptible)
			   schedule()

are we still hanging then? And I think it's silly to use
wait_event_freezable_timeout if I don't have any waitqueue to wait
on. Or are the pending changes hooking into the scheduler internally
similarly to what the set_freezable_with_signal would have done? That
would also kind of solve it. Removing set_freezable_with_signal sounds
like the scheduler internal knowledge will go too, so I guess what's
really missing is a schedule_timeout_freezable().

I think the below should solve the race but not having read your
pending changes that make the TIF_FREEZE go away you may want to see
if this is still relevant.

Still there is a try_to_freeze we need to add somewhere in the tight
loop, with this patch is automatically executed by
schedule_timeout_freezable (the same way it would be run by
wait_event_freezable_timeout if I had a waitqueue to deal with).

Also note the smp_mb setting the current state interruptible and
before calling freezing(). That should work fine if on the writer side
asserts freezing, memory barrier and than wakeup. Memory barrier is
only needed if the assert of the freezing could move into the wakeup
critical section (wakeup will likely take a spinlock with acquire
semantics so a write before taking the spinlock could mix inside the
critical section of the wakeup).

===
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] thp: reduce khugepaged freezing latency

Lack of schedule_timeout_freezable() prevented khugepaged to be waken
up across the schedule_timeout_interruptible() if freezing() becomes
true.

khugepaged would still freeze just fine by trying again the next
minute but it's better if it freezes immediately.

Reported-by: Jiri Slaby <jslaby@suse.cz>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/sched.h |    1 +
 kernel/timer.c        |   10 ++++++++++
 mm/huge_memory.c      |    4 ++--
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 68daf4f..cfe07ef 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -356,6 +356,7 @@ extern int in_sched_functions(unsigned long addr);
 #define	MAX_SCHEDULE_TIMEOUT	LONG_MAX
 extern signed long schedule_timeout(signed long timeout);
 extern signed long schedule_timeout_interruptible(signed long timeout);
+extern signed long schedule_timeout_freezable(signed long timeout);
 extern signed long schedule_timeout_killable(signed long timeout);
 extern signed long schedule_timeout_uninterruptible(signed long timeout);
 asmlinkage void schedule(void);
diff --git a/kernel/timer.c b/kernel/timer.c
index dbaa624..06a7322 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -40,6 +40,7 @@
 #include <linux/irq_work.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/freezer.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -1493,6 +1494,15 @@ signed long __sched schedule_timeout_interruptible(signed long timeout)
 }
 EXPORT_SYMBOL(schedule_timeout_interruptible);
 
+signed long __sched schedule_timeout_freezable(signed long timeout)
+{
+	do
+		set_current_state(TASK_INTERRUPTIBLE);
+	while (try_to_freeze());
+	return schedule_timeout(timeout);
+}
+EXPORT_SYMBOL(schedule_timeout_freezable);
+
 signed long __sched schedule_timeout_killable(signed long timeout)
 {
 	__set_current_state(TASK_KILLABLE);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4298aba..63d4f63 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2261,7 +2261,7 @@ static void khugepaged_alloc_sleep(void)
 {
 	DEFINE_WAIT(wait);
 	add_wait_queue(&khugepaged_wait, &wait);
-	schedule_timeout_interruptible(
+	schedule_timeout_freezable(
 		msecs_to_jiffies(
 			khugepaged_alloc_sleep_millisecs));
 	remove_wait_queue(&khugepaged_wait, &wait);
@@ -2317,7 +2317,7 @@ static void khugepaged_loop(void)
 			if (!khugepaged_scan_sleep_millisecs)
 				continue;
 			add_wait_queue(&khugepaged_wait, &wait);
-			schedule_timeout_interruptible(
+			schedule_timeout_freezable(
 				msecs_to_jiffies(
 					khugepaged_scan_sleep_millisecs));
 			remove_wait_queue(&khugepaged_wait, &wait);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
