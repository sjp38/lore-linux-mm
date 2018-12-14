Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFE8F8E01D1
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 07:10:37 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 68so4173031pfr.6
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 04:10:37 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 189si4017127pfd.142.2018.12.14.04.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 04:10:36 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 82/89] printk: Never set console_may_schedule in console_trylock()
Date: Fri, 14 Dec 2018 13:00:35 +0100
Message-Id: <20181214115733.737137210@linuxfoundation.org>
In-Reply-To: <20181214115729.658859279@linuxfoundation.org>
References: <20181214115729.658859279@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, Sasha Levin <sashal@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

[ Upstream commit fd5f7cde1b85d4c8e09ca46ce948e008a2377f64 ]

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

[1] http://lkml.kernel.org/r/201603022101.CAH73907.OVOOMFHFFtQJSL%20()%20I-love%20!%20SAKURA%20!%20ne%20!%20jp
Fixes: 6b97a20d3a79 ("printk: set may_schedule for some of console_trylock() callers")
Link: http://lkml.kernel.org/r/20180116044716.GE6607@jagdpanzerIV
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Byungchul Park <byungchul.park@lge.com>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Signed-off-by: Petr Mladek <pmladek@suse.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 kernel/printk/printk.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 2d1c2700bd85..2f654a79f80b 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1902,6 +1902,12 @@ asmlinkage int vprintk_emit(int facility, int level,
 
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
@@ -1909,6 +1915,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 */
 		if (console_trylock_spinning())
 			console_unlock();
+		preempt_enable();
 	}
 
 	return printed_len;
@@ -2225,20 +2232,7 @@ int console_trylock(void)
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
2.19.1
