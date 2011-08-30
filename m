Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 086B4900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 06:17:36 -0400 (EDT)
Date: Tue, 30 Aug 2011 12:17:26 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-ID: <20110830101726.GD13061@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110808124333.GA31739@redhat.com>
 <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
 <20110829155113.GA21661@redhat.com>
 <20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830070424.GA13061@redhat.com>
 <20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830084245.GC13061@redhat.com>
 <20110830175609.4977ef7a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110830175609.4977ef7a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 30, 2011 at 05:56:09PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 30 Aug 2011 10:42:45 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Tue, Aug 30, 2011 at 04:20:50PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 30 Aug 2011 09:04:24 +0200
> > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > 
> > > > On Tue, Aug 30, 2011 at 10:12:33AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > @@ -1710,11 +1711,18 @@ static void mem_cgroup_record_scanstat(s
> > > > >  	spin_lock(&memcg->scanstat.lock);
> > > > >  	__mem_cgroup_record_scanstat(memcg->scanstat.stats[context], rec);
> > > > >  	spin_unlock(&memcg->scanstat.lock);
> > > > > -
> > > > > -	memcg = rec->root;
> > > > > -	spin_lock(&memcg->scanstat.lock);
> > > > > -	__mem_cgroup_record_scanstat(memcg->scanstat.rootstats[context], rec);
> > > > > -	spin_unlock(&memcg->scanstat.lock);
> > > > > +	cgroup = memcg->css.cgroup;
> > > > > +	do {
> > > > > +		spin_lock(&memcg->scanstat.lock);
> > > > > +		__mem_cgroup_record_scanstat(
> > > > > +			memcg->scanstat.hierarchy_stats[context], rec);
> > > > > +		spin_unlock(&memcg->scanstat.lock);
> > > > > +		if (!cgroup->parent)
> > > > > +			break;
> > > > > +		cgroup = cgroup->parent;
> > > > > +		memcg = mem_cgroup_from_cont(cgroup);
> > > > > +	} while (memcg->use_hierarchy && memcg != rec->root);
> > > > 
> > > > Okay, so this looks correct, but it sums up all parents after each
> > > > memcg scanned, which could have a performance impact.  Usually,
> > > > hierarchy statistics are only summed up when a user reads them.
> > > > 
> > > Hmm. But sum-at-read doesn't work.
> > > 
> > > Assume 3 cgroups in a hierarchy.
> > > 
> > > 	A
> > >        /
> > >       B
> > >      /
> > >     C
> > > 
> > > C's scan contains 3 causes.
> > > 	C's scan caused by limit of A.
> > > 	C's scan caused by limit of B.
> > > 	C's scan caused by limit of C.
> > >
> > > If we make hierarchy sum at read, we think
> > > 	B's scan_stat = B's scan_stat + C's scan_stat
> > > But in precice, this is
> > > 
> > > 	B's scan_stat = B's scan_stat caused by B +
> > > 			B's scan_stat caused by A +
> > > 			C's scan_stat caused by C +
> > > 			C's scan_stat caused by B +
> > > 			C's scan_stat caused by A.
> > > 
> > > In orignal version.
> > > 	B's scan_stat = B's scan_stat caused by B +
> > > 			C's scan_stat caused by B +
> > > 
> > > After this patch,
> > > 	B's scan_stat = B's scan_stat caused by B +
> > > 			B's scan_stat caused by A +
> > > 			C's scan_stat caused by C +
> > > 			C's scan_stat caused by B +
> > > 			C's scan_stat caused by A.
> > > 
> > > Hmm...removing hierarchy part completely seems fine to me.
> > 
> > I see.
> > 
> > You want to look at A and see whether its limit was responsible for
> > reclaim scans in any children.  IMO, that is asking the question
> > backwards.  Instead, there is a cgroup under reclaim and one wants to
> > find out the cause for that.  Not the other way round.
> > 
> > In my original proposal I suggested differentiating reclaim caused by
> > internal pressure (due to own limit) and reclaim caused by
> > external/hierarchical pressure (due to limits from parents).
> > 
> > If you want to find out why C is under reclaim, look at its reclaim
> > statistics.  If the _limit numbers are high, C's limit is the problem.
> > If the _hierarchical numbers are high, the problem is B, A, or
> > physical memory, so you check B for _limit and _hierarchical as well,
> > then move on to A.
> > 
> > Implementing this would be as easy as passing not only the memcg to
> > scan (victim) to the reclaim code, but also the memcg /causing/ the
> > reclaim (root_mem):
> > 
> > 	root_mem == victim -> account to victim as _limit
> > 	root_mem != victim -> account to victim as _hierarchical
> > 
> > This would make things much simpler and more natural, both the code
> > and the way of tracking down a problem, IMO.
> 
> hmm. I have no strong opinion.

I do :-)

> > > > I don't get why this has to be done completely different from the way
> > > > we usually do things, without any justification, whatsoever.
> > > > 
> > > > Why do you want to pass a recording structure down the reclaim stack?
> > > 
> > > Just for reducing number of passed variables.
> > 
> > It's still sitting on bottom of the reclaim stack the whole time.
> > 
> > With my proposal, you would only need to pass the extra root_mem
> > pointer.
> 
> I'm sorry I miss something. Do you say to add a function like
> 
> mem_cgroup_record_reclaim_stat(memcg, root_mem, anon_scan, anon_free, anon_rotate,
>                                file_scan, file_free, elapsed_ns)
> 
> ?

Exactly, though passing it a stat item index and a delta would
probably be closer to our other statistics accounting, i.e.:

	mem_cgroup_record_reclaim_stat(sc->mem_cgroup, sc->root_mem_cgroup,
				       MEM_CGROUP_SCAN_ANON, *nr_anon);

where sc->mem_cgroup is `victim' and sc->root_mem_cgroup is `root_mem'
from hierarchical_reclaim.  ->root_mem_cgroup might be confusing,
though.  I named it ->target_mem_cgroup in my patch set but I don't
feel too strongly about that.

Even better would be to reuse enum vm_event_item and at one point
merge all the accounting stuff into a single function and have one
single set of events that makes sense on a global level as well as on
a per-memcg level.

There is deviation and implementing similar things twice with slight
variations and I don't see any justification for all that extra code
that needs maintaining.  Or counters that have similar names globally
and on a per-memcg level but with different meanings, like the rotated
counter.  Globally, a rotated page (PGROTATED) is one that is moved
back to the inactive list after writeback finishes.  Per-memcg, the
rotated counter is our internal heuristics value to balance pressure
between LRUs and means either rotated on the inactive list, activated,
not activated but countes as activated because of VM_EXEC etc.

I am still for reverting this patch before the release until we have
this all sorted out.  I feel rather strongly that these statistics are
in no way ready to make them part of the ABI and export them to
userspace as they are now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
