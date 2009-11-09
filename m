Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4466B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 02:07:49 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id nA976CRj018436
	for <linux-mm@kvack.org>; Mon, 9 Nov 2009 18:06:12 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nA977iRi1667248
	for <linux-mm@kvack.org>; Mon, 9 Nov 2009 18:07:44 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nA977hnT010342
	for <linux-mm@kvack.org>; Mon, 9 Nov 2009 18:07:44 +1100
Date: Mon, 9 Nov 2009 12:37:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] memcg : rewrite percpu countings with new
 interfaces
Message-ID: <20091109070737.GE3042@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091106175242.6e13ee29.kamezawa.hiroyu@jp.fujitsu.com>
 <20091106175545.b97ee867.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091106175545.b97ee867.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-11-06 17:55:45]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, alloc_percpu() alloc good dynamic allocations and
> Recent updates on percpu.h gives us following kind of ops 
>    - __this_cpu_add() etc...
> This is designed to be a help for reduce code size in hot-path
> and very useful to handle percpu area. Thanks for great works.
> 
> This patch rewrite memcg's (not-good) percpu status with new
> percpu support macros. This decreases code size and instruction
> size. By this, this area is now NUMA-aware and may have performance 
> benefit. 
> 
> I got good result in parallel pagefault test. (my host is 8cpu/2socket)
> 
> before==
>  Performance counter stats for './runpause.sh' (5 runs):
> 
>   474070.055912  task-clock-msecs         #      7.881 CPUs    ( +-   0.013% )
>        35829310  page-faults              #      0.076 M/sec   ( +-   0.217% )
>      3803016722  cache-references         #      8.022 M/sec   ( +-   0.215% )  (scaled from 100.00%)
>      1104083123  cache-misses             #      2.329 M/sec   ( +-   0.961% )  (scaled from 100.00%)
> 
>    60.154982314  seconds time elapsed   ( +-   0.018% )
> 
> after==
>  Performance counter stats for './runpause.sh' (5 runs):
> 
>   474919.429670  task-clock-msecs         #      7.896 CPUs    ( +-   0.013% )
>        36520440  page-faults              #      0.077 M/sec   ( +-   1.854% )
>      3109834751  cache-references         #      6.548 M/sec   ( +-   0.276% )
>      1053275160  cache-misses             #      2.218 M/sec   ( +-   0.036% )
> 
>    60.146585280  seconds time elapsed   ( +-   0.019% )
> 
> This test is affected by cpu-utilization but I think more improvements
> will be found in bigger system.
>

Hi, Kamezawa-San,

Could you please post the IPC results as well? 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
