Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E968A6B007E
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 02:46:22 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0K7kJoR022718
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 20 Jan 2010 16:46:20 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A8C3645DE4F
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:46:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F6EC45DE4E
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:46:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 67AA9E38001
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:46:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 14BCD1DB803A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:46:19 +0900 (JST)
Date: Wed, 20 Jan 2010 16:43:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100120164302.f05a91ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100120161533.6d83f607.nishimura@mxp.nes.nec.co.jp>
References: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107083440.GS3059@balbir.in.ibm.com>
	<20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107092736.GW3059@balbir.in.ibm.com>
	<20100108084727.429c40fc.kamezawa.hiroyu@jp.fujitsu.com>
	<661de9471001171130p2b0ac061he6f3dab9ef46fd06@mail.gmail.com>
	<20100118094920.151e1370.nishimura@mxp.nes.nec.co.jp>
	<4B541B44.3090407@linux.vnet.ibm.com>
	<20100119102208.59a16397.nishimura@mxp.nes.nec.co.jp>
	<661de9471001181749y2fe22a15j1c01c94aa1838e99@mail.gmail.com>
	<20100119113443.562e38ba.nishimura@mxp.nes.nec.co.jp>
	<4B552C89.8000004@linux.vnet.ibm.com>
	<20100120130902.865d8269.nishimura@mxp.nes.nec.co.jp>
	<20100120161533.6d83f607.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jan 2010 16:15:33 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > I would agree with you if you add interfaces to show some hints to users about above values,
> > but "shared_usage_in_bytes" doesn't meet it at all.
> > 
> This is just an idea(At least, we need interfaces to read and reset them).
> 
seems atractive but there is no way to decrement this counter in _scalable_ way.
We need some inovation to go this way.

But I doubt how this comes to be useful.

In general, we can assume
   - file is shared. (because of their nature.)
   - rss is private. (because of thier nature.)

Then, the problem is how rss(private anon) is shared. 
Except for crazy progam as AIM7, rss is private in many case.
Even if highly shared, in most case, shared rss can be estimated by the size
of parent process's rss. And processe's parent-child relationship is appearent.
Measurement is easy. If COW is troublesome, counting # of COW per process
is reasonable way. (But you have to fight with the cost of adding that.)

I tend not to disagree to add a counter to show "shared with other cgroup"
but disagree "shared between process". 

Thanks,
-Kame


> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 385e29b..bf601f2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -83,6 +83,8 @@ enum mem_cgroup_stat_index {
>  					used by soft limit implementation */
>  	MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
>  					used by threshold implementation */
> +	MEM_CGROUP_STAT_SHARED_IN_GROUP,
> +	MEM_CGROUP_STAT_SHARED_FROM_OTHERS,
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -1707,8 +1709,25 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  
>  	lock_page_cgroup(pc);
>  	if (unlikely(PageCgroupUsed(pc))) {
> +		struct mem_cgroup *charged = pc->mem_cgroup;
> +		struct mem_cgroup_stat *stat;
> +		struct mem_cgroup_stat_cpu *cpustat;
> +		int cpu;
> +		int shared_type;
> +
>  		unlock_page_cgroup(pc);
>  		mem_cgroup_cancel_charge(mem);
> +
> +		stat = &charged->stat;
> +		cpu = get_cpu();
> +		cpustat = &stat->cpustat[cpu];
> +		if (charged == mem)
> +			shared_type = MEM_CGROUP_STAT_SHARED_IN_GROUP;
> +		else
> +			shared_type = MEM_CGROUP_STAT_SHARED_FROM_OTHERS;
> +		__mem_cgroup_stat_add_safe(cpustat, shared_type, 1);
> +		put_cpu();
> +
>  		return;
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
