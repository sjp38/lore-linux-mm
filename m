Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C3E286B0023
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 01:56:48 -0400 (EDT)
Date: Wed, 14 Sep 2011 07:56:34 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 04/11] mm: memcg: per-priority per-zone hierarchy scan
 generations
Message-ID: <20110914055634.GA28051@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-5-git-send-email-jweiner@redhat.com>
 <20110913192759.ff0da031.kamezawa.hiroyu@jp.fujitsu.com>
 <20110913110301.GB18886@redhat.com>
 <20110914095504.30fca5d0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110914095504.30fca5d0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 14, 2011 at 09:55:04AM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 13 Sep 2011 13:03:01 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Tue, Sep 13, 2011 at 07:27:59PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 12 Sep 2011 12:57:21 +0200
> > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > 
> > > > Memory cgroup limit reclaim currently picks one memory cgroup out of
> > > > the target hierarchy, remembers it as the last scanned child, and
> > > > reclaims all zones in it with decreasing priority levels.
> > > > 
> > > > The new hierarchy reclaim code will pick memory cgroups from the same
> > > > hierarchy concurrently from different zones and priority levels, it
> > > > becomes necessary that hierarchy roots not only remember the last
> > > > scanned child, but do so for each zone and priority level.
> > > > 
> > > > Furthermore, detecting full hierarchy round-trips reliably will become
> > > > crucial, so instead of counting on one iterator site seeing a certain
> > > > memory cgroup twice, use a generation counter that is increased every
> > > > time the child with the highest ID has been visited.
> > > > 
> > > > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> > > 
> > > I cannot image how this works. could you illustrate more with easy example ?
> > 
> > Previously, we did
> > 
> > 	mem = mem_cgroup_iter(root)
> > 	  for each priority level:
> > 	    for each zone in zonelist:
> > 
> > and this would reclaim memcg-1-zone-1, memcg-1-zone-2, memcg-1-zone-3
> > etc.
> > 
> yes.
> 
> > The new code does
> > 
> > 	for each priority level
> > 	  for each zone in zonelist
> >             mem = mem_cgroup_iter(root)
> > 
> > but with a single last_scanned_child per memcg, this would scan
> > memcg-1-zone-1, memcg-2-zone-2, memcg-3-zone-3 etc, which does not
> > make much sense.
> > 
> > Now imagine two reclaimers.  With the old code, the first reclaimer
> > would pick memcg-1 and scan all its zones, the second reclaimer would
> > pick memcg-2 and reclaim all its zones.  Without this patch, the first
> > reclaimer would pick memcg-1 and scan zone-1, the second reclaimer
> > would pick memcg-2 and scan zone-1, then the first reclaimer would
> > pick memcg-3 and scan zone-2.  If the reclaimers are concurrently
> > scanning at different priority levels, things are even worse because
> > one reclaimer may put much more force on the memcgs it gets from
> > mem_cgroup_iter() than the other reclaimer.  They must not share the
> > same iterator.
> > 
> > The generations are needed because the old algorithm did not rely too
> > much on detecting full round-trips.  After every reclaim cycle, it
> > checked the limit and broke out of the loop if enough was reclaimed,
> > no matter how many children were reclaimed from.  The new algorithm is
> > used for global reclaim, where the only exit condition of the
> > hierarchy reclaim is the full roundtrip, because equal pressure needs
> > to be applied to all zones.
> > 
> Hm, ok, maybe good for global reclam.
> Is this used for both of reclaim-by-limit and global-reclaim ?

No, the hierarchy iteration in shrink_zone() is done after a single
memcg, which is equivalent to the old code: scan all zones at all
priority levels from a memcg, then move on to the next memcg.  This
also works because of the per-zone per-priority last_scanned_child:

	for each priority
	  for each zone
	    mem = mem_cgroup_iter(root)
	    scan(mem)

priority-12 + zone-1 will yield memcg-1.  priority-12 + zone-2 starts
at its own last_scanned_child, so yields memcg-1 as well, etc.  A
second reclaimer that comes in with priority-12 + zone-1 will receive
memcg-2 for scanning.  So there is no change in behaviour for limit
reclaim.

> If so, I need to abandon node-selection-logic for reclaim-by-limit
> and nodemask-for-memcg which shows me very good result. 
> I'll be sad ;)

With my clarification, do you still think so?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
