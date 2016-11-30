Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71A686B025E
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 05:28:37 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xy5so31673428wjc.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 02:28:37 -0800 (PST)
Received: from mx1.molgen.mpg.de (mx1.molgen.mpg.de. [141.14.17.9])
        by mx.google.com with ESMTPS id dp20si6751984wjb.2.2016.11.30.02.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 02:28:36 -0800 (PST)
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
 <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
From: Donald Buczek <buczek@molgen.mpg.de>
Message-ID: <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
Date: Wed, 30 Nov 2016 11:28:34 +0100
MIME-Version: 1.0
In-Reply-To: <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On 11/28/16 13:26, Paul Menzel wrote:
> [...]
>
> On 11/28/16 12:04, Michal Hocko wrote:
>> [...]
>>
>> OK, so one of the stall is reported at
>> [118077.988410] INFO: rcu_sched detected stalls on CPUs/tasks:
>> [118077.988416]     1-...: (181 ticks this GP) 
>> idle=6d5/140000000000000/0 softirq=46417663/46417663 fqs=10691
>> [118077.988417]     (detected by 4, t=60002 jiffies, g=11845915, 
>> c=11845914, q=46475)
>> [118077.988421] Task dump for CPU 1:
>> [118077.988421] kswapd1         R  running task        0 86      2 
>> 0x00000008
>> [118077.988424]  ffff88080ad87c58 ffff88080ad87c58 ffff88080ad87cf8 
>> ffff88100c1e5200
>> [118077.988426]  0000000000000003 0000000000000000 ffff88080ad87e60 
>> ffff88080ad87d90
>> [118077.988428]  ffffffff811345f5 ffff88080ad87da0 ffff88100c1e5200 
>> ffff88080ad87dd0
>> [118077.988430] Call Trace:
>> [118077.988436]  [<ffffffff811345f5>] ? shrink_node_memcg+0x605/0x870
>> [118077.988438]  [<ffffffff8113491f>] ? shrink_node+0xbf/0x1c0
>> [118077.988440]  [<ffffffff81135642>] ? kswapd+0x342/0x6b0
>>
>> the interesting part of the traces would be around the same time:
>>         clusterd-989   [009] .... 118023.654491: 
>> mm_vmscan_direct_reclaim_end: nr_reclaimed=193
>>          kswapd1-86    [001] dN.. 118023.987475: 
>> mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 
>> nr_requested=32 nr_scanned=4239830 nr_taken=0 file=1
>>          kswapd1-86    [001] dN.. 118024.320968: 
>> mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 
>> nr_requested=32 nr_scanned=4239844 nr_taken=0 file=1
>>          kswapd1-86    [001] dN.. 118024.654375: 
>> mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 
>> nr_requested=32 nr_scanned=4239858 nr_taken=0 file=1
>>          kswapd1-86    [001] dN.. 118024.987036: 
>> mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 
>> nr_requested=32 nr_scanned=4239872 nr_taken=0 file=1
>>          kswapd1-86    [001] dN.. 118025.319651: 
>> mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 
>> nr_requested=32 nr_scanned=4239886 nr_taken=0 file=1
>>          kswapd1-86    [001] dN.. 118025.652248: 
>> mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 
>> nr_requested=32 nr_scanned=4239900 nr_taken=0 file=1
>>          kswapd1-86    [001] dN.. 118025.984870: 
>> mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 
>> nr_requested=32 nr_scanned=4239914 nr_taken=0 file=1
>> [...]
>>          kswapd1-86    [001] dN.. 118084.274403: 
>> mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 
>> nr_requested=32 nr_scanned=4241133 nr_taken=0 file=1
>>
>> Note the Need resched flag. The IRQ off part is expected because we are
>> holding the LRU lock which is IRQ safe.

Hmmm. With the lock held, preemption is disabled. If we are in that 
state for some time, I'd expect need_resched just because of time 
quantum. But... :

The call stack always has

 > [<ffffffff811345f5>] ? shrink_node_memcg+0x605/0x870

which translates to

 > (gdb) list *0xffffffff811345f5
 > 0xffffffff811345f5 is in shrink_node_memcg (mm/vmscan.c:2065).
 > 2060    static unsigned long shrink_list(enum lru_list lru, unsigned 
long nr_to_scan,
 > 2061                     struct lruvec *lruvec, struct scan_control *sc)
 > 2062    {
 > 2063        if (is_active_lru(lru)) {
 > 2064            if (inactive_list_is_low(lruvec, is_file_lru(lru), sc))
 > 2065                shrink_active_list(nr_to_scan, lruvec, sc, lru);
 > 2066            return 0;
 > 2067        }
 > 2068
 > 2069        return shrink_inactive_list(nr_to_scan, lruvec, sc, lru);

So we are in shrink_active_list. I made a small change without keeping 
the old vmlinux and the addresses are off by 16 bytes, but it can be 
verified exactly on another machine:

 > buczek@void:/scratch/local/linux-4.8.10-121.x86_64/source$ grep 
shrink_node_memcg /var/log/messages
 > [...]
 > void kernel: [508779.136016]  [<ffffffff8114833a>] ? 
shrink_node_memcg+0x60a/0x870
 > (gdb) disas 0xffffffff8114833a
 > [...]
 >   0xffffffff81148330 <+1536>:    mov    %r10,0x38(%rsp)
 >   0xffffffff81148335 <+1541>:    callq 0xffffffff81147a00 
<shrink_active_list>
 >   0xffffffff8114833a <+1546>:    mov    0x38(%rsp),%r10
 >   0xffffffff8114833f <+1551>:    jmpq 0xffffffff81147f80 
<shrink_node_memcg+592>
 >   0xffffffff81148344 <+1556>:    mov    %r13,0x78(%r12)


shrink_active_list gets and releases the spinlock and calls 
cond_resched(). This should give other tasks a chance to run. Just as an 
experiment, I'm trying

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1921,7 +1921,7 @@ static void shrink_active_list(unsigned long 
nr_to_scan,
         spin_unlock_irq(&pgdat->lru_lock);

         while (!list_empty(&l_hold)) {
-               cond_resched();
+               cond_resched_rcu_qs();
                 page = lru_to_page(&l_hold);
                 list_del(&page->lru);

and didn't hit a rcu_sched warning for >21 hours uptime now. We'll see. 
Is preemption disabled for another reason?

Regards
   Donald

>> That is not a problem because
>> the lock is only held for SWAP_CLUSTER_MAX pages at maximum. It is also
>> interesing to see that we have scanned only 1303 pages during that 1
>> minute. That would be dead slow. None of them were good enough for the
>> reclaim but that doesn't sound like a problem. The trace simply suggests
>> that the reclaim was preempted by something else. Otherwise I cannot
>> imagine such a slow scanning.
>>
>> Is it possible that something else is hogging the CPU and the RCU just
>> happens to blame kswapd which is running in the standard user process
>> context?
>
> From looking at the monitoring graphs, there was always enough CPU 
> resources available. The machine has 12x E5-2630 @ 2.30GHz. So that 
> shouldn?t have been a problem.
>
>
> Kind regards,
>
> Paul Menzel


-- 
Donald Buczek
buczek@molgen.mpg.de
Tel: +49 30 8413 1433

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
