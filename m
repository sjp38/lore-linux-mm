Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 94F456B005A
	for <linux-mm@kvack.org>; Sun,  7 Oct 2012 02:07:40 -0400 (EDT)
Message-ID: <1349590047.6958.88.camel@marge.simpson.net>
Subject: Re: [PATCH 18/33] autonuma: teach CFS about autonuma affinity
From: Mike Galbraith <efault@gmx.de>
Date: Sun, 07 Oct 2012 08:07:27 +0200
In-Reply-To: <20121006123432.GS6793@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
	 <1349308275-2174-19-git-send-email-aarcange@redhat.com>
	 <1349419285.6984.98.camel@marge.simpson.net>
	 <20121005115455.GH6793@redhat.com>
	 <1349491194.6984.175.camel@marge.simpson.net>
	 <20121006123432.GS6793@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Sat, 2012-10-06 at 14:34 +0200, Andrea Arcangeli wrote: 
> Hi Mike,

Greetings,

> On Sat, Oct 06, 2012 at 04:39:54AM +0200, Mike Galbraith wrote:

> I think you just found a mistake.
> 
> So disabling wake_affine if the wakeup CPU was on a remote NODE (only
> in that case it was turned off), meant sd_affine couldn't be turned on
> and for certain wakeups select_idle_sibling wouldn't run (rendering
> pointless some of my logic in select_idle_sibling).

Well, it still looks a bit bent to me no matter how I tilt my head.

                /*
                 * If both cpu and prev_cpu are part of this domain,
                 * cpu is a valid SD_WAKE_AFFINE target.
                 */
                if (want_affine && (tmp->flags & SD_WAKE_AFFINE) &&
                    cpumask_test_cpu(prev_cpu, sched_domain_span(tmp))) {
                        affine_sd = tmp;
                        want_affine = 0;
                }

Disabling when waker/wakee are cross node makes sense to me as a cycle
saver.  If you have (SMT), MC and NODE domains, waker/wakee are cross
node, spans don't intersect, affine_sd remains NULL, the whole traverse
becomes a waste of cycles.  If WAKE_BALANCE is enabled, we'll do that
instead (which pgbench and ilk should like methinks).

> > I measured the 1 in 1:N pgbench very much preferring mobility.  The N,
> > dunno, but I don't imagine a large benefit for making them sticky
> > either.  Hohum, numbers will tell the tale.
> 
> Mobility on non-NUMA is an entirely different matter than mobility
> across NUMA nodes. Keep in mind there are tons of CPUs intra-node too
> so the mobility intra node may be enough.  But I don't know exactly
> what the mobiltiy requirements of pgbench are so I can't tell for sure
> and I fully agree we should collect numbers.

Yeah, that 1:1 vs 1:N, load meets anti-load thing is kinda interesting.
Tune for one, you may well annihilate the other.  Numbers required.

I think we need to detect and react accordingly.  If that nasty little 1
bugger is doing a lot of work, it's very special, so I don't think you
making him sticky can help any more than me taking away wakeup options..
both remove latency reducing options from a latency dominated load.

But numbers talk, pondering (may = BS) walks, so I'm outta here :)

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
