Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADBA2800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 11:13:36 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 40so529580otv.21
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 08:13:36 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h54si212621otc.129.2018.01.23.08.13.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 08:13:35 -0800 (PST)
Date: Tue, 23 Jan 2018 11:13:30 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123111330.4356ec8d@gandalf.local.home>
In-Reply-To: <20180123154347.GE1771050@devbig577.frc2.facebook.com>
References: <20180117121251.7283a56e@gandalf.local.home>
	<20180117134201.0a9cbbbf@gandalf.local.home>
	<20180119132052.02b89626@gandalf.local.home>
	<20180120071402.GB8371@jagdpanzerIV>
	<20180120104931.1942483e@gandalf.local.home>
	<20180121141521.GA429@tigerII.localdomain>
	<20180123064023.GA492@jagdpanzerIV>
	<20180123095652.5e14da85@gandalf.local.home>
	<20180123152130.GB429@tigerII.localdomain>
	<20180123104121.2ef96d81@gandalf.local.home>
	<20180123154347.GE1771050@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Tue, 23 Jan 2018 07:43:47 -0800
Tejun Heo <tj@kernel.org> wrote:

> So, at least in the case that we were seeing, it isn't that black and
> white.  printk keeps causing printks but only because printk buffer
> flushing is preventing the printk'ing context from making forward
> progress.  The key problem there is that a flushing context may get
> pinned flushing indefinitely and using a separate context does solve
> the problem.
>

Does it?

=46rom what I understand is that there's an issue with one of the printk
consoles, due to memory pressure or whatnot. Then a printk happens
within a printk recursively. It gets put into the safe buffer and an
irq is sent to printk this printk.

The issue you are saying is that when the printk enables interrupts,
the irq work triggers and loads the log buffer with the safe buffer, and
then the printk sees the new data added and continues to print, and
hence never leaves this printk.

Your solution is to delay the flushing of the safe buffer to another
thread (work queue), which I also have issues with, because you break
the "get printks out ASAP mantra". Then the work queue comes in and
flushes the printks. And since the printks cause printks, we continue
to spam the machine, but hey, we are making forward progress.

Again, this is treating the symptom and not solving the problem.

I really hate delaying printks to another thread, unless we can
guarantee that that thread is ready to go immediately (basically
spinning on a run queue waiting to print). Because if the system is
having issues (which is the main reason for printks to happen), there's
no guarantee that a work queue or another thread will ever schedule,
and the safe printk buffer never gets out to the consoles.

I much rather have throttling when recursive printks are detected.
Make it a 100 lines to print if you want, but then throttle. Because
once you have 100 lines or so, you will know that printks are causing
printks, and you don't give a crap about the repeated process. Allow
one flushing of the printk safe buffers, and then if it happens again,
throttle it.

Both methods can lose important data. I believe the throttling of
recursive printks, after 100 prints or whatever, will be the least
likely to lose important data, because printks caused by printks will
just keep repeating the same data, and we don't care about repeats. But
delaying the flushing could very well lose important data that caused
a lockup.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
