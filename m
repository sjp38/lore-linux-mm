Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 1FA5A6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 12:11:51 -0400 (EDT)
Date: Wed, 31 Jul 2013 17:11:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/18] Basic scheduler support for automatic NUMA
 balancing V5
Message-ID: <20130731161141.GX2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130725103620.GM27075@twins.programming.kicks-ass.net>
 <20130731103052.GR2296@suse.de>
 <20130731104814.GA3008@twins.programming.kicks-ass.net>
 <20130731115719.GT2296@suse.de>
 <20130731153018.GD3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130731153018.GD3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 31, 2013 at 05:30:18PM +0200, Peter Zijlstra wrote:
> On Wed, Jul 31, 2013 at 12:57:19PM +0100, Mel Gorman wrote:
> 
> > > Right, so what Ingo did is have the scan rate depend on the convergence.
> > > What exactly did you dislike about that?
> > > 
> > 
> > It depended entirely on properly detecting if we are converged or not. As
> > things like false share detection within THP is still not there I was
> > worried that it was too easy to make the wrong decision here and keep it
> > pinned at the maximum scan rate.
> > 
> > > We could define the convergence as all the faults inside the interleave
> > > mask vs the total faults, and then run at: min + (1 - c)*(max-min).
> > > 
> > 
> > And when we have such things properly in place then I think we can kick
> > away the current crutch.
> 
> OK, so I'll go write that patch I suppose ;-)
> 
> > > Ah, well the reasoning on that was that all this NUMA business is
> > > 'expensive' so we'd better only bother with tasks that persist long
> > > enough for it to pay off.
> > > 
> > 
> > Which is fair enough but tasks that lasted *just* longer than the interval
> > still got punished. Processes running with a slightly slower CPU gets
> > hurts meaning that it would be a difficult bug report to digest.
> > 
> > > In that regard it makes perfect sense to wait a fixed amount of runtime
> > > before we start scanning.
> > > 
> > > So it was not a pure hack to make kbuild work again.. that is did was
> > > good though.
> > > 
> > 
> > Maybe we should reintroduce the delay then but I really would prefer that
> > it was triggered on some sort of event.
> 
> Humm:
> 
> kernel/sched/fair.c:
> 
> /* Scan @scan_size MB every @scan_period after an initial @scan_delay in ms */
> unsigned int sysctl_numa_balancing_scan_delay = 1000;
> 
> 
> kernel/sched/core.c:__sched_fork():
> 
> 	numa_scan_period = sysctl_numa_balancing_scan_delay
> 
> 
> It seems its still there, no need to resuscitate.
> 

Yes, reverting 5bca23035391928c4c7301835accca3551b96cc2 effectively restores
the behaviour you are looking for. It just seems very crude. Then again,
I also should not have left the scan delay on top of the first_nid
check.

> I share your preference for a clear event, although nothing really comes
> to mind. The entire multi-process space seems devoid of useful triggers.
> 

RSS was another option it felt as arbitrary as a plain delay.

Should I revert 5bca23035391928c4c7301835accca3551b96cc2 with an
explanation that it potentially is completely useless in the purely
multi-process shared case?

> > > On that rate-limit, this looks to be a hard-coded number unrelated to
> > > the actual hardware.
> > 
> > Guesstimate.
> > 
> > > I think we should at the very least make it a
> > > configurable number and preferably scale the number with the SLIT info.
> > > Or alternatively actually measure the node to node bandwidth.
> > > 
> > 
> > Ideally we should just kick it away because scan rate limiting works
> > properly. Lets not make it a tunable just yet so we can avoid having to
> > deprecate it later.
> 
> I'm not seeing how the rate-limit as per the convergence is going to
> help here.

It should reduce the potential number of NUMA hinting faults that can be
incurred. However, I accept your point because even it does not directly
avoid a large number of migration events.

> Suppose we migrate the task to another node and its going to
> stay there. Then our convergence is going down to 0 (all our memory is
> remote) so we end up at the max scan rate migrating every single page
> ASAP.
> 
> This would completely and utterly saturate any interconnect.
> 

Good point and we'd arrive back at rate limiting the migration in an
attempt to avoid it.

> Also, in the case we don't have a fully connected system the memory
> transfers will need multiple hops, which greatly complicates the entire
> accounting trick :-)
> 

Also unfortunately true. The larger the machine, the more likely this
becomes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
