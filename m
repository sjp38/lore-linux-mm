Date: Mon, 19 Aug 2002 22:04:19 +0100 (IST)
From: Mel <mel@csn.ul.ie>
Subject: Re: [PATCH] rmap 14
In-Reply-To: <9C5FA1BA-B3A6-11D6-A545-000393829FA4@cs.amherst.edu>
Message-ID: <Pine.LNX.4.44.0208192128560.23261-100000@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Aug 2002, Scott Kaplan wrote:

> > The measure is the time when the script asked the module to read a page.
> > [...] I don't call schedule although it is possible I get scheduled.
>
> That's exactly the concern that I had.  Large timing result like that are
> more likely because your code was preempted for something else.  It would
> probably be good to do *something* about these statistical outliers,
> because they can affect averages substantially.

At the moment I'm not calculating averages and I haven't worked out the
best way to factor in large skews in page reads. For the moment, I'm
taking the easy option and depending on the tester to be able to ignore
the bogus data.

> where the scheduling is interfering with your timing.  You just need to
> be sure that it *is* the scheduling that's causing such anomalies, and
> not something else.
>

As Daniel posted elsewhere, the Linux Trace Toolkit is what would answer
such questions. I'm trying to get as far as possible without using LTT for
the moment but I'll keep what you said in mind as I progress.

> I agree that they're likely to compete.  I don't think it's going to be
> easy, though, to reason a-priori about what the result of that competition
> will be; that is, it's not clear to me that it will cause bursts of paging
> activity as opposed to some other kind of paging behavior.
>

You're right, I'm only guessing what is happening for the moment. There
isn't enough data avaialble yet. I've started trapping the results of
vmstat and graphing it as well to help decide what is happening but still,
I'm depending on the user to be able to analyse the data themselves for
the moment

> > Things have to start with simplified models because they can be easily
> > understood at a glance. I think it's a bit unreasonable to expect a full
> > featured suites at first release.
>
> I agree.  I was heavy handed, probably unfairly so, but there was a
> purpose to the points I tried to make:  *Since* this is a work in progress,
>   I wanted to provide feedback so that it would avoid some known, poor
> directions.

Understood,.

> It's good that you know of the limitations of modeling
> reference behavior, but lots of people have fallen into that trap and used
> poor models for evaluative purposes, believing the results to be more
> conclusive and comprehensive than they really were.

I've read some of the papers that met the problem. I think I've come up
with a way that it can be addressed but it's ideas in my head, I haven't
investigated them yet. It is possible LTT can provide the data itself in
which case I'm off the mark anyway.

Without LTT, this is the prelimary guess as what needs to be done to get
real page faulting data. Note that I haven't researched this at all.

Anyway... add an option to the kernel CONFIG_FTRACE for Fault Tracing. A
struct would exist that looks something like

struct pagetrap {
	spinlock_t lock;
	pid_t pid;
	unsigned long (*callback)(pte_t *, unsigned long addr);
}

handle_pte_fault() and mark_page_accessed is changed to check this struct
and use the callback if it is registered and the pid is the same as
current->pid .  do_exit() is changed to make sure the pid been traced
removes itself correctly. Now.... collection.

A vm regress module faulttrace.o is loaded and exports proc entries

trace_begin
trace_read
trace_stop

begin will register a function for the kernel to call back with data
regarding the pid. The address will always be page aligned so the lower
bits can be used to show what the action was. This might be mmap/munmap
(from the vm regress benchmark), page fault or whatever. It dumps the data
that has be read from trace_read periodically.

If this works out, I'd should be able to calculate the fault rate for a
pid at the very least as well as get close to real reference behaviour. I
can't think of a way of trapping every real reference from a process
unless LTT would do it.

For trapping mmaps, munmaps and so on, an LD_PRELOAD trick can be used to
get programs to use VM Regress equivilants if available. This might be
utter crap, but if it is, I might come up with a better way of trapping
real data later. It's a problem for far away.

> I figured that it
> would be better to sound the warning on that problem *before* you got
> deeply into the modeling issues for this project.
>

True, thanks for the reminder

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
