Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 314016B0088
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 06:37:42 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n95AbZsS002402
	for <linux-mm@kvack.org>; Mon, 5 Oct 2009 16:07:35 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n95AbY4a2584778
	for <linux-mm@kvack.org>; Mon, 5 Oct 2009 16:07:34 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n95AbYkx029739
	for <linux-mm@kvack.org>; Mon, 5 Oct 2009 21:37:34 +1100
Date: Mon, 5 Oct 2009 16:07:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] memcg: improving scalability by reducing lock
 contention at charge/uncharge
Message-ID: <20091005103733.GC3036@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091002135531.3b5abf5c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091002135531.3b5abf5c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-10-02 13:55:31]:

> Hi,
> 
> This patch is against mmotm + softlimit fix patches.
> (which are now in -rc git tree.)
> 
> In the latest -rc series, the kernel avoids accessing res_counter when
> cgroup is root cgroup. This helps scalabilty when memcg is not used.
> 
> It's necessary to improve scalabilty even when memcg is used. This patch
> is for that. Previous Balbir's work shows that the biggest obstacles for
> better scalabilty is memcg's res_counter. Then, there are 2 ways.
> 
> (1) make counter scale well.
> (2) avoid accessing core counter as much as possible.
> 
> My first direction was (1). But no, there is no counter which is free
> from false sharing when it needs system-wide fine grain synchronization.
> And res_counter has several functionality...this makes (1) difficult.
> spin_lock (in slow path) around counter means tons of invalidation will
> happen even when we just access counter without modification.
> 
> This patch series is for (2). This implements charge/uncharge in bached manner.
> This coalesces access to res_counter at charge/uncharge using nature of
> access locality.
> 
> Tested for a month. And I got good reorts from Balbir and Nishimura, thanks.
> One concern is that this adds some members to the bottom of task_struct.
> Better idea is welcome.
> 
> Following is test result of continuous page-fault on my 8cpu box(x86-64).
> 
> A loop like this runs on all cpus in parallel for 60secs. 
> ==
>         while (1) {
>                 x = mmap(NULL, MEGA, PROT_READ|PROT_WRITE,
>                         MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
> 
>                 for (off = 0; off < MEGA; off += PAGE_SIZE)
>                         x[off]=0;
>                 munmap(x, MEGA);
>         }
> ==
> please see # of page faults. I think this is good improvement.
> 
> 
> [Before]
>  Performance counter stats for './runpause.sh' (5 runs):
> 
>   474539.756944  task-clock-msecs         #      7.890 CPUs    ( +-   0.015% )
>           10284  context-switches         #      0.000 M/sec   ( +-   0.156% )
>              12  CPU-migrations           #      0.000 M/sec   ( +-   0.000% )
>        18425800  page-faults              #      0.039 M/sec   ( +-   0.107% )
>   1486296285360  cycles                   #   3132.080 M/sec   ( +-   0.029% )
>    380334406216  instructions             #      0.256 IPC     ( +-   0.058% )
>      3274206662  cache-references         #      6.900 M/sec   ( +-   0.453% )
>      1272947699  cache-misses             #      2.682 M/sec   ( +-   0.118% )
> 
>    60.147907341  seconds time elapsed   ( +-   0.010% )
> 
> [After]
>  Performance counter stats for './runpause.sh' (5 runs):
> 
>   474658.997489  task-clock-msecs         #      7.891 CPUs    ( +-   0.006% )
>           10250  context-switches         #      0.000 M/sec   ( +-   0.020% )
>              11  CPU-migrations           #      0.000 M/sec   ( +-   0.000% )
>        33177858  page-faults              #      0.070 M/sec   ( +-   0.152% )
>   1485264748476  cycles                   #   3129.120 M/sec   ( +-   0.021% )
>    409847004519  instructions             #      0.276 IPC     ( +-   0.123% )
>      3237478723  cache-references         #      6.821 M/sec   ( +-   0.574% )
>      1182572827  cache-misses             #      2.491 M/sec   ( +-   0.179% )
> 
>    60.151786309  seconds time elapsed   ( +-   0.014% )
>

I agree, I liked the previous patchset, let me re-review this one!
Definitely a good candidate to -mm. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
