Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 35A616B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 23:47:07 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2C3j1kZ019741
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:45:01 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C3lAOc467416
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:47:13 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2C3kq52005821
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:46:52 +1100
Date: Thu, 12 Mar 2009 09:16:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/5] memcg softlimit (Another one) v4
Message-ID: <20090312034647.GA23583@balbir.in.ibm.com>
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
>

I've tested so far by

Creating two cgroups and then 

a. Assigning limits of 1G and 2G and run memory allocation and touch
test
b. Same as (a) with 1G and 1G
c. Same as (a) with 0 and 1G
d. Same as (a) with 0 and 0

More comments in induvidual patches.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
