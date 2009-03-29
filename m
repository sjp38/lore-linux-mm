Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7066B003D
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 09:02:04 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2TD1wPT006147
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 18:31:58 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2TCwLGL4378698
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 18:28:22 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2TD1w7L019298
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 00:01:58 +1100
Date: Sun, 29 Mar 2009 18:31:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-ID: <20090329130138.GA15608@balbir.in.ibm.com>
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

I think and I speak for my patches, you should look at soft limit
reclaim as helping global reclaim and not working against it. It
provides an opportunity to reclaim from groups that might not be
important to the system.

> 
>  - Inactive/Active rotation scheme of global LRU will be broken.
> 
>  - File/Anon reclaim ratio scheme of global LRU will be broken.
>     - vm.swappiness will be ignored.
> 

Not true, with my patches none of these are affected since the reclaim
for soft limits is limited to mem cgroup LRU lists only. Zone reclaim
that happens in parallel can of-course change the global LRU.

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

I don't like the results, they are functionaly broken (see my other
email). Why should "B" get reclaimed from if it is not above its soft
limit? Why is there a swapout from "B"?


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

The code seems to add a lot of complexity and does not achieve expected
functionality. I am going to start testing this series soon
 
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
> I'll try much more complexed ones in the weekend.

Please see my response to this test result in a previous email.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
