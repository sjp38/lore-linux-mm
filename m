Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5FD76B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 03:11:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so96497217wmz.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 00:11:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q63si19954678wmd.131.2016.08.02.00.11.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 00:11:21 -0700 (PDT)
Subject: Re: OOM killer changes
References: <d8f3adcc-3607-1ef6-9ec5-82b2e125eef2@quantum.com>
 <20160801061625.GA11623@dhcp22.suse.cz>
 <b1a39756-a0b5-1900-6575-d6e1f502cb26@Quantum.com>
 <20160801182358.GB31957@dhcp22.suse.cz>
 <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c06aa91e-0631-cecc-b407-ee3794f78d37@suse.cz>
Date: Tue, 2 Aug 2016 09:11:20 +0200
MIME-Version: 1.0
In-Reply-To: <20160801192620.GD31957@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: linux-mm@kvack.org

On 08/01/2016 09:26 PM, Michal Hocko wrote:
> [re-adding linux-mm mailing list - please always use reply-to-all
>  also CCing Vlastimil who can help with the compaction debugging]
>
> On Mon 01-08-16 11:48:53, Ralf-Peter Rohbeck wrote:
>> See the messages log attached. It has several OOM killer entries.
>> Let me know if there's anything else I can do. I'll try the disk erasing on
>> 4.6 and on 4.7.
>
> Jul 31 17:17:05 fs kernel: [11918.534744] x2golistsession invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> [...]
> Jul 31 17:17:05 fs kernel: [11918.557356] Mem-Info:
> Jul 31 17:17:05 fs kernel: [11918.558268] active_anon:7856 inactive_anon:21924 isolated_anon:0
> Jul 31 17:17:05 fs kernel: [11918.558268]  active_file:70925 inactive_file:1796707 isolated_file:0
> Jul 31 17:17:05 fs kernel: [11918.558268]  unevictable:0 dirty:277675 writeback:57117 unstable:0
> Jul 31 17:17:05 fs kernel: [11918.558268]  slab_reclaimable:75821 slab_unreclaimable:9490
> Jul 31 17:17:05 fs kernel: [11918.558268]  mapped:12014 shmem:2414 pagetables:1497 bounce:0
> Jul 31 17:17:05 fs kernel: [11918.558268]  free:37021 free_pcp:89 free_cma:0
> [...]
> Jul 31 17:17:05 fs kernel: [11918.578836] Node 0 DMA32: 2137*4kB (UME) 5043*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 48892kB
> Jul 31 17:17:05 fs kernel: [11918.580370] Node 0 Normal: 2663*4kB (UME) 7452*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 70268kB
>
> The above process is trying to allocate the kernel stack which is
> order-2 (16kB) of physically contiguous memory which is clearly
> not available as you can see. Memory compaction (assuming you have
> CONFIG_COMPACTION enabled) which is a part of the oom reclaim process
> should help to form such blocks but those retries are bound and if
> there is not much hope left we eventually hit the OOM killer. If you
> look at the above counters there is a lot of memory dirty and under the
> writeback (1.3G), this suggests that the IO is quite slow wrt. writers.
> Anyway there is a lot of anonymous memory which should be a good
> candidate for compaction.
>
> But the IO doesn't seem to be the main factor I guess. Later OOM
> invocations have a slightly different pattern (let's take the last one):
>
> Aug  1 06:30:45 fs kernel: [59536.957034] x2golistsession invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> [...]
> Aug  1 06:30:45 fs kernel: [59536.976467] Mem-Info:
> Aug  1 06:30:45 fs kernel: [59536.977442] active_anon:16045 inactive_anon:20473 isolated_anon:0
> Aug  1 06:30:45 fs kernel: [59536.977442]  active_file:169767 inactive_file:1727008 isolated_file:0
> Aug  1 06:30:45 fs kernel: [59536.977442]  unevictable:0 dirty:32734 writeback:0 unstable:0
> Aug  1 06:30:45 fs kernel: [59536.977442]  slab_reclaimable:41953 slab_unreclaimable:7507
> Aug  1 06:30:45 fs kernel: [59536.977442]  mapped:10619 shmem:2443 pagetables:1971 bounce:0
> Aug  1 06:30:45 fs kernel: [59536.977442]  free:36686 free_pcp:119 free_cma:0
> [...]
> Aug  1 06:30:45 fs kernel: [59536.996407] Node 0 DMA32: 5909*4kB (UME) 3800*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 54036kB
> Aug  1 06:30:45 fs kernel: [59536.997846] Node 0 Normal: 4041*4kB (UME) 6799*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 70556kB
>
> the amount of dirty pages is much smaller as well as the anonymous
> memory. The biggest portion seems to be in the page cache. The memory
> is till hugely fragmented though. In fact if we check all the OOM
> invocations the only consistent thing is that the memory is fragmented
> and the compaction cannot make sufficient progress consistently. We can
> assume that the situation actually gets better because there are some
> holes between those OOMs so we can assume that something has unpinned a
> larger amount memory and allowed the compaction to make further progress
> or that the load has strong peaks. We would need more information from
> the compaction to know better. Vlastimil will surely tell you which
> tracepoints to enable.

Actually a snapshot of /proc/vmstat /proc/zoneinfo and 
/proc/pagetypeinfo before and after test would be also useful to provide 
first. Then compaction tracepoints:

echo 1 > /sys/kernel/debug/tracing/events/compaction/enable
cat /sys/kernel/debug/tracing/trace_pipe > /path/to/trace.log

or with trace-cmd
trace-cmd record -e compaction
trace-cmd report

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
