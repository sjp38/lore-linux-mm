Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 77C046B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 05:02:42 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so89855803lfg.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 02:02:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ed10si1611878wjb.149.2016.08.02.02.02.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 02:02:41 -0700 (PDT)
Date: Tue, 2 Aug 2016 11:02:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160802090238.GD12403@dhcp22.suse.cz>
References: <d8f3adcc-3607-1ef6-9ec5-82b2e125eef2@quantum.com>
 <20160801061625.GA11623@dhcp22.suse.cz>
 <b1a39756-a0b5-1900-6575-d6e1f502cb26@Quantum.com>
 <20160801182358.GB31957@dhcp22.suse.cz>
 <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160801192620.GD31957@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Mon 01-08-16 21:26:20, Michal Hocko wrote:
> [re-adding linux-mm mailing list - please always use reply-to-all
>  also CCing Vlastimil who can help with the compaction debugging]
> 
> On Mon 01-08-16 11:48:53, Ralf-Peter Rohbeck wrote:
> > See the messages log attached. It has several OOM killer entries.
> > Let me know if there's anything else I can do. I'll try the disk erasing on
> > 4.6 and on 4.7.
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

OK, so I've checked anon/file counters for all of OOM invocations and
the pattern is in fact pretty much consistent:
anon 29780 (1%) file 1867632 (89%) dirty 334792 (15%) slab 85311 (4%)
anon 30215 (1%) file 1866069 (89%) dirty 336974 (16%) slab 85074 (4%)
anon 32800 (1%) file 1865752 (89%) dirty 335470 (16%) slab 84793 (4%)
anon 33040 (1%) file 1850425 (88%) dirty 349561 (16%) slab 88997 (4%)
anon 31536 (1%) file 1859444 (88%) dirty 351498 (16%) slab 87475 (4%)
anon 31540 (1%) file 1861497 (88%) dirty 351126 (16%) slab 86976 (4%)
anon 28390 (1%) file 1863807 (88%) dirty 351404 (16%) slab 86292 (4%)
anon 29655 (1%) file 1863581 (88%) dirty 351632 (16%) slab 86295 (4%)
anon 28907 (1%) file 1861612 (88%) dirty 302386 (14%) slab 88269 (4%)
anon 28475 (1%) file 1857073 (88%) dirty 299464 (14%) slab 88193 (4%)
anon 29610 (1%) file 1861161 (88%) dirty 297911 (14%) slab 87796 (4%)
anon 28624 (1%) file 1862460 (88%) dirty 300628 (14%) slab 87650 (4%)
anon 35317 (1%) file 1901489 (90%) dirty 32652 (1%) slab 47519 (2%)
anon 36518 (1%) file 1896775 (90%) dirty 32734 (1%) slab 49460 (2%)

the dirty+writeback (marked as dirty above) drops down in the end but
file LRU is consistently ~89% of the memory. That alone shouldn't be
problem for the compaction to proceed except when those pages are pinned
by the filesystem for some reason. You have said that you are using the
Btrfs.  Would it be possible to retest with the same storage layout and
a different fs? That would help to rule out the FS as the source of the
problems.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
