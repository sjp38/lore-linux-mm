Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAHHcDeE013647
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 12:38:13 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAHHc7jH123632
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 10:38:12 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAHHc7Au003243
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 10:38:07 -0700
Message-ID: <473F26EA.5090808@linux.vnet.ibm.com>
Date: Sat, 17 Nov 2007 23:07:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [8/10]
 changes in vmscan.c
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com> <20071116192536.0a9f2d61.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071116192536.0a9f2d61.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> When using memory controller, there are 2 levels of memory reclaim.
>  1. zone memory reclaim because of system/zone memory shortage.
>  2. memory cgroup memory reclaim because of hitting limit.
> 
> These two can be distinguished by sc->mem_cgroup parameter.
> 
> This patch tries to make memory cgroup reclaim routine avoid affecting
> system/zone memory reclaim. This patch inserts if (!sc->mem_cgroup) and
> hook to memory_cgroup reclaim support functions.
> 
> This patch can be a help for isolating system lru activity and group lru
> activity and shows what additional functions are necessary.
> 
>  * mem_cgroup_calc_mapped_ratio() ... calculate mapped ratio for cgroup.
>  * mem_cgroup_reclaim_imbalance() ... calculate active/inactive balance in
>                                         cgroup.
>  * mem_cgroup_calc_reclaim_active() ... calculate the number of active pages to
>                                 be scanned in this priority in mem_cgroup.
> 
>  * mem_cgroup_calc_reclaim_inactive() ... calculate the number of inactive pages
>                                 to be scanned in this priority in mem_cgroup.
> 
>  * mem_cgroup_all_unreclaimable() .. checks cgroup's page is all unreclaimable
>                                      or not.
>  * mem_cgroup_get_reclaim_priority() ...
>  * mem_cgroup_note_reclaim_priority() ... record reclaim priority (temporal)
>  * mem_cgroup_remember_reclaim_priority()
>                              .... record reclaim priority as
>                                   zone->prev_priority.
>                                   This value is used for calc reclaim_mapped.
> Changelog:
>  - merged calc_reclaim_mapped patch in previous version.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

The overall idea looks good, it brings the two reclaims closer. The one
pending to do for memory controllers is to make the reclaim lumpy
reclaim aware. But at this point, I don't see a need for it, since
we track only order 1 allocations in the memory controller.

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
