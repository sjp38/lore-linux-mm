Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id m639FjdO1269814
	for <linux-mm@kvack.org>; Thu, 3 Jul 2008 19:15:45 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6397QiY227796
	for <linux-mm@kvack.org>; Thu, 3 Jul 2008 19:07:27 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6397Qxx016180
	for <linux-mm@kvack.org>; Thu, 3 Jul 2008 19:07:26 +1000
Message-ID: <486C96C8.5070104@linux.vnet.ibm.com>
Date: Thu, 03 Jul 2008 14:37:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] [0/7] misc memcg patch set
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi, it seems vmm-related bugs in -mm is reduced to some safe level.
> I restarted my patches for memcg.
> 
> This mail is just for dumping patches on my stack.
> (I'll resend one by one later.)
> 
> based on 2.6.26-rc5-mm3
> + kosaki's fixes + cgroup write_string set + Hugh Dickins's fixes for shmem
> (All patches are in -mm queue.)
> 
> Any comments are welcome (but 7/7 patch is not so neat...)
> 
> [1/7] swapcache handle fix for shmem.
> [2/7] adjust to split-lru: remove PAGE_CGROUP_FLAG_CACHE flag. 
> [3/7] adjust to split-lru: push shmem's page to active list
>       (Imported from Hugh Dickins's work.)
> [4/7] reduce usage at change limit. res_counter part.
> [5/7] reduce usage at change limit. memcg part.
> [6/7] memcg-background-job.           res_coutner part
> [7/7] memcg-background-job            memcg part.
> 
> Balbir, I'd like to import your idea of soft-limit to memcg-background-job
> patch set. (Maybe better than adding hooks to very generic part.)
> How do you think ?
> 

I am all for integration. My only requirement is that I want to reclaim from a
node when there is system memory contention. The soft limit patches touch the
generic infrastructure, just barely to indicate that we should look at
reclaiming from controllers over their soft limit.

> Other patches in plan (including other guy's)
> - soft-limit (Balbir works.)
>   I myself think memcg-background-job patches can copperative with this.
> 

That'll be nice thing to do. I am planning on a new version of the soft limit
patches soon (but due to data structure experimentation, it's taking me longer
to get done).

> - dirty_ratio for memcg. (haven't written at all)
>   Support dirty_ratio for memcg. This will improve OOM avoidance.
> 

OK, might be worth doing

> - swapiness for memcg (had patches..but have to rewrite.)
>   Support swapiness per memcg. (of no use ?)
> 

OK, Might be worth doing

> - swap_controller (Maybe Nishimura works on.)
>   The world may change after this...cgroup without swap can appears easily.
> 

I see a swap controller and swap namespace emerging, we'll need to see how they
work. The swap controller is definitely important

> - hierarchy (needs more discussion. maybe after OLS?)
>   have some pathes, but not in hurry.
> 

Same here, not in a hurry, but I think it will help define full functionality

> - more performance improvements (we need some trick.)
>   = Can we remove lock_page_cgroup() ?

We exchanged some early patches on this. We'll get back to it after the things
above.

>   = Can we reduce spinlocks ?
> 

Yes and most of our work happens under irqs disabled. We'll need to investigate
a bit more.

> - move resource at task move (needs helps from cgroup)
>   We need some magical way. It seems impossible to implement this only by memcg.
> 

I have some ideas on this. May be we can discuss this in the OLS BoF or on
email. This is low priority at the moment.

> - NUMA statistics (needs helps from cgroup)
>   It seems dynamic file creation feature or some rule to show array of
>   statistics should be defined.
> 
> - memory guarantee (soft-mlock.)
>   guard parameter against global LRU for saying "Don't reclaim from me more ;("
>   Maybe HA Linux people will want this....
> 

This is  hard goal to achieve, since we do have unreclaimable memory. Guarantees
would probably imply reservation of resources. Water marks might be a better way
to do it.

> Do you have others ?
> 

I think that should be it (it covers most if not all the documented TODOs we have)



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
