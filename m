Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 530C86B0006
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 00:15:42 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id i1-v6so8241908wrr.18
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 21:15:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h15-v6sor2028808wrq.23.2018.11.11.21.15.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 21:15:40 -0800 (PST)
Date: Mon, 12 Nov 2018 06:15:37 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 00/12] locking/lockdep: Add a new class of terminal
 locks
Message-ID: <20181112051537.GB123204@gmail.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <20181109080412.GC86700@gmail.com>
 <1fcaa330-a4be-0f8a-7974-7b17f0ce01ad@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1fcaa330-a4be-0f8a-7974-7b17f0ce01ad@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>


* Waiman Long <longman@redhat.com> wrote:

> > Could you please measure a locking intense workload instead, such as:
> >
> >    $ perf stat --null --sync --repeat 10 perf bench sched messaging
> >
> > and profile which locks used there could be marked terminal, and measure 
> > the before/after performance impact?
> 
> I will run the test. It will probably be done after the LPC next week.

Thanks!

> >> Below were selected output lines from the lockdep_stats files of the
> >> patched and unpatched kernels after bootup and running parallel kernel
> >> builds.
> >>
> >>   Item                     Unpatched kernel  Patched kernel  % Change
> >>   ----                     ----------------  --------------  --------
> >>   direct dependencies           9732             8994          -7.6%
> >>   dependency chains            18776            17033          -9.3%
> >>   dependency chain hlocks      76044            68419         -10.0%
> >>   stack-trace entries         110403           104341          -5.5%
> > That's pretty impressive!
> >
> >> There were some reductions in the size of the lockdep tables. They were
> >> not significant, but it is still a good start to rein in the number of
> >> entries in those tables to make it harder to overflow them.
> > Agreed.
> >
> > BTW., if you are interested in more radical approaches to optimize 
> > lockdep, we could also add a static checker via objtool driven call graph 
> > analysis, and mark those locks terminal that we can prove are terminal.
> >
> > This would require the unified call graph of the kernel image and of all 
> > modules to be examined in a final pass, but that's within the principal 
> > scope of objtool. (This 'final pass' could also be done during bootup, at 
> > least in initial versions.)
> >
> > Note that beyond marking it 'terminal' such a static analysis pass would 
> > also allow the detection of obvious locking bugs at the build (or boot) 
> > stage already - plus it would allow the disabling of lockdep for 
> > self-contained locks that don't interact with anything else.
> >
> > I.e. the static analysis pass would 'augment' lockdep and leave only 
> > those locks active for runtime lockdep tracking whose dependencies it 
> > cannot prove to be correct yet.
> 
> It is a pretty interesting idea to use objtool to scan for locks. The
> list of locks that I marked as terminal in this patch was found by
> looking at /proc/lockdep for those that only have backward dependencies,
> but no forward dependency. I focused on those with a large number of BDs
> and check the code to see if they could marked as terminal. This is a
> rather labor intensive process and is subject to error.

Yeah.

> [...] It would be nice if it can be done by an automated tool. So I am 
> going to look into that, but it won't be part of this initial patchset, 
> though.

Of course!

> I sent this patchset out to see if anyone has any objection to it. It
> seems you don't have any objection to that. So I am going to move ahead
> to do more testing and performance analysis.

The one worry I have is that this interim solution removes the benefit of 
a proper static analysis method.

But if you promise to make a serious effort on the static analysis 
tooling as well (which should have awesome performance results and 
automate the manual markup), then I have no fundamental objections to the 
interim approach either.

If static analysis works as well as I expect it to then in principle we 
might even be able to have lockdep enabled in production kernels: it 
would only add overhead to locks that are overly complex - which would 
create incentives to improve those dependencies.

Thanks,

	Ingo
