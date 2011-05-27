Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 645506B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 04:08:42 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4R88TsD019421
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:38:29 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4R88TIl4632586
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:38:29 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4R88SAa028682
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:08:29 +1000
Date: Fri, 27 May 2011 13:34:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: add pgfault latency histograms
Message-ID: <20110527080417.GG3440@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1306444069-5094-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1306444069-5094-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-05-26 14:07:49]:

> This adds histogram to capture pagefault latencies on per-memcg basis. I used
> this patch on the memcg background reclaim test, and figured there could be more
> usecases to monitor/debug application performance.
> 
> The histogram is composed 8 bucket in ns unit. The last one is infinite (inf)
> which is everything beyond the last one. To be more flexible, the buckets can
> be reset and also each bucket is configurable at runtime.
> 

inf is a bit confusing for page faults -- no? Why not call it "rest"
or something line "> 38400". BTW, why was 600 used as base?

> memory.pgfault_histogram: exports the histogram on per-memcg basis and also can
> be reset by echoing "reset". Meantime, all the buckets are writable by echoing
> the range into the API. see the example below.
> 
> /proc/sys/vm/pgfault_histogram: the global sysfs tunablecan be used to turn
> on/off recording the histogram.
>

Why not make this per memcg?
 
> Functional Test:
> Create a memcg with 10g hard_limit, running dd & allocate 8g anon page.
> Measure the anon page allocation latency.
> 
> $ mkdir /dev/cgroup/memory/B
> $ echo 10g >/dev/cgroup/memory/B/memory.limit_in_bytes
> $ echo $$ >/dev/cgroup/memory/B/tasks
> $ dd if=/dev/zero of=/export/hdc3/dd/tf0 bs=1024 count=20971520 &
> $ allocate 8g anon pages
> 
> $ echo 1 >/proc/sys/vm/pgfault_histogram
> 
> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> pgfault latency histogram (ns):
> < 600            2051273
> < 1200           40859
> < 2400           4004
> < 4800           1605
> < 9600           170
> < 19200          82
> < 38400          6
> < inf            0
> 
> $ echo reset >/dev/cgroup/memory/B/memory.pgfault_histogram

Can't we use something like "-1" to mean reset?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
