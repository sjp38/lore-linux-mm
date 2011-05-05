Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AB1DC6B0011
	for <linux-mm@kvack.org>; Thu,  5 May 2011 05:21:59 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id p459GtT5021400
	for <linux-mm@kvack.org>; Thu, 5 May 2011 19:16:55 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p459Llkg2400320
	for <linux-mm@kvack.org>; Thu, 5 May 2011 19:21:47 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p459LgRe020983
	for <linux-mm@kvack.org>; Thu, 5 May 2011 19:21:46 +1000
Date: Thu, 5 May 2011 14:51:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] Eliminate task stack trace duplication.
Message-ID: <20110505092140.GC14830@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1304529244-31051-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1304529244-31051-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-05-04 10:14:04]:

> The problem with small dmesg ring buffer like 512k is that only limited number
> of task traces will be logged. Sometimes we lose important information only
> because of too many duplicated stack traces.
> 
> This patch tries to reduce the duplication of task stack trace in the dump
> message by hashing the task stack. The hashtable is a 32k pre-allocated buffer
> during bootup. Then we hash the task stack with stack_depth 32 for each stack
> entry. Each time if we find the identical task trace in the task stack, we dump
> only the pid of the task which has the task trace dumped. So it is easy to back
> track to the full stack with the pid.
> 
> [   58.469730] kworker/0:0     S 0000000000000000     0     4      2 0x00000000
> [   58.469735]  ffff88082fcfde80 0000000000000046 ffff88082e9d8000 ffff88082fcfc010
> [   58.469739]  ffff88082fce9860 0000000000011440 ffff88082fcfdfd8 ffff88082fcfdfd8
> [   58.469743]  0000000000011440 0000000000000000 ffff88082fcee180 ffff88082fce9860
> [   58.469747] Call Trace:
> [   58.469751]  [<ffffffff8108525a>] worker_thread+0x24b/0x250
> [   58.469754]  [<ffffffff8108500f>] ? manage_workers+0x192/0x192
> [   58.469757]  [<ffffffff810885bd>] kthread+0x82/0x8a
> [   58.469760]  [<ffffffff8141aed4>] kernel_thread_helper+0x4/0x10
> [   58.469763]  [<ffffffff8108853b>] ? kthread_worker_fn+0x112/0x112
> [   58.469765]  [<ffffffff8141aed0>] ? gs_change+0xb/0xb
> [   58.469768] kworker/u:0     S 0000000000000004     0     5      2 0x00000000
> [   58.469773]  ffff88082fcffe80 0000000000000046 ffff880800000000 ffff88082fcfe010
> [   58.469777]  ffff88082fcea080 0000000000011440 ffff88082fcfffd8 ffff88082fcfffd8
> [   58.469781]  0000000000011440 0000000000000000 ffff88082fd4e9a0 ffff88082fcea080
> [   58.469785] Call Trace:
> [   58.469786] <Same stack as pid 4>
> [   58.470235] kworker/0:1     S 0000000000000000     0    13      2 0x00000000
> [   58.470255]  ffff88082fd3fe80 0000000000000046 ffff880800000000 ffff88082fd3e010
> [   58.470279]  ffff88082fcee180 0000000000011440 ffff88082fd3ffd8 ffff88082fd3ffd8
> [   58.470301]  0000000000011440 0000000000000000 ffffffff8180b020 ffff88082fcee180
> [   58.470325] Call Trace:
> [   58.470332] <Same stack as pid 4>

Given that pid's can be reused, I wonder if in a large time window the
output can be confusing? The dmesg ring buffer can be scaled with a
config option .. (CONFIG_LOG_BUF_LEN??)

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
