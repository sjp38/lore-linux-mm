Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 05139900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 06:23:28 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id p3TANBBi024766
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 20:23:11 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3TANB8d2306116
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 20:23:11 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3TAN9DJ016481
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 20:23:11 +1000
Date: Fri, 29 Apr 2011 15:53:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] memcg: add the soft_limit reclaim in global direct
 reclaim
Message-ID: <20110429102307.GJ6547@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1304030226-19332-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-04-28 15:37:04]:

> We recently added the change in global background reclaim which counts the
> return value of soft_limit reclaim. Now this patch adds the similar logic
> on global direct reclaim.
>

Sorry, I missed much of that discussion, I was away. I'll try and
catch up with them soon.
 
> We should skip scanning global LRU on shrink_zone if soft_limit reclaim does
> enough work. This is the first step where we start with counting the nr_scanned
> and nr_reclaimed from soft_limit reclaim into global scan_control.
> 
> The patch is based on mmotm-04-14 and i triggered kernel BUG at mm/vmscan.c:1058!
> 
> [  938.242033] kernel BUG at mm/vmscan.c:1058!
> [  938.242033] invalid opcode: 0000 [#1] SMP.
> [  938.242033] last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/device
> [  938.242033] Pid: 546, comm: kswapd0 Tainted: G        W   2.6.39-smp-direct_reclaim
> [  938.242033] RIP: 0010:[<ffffffff810ed174>]  [<ffffffff810ed174>] isolate_pages_global+0x18c/0x34f
> [  938.242033] RSP: 0018:ffff88082f83bb50  EFLAGS: 00010082
> [  938.242033] RAX: 00000000ffffffea RBX: ffff88082f83bc90 RCX: 0000000000000401
> [  938.242033] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffea001ca653e8
> [  938.242033] RBP: ffff88082f83bc20 R08: 0000000000000000 R09: ffff88085ffb6e00
> [  938.242033] R10: ffff88085ffb73d0 R11: ffff88085ffb6e00 R12: ffff88085ffb6e00
> [  938.242033] R13: ffffea001ca65410 R14: 0000000000000001 R15: ffffea001ca653e8
> [  938.242033] FS:  0000000000000000(0000) GS:ffff88085fd00000(0000) knlGS:0000000000000000
> [  938.242033] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  938.242033] CR2: 00007f5c3405c320 CR3: 0000000001803000 CR4: 00000000000006e0
> [  938.242033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  938.242033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  938.242033] Process kswapd0 (pid: 546, threadinfo ffff88082f83a000, task ffff88082fe52080)
> [  938.242033] Stack:
> [  938.242033]  ffff88085ffb6e00 ffffea0000000002 0000000000000021 0000000000000000
> [  938.242033]  0000000000000000 ffff88082f83bcb8 ffffea00108eec80 ffffea00108eecb8
> [  938.242033]  ffffea00108eecf0 0000000000000004 fffffffffffffffc 0000000000000020
> [  938.242033] Call Trace:
> [  938.242033]  [<ffffffff810ee8a5>] shrink_inactive_list+0x185/0x418
> [  938.242033]  [<ffffffff810366cc>] ? __switch_to+0xea/0x212
> [  938.242033]  [<ffffffff810e8b35>] ? determine_dirtyable_memory+0x1a/0x2c
> [  938.242033]  [<ffffffff810ef19b>] shrink_zone+0x380/0x44d
> [  938.242033]  [<ffffffff810e5188>] ? zone_watermark_ok_safe+0xa1/0xae
> [  938.242033]  [<ffffffff810efbd8>] kswapd+0x41b/0x76b
> [  938.242033]  [<ffffffff810ef7bd>] ? zone_reclaim+0x2fb/0x2fb
> [  938.242033]  [<ffffffff81088569>] kthread+0x82/0x8a
> [  938.242033]  [<ffffffff8141b0d4>] kernel_thread_helper+0x4/0x10
> [  938.242033]  [<ffffffff810884e7>] ? kthread_worker_fn+0x112/0x112
> [  938.242033]  [<ffffffff8141b0d0>] ? gs_change+0xb/0xb

What is gs_change()?

> 
> Thank you Minchan for the pointer. I reverted the following commit and I
> haven't seen the problem with the same operation. I haven't looked deeply
> on the patch yet, but figured it would be a good idea to post the dump.
> The dump looks not directly related to this patchset, but ppl can use it to
> reproduce the problem.
> 
> commit 278df9f451dc71dcd002246be48358a473504ad0
> Author: Minchan Kim <minchan.kim@gmail.com>
> Date:   Tue Mar 22 16:32:54 2011 -0700
> 
>    mm: reclaim invalidated page ASAP
> 
> How to reproduce it, On my 32G of machine
> 1. I create two memcgs and set their hard_limit and soft_limit:
> $echo 20g >A/memory.limit_in_bytes
> $echo 20g >B/memory.limit_in_bytes
> $echo 3g >A/memory.soft_limit_in_bytes
> $echo 3g >B/memory.soft_limit_in_bytes
> 
> 2. Reading a 20g file on each container
> $echo $$ >A/tasks
> $cat /export/hdc3/dd_A/tf0 > /dev/zero
> 
> $echo $$ >B/tasks
> $cat /export/hdc3/dd_B/tf0 > /dev/zero
> 
> 3. Add memory pressure by allocating anon + mlock. And trigger global
> reclaim.
>

I am sorry, but the summary leaves me confused about the patchset. You
mentioned adding memcg scan and reclaim, but then quickly shift focus
to the stacktrace.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
