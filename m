Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 68F69900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 03:28:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8FD543EE0BC
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:28:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7652645DEB2
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:28:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 512F445DEB3
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:28:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 459441DB803C
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:28:25 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F117C1DB803B
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:28:24 +0900 (JST)
Date: Tue, 30 Aug 2011 16:20:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-Id: <20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110830070424.GA13061@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110808124333.GA31739@redhat.com>
	<20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20110829155113.GA21661@redhat.com>
	<20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830070424.GA13061@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 30 Aug 2011 09:04:24 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Tue, Aug 30, 2011 at 10:12:33AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon, 29 Aug 2011 17:51:13 +0200
> > Johannes Weiner <jweiner@redhat.com> wrote:
> > 
> > > On Tue, Aug 09, 2011 at 08:33:45AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Mon, 8 Aug 2011 14:43:33 +0200
> > > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > > 
> > > > > On Fri, Jul 22, 2011 at 05:15:40PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > > +When under_hierarchy is added in the tail, the number indicates the
> > > > > > +total memcg scan of its children and itself.
> > > > > 
> > > > > In your implementation, statistics are only accounted to the memcg
> > > > > triggering the limit and the respectively scanned memcgs.
> > > > > 
> > > > > Consider the following setup:
> > > > > 
> > > > >         A
> > > > >        / \
> > > > >       B   C
> > > > >      /
> > > > >     D
> > > > > 
> > > > > If D tries to charge but hits the limit of A, then B's hierarchy
> > > > > counters do not reflect the reclaim activity resulting in D.
> > > > > 
> > > > yes, as I expected.
> > > 
> > > Andrew,
> > > 
> > > with a flawed design, the author unwilling to fix it, and two NAKs,
> > > can we please revert this before the release?
> > 
> > How about this ?
> 
> > @@ -1710,11 +1711,18 @@ static void mem_cgroup_record_scanstat(s
> >  	spin_lock(&memcg->scanstat.lock);
> >  	__mem_cgroup_record_scanstat(memcg->scanstat.stats[context], rec);
> >  	spin_unlock(&memcg->scanstat.lock);
> > -
> > -	memcg = rec->root;
> > -	spin_lock(&memcg->scanstat.lock);
> > -	__mem_cgroup_record_scanstat(memcg->scanstat.rootstats[context], rec);
> > -	spin_unlock(&memcg->scanstat.lock);
> > +	cgroup = memcg->css.cgroup;
> > +	do {
> > +		spin_lock(&memcg->scanstat.lock);
> > +		__mem_cgroup_record_scanstat(
> > +			memcg->scanstat.hierarchy_stats[context], rec);
> > +		spin_unlock(&memcg->scanstat.lock);
> > +		if (!cgroup->parent)
> > +			break;
> > +		cgroup = cgroup->parent;
> > +		memcg = mem_cgroup_from_cont(cgroup);
> > +	} while (memcg->use_hierarchy && memcg != rec->root);
> 
> Okay, so this looks correct, but it sums up all parents after each
> memcg scanned, which could have a performance impact.  Usually,
> hierarchy statistics are only summed up when a user reads them.
> 
Hmm. But sum-at-read doesn't work.

Assume 3 cgroups in a hierarchy.

	A
       /
      B
     /
    C

C's scan contains 3 causes.
	C's scan caused by limit of A.
	C's scan caused by limit of B.
	C's scan caused by limit of C.

If we make hierarchy sum at read, we think
	B's scan_stat = B's scan_stat + C's scan_stat
But in precice, this is

	B's scan_stat = B's scan_stat caused by B +
			B's scan_stat caused by A +
			C's scan_stat caused by C +
			C's scan_stat caused by B +
			C's scan_stat caused by A.

In orignal version.
	B's scan_stat = B's scan_stat caused by B +
			C's scan_stat caused by B +

After this patch,
	B's scan_stat = B's scan_stat caused by B +
			B's scan_stat caused by A +
			C's scan_stat caused by C +
			C's scan_stat caused by B +
			C's scan_stat caused by A.

Hmm...removing hierarchy part completely seems fine to me.


> I don't get why this has to be done completely different from the way
> we usually do things, without any justification, whatsoever.
> 
> Why do you want to pass a recording structure down the reclaim stack?

Just for reducing number of passed variables.

> Why not make it per-cpu counters that are only summed up, together
> with the hierarchy values, when someone is actually interested in
> them?  With an interface like mem_cgroup_count_vm_event(), or maybe
> even an extension of that function?

percpu counter seems overkill to me because there is no heavy lock contention.


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
