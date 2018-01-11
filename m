Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00D5F6B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 23:58:23 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z7so651385pfe.21
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 20:58:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k17sor2012137pfh.1.2018.01.10.20.58.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 20:58:22 -0800 (PST)
Date: Thu, 11 Jan 2018 13:58:17 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111045817.GA494@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110130517.6ff91716@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/10/18 13:05), Steven Rostedt wrote:
[..]
> My solution takes printk from its current unbounded state, and makes it
> fixed bounded. Which means printk() is now a O(1) algorithm.
						^^^
						O(logbuf)

and   O(logbuf) > watchdog_thresh   is totally possible. and there
is nothing super unlucky in having O(logbuf). limiting printk is the
right way to go, sure. but you limit it to the wrong thing. limiting
it to logbuf is not enough, especially given that logbuf size is
configurable via kernel param - it's a moving target. if one wants
printk to stop disappointing the watchdog then printk must learn to
respect watchdog's threshold.


https://marc.info/?l=linux-kernel&m=151444381104068


hence a small fix up

---

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 8882a4bf2a9e..4efa7542d84d 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -2341,6 +2341,14 @@ void console_unlock(void)
 
 		printk_safe_enter_irqsave(flags);
 		raw_spin_lock(&logbuf_lock);
+
+		if (log_next_seq - console_seq > 666) {
+			console_seq = log_next_seq;
+			raw_spin_unlock(&logbuf_lock);
+			printk_safe_exit_irqrestore(flags);
+			panic("you mad bro? this can softlockup your system! let me fix that for you");
+		}
+
 		if (seen_seq != log_next_seq) {
 			wake_klogd = true;
 			seen_seq = log_next_seq;

---

> The solution is simple, everyone at KS agreed with it, there should be
> no controversy here.

frankly speaking, that's not what I recall ;)


[..]
> My printk solution is solid, with no risk of regressions of current
> printk usages.

except that handing off a console_sem to atomic task when there
is   O(logbuf) > watchdog_thresh   is a regression, basically...
it is what it is.


> If anything, I'll pull theses patches myself, and push them to Linus
> directly

lovely.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
