Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AAD8C6B003D
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 04:23:52 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2S7qTu6031672
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 13:22:29 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2S8KXt42072780
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 13:50:33 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2S8O898010602
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 19:24:08 +1100
Date: Sat, 28 Mar 2009 13:53:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-ID: <20090328082350.GS24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 13:59:33]:

> Hi,
> 
> Memory cgroup's soft limit feature is a feature to tell global LRU 
> "please reclaim from this memcg at memory shortage".
> 
> And Balbir's one and my one was proposed.
> This is new one. (so restart from v1), this is very new-born.
> 
> While testing soft limit, my dilemma was following.
> 
>  - needs additional cost of can if implementation is naive (unavoidable?)
> 
>  - Inactive/Active rotation scheme of global LRU will be broken.
> 
>  - File/Anon reclaim ratio scheme of global LRU will be broken.
>     - vm.swappiness will be ignored.
> 
>  - If using memcg's memory reclaim routine, 
>     - shrink_slab() will be never called.
>     - stale SwapCache has no chance to be reclaimed (stale SwapCache means
>       readed but not used one.)
>     - memcg can have no memory in a zone.
>     - memcg can have no Anon memory
>     - lumpty_reclaim() is not called.
> 
> 
> This patch tries to avoid to use existing memcg's reclaim routine and
> just tell "Hints" to global LRU. This patch is briefly tested and shows
> good result to me. (But may not to you. plz brame me.)
> 
> Major characteristic is.
>  - memcg will be inserted to softlimit-queue at charge() if usage excess
>    soft limit.
>  - softlimit-queue is a queue with priority. priority is detemined by size
>    of excessing usage.
>  - memcg's soft limit hooks is called by shrink_xxx_list() to show hints.
>  - Behavior is affected by vm.swappiness and LRU scan rate is determined by
>    global LRU's status.
> 
> I'm sorry that I'm tend not to tell enough explanation.  plz ask me.
> There will be much discussion points, anyway. As usual, I'm not in hurry.
> 
> 
> ==brief test result==
> On 2CPU/1.6GB bytes machine. create group A and B
>   A.  soft limit=300M
>   B.  no soft limit
> 
>   Run a malloc() program on B and allcoate 1G of memory. The program just
>   sleeps after allocating memory and no memory refernce after it.
>   Run make -j 6 and compile the kernel.
> 
>   When vm.swappiness = 60  => 60MB of memory are swapped out from B.
>   When vm.swappiness = 10  => 1MB of memory are swapped out from B    
> 
>   If no soft limit, 350MB of swap out will happen from B.(swapiness=60)
> 

How did you calculate the swap usage of group B?

> I'll try much more complexed ones in the weekend.

You might want to try experiments where the group with the higher soft
limit starts much later than the group with lower soft limit and both
have a high demand for memory. Also try corner cases such as soft
limits being 0, or groups where soft limits are equal, etc.

We have a long weekend, so I've been unable to test/review your
patches. I'll do so soon if possible.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
