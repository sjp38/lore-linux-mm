Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id DD66A6B02A1
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 20:38:47 -0500 (EST)
Received: by yhoo21 with SMTP id o21so1109005yho.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 17:38:47 -0800 (PST)
Date: Tue, 13 Dec 2011 17:38:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 1/3] slub: set a criteria for slub node partial adding
In-Reply-To: <6E3BC7F7C9A4BF4286DD4C043110F30B67236EED18@shsmsx502.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1112131734070.8593@chino.kir.corp.google.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com> <alpine.DEB.2.00.1112020842280.10975@router.home> <1323419402.16790.6105.camel@debian> <alpine.DEB.2.00.1112090203370.12604@chino.kir.corp.google.com>
 <6E3BC7F7C9A4BF4286DD4C043110F30B67236EED18@shsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Alex" <alex.shi@intel.com>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Eric Dumazet <eric.dumazet@gmail.com>

On Fri, 9 Dec 2011, Shi, Alex wrote:

> Of course any testing may have result variation. But it is benchmark 
> accordingly, and there are lot technical to tuning your testing to make 
> its stand division acceptable, like to sync your system in a clear 
> status, to close unnecessary services, to use separate working disks for 
> your testing etc. etc. For this data, like on my SNB-EP machine, (the 
> following data is not stands for Intel, it is just my personal data). 

I always run benchmarks with freshly booted machines and disabling all but 
the most basic and required userspace for my testing environment, I can 
assure you that my comparison of slab and slub on netperf TCP_RR isn't 
because of any noise from userspace.

> 4 times result of hackbench on this patch are 5.59, 5.475, 5.47833, 
> 5.504

I haven't been running hackbench benchmarks, sorry.  I was always under 
the assumption that slub still was slightly better than slab with 
hackbench since that was used as justification for it becoming the default 
allocator and also because Christoph had patches merged recently which 
improved its performance on slub.  I've been speaking only about my 
history with netperf TCP_RR when using slub.

> > Not sure what you're asking me to test, you would like this:
> > 
> > 	{
> > 	        n->nr_partial++;
> > 	-       if (tail == DEACTIVATE_TO_TAIL)
> > 	-               list_add_tail(&page->lru, &n->partial);
> > 	-       else
> > 	-               list_add(&page->lru, &n->partial);
> > 	+       list_add_tail(&page->lru, &n->partial);
> > 	}
> > 
> > with the statistics patch above?  I typically run with CONFIG_SLUB_STATS
> > disabled since it impacts performance so heavily and I'm not sure what
> > information you're looking for with regards to those stats.
> 
> NO, when you collect data, please close SLUB_STAT in kernel config.  
> _to_head statistics collection patch just tell you, I collected the 
> statistics not include add_partial in early_kmem_cache_node_alloc(). And 
> other places of add_partial were covered. Of course, the kernel with 
> statistic can not be used to measure performance. 
> 

Ok, I'll benchmark netperf TCP_RR comparing Linus' latest -git both with 
and without the above change.  It was confusing because you had three 
diffs in your email, I wasn't sure which or combination of which you 
wanted me to try :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
