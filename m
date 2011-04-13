Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 70287900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 19:59:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 244BD3EE0BC
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 08:59:38 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D3FE45DE58
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 08:59:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E1E1745DE55
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 08:59:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D5B92E08002
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 08:59:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 957E2E08001
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 08:59:37 +0900 (JST)
Date: Thu, 14 Apr 2011 08:52:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3] Add the pagefault count into memcg stats
Message-Id: <20110414085239.a597fb5c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1104131301180.8140@chino.kir.corp.google.com>
References: <1301419953-2282-1-git-send-email-yinghan@google.com>
	<alpine.DEB.2.00.1104131301180.8140@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, 13 Apr 2011 13:12:33 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 29 Mar 2011, Ying Han wrote:
> 
> > Two new stats in per-memcg memory.stat which tracks the number of
> > page faults and number of major page faults.
> > 
> > "pgfault"
> > "pgmajfault"
> > 
> > They are different from "pgpgin"/"pgpgout" stat which count number of
> > pages charged/discharged to the cgroup and have no meaning of reading/
> > writing page to disk.
> > 
> > It is valuable to track the two stats for both measuring application's
> > performance as well as the efficiency of the kernel page reclaim path.
> > Counting pagefaults per process is useful, but we also need the aggregated
> > value since processes are monitored and controlled in cgroup basis in memcg.
> > 
> > Functional test: check the total number of pgfault/pgmajfault of all
> > memcgs and compare with global vmstat value:
> > 
> > $ cat /proc/vmstat | grep fault
> > pgfault 1070751
> > pgmajfault 553
> > 
> > $ cat /dev/cgroup/memory.stat | grep fault
> > pgfault 1071138
> > pgmajfault 553
> > total_pgfault 1071142
> > total_pgmajfault 553
> > 
> > $ cat /dev/cgroup/A/memory.stat | grep fault
> > pgfault 199
> > pgmajfault 0
> > total_pgfault 199
> > total_pgmajfault 0
> > 
> > Performance test: run page fault test(pft) wit 16 thread on faulting in 15G
> > anon pages in 16G container. There is no regression noticed on the "flt/cpu/s"
> > 
> > Sample output from pft:
> > TAG pft:anon-sys-default:
> >   Gb  Thr CLine   User     System     Wall    flt/cpu/s fault/wsec
> >   15   16   1     0.67s   233.41s    14.76s   16798.546 266356.260
> > 
> > +-------------------------------------------------------------------------+
> >     N           Min           Max        Median           Avg        Stddev
> > x  10     16682.962     17344.027     16913.524     16928.812      166.5362
> > +  10     16695.568     16923.896     16820.604     16824.652     84.816568
> > No difference proven at 95.0% confidence
> > 
> > Change v3..v2
> > 1. removed the unnecessary function definition in memcontrol.h
> > 
> > Signed-off-by: Ying Han <yinghan@google.com>
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I'm wondering if we can just modify count_vm_event() directly for 
> CONFIG_CGROUP_MEM_RES_CTLR so that we automatically track all vmstat items 
> (those in enum vm_event_item) for each memcg.  We could add an array of 
> NR_VM_EVENT_ITEMS into each struct mem_cgroup to be incremented on 
> count_vm_event() for current's memcg.
> 
> If that's done, we wouldn't have to add additional calls for every vmstat 
> item we want to duplicate from the global counters.
> 

Maybe we do that finally.

For now, IIUC, over 50% of VM_EVENTS are needless for memcg (ex. per zone stats)
and this array consumes large size of percpu area. I think we need to select
events carefully even if we do that. And current memcg's percpu stat is mixture
of vm_events and vm_stat. We may need to sort out them and re-design it.
My concern is that I'm not sure we have enough percpu area for vmstat+vmevents
for 1000+ memcg, and it's allowed even if we can do.

But yes, it seems worth to consider.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
