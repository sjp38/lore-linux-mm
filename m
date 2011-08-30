Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9895C900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 06:41:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 35C083EE0B5
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 19:41:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E9B6F45DE86
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 19:41:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C438345DE7E
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 19:41:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADE6F1DB8040
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 19:41:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 691171DB803E
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 19:41:35 +0900 (JST)
Date: Tue, 30 Aug 2011 19:34:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-Id: <20110830193406.361d758a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110830101726.GD13061@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110808124333.GA31739@redhat.com>
	<20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20110829155113.GA21661@redhat.com>
	<20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830070424.GA13061@redhat.com>
	<20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830084245.GC13061@redhat.com>
	<20110830175609.4977ef7a.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830101726.GD13061@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 30 Aug 2011 12:17:26 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Tue, Aug 30, 2011 at 05:56:09PM +0900, KAMEZAWA Hiroyuki wrote:

> > > > > I don't get why this has to be done completely different from the way
> > > > > we usually do things, without any justification, whatsoever.
> > > > > 
> > > > > Why do you want to pass a recording structure down the reclaim stack?
> > > > 
> > > > Just for reducing number of passed variables.
> > > 
> > > It's still sitting on bottom of the reclaim stack the whole time.
> > > 
> > > With my proposal, you would only need to pass the extra root_mem
> > > pointer.
> > 
> > I'm sorry I miss something. Do you say to add a function like
> > 
> > mem_cgroup_record_reclaim_stat(memcg, root_mem, anon_scan, anon_free, anon_rotate,
> >                                file_scan, file_free, elapsed_ns)
> > 
> > ?
> 
> Exactly, though passing it a stat item index and a delta would
> probably be closer to our other statistics accounting, i.e.:
> 
> 	mem_cgroup_record_reclaim_stat(sc->mem_cgroup, sc->root_mem_cgroup,
> 				       MEM_CGROUP_SCAN_ANON, *nr_anon);
> 
> where sc->mem_cgroup is `victim' and sc->root_mem_cgroup is `root_mem'
> from hierarchical_reclaim.  ->root_mem_cgroup might be confusing,
> though.  I named it ->target_mem_cgroup in my patch set but I don't
> feel too strongly about that.
> 
> Even better would be to reuse enum vm_event_item and at one point
> merge all the accounting stuff into a single function and have one
> single set of events that makes sense on a global level as well as on
> a per-memcg level.
> 
> There is deviation and implementing similar things twice with slight
> variations and I don't see any justification for all that extra code
> that needs maintaining.  Or counters that have similar names globally
> and on a per-memcg level but with different meanings, like the rotated
> counter.  Globally, a rotated page (PGROTATED) is one that is moved
> back to the inactive list after writeback finishes.  Per-memcg, the
> rotated counter is our internal heuristics value to balance pressure
> between LRUs and means either rotated on the inactive list, activated,
> not activated but countes as activated because of VM_EXEC etc.
> 
> I am still for reverting this patch before the release until we have
> this all sorted out.  I feel rather strongly that these statistics are
> in no way ready to make them part of the ABI and export them to
> userspace as they are now.
> 

How about fixing interface first ? 1st version of this patch was 
in April and no big change since then.
I don't want to be starved more.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
