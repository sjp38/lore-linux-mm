Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A259C6B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 03:44:58 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so9491126wml.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 00:44:58 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id u1si5913901wju.85.2016.08.12.00.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 00:44:57 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id f65so13195069wmi.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 00:44:57 -0700 (PDT)
Date: Fri, 12 Aug 2016 09:44:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.7.0, cp -al causes OOM
Message-ID: <20160812074455.GD3639@dhcp22.suse.cz>
References: <201608120901.41463.a.miskiewicz@gmail.com>
 <20160812074340.GC3639@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812074340.GC3639@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arekm@maven.pl
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org

[Fixing linux-mm mailing list]

On Fri 12-08-16 09:43:40, Michal Hocko wrote:
> Hi,
> 
> On Fri 12-08-16 09:01:41, Arkadiusz Miskiewicz wrote:
> > 
> > Hello.
> > 
> > I have a system with 4x2TB SATA disks, split into few partitions. Celeron G530,
> > 8GB of ram, 20GB of swap. It's just basic system (so syslog,
> > cron, udevd, irqbalance) + my cp tests and nothing more. kernel 4.7.0
> > 
> > There is software raid 5 partition on sd[abcd]4 and ext4 created with -T news
> > option.
> > 
> > Using deadline I/O scheduler.
> > 
> > For testing I have 400GB of tiny files on it (about 6.4mln inodes) in mydir.
> > I did "cp -al mydir copy{1,2,...,10}" 10x in parallel and that ended up
> > with 5 of cp being killed by OOM while other 5x finished.
> > 
> > Even two in parallel seem to be enough for OOM to kick in:
> > rm -rf copy1; cp -al mydir copy1
> > rm -rf copy2; cp -al mydir copy2
> 
> Ouch
> 
> > I would expect 8GB of ram to be enough for just rm/cp. Ideas?
> > 
> > Note that I first tested the same thing with xfs (hence you can see
> > " task xfsaild/md2:661 blocked for more than 120 seconds." and xfs
> > related stacktraces in dmesg) and 10x cp managed to finish without
> > OOM. Later I did test with ext4 which caused OOMs. I guess it is
> > probably not some generic memory management problem but that's only my
> > guess.
> 
> I suspect the compaction is not able to migrate FS buffers to form
> higher order pages.
> 
> [...]
> > [87259.568301] bash invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> 
> This is a kernel stack allocation (so order-2 request)
> 
> [...]
> > [87259.568369] active_anon:439065 inactive_anon:146385 isolated_anon:0
> >                 active_file:201920 inactive_file:122369 isolated_file:0
> 
> This is around 3.5G of memory for file/anonymous pages which is ~43% of
> RAM. Considering that the free memory is quite low this means that the
> majority of the memory is consumed by somebody else.
> 
> >                 unevictable:0 dirty:26675 writeback:0 unstable:0
> >                 slab_reclaimable:966564 slab_unreclaimable:79528
> 
> OK, so the slab objects eat 50% of memory. I would check /proc/slabinfo
> who has eaten that memory. Large portion of the slab is reclaimable but
> I suspect that it can easily prevent memory compaction to succeed.
> 
> >                 mapped:2236 shmem:1 pagetables:1759 bounce:0
> >                 free:30651 free_pcp:0 free_cma:0
> [...]
> > [87259.568395] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15360kB
> > [87259.568403] Node 0 DMA32: 11467*4kB (UME) 1525*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 58068kB
> > [87259.568411] Node 0 Normal: 9927*4kB (UMEH) 1119*8kB (UMH) 19*16kB (H) 8*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 49348kB
> 
> As you can see there are barely some high order pages available. There
> are few in the atomic reserves which is a bit surprising because I would
> expect they would get released under a heavy memory pressure. I will
> double check that part.
> 
> Anyway I suspect the primary reason is that the compaction cannot make
> forward progress. Before 4.7 the OOM detection didn't bother to take
> the compaction feedback into account and just blindly retried as long as
> there was a reclaim progress. This was basically unbounded in time and
> without any guarantee of a success... /proc/vmstat snapshots before you
> start your load and after the OOM killer might tell us more.
> 
> Anyway filling up memory with so many slab objects sounds suspicious on
> its own. I guess that the fact you have huge number of files plays an
> important role. This is something for ext4 people to answer.
> 
> [...]
> > [99888.398968] kthreadd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> [...]
> > [99888.399036] Mem-Info:
> > [99888.399040] active_anon:195818 inactive_anon:195891 isolated_anon:0
> >                 active_file:294335 inactive_file:23747 isolated_file:0
> 
> LRU pages got down to 34%...
> 
> >                 unevictable:0 dirty:38741 writeback:2 unstable:0
> >                 slab_reclaimable:1079860 slab_unreclaimable:157162
> 
> while slab memory increased to 59%
> 
> [...]
> 
> > [99888.399066] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15360kB
> > [99888.399075] Node 0 DMA32: 14370*4kB (UME) 1809*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 71952kB
> > [99888.399082] Node 0 Normal: 12172*4kB (UMEH) 165*8kB (UMEH) 23*16kB (H) 9*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 50792kB
> 
> high order reserves still block some order-2+ blocks.
> 
> [...]
> 
> > [103315.505488] kthreadd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> [...]
> > [103315.505554] Mem-Info:
> > [103315.505559] active_anon:154510 inactive_anon:154514 isolated_anon:0
> >                  active_file:317774 inactive_file:43364 isolated_file:0
> 
> and the LRU pages go even more down to 32%
> 
> >                  unevictable:0 dirty:11801 writeback:5212 unstable:0
> >                  slab_reclaimable:1112194 slab_unreclaimable:166028
> 
> while slab grows above 60%
> 
> [...]
> > [104400.507680] Mem-Info:
> > [104400.507684] active_anon:129371 inactive_anon:129450 isolated_anon:0
> >                  active_file:316704 inactive_file:55666 isolated_file:0
> 
> LRU 30%
> 
> >                  unevictable:0 dirty:29991 writeback:0 unstable:0
> >                  slab_reclaimable:1145618 slab_unreclaimable:171545
> 
> slab 63%
> 
> [...]
> 
> > [114824.060378] Mem-Info:
> > [114824.060403] active_anon:170168 inactive_anon:170168 isolated_anon:0
> >                  active_file:192892 inactive_file:133384 isolated_file:0
> 
> LRU 32%
> 
> >                  unevictable:0 dirty:37109 writeback:1 unstable:0
> >                  slab_reclaimable:1176088 slab_unreclaimable:109598
> 
> slab 61%
> 
> [...]
> 
> That being said it is really unusual to see such a large kernel memory
> foot print. The slab memory consumption grows but it doesn't seem to be
> a memory leak at first glance. Anyway such a large in-kernel consumption
> can severely affect forming higher order memory blocks. I believe we can
> do slightly better wrt high atomic reserves but that doesn't sound like
> a core problem here. I believe ext4 should look at what is going on
> there as well.
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
