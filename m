Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mA66xluW023184
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 17:59:47 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA66sHoC252690
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 17:54:17 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA66sGwR015071
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 17:54:16 +1100
Message-ID: <49129493.9070103@linux.vnet.ibm.com>
Date: Thu, 06 Nov 2008 12:24:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/6] memcg updates (05/Nov)
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Weekly (RFC) update for memcg.
> 
> This set includes
> 
> 1. change force_empty to do move account rather than forget all

I would like this to be selectable, please. We don't want to break behaviour and
not everyone would like to pay the cost of movement.

> 2. swap cache handling
> 3. mem+swap controller kconfig
> 4. swap_cgroup for rememver swap account information
> 5. mem+swap controller core
> 6. synchronize memcg's LRU and global LRU.
> 
> "1" is already sent, "6" is a newcomer.
> I'd like to push out "2" or "2-5" in the next week (if no bugs.)
> 
> after 6, next candidates are
>   - dirty_ratio handler
>   - account move at task move.
> 
> Some more explanation about purpose of "6". (see details in patch itself)
> Now, one of complicated logic in memcg is LRU handling. Because the place of
> lru_head depends on page_cgroup->mem_cgroup pointer, we have to take
> lock as following even under zone->lru_lock.
> ==
>   pc = lookup_page_cgroup(page);
>   if (!trylock_page_cgroup(pc))
>   	return -EBUSY;
> 
>    if (PageCgroupUsed(pc)) {
> 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
> 	spin_lock_irqsave(&mz->lru_lock, flags);
> 	....some operation on LRU.
> 	spin_unlock_irqrestore(&mz->lru_lock, flags);
>    }
>    unlock_page_cgroup(pc);
> ==
> Sigh..
> 
> After "6", page_cgroup's LRU management can be done independently to some extent.
> == as
>   (zone->lru_lock is held here)
>   pc = lookup_page_cgroup(page);
>   list operation on pc.
>   (unlock zone->lru_lock)
> ==
> Maybe good for maintainance and as a bonus, we can make use of isolate_lru_page() when
> doing some racy operation.
> 
> 	isolate_lru_page(page);
> 	pc = lookup_page_cgroup(page);
> 	do some jobs.
> 	putback_lru_page(page);
> 
> Maybe this will be a help to implement "account move at task move".

Sounds promising!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
