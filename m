Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F024F8D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 21:54:18 -0400 (EDT)
Date: Tue, 22 Mar 2011 10:47:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: consider per-cpu stock reserves when returning
 RES_USAGE for _MEM
Message-Id: <20110322104723.fd81dddc.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110322091014.27677ab3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110318152532.GB18450@tiehlicka.suse.cz>
	<20110321093419.GA26047@tiehlicka.suse.cz>
	<20110321102420.GB26047@tiehlicka.suse.cz>
	<20110322091014.27677ab3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Tue, 22 Mar 2011 09:10:14 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 21 Mar 2011 11:24:20 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > [Sorry for reposting but I forgot to fully refresh the patch before
> > posting...]
> > 
> > On Mon 21-03-11 10:34:19, Michal Hocko wrote:
> > > On Fri 18-03-11 16:25:32, Michal Hocko wrote:
> > > [...]
> > > > According to our documention this is a reasonable test case:
> > > > Documentation/cgroups/memory.txt:
> > > > memory.usage_in_bytes           # show current memory(RSS+Cache) usage.
> > > > 
> > > > This however doesn't work after your commit:
> > > > cdec2e4265d (memcg: coalesce charging via percpu storage)
> > > > 
> > > > because since then we are charging in bulks so we can end up with
> > > > rss+cache <= usage_in_bytes.
> > > [...]
> > > > I think we have several options here
> > > > 	1) document that the value is actually >= rss+cache and it shows
> > > > 	   the guaranteed charges for the group
> > > > 	2) use rss+cache rather then res->count
> > > > 	3) remove the file
> > > > 	4) call drain_all_stock_sync before asking for the value in
> > > > 	   mem_cgroup_read
> > > > 	5) collect the current amount of stock charges and subtract it
> > > > 	   from the current res->count value
> > > > 
> > > > 1) and 2) would suggest that the file is actually not very much useful.
> > > > 3) is basically the interface change as well
> > > > 4) sounds little bit invasive as we basically lose the advantage of the
> > > > pool whenever somebody reads the file. Btw. for who is this file
> > > > intended?
> > > > 5) sounds like a compromise
> > > 
> > > I guess that 4) is really too invasive - for no good reason so here we
> > > go with the 5) solution.
> 
> I think the test in LTP is bad...(it should be fuzzy.) because we cannot
> avoid races...
I agree.

> But ok, this itself will be a problem with a large machine with many cpus.
> 
> 
> > --- 
> > From: Michal Hocko <mhocko@suse.cz>
> > Subject: memcg: consider per-cpu stock reserves when returning RES_USAGE for _MEM
> > 
> > Since cdec2e4265d (memcg: coalesce charging via percpu storage) commit we
> > are charging resource counter in batches. This means that the current
> > res->count value doesn't show the real consumed value (rss+cache as we
> > describe in the documentation) but rather a promissed charges for future.
> > We are pre-charging CHARGE_SIZE bulk at once and subsequent charges are
> > satisfied from the per-cpu cgroup_stock pool.
> > 
> > We have seen a report that one of the LTP testcases checks exactly this
> > condition so the test fails.
> > 
> > As this exported value is a part of kernel->userspace interface we should
> > try to preserve the original (and documented) semantic.
> > 
> > This patch fixes the issue by collecting the current usage of each per-cpu
> > stock and subtracting it from the current res counter value.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> This doesn't seems correct.
> 
> > Index: linus_tree/mm/memcontrol.c
> > ===================================================================
> > --- linus_tree.orig/mm/memcontrol.c	2011-03-18 16:09:11.000000000 +0100
> > +++ linus_tree/mm/memcontrol.c	2011-03-21 10:21:55.000000000 +0100
> > @@ -3579,13 +3579,30 @@ static unsigned long mem_cgroup_recursiv
> >  	return val;
> >  }
> >  
> > +static u64 mem_cgroup_current_usage(struct mem_cgroup *mem)
> > +{
> > +	u64 val = res_counter_read_u64(&mem->res, RES_USAGE);
> > +	u64 per_cpu_val = 0;
> > +	int cpu;
> > +
> > +	get_online_cpus();
> > +	for_each_online_cpu(cpu) {
> > +		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > +
> > +		per_cpu_val += stock->nr_pages * PAGE_SIZE;
> 
> 		if (memcg_stock->cached == mem)
> 			per_cpu_val += stock->nr_pages * PAGE_SIZE;
> 
> AND I think you doesn't handle batched uncharge.
> Do you have any idea ? (Peter Zilstra's patch will make error size of
> bached uncharge bigger.)
> 
> So....rather than this, just always using root memcg's code is
> a good way. Could you try ?
> ==
>         usage = mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_CACHE);
>         usage += mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_RSS);
> 
>         if (swap)
>                 val += mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
> 
>         return val << PAGE_SHIFT;
> ==
> 
So, option 2) above.

As Michal already said, this change will make *.usage_in_bytes not so useful,
i.e. we can use memory.stat instead.

I don't have any good idea, but I tend to agree to 1) or 3)(or rename the file names) now.
Considering batched uncharge, I think 4) and 5) is difficult.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
