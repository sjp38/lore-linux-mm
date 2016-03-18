Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 54B07828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 09:42:33 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id l124so31669320wmf.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 06:42:33 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id g130si16883016wma.19.2016.03.18.06.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Mar 2016 06:42:32 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id p65so37925507wmp.0
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 06:42:32 -0700 (PDT)
Date: Fri, 18 Mar 2016 14:42:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,writeback: Don't use memory reserves for
 wb_start_writeback
Message-ID: <20160318134230.GC30225@dhcp22.suse.cz>
References: <1457847155-19394-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201603132322.BEA57780.QMVOHFOSFJLOtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603132322.BEA57780.QMVOHFOSFJLOtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: viro@zeniv.linux.org.uk, tj@kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sun 13-03-16 23:22:23, Tetsuo Handa wrote:
[...]
> >From 5d43acbc5849a63494a732e39374692822145923 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 13 Mar 2016 23:03:05 +0900
> Subject: [PATCH] mm,writeback: Don't use memory reserves for
>  wb_start_writeback
> 
> When writeback operation cannot make forward progress because memory
> allocation requests needed for doing I/O cannot be satisfied (e.g.
> under OOM-livelock situation), we can observe flood of order-0 page
> allocation failure messages caused by complete depletion of memory
> reserves.
> 
> This is caused by unconditionally allocating "struct wb_writeback_work"
> objects using GFP_ATOMIC from PF_MEMALLOC context.
> 
> __alloc_pages_nodemask() {
>   __alloc_pages_slowpath() {
>     __alloc_pages_direct_reclaim() {
>       __perform_reclaim() {
>         current->flags |= PF_MEMALLOC;
>         try_to_free_pages() {
>           do_try_to_free_pages() {
>             wakeup_flusher_threads() {
>               wb_start_writeback() {
>                 kzalloc(sizeof(*work), GFP_ATOMIC) {
>                   /* ALLOC_NO_WATERMARKS via PF_MEMALLOC */
>                 }
>               }
>             }
>           }
>         }
>         current->flags &= ~PF_MEMALLOC;
>       }
>     }
>   }
> }
> 
> Since I/O is stalling, allocating writeback requests forever shall deplete
> memory reserves. Fortunately, since wb_start_writeback() can fall back to
> wb_wakeup() when allocating "struct wb_writeback_work" failed, we don't
> need to allow wb_start_writeback() to use memory reserves.
> 
> ----------
> [   59.562581] Mem-Info:
> [   59.563935] active_anon:289393 inactive_anon:2093 isolated_anon:29
> [   59.563935]  active_file:10838 inactive_file:113013 isolated_file:859
> [   59.563935]  unevictable:0 dirty:108531 writeback:5308 unstable:0
> [   59.563935]  slab_reclaimable:5526 slab_unreclaimable:7077
> [   59.563935]  mapped:9970 shmem:2159 pagetables:2387 bounce:0
> [   59.563935]  free:3042 free_pcp:0 free_cma:0
> [   59.574558] Node 0 DMA free:6968kB min:44kB low:52kB high:64kB active_anon:6056kB inactive_anon:176kB active_file:712kB inactive_file:744kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:756kB writeback:0kB mapped:736kB shmem:184kB slab_reclaimable:48kB slab_unreclaimable:208kB kernel_stack:160kB pagetables:144kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:9708 all_unreclaimable? yes
> [   59.585464] lowmem_reserve[]: 0 1732 1732 1732
> [   59.587123] Node 0 DMA32 free:5200kB min:5200kB low:6500kB high:7800kB active_anon:1151516kB inactive_anon:8196kB active_file:42640kB inactive_file:451076kB unevictable:0kB isolated(anon):116kB isolated(file):3564kB present:2080640kB managed:1775332kB mlocked:0kB dirty:433368kB writeback:21232kB mapped:39144kB shmem:8452kB slab_reclaimable:22056kB slab_unreclaimable:28100kB kernel_stack:20976kB pagetables:9404kB unstable:0kB bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:2701604 all_unreclaimable? no
> [   59.599649] lowmem_reserve[]: 0 0 0 0
> [   59.601431] Node 0 DMA: 25*4kB (UME) 16*8kB (UME) 3*16kB (UE) 5*32kB (UME) 2*64kB (UM) 2*128kB (ME) 2*256kB (ME) 1*512kB (E) 1*1024kB (E) 2*2048kB (ME) 0*4096kB = 6964kB
> [   59.606509] Node 0 DMA32: 925*4kB (UME) 140*8kB (UME) 5*16kB (ME) 5*32kB (M) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5060kB
> [   59.610415] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
> [   59.612879] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> [   59.615308] 126847 total pagecache pages
> [   59.616921] 0 pages in swap cache
> [   59.618475] Swap cache stats: add 0, delete 0, find 0/0
> [   59.620268] Free swap  = 0kB
> [   59.621650] Total swap = 0kB
> [   59.623011] 524157 pages RAM
> [   59.624365] 0 pages HighMem/MovableOnly
> [   59.625893] 76348 pages reserved
> [   59.627506] 0 pages hwpoisoned
> [   59.628838] Out of memory: Kill process 4450 (file_io.00) score 998 or sacrifice child
> [   59.631071] Killed process 4450 (file_io.00) total-vm:4308kB, anon-rss:100kB, file-rss:1184kB, shmem-rss:0kB
> [   61.526353] kthreadd: page allocation failure: order:0, mode:0x2200020
> [   61.527976] file_io.00: page allocation failure: order:0, mode:0x2200020
> [   61.527978] CPU: 0 PID: 4457 Comm: file_io.00 Not tainted 4.5.0-rc7+ #45
> [   61.527979] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [   61.527981]  0000000000000086 000000000005bb2d ffff88006cc5b588 ffffffff812a4d65
> [   61.527982]  0000000002200020 0000000000000000 ffff88006cc5b618 ffffffff81106dc7
> [   61.527983]  0000000000000000 ffffffffffffffff 00ff880000000000 ffff880000000004
> [   61.527983] Call Trace:
> [   61.528009]  [<ffffffff812a4d65>] dump_stack+0x4d/0x68
> [   61.528012]  [<ffffffff81106dc7>] warn_alloc_failed+0xf7/0x150
> [   61.528014]  [<ffffffff81109e3f>] __alloc_pages_nodemask+0x23f/0xa60
> [   61.528016]  [<ffffffff81137770>] ? page_check_address_transhuge+0x350/0x350
> [   61.528018]  [<ffffffff8111327d>] ? page_evictable+0xd/0x40
> [   61.528019]  [<ffffffff8114d927>] alloc_pages_current+0x87/0x110
> [   61.528021]  [<ffffffff81155181>] new_slab+0x3a1/0x440
> [   61.528023]  [<ffffffff81156fdf>] ___slab_alloc+0x3cf/0x590
> [   61.528024]  [<ffffffff811a0999>] ? wb_start_writeback+0x39/0x90
> [   61.528027]  [<ffffffff815a7f68>] ? preempt_schedule_common+0x1f/0x37
> [   61.528028]  [<ffffffff815a7f9f>] ? preempt_schedule+0x1f/0x30
> [   61.528030]  [<ffffffff81001012>] ? ___preempt_schedule+0x12/0x14
> [   61.528030]  [<ffffffff811a0999>] ? wb_start_writeback+0x39/0x90
> [   61.528032]  [<ffffffff81175536>] __slab_alloc.isra.64+0x18/0x1d
> [   61.528033]  [<ffffffff8115778c>] kmem_cache_alloc+0x11c/0x150
> [   61.528034]  [<ffffffff811a0999>] wb_start_writeback+0x39/0x90
> [   61.528035]  [<ffffffff811a0d9f>] wakeup_flusher_threads+0x7f/0xf0
> [   61.528036]  [<ffffffff81115ac9>] do_try_to_free_pages+0x1f9/0x410
> [   61.528037]  [<ffffffff81115d74>] try_to_free_pages+0x94/0xc0
> [   61.528038]  [<ffffffff8110a166>] __alloc_pages_nodemask+0x566/0xa60
> [   61.528040]  [<ffffffff81200878>] ? xfs_bmapi_read+0x208/0x2f0
> [   61.528041]  [<ffffffff8114d927>] alloc_pages_current+0x87/0x110
> [   61.528042]  [<ffffffff8110092f>] __page_cache_alloc+0xaf/0xc0
> [   61.528043]  [<ffffffff811011e8>] pagecache_get_page+0x88/0x260
> [   61.528044]  [<ffffffff81101d31>] grab_cache_page_write_begin+0x21/0x40
> [   61.528046]  [<ffffffff81222c9f>] xfs_vm_write_begin+0x2f/0xf0
> [   61.528047]  [<ffffffff810b14be>] ? current_fs_time+0x1e/0x30
> [   61.528048]  [<ffffffff81101eca>] generic_perform_write+0xca/0x1c0
> [   61.528050]  [<ffffffff8107c390>] ? wake_up_process+0x10/0x20
> [   61.528051]  [<ffffffff8122e01c>] xfs_file_buffered_aio_write+0xcc/0x1f0
> [   61.528052]  [<ffffffff81079037>] ? finish_task_switch+0x77/0x280
> [   61.528053]  [<ffffffff8122e1c4>] xfs_file_write_iter+0x84/0x140
> [   61.528054]  [<ffffffff811777a7>] __vfs_write+0xc7/0x100
> [   61.528055]  [<ffffffff811784cd>] vfs_write+0x9d/0x190
> [   61.528056]  [<ffffffff810010a1>] ? do_audit_syscall_entry+0x61/0x70
> [   61.528057]  [<ffffffff811793c0>] SyS_write+0x50/0xc0
> [   61.528059]  [<ffffffff815ab4d7>] entry_SYSCALL_64_fastpath+0x12/0x6a
> [   61.528059] Mem-Info:
> [   61.528062] active_anon:293335 inactive_anon:2093 isolated_anon:0
> [   61.528062]  active_file:10829 inactive_file:110045 isolated_file:32
> [   61.528062]  unevictable:0 dirty:109275 writeback:822 unstable:0
> [   61.528062]  slab_reclaimable:5489 slab_unreclaimable:10070
> [   61.528062]  mapped:9999 shmem:2159 pagetables:2420 bounce:0
> [   61.528062]  free:3 free_pcp:0 free_cma:0
> [   61.528065] Node 0 DMA free:12kB min:44kB low:52kB high:64kB active_anon:6060kB inactive_anon:176kB active_file:708kB inactive_file:756kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:756kB writeback:0kB mapped:736kB shmem:184kB slab_reclaimable:48kB slab_unreclaimable:7160kB kernel_stack:160kB pagetables:144kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:9844 all_unreclaimable? yes
> [   61.528066] lowmem_reserve[]: 0 1732 1732 1732
> [   61.528068] Node 0 DMA32 free:0kB min:5200kB low:6500kB high:7800kB active_anon:1167280kB inactive_anon:8196kB active_file:42608kB inactive_file:439424kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:2080640kB managed:1775332kB mlocked:0kB dirty:436344kB writeback:3288kB mapped:39260kB shmem:8452kB slab_reclaimable:21908kB slab_unreclaimable:33120kB kernel_stack:20976kB pagetables:9536kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:11073180 all_unreclaimable? yes
> [   61.528069] lowmem_reserve[]: 0 0 0 0
> [   61.528072] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   61.528074] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   61.528075] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
> [   61.528075] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> [   61.528076] 123086 total pagecache pages
> [   61.528076] 0 pages in swap cache
> [   61.528077] Swap cache stats: add 0, delete 0, find 0/0
> [   61.528077] Free swap  = 0kB
> [   61.528077] Total swap = 0kB
> [   61.528077] 524157 pages RAM
> [   61.528078] 0 pages HighMem/MovableOnly
> [   61.528078] 76348 pages reserved
> [   61.528078] 0 pages hwpoisoned
> [   61.528079] SLUB: Unable to allocate memory on node -1 (gfp=0x2088020)
> [   61.528080]   cache: kmalloc-64, object size: 64, buffer size: 64, default order: 0, min order: 0
> [   61.528080]   node 0: slabs: 3218, objs: 205952, free: 0
> [   61.528085] file_io.00: page allocation failure: order:0, mode:0x2200020
> [   61.528086] CPU: 0 PID: 4457 Comm: file_io.00 Not tainted 4.5.0-rc7+ #45
> ----------
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  fs/fs-writeback.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 5c46ed9..21450c7 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -929,7 +929,8 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  	 * This is WB_SYNC_NONE writeback, so if allocation fails just
>  	 * wakeup the thread for old dirty data writeback
>  	 */
> -	work = kzalloc(sizeof(*work), GFP_ATOMIC);
> +	work = kzalloc(sizeof(*work),
> +		       GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
>  	if (!work) {
>  		trace_writeback_nowork(wb);
>  		wb_wakeup(wb);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
