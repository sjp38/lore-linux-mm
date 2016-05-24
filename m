Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B761A6B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 03:16:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a136so5964281wme.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 00:16:22 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id m68si21690839wma.60.2016.05.24.00.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 00:16:21 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id n129so113526211wmn.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 00:16:21 -0700 (PDT)
Date: Tue, 24 May 2016 09:16:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160524071619.GB8259@dhcp22.suse.cz>
References: <20160520202817.GA22201@redhat.com>
 <20160523072904.GC2278@dhcp22.suse.cz>
 <20160523151419.GA8284@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160523151419.GA8284@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 23-05-16 17:14:19, Oleg Nesterov wrote:
> On 05/23, Michal Hocko wrote:
[...]
> > Could you add some tracing and see what are the numbers
> > above?
> 
> with the patch below I can press Ctrl-C when it hangs, this breaks the
> endless loop and the output looks like
> 
> 	vmscan: ZONE=ffffffff8189f180 0 scanned=0 pages=6
> 	vmscan: ZONE=ffffffff8189eb00 0 scanned=1 pages=0
> 	...
> 	vmscan: ZONE=ffffffff8189eb00 0 scanned=2 pages=1
> 	vmscan: ZONE=ffffffff8189f180 0 scanned=4 pages=6
> 	...
> 	vmscan: ZONE=ffffffff8189f180 0 scanned=4 pages=6
> 	vmscan: ZONE=ffffffff8189f180 0 scanned=4 pages=6
> 
> the numbers are always small.

Small but scanned is not 0 and constant which means it either gets reset
repeatedly (something gets freed) or we have stopped scanning. Which
pattern can you see? I assume that the swap space is full at the time
(could you add get_nr_swap_pages() to the output). Also zone->name would
be better than the pointer.

I am trying to reproduce but your test case always hits the oom killer:

This is in a qemu x86_64 virtual machine:
# free
             total       used       free     shared    buffers     cached
Mem:        490212      96788     393424          0       3196       9976
-/+ buffers/cache:      83616     406596
Swap:       138236      57740      80496

I have tried with much larger swap space but no change except for the
run time of the test which is expected.

# grep "^processor" /proc/cpuinfo | wc -l
1

[... Skipped several previous attempts ...]
[  695.215235] vmscan: XXX: zone:DMA32 nr_pages_scanned:0 reclaimable:20
[  695.215245] vmscan: XXX: zone:DMA32 nr_pages_scanned:0 reclaimable:20
[  695.215255] vmscan: XXX: zone:DMA32 nr_pages_scanned:0 reclaimable:20
[  695.215282] vmscan: XXX: zone:DMA32 nr_pages_scanned:1 reclaimable:27
[  695.215303] vmscan: XXX: zone:DMA32 nr_pages_scanned:5 reclaimable:27
[  695.215327] vmscan: XXX: zone:DMA32 nr_pages_scanned:18 reclaimable:27
[  695.215351] vmscan: XXX: zone:DMA32 nr_pages_scanned:45 reclaimable:27
[  695.215362] vmscan: XXX: zone:DMA32 nr_pages_scanned:45 reclaimable:27
[  695.215373] vmscan: XXX: zone:DMA32 nr_pages_scanned:45 reclaimable:27
[  695.215382] vmscan: XXX: zone:DMA32 nr_pages_scanned:45 reclaimable:27
[  695.215392] vmscan: XXX: zone:DMA32 nr_pages_scanned:45 reclaimable:27
[  695.215402] vmscan: XXX: zone:DMA32 nr_pages_scanned:45 reclaimable:27
[  695.215412] vmscan: XXX: zone:DMA32 nr_pages_scanned:45 reclaimable:27
[  695.215422] vmscan: XXX: zone:DMA32 nr_pages_scanned:45 reclaimable:27
[  695.215431] vmscan: XXX: zone:DMA32 nr_pages_scanned:45 reclaimable:27
[  695.215442] vmscan: XXX: zone:DMA32 nr_pages_scanned:46 reclaimable:27
[  695.215462] vmscan: XXX: zone:DMA32 nr_pages_scanned:48 reclaimable:27
[  695.215482] vmscan: XXX: zone:DMA32 nr_pages_scanned:53 reclaimable:27
[  695.215504] vmscan: XXX: zone:DMA32 nr_pages_scanned:63 reclaimable:27
[  695.215528] vmscan: XXX: zone:DMA32 nr_pages_scanned:90 reclaimable:27
[...]
[  695.215620] vmscan: XXX: zone:DMA32 nr_pages_scanned:91 reclaimable:27
[  695.215640] vmscan: XXX: zone:DMA32 nr_pages_scanned:94 reclaimable:27
[  695.215659] vmscan: XXX: zone:DMA32 nr_pages_scanned:100 reclaimable:27
[  695.215683] vmscan: XXX: zone:DMA32 nr_pages_scanned:113 reclaimable:27
[...]
[  695.215786] vmscan: XXX: zone:DMA32 nr_pages_scanned:140 reclaimable:27
[  695.215797] vmscan: XXX: zone:DMA32 nr_pages_scanned:141 reclaimable:27
[  695.215816] vmscan: XXX: zone:DMA32 nr_pages_scanned:144 reclaimable:27
[  695.215836] vmscan: XXX: zone:DMA32 nr_pages_scanned:150 reclaimable:27
[  695.215906] test-oleg invoked oom-killer: gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), order=0, oom_score_adj=0
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
