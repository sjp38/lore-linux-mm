Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l92DZnhw008053
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 23:35:49 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l92DYN3u4771946
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 23:34:23 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l92DYMWc023492
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 23:34:23 +1000
Message-ID: <470248D7.5090403@linux.vnet.ibm.com>
Date: Tue, 02 Oct 2007 19:04:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [BUGFIX][RFC][PATCH][only -mm] FIX memory leak in memory cgroup
 vs. page migration [0/1]
References: <20071002183031.3352be6a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071002183031.3352be6a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Current implementation of memory cgroup controller does following in migration.
> 
> 1. uncharge when unmapped.
> 2. charge again when remapped.
> 
> Consider migrate a page from OLD to NEW.
> 
> In following case, memory (for page_cgroup) will leak.
> 
> 1. charge OLD page as page-cache. (charge = 1
> 2. A process mmap OLD page. (chage + 1 = 2)
> 3. A process migrates it.
>    try_to_unmap(OLD) (charge - 1 = 1)
>    replace OLD with NEW
>    remove_migration_pte(NEW) (New is newly charged.)
>    discard OLD page. (page_cgroup for OLD page is not reclaimed.)
> 

Interesting test scenario, I'll try and reproduce the problem here.
Why does discard OLD page not reclaim page_cgroup?

> patch is in the next mail.
> 

Thanks

> Test Log on 2.6.18-rc8-mm2.
> ==
> # mount cgroup and create group_A group_B
> [root@drpq kamezawa]# mount -t cgroup none /opt/mem_control/ -o memory
> [root@drpq kamezawa]# mkdir /opt/mem_control/group_A/
> [root@drpq kamezawa]# mkdir /opt/mem_control/group_B/
> [root@drpq kamezawa]# bash
> [root@drpq kamezawa]# echo $$ > /opt/mem_control/group_A/tasks
> [root@drpq kamezawa]# cat /opt/mem_control/group_A/memory.usage_in_bytes
> 475136
> [root@drpq kamezawa]# grep size-64 /proc/slabinfo
> size-64(DMA)           0      0     64  240    1 : tunables  120   60    8 : slabdata      0      0      0
> size-64            30425  30960     64  240    1 : tunables  120   60    8 : slabdata    129    129     12
> 
> # charge file cache 512Mfile to groupA
> [root@drpq kamezawa]# cat 512Mfile > /dev/null
> [root@drpq kamezawa]# cat /opt/mem_control/group_A/memory.usage_in_bytes
> 539525120
> 
> # for test, try drop_caches. drop_cache works well and chage decreased.
> [root@drpq kamezawa]# echo 3 > /proc/sys/vm/drop_caches
> [root@drpq kamezawa]# cat /opt/mem_control/group_A/memory.usage_in_bytes
> 983040
> 
> # chage file cache 512Mfile again.
> [root@drpq kamezawa]# taskset 01 cat 512Mfile > /dev/null
> [root@drpq kamezawa]# exit
> exit
> [root@drpq kamezawa]# cat /opt/mem_control/group_?/memory.usage_in_bytes
> 539738112
> 0
> [root@drpq kamezawa]# bash
> #enter group B
> [root@drpq kamezawa]# echo $$ > /opt/mem_control/group_B/tasks
> [root@drpq kamezawa]# cat /opt/mem_control/group_?/memory.usage_in_bytes
> 539738112
> 557056
> [root@drpq kamezawa]#  grep size-64 /proc/slabinfo
> size-64(DMA)           0      0     64  240    1 : tunables  120   60    8 : slabdata      0      0      0
> size-64            48263  59760     64  240    1 : tunables  120   60    8 : slabdata    249    249     12
> # migrate_test mmaps 512Mfile and call system call move_pages(). and sleep.
> [root@drpq kamezawa]# ./migrate_test 512Mfile 1 &
> [1] 4108
> #At the end of migration,

Where can I find migrate_test?

> [root@drpq kamezawa]# cat /opt/mem_control/group_?/memory.usage_in_bytes
> 539738112
> 537706496
> 
> #Wow, charge is twice ;)
> [root@drpq kamezawa]#  grep size-64 /proc/slabinfo
> size-64(DMA)           0      0     64  240    1 : tunables  120   60    8 : slabdata      0      0      0
> size-64            81180  92400     64  240    1 : tunables  120   60    8 : slabdata    385    385     12
> 
> #Kill migrate_test, because 512Mfile is unmapped, charge in group_B is dropped.
> [root@drpq kamezawa]# kill %1
> [root@drpq kamezawa]# cat /opt/mem_control/group_?/memory.usage_in_bytes
> 536936448
> 1458176
> [1]+  Terminated              ./migrate_test 512Mfile 1
> 
> #Try drop caches again
> [root@drpq kamezawa]# echo 3 > /proc/sys/vm/drop_caches
> [root@drpq kamezawa]# cat /opt/mem_control/group_?/memory.usage_in_bytes
> 536920064
> 1097728
> #no change because charge in group_A is leaked.....
> 
> [root@drpq kamezawa]#  grep size-64 /proc/slabinfo
> size-64(DMA)           0      0     64  240    1 : tunables  120   60    8 : slabdata      0      0      0
> size-64            48137  60720     64  240    1 : tunables  120   60    8 : slabdata    253    253    210
> [root@drpq kamezawa]#
> 
> ==
> 
> -Kame
> 


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
