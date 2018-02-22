Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC396B02A4
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 04:40:15 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 62so4112906iow.16
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 01:40:15 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h184si1367923ioe.132.2018.02.22.01.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Feb 2018 01:40:14 -0800 (PST)
Date: Thu, 22 Feb 2018 10:40:09 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Message-ID: <20180222094009.GO25201@hirez.programming.kicks-ass.net>
References: <20180205220325.197241-1-dancol@google.com>
 <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
 <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuetc7DepPPO6DmMp9APNz5+8+KansNBr_ijuuyCTu=v1mg@mail.gmail.com>
 <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Daniel Colascione <dancol@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@suse.com>

On Thu, Feb 22, 2018 at 11:06:33AM +0900, Minchan Kim wrote:
> On Wed, Feb 21, 2018 at 04:23:43PM -0800, Daniel Colascione wrote:
> >  kernel/sched/core.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index a7bf32aabfda..7f197a7698ee 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -3429,6 +3429,9 @@ asmlinkage __visible void __sched schedule(void)
> >         struct task_struct *tsk = current;
> >
> >         sched_submit_work(tsk);
> > +       if (tsk->mm)
> > +               sync_mm_rss(tsk->mm);
> > +
> >         do {
> >                 preempt_disable();
> >                 __schedule(false);
> >

Obviously I completely hate that; and you really _should_ have Cc'ed me
earlier ;-)

That it still well over 100 cycles in the case when all counters did
change. Far _far_ more if the mm counters are contended (up to 150 times
more is quite possible).

> > > > Ping? Is this approach just a bad idea? We could instead just manually sync
> > > > all mm-attached tasks at counter-retrieval time.
> > >
> > > IMHO, yes, it should be done when user want to see which would be really
> > > cold path while this shecule function is hot.
> > >
> > 
> > The problem with doing it that way is that we need to look at each task
> > attached to a particular mm. AFAIK (and please tell me if I'm wrong), the
> > only way to do that is to iterate over all processes, and for each process
> > attached to the mm we want, iterate over all its tasks (since each one has
> > to have the same mm, I think). Does that sound right?

You could just iterate the thread group and call it a day. Yes strictly
speaking its possible to have mm's shared outside the thread group,
practically that 'never' happens.

CLONE_VM without CLONE_THREAD just isn't a popular thing afaik.

So while its not perfect, it might well be good enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
