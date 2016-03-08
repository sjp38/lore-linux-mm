Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 89F2B6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 04:08:21 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so121464638wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:08:21 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id cr8si2559010wjb.49.2016.03.08.01.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 01:08:20 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id p65so2832297wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:08:20 -0800 (PST)
Date: Tue, 8 Mar 2016 10:08:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more (was: Re:
 [PATCH 0/3] OOM detection rework v4)
Message-ID: <20160308090818.GA13542@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <20160308035104.GA447@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160308035104.GA447@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue 08-03-16 12:51:04, Sergey Senozhatsky wrote:
> Hello Michal,
> 
> On (03/07/16 17:08), Michal Hocko wrote:
> > On Mon 29-02-16 22:02:13, Michal Hocko wrote:
> > > Andrew,
> > > could you queue this one as well, please? This is more a band aid than a
> > > real solution which I will be working on as soon as I am able to
> > > reproduce the issue but the patch should help to some degree at least.
> > 
> > Joonsoo wasn't very happy about this approach so let me try a different
> > way. What do you think about the following? Hugh, Sergey does it help
> > for your load? I have tested it with the Hugh's load and there was no
> > major difference from the previous testing so at least nothing has blown
> > up as I am not able to reproduce the issue here.
> 
> (next-20160307 + "[PATCH] mm, oom: protect !costly allocations some more")
> 
> seems it's significantly less likely to oom-kill now, but I still can see
> something like this

Thanks for the testing. This is highly appreciated. If you are able to
reproduce this then collecting compaction related tracepoints might be
really helpful.

> [  501.942745] coretemp-sensor invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
> [  501.942853] active_anon:151312 inactive_anon:54791 isolated_anon:0
>                 active_file:31213 inactive_file:302048 isolated_file:0
>                 unevictable:0 dirty:44 writeback:221 unstable:0
>                 slab_reclaimable:43570 slab_unreclaimable:5651
>                 mapped:16660 shmem:29495 pagetables:2542 bounce:0
>                 free:10884 free_pcp:214 free_cma:0
[...]
> [  501.942867] DMA32 free:23664kB min:6232kB low:9332kB high:12432kB active_anon:516228kB inactive_anon:129136kB active_file:96508kB inactive_file:954780kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3194880kB managed:3107512kB mlocked:0kB dirty:136kB writeback:440kB mapped:51816kB shmem:91488kB slab_reclaimable:129856kB slab_unreclaimable:13876kB kernel_stack:2160kB pagetables:7888kB unstable:0kB bounce:0kB free_pcp:724kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:128 all_unreclaimable? no
> [  501.942870] lowmem_reserve[]: 0 0 824 824
> [  501.942876] Normal free:4784kB min:1696kB low:2540kB high:3384kB active_anon:89020kB inactive_anon:90028kB active_file:28248kB inactive_file:253308kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:917504kB managed:844512kB mlocked:0kB dirty:40kB writeback:444kB mapped:14700kB shmem:26492kB slab_reclaimable:44396kB slab_unreclaimable:8620kB kernel_stack:1328kB pagetables:2280kB unstable:0kB bounce:0kB free_pcp:244kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:60 all_unreclaimable? no

Both DMA32 and Normal zones are over high watermarks so this OOM is due
to the memory fragmentation.

> [  501.942912] DMA32: 564*4kB (UME) 2700*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 23856kB
> [  501.942921] Normal: 959*4kB (ME) 128*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4860kB

There are no order-2+ pages usable even after we know that the
compaction was active and didn't back out early. I might be missing
something of course and the patch might still be tweaked to be more
conservative. Tracepoints should tell us more though.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
