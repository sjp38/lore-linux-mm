Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 2D0FA6B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 22:40:11 -0400 (EDT)
Message-ID: <1349491194.6984.175.camel@marge.simpson.net>
Subject: Re: [PATCH 18/33] autonuma: teach CFS about autonuma affinity
From: Mike Galbraith <efault@gmx.de>
Date: Sat, 06 Oct 2012 04:39:54 +0200
In-Reply-To: <20121005115455.GH6793@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
	 <1349308275-2174-19-git-send-email-aarcange@redhat.com>
	 <1349419285.6984.98.camel@marge.simpson.net>
	 <20121005115455.GH6793@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Fri, 2012-10-05 at 13:54 +0200, Andrea Arcangeli wrote: 
> On Fri, Oct 05, 2012 at 08:41:25AM +0200, Mike Galbraith wrote:
> > On Thu, 2012-10-04 at 01:51 +0200, Andrea Arcangeli wrote: 
> > > The CFS scheduler is still in charge of all scheduling decisions. At
> > > times, however, AutoNUMA balancing will override them.
> > > 
> > > Generally, we'll just rely on the CFS scheduler to keep doing its
> > > thing, while preferring the task's AutoNUMA affine node when deciding
> > > to move a task to a different runqueue or when waking it up.
> > 
> > Why does AutoNuma fiddle with wakeup decisions _within_ a node?
> > 
> > pgbench intensely disliked me recently depriving it of migration routes
> > in select_idle_sibling(), so AutoNuma saying NAK seems unlikely to make
> > it or ilk any happier.
> 
> Preferring doesn't mean NAK. It means "search affine first" if there's
> not, go the usual route like if autonuma was not there.

I'll rephrase.  We're searching a processor.  What does that have to do
with NUMA?  I saw you turning want_affine off (and wonder what that's
gonna do to fluctuating vs for more or less static loads), and get that.

> In short there's no risk of regressions like it happened until 3.6-rc6
> (I reverted that patch before it was reverted in 3.6-rc6).

(Shrug, +1000% vs -20%.  Relevant is the NUMA vs package bit, and node
stickiness vs 1:N bit)

> > Hm.  How does this profiling work for 1:N loads?  Once you need two or
> > more nodes, there is no best node for the 1, so restricting it can only
> > do harm.  For pgbench and ilk, loads of cross node traffic should mean
> > the 1 is succeeding at keeping the N busy.
> 
> That resembles numa01 on the 8 node system. There are N threads
> trashing over all the memory of 4 nodes, and another N threads
> trashing over the memory of another 4 nodes. It still work massively
> better than no autonuma.

I measured the 1 in 1:N pgbench very much preferring mobility.  The N,
dunno, but I don't imagine a large benefit for making them sticky
either.  Hohum, numbers will tell the tale.

> If there are multiple threads their affinity will vary slighly and the
> task_selected_nid will distribute (and if it doesn't distribute the
> idle load balancing will still work perfectly as upstream).
> 
> If there's just one thread, so really 1:N, it doesn't matter in which
> CPU of the 4 nodes we put it if it's the memory split is 25/25/25/25.

It should matter when load is not static.  Just as select_idle_sibling()
is not a great idea once you're ramped up, retained stickiness should
hurt dynamic responsiveness.  But never mind, that's just me pondering
the up/down sides of stickiness.

> In short in those 1:N scenarios, it's usually better to just stick to
> the last node it run on, and it does with AutoNUMA. This is why it's
> better to have 1 task_selected_nid instead of 4. There may be level 3
> caches for the node too and that will preserve them too.

My point was that there is no correct node to prefer, so wondered if
AutoNuma could possibly recognize that, and not do what can only be the
wrong thing.  It needs to only tag things it is really sure about.

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
