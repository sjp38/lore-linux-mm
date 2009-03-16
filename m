Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 235FC6B003D
	for <linux-mm@kvack.org>; Sun, 15 Mar 2009 20:11:28 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2G0BPud005964
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 16 Mar 2009 09:11:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EA60A45DE52
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:11:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C47AF45DE4F
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:11:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AC9361DB8041
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:11:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 669361DB8042
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:11:24 +0900 (JST)
Date: Mon, 16 Mar 2009 09:10:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/5] memcg softlimit (Another one) v4
Message-Id: <20090316091002.e34f3eeb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090314185246.GT16897@balbir.in.ibm.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090314185246.GT16897@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, 15 Mar 2009 00:22:46 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 09:52:47]:
> 
> > Hi, this is a patch for implemnt softlimit to memcg.
> > 
> > I did some clean up and bug fixes. 
> > 
> > Anyway I have to look into details of "LRU scan algorithm" after this.
> > 
> > How this works:
> > 
> >  (1) Set softlimit threshold to memcg.
> >      #echo 400M > /cgroups/my_group/memory.softlimit_in_bytes.
> > 
> >  (2) Define priority as victim.
> >      #echo 3 > /cgroups/my_group/memory.softlimit_priority.
> >      0 is the lowest, 8 is the highest.
> >      If "8", softlimit feature ignore this group.
> >      default value is "8".
> > 
> >  (3) Add some memory pressure and make kswapd() work.
> >      kswapd will reclaim memory from victims paying regard to priority.
> > 
> > Simple test on my 2cpu 86-64 box with 1.6Gbytes of memory (...vmware)
> > 
> >   While a process malloc 800MB of memory and touch it and sleep in a group,
> >   run kernel make -j 16 under a victim cgroup with softlimit=300M, priority=3.
> > 
> >   Without softlimit => 400MB of malloc'ed memory are swapped out.
> >   With softlimit    =>  80MB of malloc'ed memory are swapped out. 
> > 
> > I think 80MB of swap is from direct memory reclaim path. And this
> > seems not to be terrible result.
> > 
> > I'll do more test on other hosts. Any comments are welcome.
> 
> Hi, Kamezawa-San,
> 
> I tried some simple tests with this patch and the results are not
> anywhere close to expected.
> 
> 1. My setup is 4GB RAM with 4 CPUs and I boot with numa=fake=4
> 2. I setup my cgroups as follows
>    a. created /a and /b and set memory.use_hierarchy=1
>    b. created /a/x and /b/x, set their memory.softlimit_priority=1
>    c. set softlimit_in_bytes for a/x to 1G and b/x to 2G
>    d. I assigned tasks to a/x and b/x
> 
> I expected the tasks in a/x and b/x to get memory distributed in the
> ratio to 1:2. Here is what I found
> 
> 1. The task in a/x got more memory than the task in b/x even though
>    I started the task in b/x first
> 2. Even changing softlimit_priority (increased for b) did not help much
> 

Thank you, I'll rewrite all. But 1G/2G usage can make kswapd() run on
4GB host ? What memory usage will be just depens on usage per-zone and
if both of a/x, b/x 's usage are always over softlimit,
the result will never be 1:2, because any usage over softlimit 
can be victim and reclaimed in round-robin.
Anyway, softlimit_priority seems to be not good, I'll remove it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
