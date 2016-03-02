Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 07280828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:11:57 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id xx9so85790419obc.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:11:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ge5si4898697obb.82.2016.03.02.06.11.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 06:11:56 -0800 (PST)
Subject: Re: How to avoid printk() delay caused by cond_resched() ?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201603022101.CAH73907.OVOOMFHFFtQJSL@I-love.SAKURA.ne.jp>
	<20160302133810.GB22171@pathway.suse.cz>
In-Reply-To: <20160302133810.GB22171@pathway.suse.cz>
Message-Id: <201603022311.CGC64089.HOOLJFVSMFQOtF@I-love.SAKURA.ne.jp>
Date: Wed, 2 Mar 2016 23:11:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pmladek@suse.com
Cc: sergey.senozhatsky@gmail.com, jack@suse.com, tj@kernel.org, kyle@kernel.org, davej@codemonkey.org.uk, calvinowens@fb.com, akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@kernel.org

Petr Mladek wrote:
> On Wed 2016-03-02 21:01:03, Tetsuo Handa wrote:
> > I have a question about "printk: set may_schedule for some of
> > console_trylock() callers" in linux-next.git.
> > 
> > I'm trying to dump information of all threads which might be relevant
> > to stalling inside memory allocator. But it seems to me that since this
> > patch changed to allow calling cond_resched() from printk() if it is
> > safe to do so, it is now possible that the thread which invoked the OOM
> > killer can sleep for minutes with the oom_lock mutex held when my dump is
> > in progress. I want to release oom_lock mutex as soon as possible so
> > that other threads can call out_of_memory() to get TIF_MEMDIE and exit
> > their allocations.
> > 
> > So, how can I prevent printk() triggered by out_of_memory() from sleeping
> > for minutes with oom_lock mutex held? Guard it with preempt_disable() /
> > preempt_enable() ? Guard it with rcu_read_lock() / rcu_read_unlock() ? 
> >
> 
> preempt_disable() / preempt_enable() would do the job.

I see. Thank you.

> The question is where to put it. If you are concerned about
> the delay, you might want to disable preemption around
> the whole locked area, so that it works reasonable also
> in the preemptive kernel.
> 

We had a similar problem in the past. I'll again propose
http://lkml.kernel.org/r/201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp .

> I am looking forward to have the console printing offloaded
> into the workqueues. Then printk() will become consistently
> "fast" operation and will cause less surprises like this.
> 

That's a good news. I was wishing that there were a dedicated kernel
thread which does printk() operation. While at it, I ask for an API
which waits for printk buffer to be flushed (something like below) so that
a watchdog thread which might dump thousands of threads from sleepable
context (like my dump) can avoid "** XXX printk messages dropped **"
messages.

----------
diff --git a/include/linux/console.h b/include/linux/console.h
index ea731af..11e936c 100644
--- a/include/linux/console.h
+++ b/include/linux/console.h
@@ -147,6 +147,7 @@ extern int unregister_console(struct console *);
 extern struct console *console_drivers;
 extern void console_lock(void);
 extern int console_trylock(void);
+extern void wait_console_flushed(unsigned long timeout);
 extern void console_unlock(void);
 extern void console_conditional_schedule(void);
 extern void console_unblank(void);
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 9917f69..2eb60df 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -121,6 +121,15 @@ static int __down_trylock_console_sem(unsigned long ip)
 	up(&console_sem);\
 } while (0)
 
+static int __down_timeout_console_sem(unsigned long timeout, unsigned long ip)
+{
+	if (down_timeout(&console_sem, timeout))
+		return 1;
+	mutex_acquire(&console_lock_dep_map, 0, 1, ip);
+	return 0;
+}
+#define down_timeout_console_sem(timeout) __down_timeout_console_sem((timeout), _RET_IP_)
+
 /*
  * This is used for debugging the mess that is the VT code by
  * keeping track if we have the console semaphore held. It's
@@ -2125,6 +2134,21 @@ int console_trylock(void)
 }
 EXPORT_SYMBOL(console_trylock);
 
+void wait_console_flushed(unsigned long timeout)
+{
+	might_sleep();
+
+	if (down_timeout_console_sem(timeout))
+		return;
+	if (console_suspended) {
+		up_console_sem();
+		return;
+	}
+	console_locked = 1;
+	console_may_schedule = 1;
+	console_unlock();
+}
+
 int is_console_locked(void)
 {
 	return console_locked;
----------

> Best Regards,
> Petr
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
