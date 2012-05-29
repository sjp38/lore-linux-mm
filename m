Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 256BE6B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 13:34:41 -0400 (EDT)
Date: Tue, 29 May 2012 19:33:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 22/35] autonuma: sched_set_autonuma_need_balance
Message-ID: <20120529173347.GJ21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-23-git-send-email-aarcange@redhat.com>
 <1338307942.26856.111.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338307942.26856.111.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, May 29, 2012 at 06:12:22PM +0200, Peter Zijlstra wrote:
> On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> > Invoke autonuma_balance only on the busy CPUs at the same frequency of
> > the CFS load balance.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >  kernel/sched/fair.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> > index 99d1d33..1357938 100644
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -4893,6 +4893,9 @@ static void run_rebalance_domains(struct softirq_action *h)
> >  
> >  	rebalance_domains(this_cpu, idle);
> >  
> > +	if (!this_rq->idle_balance)
> > +		sched_set_autonuma_need_balance();
> > +
> 
> This just isn't enough.. the whole thing needs to move out of
> schedule(). The only time schedule() should ever look at another cpu is
> if its idle.
> 
> As it stands load-balance actually takes too much time as it is to live
> in a softirq, -rt gets around that by pushing all softirqs into a thread
> and I was thinking of doing some of that for mainline too.

No worries, I didn't mean to leave it like this forever. I was
considering using the stop cpu _nowait variant but I didn't have
enough time to realize if it would work for my case. I need to rethink
about that.

I was thinking which thread to use for that or if to use the stop_cpu
_nowait variant that active balancing is using, but it wasn't so easy
to change and considering from a practical standpoint it already flies
I released it. It's already an improvement, the previous approach was
mostly a debug approach to see if autonuma_balance would flood the
debug log and not converging.

autonuma_balance isn't fundamentally different from load_balance, they
boot look around at the other runqueues, to see if some task should be
moved.

If you move the load_balance to a kernel thread, I could move
autonuma_balance there too.

I just wasn't sure if to invoke a schedule() to actually call
autonuma_balance() made any sense, so I thought running it from
softirq too with the noblocking _nowait variant (or keep it in
schedule to be able to call stop_one_cpu without _nowait) would have
been more efficient.

The moment I gave up on the _nowait variant before releasing is when I
couldn't understand what is tlb_migrate_finish doing, and why it's not
present in the _nowait version in fair.c. Can you explain me that?

Obviously it's only used by ia64 so I could as well ignore that but it
was still an additional annoyance that made me think I needed a bit
more of time to think about it.

I'm glad you acknowledge load_balance already takes a bulk of the time
as it needs to find the busiest runqueue checking other CPU runqueues
too... With autonuma14 there's no measurable difference in hackbench
with autonuma=y or noautonuma boot parameter anymore, or upstream
without autonuma applied (not just autonuma=n). So the cost on a
24-way SMP is 0.

Then I tried to measure it also with lockdep and all lock/mutex
debugging/stats enabled there's a slighty measurable slowdown in
hackbench that may not be a measurement error, but it's barely
noticeable and I expect if I remove load_balance from the softirq, the
gain would be bigger than removing autonuma_balance (it goes from 70
to 80 sec in avg IIRC, but the error is about 10sec, just the avg
seems slightly higher). With lockdep and all other debug disabled it
takes fixed 6sec for all configs and it's definitely not measurable
(tested both thread and process, not that it makes any difference for
this).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
