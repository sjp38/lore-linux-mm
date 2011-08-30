Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 11EBD900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 07:53:10 -0400 (EDT)
Date: Tue, 30 Aug 2011 13:03:37 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-ID: <20110830110337.GE13061@redhat.com>
References: <20110808124333.GA31739@redhat.com>
 <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
 <20110829155113.GA21661@redhat.com>
 <20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830070424.GA13061@redhat.com>
 <20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830084245.GC13061@redhat.com>
 <20110830175609.4977ef7a.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830101726.GD13061@redhat.com>
 <20110830193406.361d758a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110830193406.361d758a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 30, 2011 at 07:34:06PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 30 Aug 2011 12:17:26 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Tue, Aug 30, 2011 at 05:56:09PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> > > > > > I don't get why this has to be done completely different from the way
> > > > > > we usually do things, without any justification, whatsoever.
> > > > > > 
> > > > > > Why do you want to pass a recording structure down the reclaim stack?
> > > > > 
> > > > > Just for reducing number of passed variables.
> > > > 
> > > > It's still sitting on bottom of the reclaim stack the whole time.
> > > > 
> > > > With my proposal, you would only need to pass the extra root_mem
> > > > pointer.
> > > 
> > > I'm sorry I miss something. Do you say to add a function like
> > > 
> > > mem_cgroup_record_reclaim_stat(memcg, root_mem, anon_scan, anon_free, anon_rotate,
> > >                                file_scan, file_free, elapsed_ns)
> > > 
> > > ?
> > 
> > Exactly, though passing it a stat item index and a delta would
> > probably be closer to our other statistics accounting, i.e.:
> > 
> > 	mem_cgroup_record_reclaim_stat(sc->mem_cgroup, sc->root_mem_cgroup,
> > 				       MEM_CGROUP_SCAN_ANON, *nr_anon);
> > 
> > where sc->mem_cgroup is `victim' and sc->root_mem_cgroup is `root_mem'
> > from hierarchical_reclaim.  ->root_mem_cgroup might be confusing,
> > though.  I named it ->target_mem_cgroup in my patch set but I don't
> > feel too strongly about that.
> > 
> > Even better would be to reuse enum vm_event_item and at one point
> > merge all the accounting stuff into a single function and have one
> > single set of events that makes sense on a global level as well as on
> > a per-memcg level.
> > 
> > There is deviation and implementing similar things twice with slight
> > variations and I don't see any justification for all that extra code
> > that needs maintaining.  Or counters that have similar names globally
> > and on a per-memcg level but with different meanings, like the rotated
> > counter.  Globally, a rotated page (PGROTATED) is one that is moved
> > back to the inactive list after writeback finishes.  Per-memcg, the
> > rotated counter is our internal heuristics value to balance pressure
> > between LRUs and means either rotated on the inactive list, activated,
> > not activated but countes as activated because of VM_EXEC etc.
> > 
> > I am still for reverting this patch before the release until we have
> > this all sorted out.  I feel rather strongly that these statistics are
> > in no way ready to make them part of the ABI and export them to
> > userspace as they are now.
> 
> How about fixing interface first ? 1st version of this patch was 
> in April and no big change since then.
> I don't want to be starved more.

Back then I mentioned all my concerns and alternate suggestions.
Different from you, I explained and provided a reason for every single
counter I wanted to add, suggested a basic pattern for how to
interpret them to gain insight into memcg configurations and their
behaviour.  No reaction.  If you want to make progress, than don't
ignore concerns and arguments.  If my arguments are crap, then tell me
why and we can move on.

What we have now is not ready.  It wasn't discussed properly, which
certainly wasn't for the lack of interest in this change.  I just got
tired of raising the same points over and over again without answer.

The amount of time a change has been around is not an argument for it
to get merged.  On the other hand, the fact that it hasn't changed
since April *even though* the implementation was opposed back then
doesn't really speak for your way of getting this upstream, does it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
