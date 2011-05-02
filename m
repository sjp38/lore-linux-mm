Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAC66B002E
	for <linux-mm@kvack.org>; Mon,  2 May 2011 02:10:00 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4269qVA004185
	for <linux-mm@kvack.org>; Mon, 2 May 2011 11:39:52 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4269q2V2834616
	for <linux-mm@kvack.org>; Mon, 2 May 2011 11:39:52 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4269p0i011136
	for <linux-mm@kvack.org>; Mon, 2 May 2011 16:09:51 +1000
Date: Mon, 2 May 2011 11:39:49 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
Message-ID: <20110502060949.GN6547@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-04-25 18:25:29]:

> 
> This patch is based on Ying Han's one....at its origin, but I changed too much ;)
> Then, start this as new thread.
> 
> (*) This work is not related to the topic "rewriting global LRU using memcg"
>     discussion, at all. This kind of hi/low watermark has been planned since
>     memcg was born. 
> 
> At first, per-memcg background reclaim is used for
>   - helping memory reclaim and avoid direct reclaim.
>   - set a not-hard limit of memory usage.
> 
> For example, assume a memcg has its hard-limit as 500M bytes.
> Then, set high-watermark as 400M. Here, memory usage can exceed 400M up to 500M
> but memory usage will be reduced automatically to 400M as time goes by.
> 
> This is useful when a user want to limit memory usage to 400M but don't want to
> see big performance regression by hitting limit when memory usage spike happens.
> 
> 1) == hard limit = 400M ==
> [root@rhel6-test hilow]# time cp ./tmpfile xxx                
> real    0m7.353s
> user    0m0.009s
> sys     0m3.280s
>

What do the stats look like (graphed during this period?)
 
> 2) == hard limit 500M/ hi_watermark = 400M ==
> [root@rhel6-test hilow]# time cp ./tmpfile xxx
> 
> real    0m6.421s
> user    0m0.059s
> sys     0m2.707s
> 
What do the stats look like (graphed during this period?) for
comparison. Does the usage extend beyond 400 very often?

> Above is a brief result on VM and needs more study. But my impression is positive.
> I'd like to use bigger real machine in the next time.
> 
> Here is a short list of updates from Ying Han's one.
> 
>  1. use workqueue and visit memcg in round robin.
>  2. only allow setting hi watermark. low-watermark is automatically determined.
>     This is good for avoiding bad cpu usage by background reclaim.
>  3. totally rewrite algorithm of shrink_mem_cgroup for round-robin.
>  4. fixed get_scan_count() , this was problematic.
>  5. added some statistics, which I think necessary.
>  6. added documenation
> 
> Then, the algorithm is not a cut-n-paste from kswapd. I thought kswapd should be
> updated...and 'priority' in vmscan.c seems to be an enemy of memcg ;)
>

Thanks for looking into this. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
