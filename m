Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id D4EB56B005A
	for <linux-mm@kvack.org>; Sat,  6 Oct 2012 08:35:12 -0400 (EDT)
Date: Sat, 6 Oct 2012 14:34:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 18/33] autonuma: teach CFS about autonuma affinity
Message-ID: <20121006123432.GS6793@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-19-git-send-email-aarcange@redhat.com>
 <1349419285.6984.98.camel@marge.simpson.net>
 <20121005115455.GH6793@redhat.com>
 <1349491194.6984.175.camel@marge.simpson.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1349491194.6984.175.camel@marge.simpson.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi Mike,

On Sat, Oct 06, 2012 at 04:39:54AM +0200, Mike Galbraith wrote:
> On Fri, 2012-10-05 at 13:54 +0200, Andrea Arcangeli wrote: 
> > On Fri, Oct 05, 2012 at 08:41:25AM +0200, Mike Galbraith wrote:
> > > On Thu, 2012-10-04 at 01:51 +0200, Andrea Arcangeli wrote: 
> > > > The CFS scheduler is still in charge of all scheduling decisions. At
> > > > times, however, AutoNUMA balancing will override them.
> > > > 
> > > > Generally, we'll just rely on the CFS scheduler to keep doing its
> > > > thing, while preferring the task's AutoNUMA affine node when deciding
> > > > to move a task to a different runqueue or when waking it up.
> > > 
> > > Why does AutoNuma fiddle with wakeup decisions _within_ a node?
> > > 
> > > pgbench intensely disliked me recently depriving it of migration routes
> > > in select_idle_sibling(), so AutoNuma saying NAK seems unlikely to make
> > > it or ilk any happier.
> > 
> > Preferring doesn't mean NAK. It means "search affine first" if there's
> > not, go the usual route like if autonuma was not there.
> 
> I'll rephrase.  We're searching a processor.  What does that have to do
> with NUMA?  I saw you turning want_affine off (and wonder what that's
> gonna do to fluctuating vs for more or less static loads), and get that.

I think you just found a mistake.

So disabling wake_affine if the wakeup CPU was on a remote NODE (only
in that case it was turned off), meant sd_affine couldn't be turned on
and for certain wakeups select_idle_sibling wouldn't run (rendering
pointless some of my logic in select_idle_sibling).

So I'm reversing this hunk:

@@ -2708,7 +2722,8 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
                return prev_cpu;
 
        if (sd_flag & SD_BALANCE_WAKE) {
-               if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
+               if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)) &&
+                   task_autonuma_cpu(p, cpu))
                        want_affine = 1;
                new_cpu = prev_cpu;
        }


Another optimization I noticed is that I should record idle_target =
true if target == cpu && idle_cpu(cpu) but task_autonuma_cpu fails, so
we'll pick the target if it was idle, and there's no CPU idle in the
affine node.

> I measured the 1 in 1:N pgbench very much preferring mobility.  The N,
> dunno, but I don't imagine a large benefit for making them sticky
> either.  Hohum, numbers will tell the tale.

Mobility on non-NUMA is an entirely different matter than mobility
across NUMA nodes. Keep in mind there are tons of CPUs intra-node too
so the mobility intra node may be enough.  But I don't know exactly
what the mobiltiy requirements of pgbench are so I can't tell for sure
and I fully agree we should collect numbers.

The availability of NUMA systems increased a lot lately so hopefully
more people will be able to test it and provide feedback.

Overall getting wrong the intra-node convergence is more concerning
than not being optimal in the 1:N load. Getting the former wrong means
we risk to delay convergence (and having to fixup later with autonuma
balancing events). The latter is just about maxim out all memory
channels and all HT idle cores, in a MADV_INTERLEAVE behavior and to
mitigage the spurious page migrates (which will still happen seldom
and we need them to keep happening slowly to avoid ending up using a
single memory channel). But the latter is a less deterministic case,
it's harder to be faster than upstream unless upstream does all
allocations in one thread first and then starts the other threads
computing on the memory later. The 1:N has no perfect solution anyway,
unless we just detect it and hammer it with MADV_INTERLEAVE. But I
tried to avoid hard classifications and radical change in behavior and
I try to do something that always works no matter the load we throw at
it. So I'm usually more concerned about optimizing for the former case
which has a perfect solution possible.

> > If there are multiple threads their affinity will vary slighly and the
> > task_selected_nid will distribute (and if it doesn't distribute the
> > idle load balancing will still work perfectly as upstream).
> > 
> > If there's just one thread, so really 1:N, it doesn't matter in which
> > CPU of the 4 nodes we put it if it's the memory split is 25/25/25/25.
> 
> It should matter when load is not static.  Just as select_idle_sibling()
> is not a great idea once you're ramped up, retained stickiness should
> hurt dynamic responsiveness.  But never mind, that's just me pondering
> the up/down sides of stickiness.

Actually I'm going to test removing the above hunk.

> > In short in those 1:N scenarios, it's usually better to just stick to
> > the last node it run on, and it does with AutoNUMA. This is why it's
> > better to have 1 task_selected_nid instead of 4. There may be level 3
> > caches for the node too and that will preserve them too.
> 
> My point was that there is no correct node to prefer, so wondered if
> AutoNuma could possibly recognize that, and not do what can only be the
> wrong thing.  It needs to only tag things it is really sure about.

You know sched/fair.c so much better than me, so you decide. AutoNUMA
is just an ideal hacking base that converges and works well, and we
can build on that. It's very easy to modify and experiment
with. All contributions are welcome ;).

I'm adding new ideas to it as I write this in some experimetnal branch
(just reached new records of convergence vs autonuma27, by accounting
in real time for the page migrations in mm_autonuma without having to
boost the numa hinting page fault rate).

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
