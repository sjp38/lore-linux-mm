Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFD982F64
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:26:19 -0500 (EST)
Received: by wmvv187 with SMTP id v187so278148186wmv.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:26:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l69si40691158wmb.75.2015.11.18.05.26.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 05:26:18 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v3 01/22] timer: Allow to check when the timer callback has not finished yet
Date: Wed, 18 Nov 2015 14:25:06 +0100
Message-Id: <1447853127-3461-2-git-send-email-pmladek@suse.com>
In-Reply-To: <1447853127-3461-1-git-send-email-pmladek@suse.com>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

timer_pending() checks whether the list of callbacks is empty.
Each callback is removed from the list before it is called,
see call_timer_fn() in __run_timers().

Sometimes we need to make sure that the callback has finished.
For example, if we want to free some resources that are accessed
by the callback.

For this purpose, this patch adds timer_active(). It checks both
the list of callbacks and the running_timer. It takes the base_lock
to see a consistent state.

I plan to use it to implement delayed works in kthread worker.
But I guess that it will have wider use. In fact, I wonder if
timer_pending() is misused in some situations.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/timer.h |  2 ++
 kernel/time/timer.c   | 24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/linux/timer.h b/include/linux/timer.h
index 61aa61dc410c..237b7c3e2b4e 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -165,6 +165,8 @@ static inline int timer_pending(const struct timer_list * timer)
 	return timer->entry.pprev != NULL;
 }
 
+extern int timer_active(struct timer_list *timer);
+
 extern void add_timer_on(struct timer_list *timer, int cpu);
 extern int del_timer(struct timer_list * timer);
 extern int mod_timer(struct timer_list *timer, unsigned long expires);
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index bbc5d1114583..1c16f3230771 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -778,6 +778,30 @@ static struct tvec_base *lock_timer_base(struct timer_list *timer,
 	}
 }
 
+/**
+ * timer_active - is a timer still in use?
+ * @timer: the timer in question
+ *
+ * timer_in_use() will tell whether the timer is pending or if the callback
+ * is curretly running.
+ *
+ * Use this function if you want to make sure that some resources
+ * will not longer get accessed by the timer callback. timer_pending()
+ * is not safe in this case.
+ */
+int timer_active(struct timer_list *timer)
+{
+	struct tvec_base *base;
+	unsigned long flags;
+	int ret;
+
+	base = lock_timer_base(timer, &flags);
+	ret = timer_pending(timer) || base->running_timer == timer;
+	spin_unlock_irqrestore(&base->lock, flags);
+
+	return ret;
+}
+
 static inline int
 __mod_timer(struct timer_list *timer, unsigned long expires,
 	    bool pending_only, int pinned)
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
