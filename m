Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2U8GH61001215
	for <linux-mm@kvack.org>; Sun, 30 Mar 2008 19:16:17 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2U8GBol2441246
	for <linux-mm@kvack.org>; Sun, 30 Mar 2008 19:16:11 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2U8GA7x032399
	for <linux-mm@kvack.org>; Sun, 30 Mar 2008 18:16:11 +1000
Message-ID: <47EF4B51.20204@linux.vnet.ibm.com>
Date: Sun, 30 Mar 2008 13:42:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][-mm][0/2] page reclaim throttle take4
References: <20080330171152.89D5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080330171152.89D5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> changelog
> ========================================
>   v3 -> v4:
>      o fixed recursive shrink_zone problem.
>      o add last_checked variable in shrink_zone for 
>        prevent corner case regression.
> 
>   v2 -> v3:
>      o use wake_up() instead wake_up_all()
>      o max reclaimers can be changed Kconfig option and sysctl.
>      o some cleanups
> 
>   v1 -> v2:
>      o make per zone throttle 
> 
> 
> background
> =====================================
> current VM implementation doesn't has limit of # of parallel reclaim.
> when heavy workload, it bring to 2 bad things
>   - heavy lock contention
>   - unnecessary swap out
> 
> The end of last year, KAMEZA Hiroyuki proposed the patch of page 
> reclaim throttle and explain it improve reclaim time.
> 	http://marc.info/?l=linux-mm&m=119667465917215&w=2
> 
> but unfortunately it works only memcgroup reclaim.
> Today, I implement it again for support global reclaim and mesure it.
> 
> 
> benefit
> =====================================
> <<1. fix the bug of incorrect OOM killer>>
> 
> if do following commanc, sometimes OOM killer happened.
> (OOM happend about 10%)
> 
>  $ ./hackbench 125 process 1000
> 
> because following bad scenario happend.
> 
>    1. memory shortage happend.
>    2. many task call shrink_zone at the same time.
>    3. all page are isolated from LRU at the same time.
>    4. the last task can't isolate any page from LRU.
>    5. it cause reclaim failure.
>    6. it cause OOM killer.
> 
> my patch is directly solution for that problem.
> 
> 
> <<2. performance improvement>>
> I mesure various parameter of hackbench.
> 
> result number mean seconds (i.e. smaller is better)
> 

The results look quite impressive. Have you seen how your patches integrate with
Rik's LRU changes?

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
