Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id ED62A6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:05:36 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id e65so10684156pfe.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 13:05:36 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p13si57429448pfi.234.2016.01.20.13.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 13:05:36 -0800 (PST)
Date: Wed, 20 Jan 2016 13:05:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kernel/hung_task.c: use timeout diff when timeout is
 updated
Message-Id: <20160120130534.57e4f7d8c33549a6e473d475@linux-foundation.org>
In-Reply-To: <20151221134545.cb0558878932913e348656e9@linux-foundation.org>
References: <201512172123.DFJ69220.SFFOLOJtVHOQMF@I-love.SAKURA.ne.jp>
	<20151217141805.f418cf9b137da08656504001@linux-foundation.org>
	<201512212045.HHC00516.SQOJVHLFFtMOOF@I-love.SAKURA.ne.jp>
	<20151221134545.cb0558878932913e348656e9@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, oleg@redhat.com, atomlin@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On Mon, 21 Dec 2015 13:45:45 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 21 Dec 2015 20:45:23 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > > 
> > > And it would be helpful to add a comment to hung_timeout_jiffies()
> > > which describes the behaviour and explains the reasons for it.
> > 
> > But before doing it, I'd like to confirm hung task maintainer's will.
> > 
> > The reason I proposed this patch is that I want to add a watchdog task
> > which emits warning messages when memory allocations are stalling.
> > http://lkml.kernel.org/r/201512130033.ABH90650.FtFOMOFLVOJHQS@I-love.SAKURA.ne.jp
> > 
> > But concurrently emitting multiple backtraces is problematic. Concurrent
> > emitting by hung task watchdog and memory allocation stall watchdog is very
> > likely to occur, for it is likely that other task is also stuck in
> > uninterruptible sleep when one task got stuck at memory allocation.
> > 
> > Therefore, I started trying to use same thread for both watchdogs.
> > A draft patch is at
> > http://lkml.kernel.org/r/201512170011.IAC73451.FLtFMSJHOQFVOO@I-love.SAKURA.ne.jp .
> > 
> > If you prefer current hang task behavior, I'll try to preseve current
> > behavior. Instead, I might use two threads and try to mutex both watchdogs
> > using console_lock() or something like that.
> > 
> > So, may I ask what your preference is?
> 
> I've added linux-mm to Cc.  Please never forget that.
> 
> The general topic here is "add more diagnostics around an out-of-memory
> event".  Clearly we need this, but Michal is working on the same thing
> as part of his "OOM detection rework v4" work, so can we please do the
> appropriate coordination and review there?
> 
> Preventing watchdog-triggered backtraces from messing each other up is
> of course a good idea.  Your malloc watchdog patch adds a surprising
> amount of code and adding yet another kernel thread is painful but
> perhaps it's all worth it.  It's a matter of people reviewing, testing
> and using the code in realistic situations and that process has hardly
> begun, alas.
> 
> Sorry, that was waffly but I don't feel able to be more definite at
> this time.

So this patch is rather stuck in place. 

Can we please work out how to proceed?  I don't like hanging onto
limbopatches for ages.



From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: kernel/hung_task.c: use timeout diff when timeout is updated

When new timeout is written to /proc/sys/kernel/hung_task_timeout_secs,
khungtaskd is interrupted and again sleeps for full timeout duration.

This means that hang task will not be checked if new timeout is written
periodically within old timeout duration and/or checking of hang task will
be delayed for up to previous timeout duration.  Fix this by remembering
last time khungtaskd checked hang task.

This change will allow other watchdog tasks (if any) to share khungtaskd
by sleeping for minimal timeout diff of all watchdog tasks.  Doing more
watchdog tasks from khungtaskd will reduce the possibility of printk()
collisions by multiple watchdog threads.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Aaron Tomlin <atomlin@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/hung_task.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff -puN kernel/hung_task.c~kernel-hung_taskc-use-timeout-diff-when-timeout-is-updated kernel/hung_task.c
--- a/kernel/hung_task.c~kernel-hung_taskc-use-timeout-diff-when-timeout-is-updated
+++ a/kernel/hung_task.c
@@ -185,10 +185,12 @@ static void check_hung_uninterruptible_t
 	rcu_read_unlock();
 }
 
-static unsigned long timeout_jiffies(unsigned long timeout)
+static long hung_timeout_jiffies(unsigned long last_checked,
+				 unsigned long timeout)
 {
 	/* timeout of 0 will disable the watchdog */
-	return timeout ? timeout * HZ : MAX_SCHEDULE_TIMEOUT;
+	return timeout ? last_checked - jiffies + timeout * HZ :
+		MAX_SCHEDULE_TIMEOUT;
 }
 
 /*
@@ -224,18 +226,21 @@ EXPORT_SYMBOL_GPL(reset_hung_task_detect
  */
 static int watchdog(void *dummy)
 {
+	unsigned long hung_last_checked = jiffies;
+
 	set_user_nice(current, 0);
 
 	for ( ; ; ) {
 		unsigned long timeout = sysctl_hung_task_timeout_secs;
+		long t = hung_timeout_jiffies(hung_last_checked, timeout);
 
-		while (schedule_timeout_interruptible(timeout_jiffies(timeout)))
-			timeout = sysctl_hung_task_timeout_secs;
-
-		if (atomic_xchg(&reset_hung_task, 0))
+		if (t <= 0) {
+			if (!atomic_xchg(&reset_hung_task, 0))
+				check_hung_uninterruptible_tasks(timeout);
+			hung_last_checked = jiffies;
 			continue;
-
-		check_hung_uninterruptible_tasks(timeout);
+		}
+		schedule_timeout_interruptible(t);
 	}
 
 	return 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
