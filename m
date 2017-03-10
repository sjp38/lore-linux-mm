Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30BBF28093C
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 18:31:58 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id 72so103895733uaf.7
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 15:31:58 -0800 (PST)
Received: from mail-ua0-x243.google.com (mail-ua0-x243.google.com. [2607:f8b0:400c:c08::243])
        by mx.google.com with ESMTPS id u187si4301858vkf.86.2017.03.10.15.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 15:31:57 -0800 (PST)
Received: by mail-ua0-x243.google.com with SMTP id u30so16117645uau.2
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 15:31:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170307131751.24936-1-mhocko@kernel.org>
References: <20170307131751.24936-1-mhocko@kernel.org>
From: Yang Li <pku.leo@gmail.com>
Date: Fri, 10 Mar 2017 17:31:56 -0600
Message-ID: <CADRPPNT9zyc_0sg0eoZEMbTQ+mCHAkmzmHW93zHaOuzpALtzrg@mail.gmail.com>
Subject: Re: [PATCH] mm: move pcp and lru-pcp drainging into single wq
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Li Yang <leoyang.li@nxp.com>

On Tue, Mar 7, 2017 at 7:17 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> We currently have 2 specific WQ_RECLAIM workqueues in the mm code.
> vmstat_wq for updating pcp stats and lru_add_drain_wq dedicated to drain
> per cpu lru caches. This seems more than necessary because both can run
> on a single WQ. Both do not block on locks requiring a memory allocation
> nor perform any allocations themselves. We will save one rescuer thread
> this way.
>
> On the other hand drain_all_pages() queues work on the system wq which
> doesn't have rescuer and so this depend on memory allocation (when all
> workers are stuck allocating and new ones cannot be created). This is
> not critical as there should be somebody invoking the OOM killer (e.g.
> the forking worker) and get the situation unstuck and eventually
> performs the draining. Quite annoying though. This worker should be
> using WQ_RECLAIM as well. We can reuse the same one as for lru draining
> and vmstat.
>
> Changes since v1
> - rename vmstat_wq to mm_percpu_wq - per Mel
> - make sure we are not trying to enqueue anything while the WQ hasn't
>   been intialized yet. This shouldn't happen because the initialization
>   is done from an init code but some init section might be triggering
>   those paths indirectly so just warn and skip the draining in that case
>   per Vlastimil

So what's the plan if this really happens?  Shall we put the
initialization of the mm_percpu_wq earlier?  Or if it is really
harmless we can probably remove the warnings.

I'm seeing this on arm64 with a linux-next tree:

[    0.276449] WARNING: CPU: 2 PID: 1 at mm/page_alloc.c:2423
drain_all_pages+0x244/0x25c
[    0.276537] Modules linked in:

[    0.276594] CPU: 2 PID: 1 Comm: swapper/0 Not tainted
4.11.0-rc1-next-20170310-00027-g64dfbc5 #127
[    0.276693] Hardware name: Freescale Layerscape 2088A RDB Board (DT)
[    0.276764] task: ffffffc07c4a6d00 task.stack: ffffffc07c4a8000
[    0.276831] PC is at drain_all_pages+0x244/0x25c
[    0.276886] LR is at start_isolate_page_range+0x14c/0x1f0
[    0.276946] pc : [<ffffff80081636bc>] lr : [<ffffff80081c675c>]
pstate: 80000045
[    0.277028] sp : ffffffc07c4abb10
[    0.277066] x29: ffffffc07c4abb10 x28: 00000000000ff000
[    0.277128] x27: 0000000000000004 x26: 0000000000000000
[    0.277190] x25: 00000000000ff400 x24: 0000000000000040
[    0.277252] x23: ffffff8008ab0000 x22: ffffff8008c46000
[    0.277313] x21: ffffff8008c2b700 x20: ffffff8008c2b200
[    0.277374] x19: ffffff8008c2b200 x18: ffffff80088b5068
[    0.277436] x17: 000000000000000e x16: 0000000000000007
[    0.277497] x15: 0000000000000001 x14: ffffffffffffffff
[    0.277559] x13: 0000000000000068 x12: 0000000000000001
[    0.277620] x11: ffffff8008c2b6e0 x10: 0000000000010000
[    0.277682] x9 : ffffff8008c2b6e0 x8 : 00000000000000cd
[    0.277743] x7 : ffffffc07c4abb70 x6 : ffffff8008c2b868
[    0.277804] x5 : ffffff8008b84b4e x4 : 0000000000000000
[    0.277866] x3 : 0000000000000c00 x2 : 0000000000000311
[    0.277927] x1 : 0000000000000001 x0 : ffffff8008bc8000

[    0.278008] ---[ end trace 905d0cf24acf61bb ]---
[    0.278060] Call trace:
[    0.278089] Exception stack(0xffffffc07c4ab940 to 0xffffffc07c4aba70)
[    0.278162] b940: ffffff8008c2b200 0000008000000000
ffffffc07c4abb10 ffffff80081636bc
[    0.278249] b960: ffffff8008ba8dd0 ffffff8008ba8c80
ffffff8008c2c580 ffffff8008bc5f08
[    0.278336] b980: ffffffbebffdafff ffffffbebffdb000
ffffff8008c797d8 ffffffbebffdafff
[    0.278423] b9a0: ffffffbebffdb000 ffffffc07c667000
ffffffc07c4ab9c0 ffffff800817ff7c
[    0.278510] b9c0: ffffffc07c4aba40 ffffff8008180618
00000000000003d0 0000000000000f60
[    0.278597] b9e0: ffffff8008bc8000 0000000000000001
0000000000000311 0000000000000c00
[    0.278684] ba00: 0000000000000000 ffffff8008b84b4e
ffffff8008c2b868 ffffffc07c4abb70
[    0.278771] ba20: 00000000000000cd ffffff8008c2b6e0
0000000000010000 ffffff8008c2b6e0
[    0.278858] ba40: 0000000000000001 0000000000000068
ffffffffffffffff 0000000000000001
[    0.278945] ba60: 0000000000000007 000000000000000e
[    0.279000] [<ffffff80081636bc>] drain_all_pages+0x244/0x25c
[    0.279065] [<ffffff80081c675c>] start_isolate_page_range+0x14c/0x1f0
[    0.279137] [<ffffff8008166a48>] alloc_contig_range+0xec/0x354
[    0.279203] [<ffffff80081c6c5c>] cma_alloc+0x100/0x1fc
[    0.279263] [<ffffff8008481714>] dma_alloc_from_contiguous+0x3c/0x44
[    0.279336] [<ffffff8008b25720>] atomic_pool_init+0x7c/0x208
[    0.279399] [<ffffff8008b258f0>] arm64_dma_init+0x44/0x4c
[    0.279461] [<ffffff8008083144>] do_one_initcall+0x38/0x128
[    0.279525] [<ffffff8008b20d30>] kernel_init_freeable+0x1a0/0x240
[    0.279596] [<ffffff8008807778>] kernel_init+0x10/0xfc
[    0.279654] [<ffffff8008082b70>] ret_from_fork+0x10/0x20


Regards,
Leo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
