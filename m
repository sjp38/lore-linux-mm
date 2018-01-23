Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D525D800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:21:57 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id a21so1576495qtd.6
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:21:57 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p73sor13238398qki.75.2018.01.23.09.21.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 09:21:56 -0800 (PST)
Date: Tue, 23 Jan 2018 09:21:53 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123172153.GF1771050@devbig577.frc2.facebook.com>
References: <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180123064023.GA492@jagdpanzerIV>
 <20180123095652.5e14da85@gandalf.local.home>
 <20180123152130.GB429@tigerII.localdomain>
 <20180123104121.2ef96d81@gandalf.local.home>
 <20180123154347.GE1771050@devbig577.frc2.facebook.com>
 <20180123111330.4356ec8d@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123111330.4356ec8d@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hey,

On Tue, Jan 23, 2018 at 11:13:30AM -0500, Steven Rostedt wrote:
> From what I understand is that there's an issue with one of the printk
> consoles, due to memory pressure or whatnot. Then a printk happens
> within a printk recursively. It gets put into the safe buffer and an
> irq is sent to printk this printk.
> 
> The issue you are saying is that when the printk enables interrupts,
> the irq work triggers and loads the log buffer with the safe buffer, and
> then the printk sees the new data added and continues to print, and
> hence never leaves this printk.

I'm not sure it's irq or the same calling context, but yeah whatever
it may be, it keeps adding new data.

> Your solution is to delay the flushing of the safe buffer to another
> thread (work queue), which I also have issues with, because you break
> the "get printks out ASAP mantra". Then the work queue comes in and
> flushes the printks. And since the printks cause printks, we continue
> to spam the machine, but hey, we are making forward progress.

I'm not sure "get printks out ASAP mantra" is the overriding concern
after spending 20s flushing in an unknown context.  I'm honestly
curious.  Would that still matter that much at that point?  I went
through the recent common crashes in the fleet earlier today and a
good number of them are printk taking too long unnecessarily
escalating the situation (most commonly triggering NMI watchdog).  I'm
not saying that this should override other concerns but it seems clear
to me that we're pretty badly exposed on this front.

> Again, this is treating the symptom and not solving the problem.

Or adding a safety net when things go south, but this isn't what I was
trying to argue.  I mostly thought your understanding of what I
reported wasn't accurate and wanted to clear that up.

> I really hate delaying printks to another thread, unless we can
> guarantee that that thread is ready to go immediately (basically
> spinning on a run queue waiting to print). Because if the system is
> having issues (which is the main reason for printks to happen), there's
> no guarantee that a work queue or another thread will ever schedule,
> and the safe printk buffer never gets out to the consoles.
>
> I much rather have throttling when recursive printks are detected.
> Make it a 100 lines to print if you want, but then throttle. Because
> once you have 100 lines or so, you will know that printks are causing
> printks, and you don't give a crap about the repeated process. Allow
> one flushing of the printk safe buffers, and then if it happens again,
> throttle it.
> 
> Both methods can lose important data. I believe the throttling of
> recursive printks, after 100 prints or whatever, will be the least
> likely to lose important data, because printks caused by printks will
> just keep repeating the same data, and we don't care about repeats. But
> delaying the flushing could very well lose important data that caused
> a lockup.

Hmmm... what you're suggesting still seems more fragile - ie. when
does that 100 count get reset?  OOM prints quite a few lines and if
we're resetting on each line, that two order explosion of messages can
still be really really bad.  And issues like that seem to suggest that
the root problem to handle here is avoiding locking up a context in
flushing for too long.  Your approach is trying to avoid causing that
but it's a symptom which can be reached in many different ways.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
