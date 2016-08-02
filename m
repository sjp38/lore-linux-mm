Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC78A828E5
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 09:29:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so299323497pad.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 06:29:00 -0700 (PDT)
Received: from mail-pf0-f193.google.com (mail-pf0-f193.google.com. [209.85.192.193])
        by mx.google.com with ESMTPS id t15si3115741pas.199.2016.08.02.06.28.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 06:28:59 -0700 (PDT)
Received: by mail-pf0-f193.google.com with SMTP id g202so12557416pfb.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 06:28:59 -0700 (PDT)
Date: Tue, 2 Aug 2016 15:28:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM killer invoked during btrfs send/recieve on otherwise idle
 machine
Message-ID: <20160802132855.GA24890@dhcp22.suse.cz>
References: <20160731051121.GB307@x4>
 <20160731151047.GA4496@dhcp22.suse.cz>
 <20160731152522.GA311@x4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160731152522.GA311@x4>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

JFYI http://lkml.kernel.org/r/20160801192620.GD31957@dhcp22.suse.cz
sounds quite similar to your report. order-2 OOMs with btrfs and many
pagecache pages wrt. to the anon. I suspect that btrfs is preventing
the compaction for some reason.

On Sun 31-07-16 17:25:22, Markus Trippelsdorf wrote:
> On 2016.07.31 at 17:10 +0200, Michal Hocko wrote:
> > [CC Mel and linux-mm]
> > 
> > On Sun 31-07-16 07:11:21, Markus Trippelsdorf wrote:
> > > Tonight the OOM killer got invoked during backup of /:
> > > 
> > > [Jul31 01:56] kthreadd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> > 
> > This a kernel stack allocation.
> > 
> > > [  +0.000004] CPU: 3 PID: 2 Comm: kthreadd Not tainted 4.7.0-06816-g797cee982eef-dirty #37
> > > [  +0.000000] Hardware name: System manufacturer System Product Name/M4A78T-E, BIOS 3503    04/13/2011
> > > [  +0.000002]  0000000000000000 ffffffff813c2d58 ffff8802168e7d48 00000000002ec4ea
> > > [  +0.000002]  ffffffff8118eb9d 00000000000001b8 0000000000000440 00000000000003b0
> > > [  +0.000002]  ffff8802133fe400 00000000002ec4ea ffffffff81b8ac9c 0000000000000006
> > > [  +0.000001] Call Trace:
> > > [  +0.000004]  [<ffffffff813c2d58>] ? dump_stack+0x46/0x6e
> > > [  +0.000003]  [<ffffffff8118eb9d>] ? dump_header.isra.11+0x4c/0x1a7
> > > [  +0.000002]  [<ffffffff811382eb>] ? oom_kill_process+0x2ab/0x460
> > > [  +0.000001]  [<ffffffff811387e3>] ? out_of_memory+0x2e3/0x380
> > > [  +0.000002]  [<ffffffff81141532>] ? __alloc_pages_slowpath.constprop.124+0x1d32/0x1e40
> > > [  +0.000001]  [<ffffffff81141b4c>] ? __alloc_pages_nodemask+0x10c/0x120
> > > [  +0.000002]  [<ffffffff810939aa>] ? copy_process.part.72+0xea/0x17a0
> > > [  +0.000002]  [<ffffffff810d1a55>] ? pick_next_task_fair+0x915/0x1520
> > > [  +0.000001]  [<ffffffff810b7a00>] ? kthread_flush_work_fn+0x20/0x20
> > > [  +0.000001]  [<ffffffff8109549a>] ? kernel_thread+0x7a/0x1c0
> > > [  +0.000001]  [<ffffffff810b82f2>] ? kthreadd+0xd2/0x120
> > > [  +0.000002]  [<ffffffff818d828f>] ? ret_from_fork+0x1f/0x40
> > > [  +0.000001]  [<ffffffff810b8220>] ? kthread_stop+0x100/0x100
> > > [  +0.000001] Mem-Info:
> > > [  +0.000003] active_anon:5882 inactive_anon:60307 isolated_anon:0
> > >                active_file:1523729 inactive_file:223965 isolated_file:0
> > >                unevictable:1970 dirty:130014 writeback:40735 unstable:0
> > >                slab_reclaimable:179690 slab_unreclaimable:8041
> > >                mapped:6771 shmem:3 pagetables:592 bounce:0
> > >                free:11374 free_pcp:54 free_cma:0
> > > [  +0.000004] Node 0 active_anon:23528kB inactive_anon:241228kB active_file:6094916kB inactive_file:895860kB unevictable:7880kB isolated(anon):0kB isolated(file):0kB mapped:27084kB dirty:520056kB writeback:162940kB shmem:12kB writeback_tmp:0kB unstable:0kB pages_scanned:32 all_unreclaimable? no
> > > [  +0.000002] DMA free:15908kB min:20kB low:32kB high:44kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> > > [  +0.000001] lowmem_reserve[]: 0 3486 7953 7953
> > > [  +0.000004] DMA32 free:23456kB min:4996kB low:8564kB high:12132kB active_anon:2480kB inactive_anon:10564kB active_file:2559792kB inactive_file:478680kB unevictable:0kB writepending:365292kB present:3652160kB managed:3574264kB mlocked:0kB slab_reclaimable:437456kB slab_unreclaimable:12304kB kernel_stack:144kB pagetables:28kB bounce:0kB free_pcp:212kB local_pcp:0kB free_cma:0kB
> > > [  +0.000001] lowmem_reserve[]: 0 0 4466 4466
> > > [  +0.000003] Normal free:6132kB min:6400kB low:10972kB high:15544kB active_anon:21048kB inactive_anon:230664kB active_file:3535124kB inactive_file:417312kB unevictable:7880kB writepending:318020kB present:4718592kB managed:4574096kB mlocked:7880kB slab_reclaimable:281304kB slab_unreclaimable:19860kB kernel_stack:2944kB pagetables:2340kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> > > [  +0.000000] lowmem_reserve[]: 0 0 0 0
> > > [  +0.000002] DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (U) 3*4096kB (M) = 15908kB
> > > [  +0.000005] DMA32: 4215*4kB (UMEH) 319*8kB (UMH) 5*16kB (H) 2*32kB (H) 2*64kB (H) 1*128kB (H) 0*256kB 1*512kB (H) 1*1024kB (H) 1*2048kB (H) 0*4096kB = 23396kB
> > > [  +0.000006] Normal: 650*4kB (UMH) 4*8kB (UH) 27*16kB (H) 23*32kB (H) 17*64kB (H) 11*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6296kB
> > 
> > The memory is quite fragmented but there are order-2+ free blocks. They
> > seem to be in the high atomic reserves but we should release them.
> > Is this reproducible? If yes, could you try with the 4.7 kernel please?
> 
> It never happened before and it only happend once yet. I will continue
> to run the latest git kernel and let you know if it happens again.
> 
> (I did copy several git trees to my root partition yesterday, so the
> incremental btrfs stream was larger than usual.)
> 
> -- 
> Markus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
