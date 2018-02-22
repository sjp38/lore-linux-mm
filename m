Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65C2E6B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 19:16:43 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y25so1571639pfe.5
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 16:16:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x32-v6sor612140pld.18.2018.02.21.16.16.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 16:16:40 -0800 (PST)
Date: Thu, 22 Feb 2018 09:16:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Message-ID: <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
References: <20180205220325.197241-1-dancol@google.com>
 <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hi Daniel,

On Wed, Feb 21, 2018 at 11:05:04AM -0800, Daniel Colascione wrote:
> On Mon, Feb 5, 2018 at 2:03 PM, Daniel Colascione <dancol@google.com> wrote:
> 
> > When SPLIT_RSS_COUNTING is in use (which it is on SMP systems,
> > generally speaking), we buffer certain changes to mm-wide counters
> > through counters local to the current struct task, flushing them to
> > the mm after seeing 64 page faults, as well as on task exit and
> > exec. This scheme can leave a large amount of memory unaccounted-for
> > in process memory counters, especially for processes with many threads
> > (each of which gets 64 "free" faults), and it produces an
> > inconsistency with the same memory counters scanned VMA-by-VMA using
> > smaps. This inconsistency can persist for an arbitrarily long time,
> > since there is no way to force a task to flush its counters to its mm.

Nice catch. Incosistency is bad but we usually have done it for performance.
So, FWIW, it would be much better to describe what you are suffering from
for matainter to take it.

> >
> > This patch flushes counters on context switch. This way, we bound the
> > amount of unaccounted memory without forcing tasks to flush to the
> > mm-wide counters on each minor page fault. The flush operation should
> > be cheap: we only have a few counters, adjacent in struct task, and we
> > don't atomically write to the mm counters unless we've changed
> > something since the last flush.
> >
> > Signed-off-by: Daniel Colascione <dancol@google.com>
> > ---
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
> 
> 
> Ping? Is this approach just a bad idea? We could instead just manually sync
> all mm-attached tasks at counter-retrieval time.

IMHO, yes, it should be done when user want to see which would be really
cold path while this shecule function is hot.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
