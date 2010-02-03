Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 564396B0078
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 02:23:09 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o137N4Qu020355
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Feb 2010 16:23:04 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 85A5745DE52
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:23:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BF7145DE51
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:23:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B9291DB8043
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:23:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D862F1DB803C
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:23:00 +0900 (JST)
Date: Wed, 3 Feb 2010 16:19:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg: use generic percpu instead of private
 implementation
Message-Id: <20100203161936.e45955b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100203065305.GD19641@balbir.in.ibm.com>
References: <20100203121624.bab7be2c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100203065305.GD19641@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010 12:23:05 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-02-03 12:16:24]:
> 
> > This is a repost. I'll post my test program in reply to this.
> > Updated against mmotm-2010-Feb-01.
> > 
> > Thanks,
> > -Kame
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > When per-cpu counter for memcg was implemneted, dynamic percpu allocator
> > was not very good. But now, we have good one and useful macros.
> > This patch replaces memcg's private percpu counter implementation with
> > generic dynamic percpu allocator.
> > 
> > The benefits are
> > 	- We can remove private implementation.
> > 	- The counters will be NUMA-aware. (Current one is not...)
> > 	- This patch makes sizeof struct mem_cgroup smaller. Then,
> > 	  struct mem_cgroup may be fit in page size on small config.
> >         - About basic performance aspects, see below.
> > 
> >  [Before]
> >  # size mm/memcontrol.o
> >    text    data     bss     dec     hex filename
> >   24373    2528    4132   31033    7939 mm/memcontrol.o
> > 
> >  [page-fault-throuput test on 8cpu/SMP in root cgroup]
> >  # /root/bin/perf stat -a -e page-faults,cache-misses --repeat 5 ./multi-fault-fork 8
> > 
> >  Performance counter stats for './multi-fault-fork 8' (5 runs):
> > 
> >        45878618  page-faults                ( +-   0.110% )
> >       602635826  cache-misses               ( +-   0.105% )
> > 
> >    61.005373262  seconds time elapsed   ( +-   0.004% )
> > 
> >  Then cache-miss/page fault = 13.14
> > 
> >  [After]
> >  #size mm/memcontrol.o
> >    text    data     bss     dec     hex filename
> >   23913    2528    4132   30573    776d mm/memcontrol.o
> >  # /root/bin/perf stat -a -e page-faults,cache-misses --repeat 5 ./multi-fault-fork 8
> > 
> >  Performance counter stats for './multi-fault-fork 8' (5 runs):
> > 
> >        48179400  page-faults                ( +-   0.271% )
> >       588628407  cache-misses               ( +-   0.136% )
> > 
> >    61.004615021  seconds time elapsed   ( +-   0.004% )
> > 
> >   Then cache-miss/page fault = 12.22
> > 
> >  Text size is reduced.
> >  This performance improvement is not big and will be invisible in real world
> >  applications. But this result shows this patch has some good effect even
> >  on (small) SMP.
> > 
> > Changelog: 2010/02/02
> >  - adjusted to mmotm-Feb01.
> >  - added performance result to the patch description.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |  184 +++++++++++++++++++-------------------------------------
> >  1 file changed, 63 insertions(+), 121 deletions(-)
> > 
> > Index: mmotm-2.6.33-Feb01/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb01.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Feb01/mm/memcontrol.c
> > @@ -89,54 +89,8 @@ enum mem_cgroup_stat_index {
> > 
> >  struct mem_cgroup_stat_cpu {
> >  	s64 count[MEM_CGROUP_STAT_NSTATS];
> > -} ____cacheline_aligned_in_smp;
> > -
> > -struct mem_cgroup_stat {
> > -	struct mem_cgroup_stat_cpu cpustat[0];
> >  };
> > 
> > -static inline void
> > -__mem_cgroup_stat_set_safe(struct mem_cgroup_stat_cpu *stat,
> > -				enum mem_cgroup_stat_index idx, s64 val)
> > -{
> > -	stat->count[idx] = val;
> > -}
> > -
> > -static inline s64
> > -__mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
> > -				enum mem_cgroup_stat_index idx)
> > -{
> > -	return stat->count[idx];
> > -}
> > -
> > -/*
> > - * For accounting under irq disable, no need for increment preempt count.
> > - */
> > -static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat_cpu *stat,
> > -		enum mem_cgroup_stat_index idx, int val)
> > -{
> > -	stat->count[idx] += val;
> > -}
> > -
> > -static s64 mem_cgroup_read_stat(struct mem_cgroup_stat *stat,
> > -		enum mem_cgroup_stat_index idx)
> > -{
> > -	int cpu;
> > -	s64 ret = 0;
> > -	for_each_possible_cpu(cpu)
> > -		ret += stat->cpustat[cpu].count[idx];
> > -	return ret;
> > -}
> > -
> > -static s64 mem_cgroup_local_usage(struct mem_cgroup_stat *stat)
> > -{
> > -	s64 ret;
> > -
> > -	ret = mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_CACHE);
> > -	ret += mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_RSS);
> > -	return ret;
> > -}
> > -
> >  /*
> >   * per-zone information in memory controller.
> >   */
> > @@ -270,9 +224,9 @@ struct mem_cgroup {
> >  	unsigned long 	move_charge_at_immigrate;
> > 
> >  	/*
> > -	 * statistics. This must be placed at the end of memcg.
> > +	 * percpu counter.
> >  	 */
> > -	struct mem_cgroup_stat stat;
> > +	struct mem_cgroup_stat_cpu *stat;
> >  };
> > 
> >  /* Stuffs for move charges at task migration. */
> > @@ -441,19 +395,14 @@ mem_cgroup_remove_exceeded(struct mem_cg
> >  static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
> >  {
> >  	bool ret = false;
> > -	int cpu;
> >  	s64 val;
> > -	struct mem_cgroup_stat_cpu *cpustat;
> > 
> > -	cpu = get_cpu();
> > -	cpustat = &mem->stat.cpustat[cpu];
> > -	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_SOFTLIMIT);
> > +	val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> >  	if (unlikely(val < 0)) {
> > -		__mem_cgroup_stat_set_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT,
> > +		this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT],
> >  				SOFTLIMIT_EVENTS_THRESH);
> >  		ret = true;
> >  	}
> > -	put_cpu();
> >  	return ret;
> >  }
> > 
> > @@ -549,17 +498,31 @@ mem_cgroup_largest_soft_limit_node(struc
> >  	return mz;
> >  }
> > 
> > +static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
> > +		enum mem_cgroup_stat_index idx)
> > +{
> > +	int cpu;
> > +	s64 val = 0;
> > +
> > +	for_each_possible_cpu(cpu)
> 
> Is for_each_possible_cpu() what we need? Is this to avoid CPU hotplug
> events? 
> 
> Looks good overall, except the question above.

Yes. It's against cpu hotplug. Further improvement is add a cpu hotplug
handler (and merge date to other cpus). But I think it should be another
patch.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
