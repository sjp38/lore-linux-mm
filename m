Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2059A6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:26:17 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so36706410wmw.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 04:26:17 -0800 (PST)
Received: from mx1.molgen.mpg.de (mx1.molgen.mpg.de. [141.14.17.9])
        by mx.google.com with ESMTPS id 19si54284008wjh.246.2016.11.28.04.26.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 04:26:15 -0800 (PST)
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
References: <20161108183938.GD4127@linux.vnet.ibm.com>
 <9f87f8f0-9d0f-f78f-8dca-993b09b19a69@molgen.mpg.de>
 <20161116173036.GK3612@linux.vnet.ibm.com>
 <20161121134130.GB18112@dhcp22.suse.cz>
 <20161121140122.GU3612@linux.vnet.ibm.com>
 <20161121141818.GD18112@dhcp22.suse.cz>
 <20161121142901.GV3612@linux.vnet.ibm.com>
 <68025f6c-6801-ab46-b0fc-a9407353d8ce@molgen.mpg.de>
 <20161124101525.GB20668@dhcp22.suse.cz> <583AA50A.9010608@molgen.mpg.de>
 <20161128110449.GK14788@dhcp22.suse.cz>
From: Paul Menzel <pmenzel@molgen.mpg.de>
Message-ID: <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
Date: Mon, 28 Nov 2016 13:26:14 +0100
MIME-Version: 1.0
In-Reply-To: <20161128110449.GK14788@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>
Cc: dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

+linux-mm@kvack.org
-linux-xfs@vger.kernel.org

Dear Michal,


Thank you for your reply, and for looking at the log files.

On 11/28/16 12:04, Michal Hocko wrote:
> On Sun 27-11-16 10:19:06, Donald Buczek wrote:
>> On 24.11.2016 11:15, Michal Hocko wrote:
>>> On Mon 21-11-16 16:35:53, Donald Buczek wrote:
>>> [...]
>>>> Hello,
>>>>
>>>> thanks a lot for looking into this!
>>>>
>>>> Let me add some information from the reporting site:
>>>>
>>>> * We've tried the patch from Paul E. McKenney (the one posted Wed, 16 Nov
>>>> 2016)  and it doesn't shut up the rcu stall warnings.
>>>>
>>>> * Log file from a boot with the patch applied ( grep kernel
>>>> /var/log/messages ) is here :
>>>> http://owww.molgen.mpg.de/~buczek/321322/2016-11-21_syslog.txt
>>>>
>>>> * This system is a backup server and walks over thousands of files sometimes
>>>> with multiple parallel rsync processes.
>>>>
>>>> * No rcu_* warnings on that machine with 4.7.2, but with 4.8.4 , 4.8.6 ,
>>>> 4.8.8 and now 4.9.0-rc5+Pauls patch
>>> I assume you haven't tried the Linus 4.8 kernel without any further
>>> stable patches? Just to be sure we are not talking about some later
>>> regression which found its way to the stable tree.
>>
>> We've tried v4.8 and got the first rcu stall warnings with this, too. First
>> one after about 20 hours uptime.
>>
>>
>>>> * When the backups are actually happening there might be relevant memory
>>>> pressure from inode cache and the rsync processes. We saw the oom-killer
>>>> kick in on another machine with same hardware and similar (a bit higher)
>>>> workload. This other machine also shows a lot of rcu stall warnings since
>>>> 4.8.4.
>>>>
>>>> * We see "rcu_sched detected stalls" also on some other machines since we
>>>> switched to 4.8 but not as frequently as on the two backup servers. Usually
>>>> there's "shrink_node" and "kswapd" on the top of the stack. Often
>>>> "xfs_reclaim_inodes" variants on top of that.
>>> I would be interested to see some reclaim tracepoints enabled. Could you
>>> try that out? At least mm_shrink_slab_{start,end} and
>>> mm_vmscan_lru_shrink_inactive. This should tell us more about how the
>>> reclaim behaved.
>>
>> http://owww.molgen.mpg.de/~buczek/321322/2016-11-26.dmesg.txt  (80K)
>> http://owww.molgen.mpg.de/~buczek/321322/2016-11-26.trace.txt (50M)
>>
>> Traces wrapped, but the last event is covered. all vmscan events were
>> enabled
>
> OK, so one of the stall is reported at
> [118077.988410] INFO: rcu_sched detected stalls on CPUs/tasks:
> [118077.988416] 	1-...: (181 ticks this GP) idle=6d5/140000000000000/0 softirq=46417663/46417663 fqs=10691
> [118077.988417] 	(detected by 4, t=60002 jiffies, g=11845915, c=11845914, q=46475)
> [118077.988421] Task dump for CPU 1:
> [118077.988421] kswapd1         R  running task        0    86      2 0x00000008
> [118077.988424]  ffff88080ad87c58 ffff88080ad87c58 ffff88080ad87cf8 ffff88100c1e5200
> [118077.988426]  0000000000000003 0000000000000000 ffff88080ad87e60 ffff88080ad87d90
> [118077.988428]  ffffffff811345f5 ffff88080ad87da0 ffff88100c1e5200 ffff88080ad87dd0
> [118077.988430] Call Trace:
> [118077.988436]  [<ffffffff811345f5>] ? shrink_node_memcg+0x605/0x870
> [118077.988438]  [<ffffffff8113491f>] ? shrink_node+0xbf/0x1c0
> [118077.988440]  [<ffffffff81135642>] ? kswapd+0x342/0x6b0
>
> the interesting part of the traces would be around the same time:
>         clusterd-989   [009] .... 118023.654491: mm_vmscan_direct_reclaim_end: nr_reclaimed=193
>          kswapd1-86    [001] dN.. 118023.987475: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239830 nr_taken=0 file=1
>          kswapd1-86    [001] dN.. 118024.320968: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239844 nr_taken=0 file=1
>          kswapd1-86    [001] dN.. 118024.654375: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239858 nr_taken=0 file=1
>          kswapd1-86    [001] dN.. 118024.987036: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239872 nr_taken=0 file=1
>          kswapd1-86    [001] dN.. 118025.319651: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239886 nr_taken=0 file=1
>          kswapd1-86    [001] dN.. 118025.652248: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239900 nr_taken=0 file=1
>          kswapd1-86    [001] dN.. 118025.984870: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239914 nr_taken=0 file=1
> [...]
>          kswapd1-86    [001] dN.. 118084.274403: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4241133 nr_taken=0 file=1
>
> Note the Need resched flag. The IRQ off part is expected because we are
> holding the LRU lock which is IRQ safe. That is not a problem because
> the lock is only held for SWAP_CLUSTER_MAX pages at maximum. It is also
> interesing to see that we have scanned only 1303 pages during that 1
> minute. That would be dead slow. None of them were good enough for the
> reclaim but that doesn't sound like a problem. The trace simply suggests
> that the reclaim was preempted by something else. Otherwise I cannot
> imagine such a slow scanning.
>
> Is it possible that something else is hogging the CPU and the RCU just
> happens to blame kswapd which is running in the standard user process
> context?

 From looking at the monitoring graphs, there was always enough CPU 
resources available. The machine has 12x E5-2630 @ 2.30GHz. So that 
shouldn?t have been a problem.


Kind regards,

Paul Menzel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
