Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D08B6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 23:47:22 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id q1so5203876plr.15
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 20:47:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l187sor257758pga.196.2018.01.15.20.47.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 20:47:21 -0800 (PST)
Date: Tue, 16 Jan 2018 13:47:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116044716.GE6607@jagdpanzerIV>
References: <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
 <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
 <20180116022349.GD6607@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116022349.GD6607@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (01/16/18 11:23), Sergey Senozhatsky wrote:
[..]
> > Adding the preempt_disable() basically means to revert the already
> > mentioned commit 6b97a20d3a7909daa06625 ("printk: set may_schedule
> > for some of console_trylock() callers").
> > 
> > I originally wanted to solve this separately to make it easier. But
> > the change looks fine to me. Therefore we reached a mutual agreement.
> > Sergey, do you want to send a patch or should I just put it at
> > the end of this patchset?
> 
> you can add the patch.

if you don't mind, let me fix the thing that I broke.
that would be responsible. I believe I also must say the following:
  Tetsuo, many thanks for reporting the issues for song long, and
  sorry that it took quite a while to revert that change.

8<====

From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] printk: never set console_may_schedule in console_trylock()

This patch, basically, reverts commit 6b97a20d3a79 ("printk:
set may_schedule for some of console_trylock() callers").
That commit was a mistake, it introduced a big dependency
on the scheduler, by enabling preemption under console_sem
in printk()->console_unlock() path, which is rather too
critical. The patch did not significantly reduce the
possibilities of printk() lockups, but made it possible to
stall printk(), as has been reported by Tetsuo Handa [1].

Another issues is that preemption under console_sem also
messes up with Steven Rostedt's hand off scheme, by making
it possible to sleep with console_sem both in console_unlock()
and in vprintk_emit(), after acquiring the console_sem
ownership (anywhere between printk_safe_exit_irqrestore() in
console_trylock_spinning() and printk_safe_enter_irqsave()
in console_unlock()). This makes hand off less likely and,
at the same time, may result in a significant amount of
pending logbuf messages. Preempted console_sem owner makes
it impossible for other CPUs to emit logbuf messages, but
does not make it impossible for other CPUs to append new
messages to the logbuf.

Reinstate the old behavior and make printk() non-preemptible.
Should any printk() lockup reports arrive they must be handled
in a different way.

[1] https://marc.info/?l=linux-mm&m=145692016122716
Fixes: 6b97a20d3a79 ("printk: set may_schedule for some of console_trylock() callers")
Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 kernel/printk/printk.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index ffe05024c622..9cb943c90d98 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1895,6 +1895,12 @@ asmlinkage int vprintk_emit(int facility, int level,
 
 	/* If called from the scheduler, we can not call up(). */
 	if (!in_sched) {
+		/*
+		 * Disable preemption to avoid being preempted while holding
+		 * console_sem which would prevent anyone from printing to
+		 * console
+		 */
+		preempt_disable();
 		/*
 		 * Try to acquire and then immediately release the console
 		 * semaphore.  The release will print out buffers and wake up
@@ -1902,6 +1908,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 */
 		if (console_trylock_spinning())
 			console_unlock();
+		preempt_enable();
 	}
 
 	return printed_len;
@@ -2229,20 +2236,7 @@ int console_trylock(void)
 		return 0;
 	}
 	console_locked = 1;
-	/*
-	 * When PREEMPT_COUNT disabled we can't reliably detect if it's
-	 * safe to schedule (e.g. calling printk while holding a spin_lock),
-	 * because preempt_disable()/preempt_enable() are just barriers there
-	 * and preempt_count() is always 0.
-	 *
-	 * RCU read sections have a separate preemption counter when
-	 * PREEMPT_RCU enabled thus we must take extra care and check
-	 * rcu_preempt_depth(), otherwise RCU read sections modify
-	 * preempt_count().
-	 */
-	console_may_schedule = !oops_in_progress &&
-			preemptible() &&
-			!rcu_preempt_depth();
+	console_may_schedule = 0;
 	return 1;
 }
 EXPORT_SYMBOL(console_trylock);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
