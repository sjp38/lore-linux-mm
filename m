Date: Mon, 7 Jan 2008 17:57:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
In-Reply-To: <Pine.LNX.4.64.0801071141130.23617@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0801071751320.13505@chino.kir.corp.google.com>
References: <504e981185254a12282d.1199326157@v2.random> <Pine.LNX.4.64.0801071141130.23617@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@cpushare.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jan 2008, Christoph Lameter wrote:

> > +		if (unlikely(test_tsk_thread_flag(p, TIF_MEMDIE))) {
> > +			/*
> > +			 * Hopefully we already waited long enough,
> > +			 * or exit_mm already run, but we must try to kill
> > +			 * another task to avoid deadlocking.
> > +			 */
> > +			continue;
> > +		}
> 
> If all tasks are marked TIF_MEMDIE then we just scan through them return 
> NULL and
> 

That's the problem that I've been mentioning: giving several tasks access 
to memory reserves just isn't right.  It should be given to a single 
OOM-killed task that will alleviate the OOM condition for the task that 
called out_of_memory().  For an entire system it would still be possible 
for several tasks to be TIF_MEMDIE (in the case of cpuset, memory 
controller, or mempolicy OOM killing) but never more than one task that 
shares a common zone.

> >  		/* Found nothing?!?! Either we hang forever, or we panic. */
> > -		if (!p) {
> > +		if (unlikely(!p)) {
> >  			read_unlock(&tasklist_lock);
> >  			panic("Out of memory and no killable processes...\n");
> 
> panic.
> 
> Should we not wait awhile before panicing? The processes may need some 
> time to terminate.
> 

That's only possible with my proposal of adding

	unsigned long oom_kill_jiffies;

to struct task_struct.  We can't get away with a system-wide jiffies 
variable, nor can we get away with per-cgroup, per-cpuset, or 
per-mempolicy variable.  The only way to clear such a variable is in the 
exit path (by checking test_thread_flag(tsk, TIF_MEMDIE) in do_exit()) and 
fails miserably if there are simultaneous but zone-disjoint OOMs 
occurring.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
