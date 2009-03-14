Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 23CC76B003D
	for <linux-mm@kvack.org>; Sat, 14 Mar 2009 14:53:24 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2EIr3Bx005503
	for <linux-mm@kvack.org>; Sun, 15 Mar 2009 00:23:03 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2EIr11s4444318
	for <linux-mm@kvack.org>; Sun, 15 Mar 2009 00:23:01 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2EIqrrh019493
	for <linux-mm@kvack.org>; Sun, 15 Mar 2009 05:52:53 +1100
Date: Sun, 15 Mar 2009 00:22:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/5] memcg softlimit (Another one) v4
Message-ID: <20090314185246.GT16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 09:52:47]:

> Hi, this is a patch for implemnt softlimit to memcg.
> 
> I did some clean up and bug fixes. 
> 
> Anyway I have to look into details of "LRU scan algorithm" after this.
> 
> How this works:
> 
>  (1) Set softlimit threshold to memcg.
>      #echo 400M > /cgroups/my_group/memory.softlimit_in_bytes.
> 
>  (2) Define priority as victim.
>      #echo 3 > /cgroups/my_group/memory.softlimit_priority.
>      0 is the lowest, 8 is the highest.
>      If "8", softlimit feature ignore this group.
>      default value is "8".
> 
>  (3) Add some memory pressure and make kswapd() work.
>      kswapd will reclaim memory from victims paying regard to priority.
> 
> Simple test on my 2cpu 86-64 box with 1.6Gbytes of memory (...vmware)
> 
>   While a process malloc 800MB of memory and touch it and sleep in a group,
>   run kernel make -j 16 under a victim cgroup with softlimit=300M, priority=3.
> 
>   Without softlimit => 400MB of malloc'ed memory are swapped out.
>   With softlimit    =>  80MB of malloc'ed memory are swapped out. 
> 
> I think 80MB of swap is from direct memory reclaim path. And this
> seems not to be terrible result.
> 
> I'll do more test on other hosts. Any comments are welcome.

Hi, Kamezawa-San,

I tried some simple tests with this patch and the results are not
anywhere close to expected.

1. My setup is 4GB RAM with 4 CPUs and I boot with numa=fake=4
2. I setup my cgroups as follows
   a. created /a and /b and set memory.use_hierarchy=1
   b. created /a/x and /b/x, set their memory.softlimit_priority=1
   c. set softlimit_in_bytes for a/x to 1G and b/x to 2G
   d. I assigned tasks to a/x and b/x

I expected the tasks in a/x and b/x to get memory distributed in the
ratio to 1:2. Here is what I found

1. The task in a/x got more memory than the task in b/x even though
   I started the task in b/x first
2. Even changing softlimit_priority (increased for b) did not help much


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
