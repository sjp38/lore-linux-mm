Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E20F3900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 20:47:08 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3E0l4VR013276
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:47:05 -0700
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by wpaz5.hot.corp.google.com with ESMTP id p3E0l1sP017025
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:47:03 -0700
Received: by pvh11 with SMTP id 11so512984pvh.36
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:47:03 -0700 (PDT)
Date: Wed, 13 Apr 2011 17:47:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V3] Add the pagefault count into memcg stats
In-Reply-To: <20110414085239.a597fb5c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104131742250.16515@chino.kir.corp.google.com>
References: <1301419953-2282-1-git-send-email-yinghan@google.com> <alpine.DEB.2.00.1104131301180.8140@chino.kir.corp.google.com> <20110414085239.a597fb5c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, 14 Apr 2011, KAMEZAWA Hiroyuki wrote:

> > I'm wondering if we can just modify count_vm_event() directly for 
> > CONFIG_CGROUP_MEM_RES_CTLR so that we automatically track all vmstat items 
> > (those in enum vm_event_item) for each memcg.  We could add an array of 
> > NR_VM_EVENT_ITEMS into each struct mem_cgroup to be incremented on 
> > count_vm_event() for current's memcg.
> > 
> > If that's done, we wouldn't have to add additional calls for every vmstat 
> > item we want to duplicate from the global counters.
> > 
> 
> Maybe we do that finally.
> 
> For now, IIUC, over 50% of VM_EVENTS are needless for memcg (ex. per zone stats)
> and this array consumes large size of percpu area. I think we need to select
> events carefully even if we do that. And current memcg's percpu stat is mixture
> of vm_events and vm_stat. We may need to sort out them and re-design it.
> My concern is that I'm not sure we have enough percpu area for vmstat+vmevents
> for 1000+ memcg, and it's allowed even if we can do.
> 

What I proposed above was adding an array directly into struct mem_cgroup 
so that we don't collect the stats percpu, they are incremented directly 
in the mem_cgroup.  Perhaps if we separated enum vm_event_item out into 
two separate arrays (those useful only globally and those useful for both 
global and memcg), then this would be simple.

Something like

	enum vm_event_item {
		PGPGIN,
		PGPGOUT,
		PSWPIN,
		PSWPOUT,
		...
		NR_VM_EVENT_ITEMS,
	};

	enum vm_global_event_item {
		KSWAPD_STEAL = NR_VM_EVENT_ITEMS,
		KSWAPD_INODESTEAL,
		...
	};

and then in count_vm_event(), check

	if (item < NR_VM_EVENT_ITEMS) {
		memcg_add_vm_event(mem, item, count);
	}

I don't think we need to be concerned about reordering the global 
/proc/vmstat to fit this purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
