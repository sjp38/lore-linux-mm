Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3A7800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:21:36 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n187so514912pfn.10
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:21:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8-v6sor1368602plm.124.2018.01.23.07.21.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 07:21:35 -0800 (PST)
Date: Wed, 24 Jan 2018 00:21:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123152130.GB429@tigerII.localdomain>
References: <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180123064023.GA492@jagdpanzerIV>
 <20180123095652.5e14da85@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123095652.5e14da85@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/23/18 09:56), Steven Rostedt wrote:
[..]
> > Why do we even use irq_work for printk_safe?
> 
> Why not?
> 
> Really, I think you are trying to solve a symptom and not the problem.
> If we are having issues with irq_work, we are going to have issues with
> a work queue. It's just spreading out the problem instead of fixing it.

I don't want to have heuristics in print_safe, I don't want to have a magic
number controlled by a user-space visible knob, I don't want to have the
first 3 lines of a lockdep splat.


The problem is - we flush printk_safe too soon and printing CPU ends up
in a lockup - it log_store()-s new messages while it's printing the pending
ones. It's fine to do so when CPU is in preemptible context. Really, we
should not care in printk_safe as long as we don't lockup the kernel. The
misbehaving console must be fixed. If CPU is not in preemptible context then
we do lockup the kernel. Because we flush printk_safe regardless of the
current CPU context. If we will flush printk_safe via WQ then we automatically
add this "OK! The CPU is preemptible, we can log_store(), it's totally OK, we
will not lockup it up." thing. Yes, we fill up the logbuf with probably needed
and appreciated or unneeded messages. But we should not care in printk_safe.
We don't lockup the kernel... And the misbehaving console must be fixed.

I disagree with "If we are having issues with irq_work, we are going to have
issues with a work queue". There is a tremendous difference between irq_work
on that CPU and queue_work_on(smp_proessor_id()). One does not care about CPU
context, the other one does.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
