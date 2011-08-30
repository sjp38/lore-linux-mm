Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E0F6C900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 03:04:31 -0400 (EDT)
Date: Tue, 30 Aug 2011 09:04:24 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-ID: <20110830070424.GA13061@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110808124333.GA31739@redhat.com>
 <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
 <20110829155113.GA21661@redhat.com>
 <20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 30, 2011 at 10:12:33AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 29 Aug 2011 17:51:13 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Tue, Aug 09, 2011 at 08:33:45AM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 8 Aug 2011 14:43:33 +0200
> > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > 
> > > > On Fri, Jul 22, 2011 at 05:15:40PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > +When under_hierarchy is added in the tail, the number indicates the
> > > > > +total memcg scan of its children and itself.
> > > > 
> > > > In your implementation, statistics are only accounted to the memcg
> > > > triggering the limit and the respectively scanned memcgs.
> > > > 
> > > > Consider the following setup:
> > > > 
> > > >         A
> > > >        / \
> > > >       B   C
> > > >      /
> > > >     D
> > > > 
> > > > If D tries to charge but hits the limit of A, then B's hierarchy
> > > > counters do not reflect the reclaim activity resulting in D.
> > > > 
> > > yes, as I expected.
> > 
> > Andrew,
> > 
> > with a flawed design, the author unwilling to fix it, and two NAKs,
> > can we please revert this before the release?
> 
> How about this ?

> @@ -1710,11 +1711,18 @@ static void mem_cgroup_record_scanstat(s
>  	spin_lock(&memcg->scanstat.lock);
>  	__mem_cgroup_record_scanstat(memcg->scanstat.stats[context], rec);
>  	spin_unlock(&memcg->scanstat.lock);
> -
> -	memcg = rec->root;
> -	spin_lock(&memcg->scanstat.lock);
> -	__mem_cgroup_record_scanstat(memcg->scanstat.rootstats[context], rec);
> -	spin_unlock(&memcg->scanstat.lock);
> +	cgroup = memcg->css.cgroup;
> +	do {
> +		spin_lock(&memcg->scanstat.lock);
> +		__mem_cgroup_record_scanstat(
> +			memcg->scanstat.hierarchy_stats[context], rec);
> +		spin_unlock(&memcg->scanstat.lock);
> +		if (!cgroup->parent)
> +			break;
> +		cgroup = cgroup->parent;
> +		memcg = mem_cgroup_from_cont(cgroup);
> +	} while (memcg->use_hierarchy && memcg != rec->root);

Okay, so this looks correct, but it sums up all parents after each
memcg scanned, which could have a performance impact.  Usually,
hierarchy statistics are only summed up when a user reads them.

I don't get why this has to be done completely different from the way
we usually do things, without any justification, whatsoever.

Why do you want to pass a recording structure down the reclaim stack?
Why not make it per-cpu counters that are only summed up, together
with the hierarchy values, when someone is actually interested in
them?  With an interface like mem_cgroup_count_vm_event(), or maybe
even an extension of that function?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
