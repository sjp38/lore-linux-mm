Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 415CE900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 21:25:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3E1963EE0C8
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 10:25:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2486E45DE55
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 10:25:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F21FB45DE54
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 10:24:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E5E8AE08001
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 10:24:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 86AB3E38005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 10:24:59 +0900 (JST)
Date: Thu, 14 Apr 2011 10:18:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3] Add the pagefault count into memcg stats
Message-Id: <20110414101828.b0f3729b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1104131742250.16515@chino.kir.corp.google.com>
References: <1301419953-2282-1-git-send-email-yinghan@google.com>
	<alpine.DEB.2.00.1104131301180.8140@chino.kir.corp.google.com>
	<20110414085239.a597fb5c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1104131742250.16515@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, 13 Apr 2011 17:47:01 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 14 Apr 2011, KAMEZAWA Hiroyuki wrote:
> 
> > > I'm wondering if we can just modify count_vm_event() directly for 
> > > CONFIG_CGROUP_MEM_RES_CTLR so that we automatically track all vmstat items 
> > > (those in enum vm_event_item) for each memcg.  We could add an array of 
> > > NR_VM_EVENT_ITEMS into each struct mem_cgroup to be incremented on 
> > > count_vm_event() for current's memcg.
> > > 
> > > If that's done, we wouldn't have to add additional calls for every vmstat 
> > > item we want to duplicate from the global counters.
> > > 
> > 
> > Maybe we do that finally.
> > 
> > For now, IIUC, over 50% of VM_EVENTS are needless for memcg (ex. per zone stats)
> > and this array consumes large size of percpu area. I think we need to select
> > events carefully even if we do that. And current memcg's percpu stat is mixture
> > of vm_events and vm_stat. We may need to sort out them and re-design it.
> > My concern is that I'm not sure we have enough percpu area for vmstat+vmevents
> > for 1000+ memcg, and it's allowed even if we can do.
> > 
> 
> What I proposed above was adding an array directly into struct mem_cgroup 
> so that we don't collect the stats percpu, they are incremented directly 
> in the mem_cgroup.  Perhaps if we separated enum vm_event_item out into 
> two separate arrays (those useful only globally and those useful for both 
> global and memcg), then this would be simple.
> 
> Something like
> 
> 	enum vm_event_item {
> 		PGPGIN,
> 		PGPGOUT,
> 		PSWPIN,
> 		PSWPOUT,
> 		...
> 		NR_VM_EVENT_ITEMS,
> 	};
> 
> 	enum vm_global_event_item {
> 		KSWAPD_STEAL = NR_VM_EVENT_ITEMS,
> 		KSWAPD_INODESTEAL,
> 		...
> 	};
> 
> and then in count_vm_event(), check
> 
> 	if (item < NR_VM_EVENT_ITEMS) {
> 		memcg_add_vm_event(mem, item, count);
> 	}
> 
> I don't think we need to be concerned about reordering the global 
> /proc/vmstat to fit this purpose.
> 
Hmm, ok. will try that.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
