Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id BCF156B0005
	for <linux-mm@kvack.org>; Sun, 13 Mar 2016 10:22:31 -0400 (EDT)
Received: by mail-io0-f174.google.com with SMTP id z76so195962216iof.3
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 07:22:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p143si10818195ioe.96.2016.03.13.07.22.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 13 Mar 2016 07:22:30 -0700 (PDT)
Subject: Re: [PATCH] mm,writeback: Don't use memory reserves for wb_start_writeback
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1457847155-19394-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1457847155-19394-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201603132322.BEA57780.QMVOHFOSFJLOtF@I-love.SAKURA.ne.jp>
Date: Sun, 13 Mar 2016 23:22:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, viro@zeniv.linux.org.uk, tj@kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Tetsuo Handa wrote:
> Since I/O is stalling, allocating writeback requests forever shall deplete
> memory reserves. Fortunately, since wb_start_writeback() can fall back to
> wb_wakeup() when allocating "struct wb_writeback_work" failed, we don't
> need to use ALLOC_NO_WATERMARKS for wb_start_writeback().

Well, maybe we should not use memory reserves at all.

I retested with this patch and kmallocwd patch applied. While depletion
of memory reserves by wb_start_writeback() no longer occurs, I can
still observe order-0 page allocation failure messages caused by
GFP_ATOMIC allocation requests because wb_start_writeback() consumed
memory reserves to the level where GFP_ATOMIC starts failing.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160313.txt.xz .
----------
[   89.794733] swapper/2: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[   89.804714] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.5.0-rc7-next-20160311+ #399
[   89.813049] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   89.819803]  0000000000000086 631ee38347526c6b ffff88007fc83640 ffffffff812b5c97
[   89.823859]  0000000000000000 0000000000000000 ffff88007fc836d0 ffffffff811131b1
[   89.827917]  02200020ffffffff 0000000000000040 fffffffffffffffe 0000000000000000
[   89.831879] Call Trace:
[   89.834214]  <IRQ>  [<ffffffff812b5c97>] dump_stack+0x4f/0x68
[   89.837652]  [<ffffffff811131b1>] warn_alloc_failed+0x101/0x160
[   89.841115]  [<ffffffff81116521>] __alloc_pages_nodemask+0x481/0xd50
[   89.844677]  [<ffffffff8115b977>] alloc_pages_current+0x87/0x110
[   89.848158]  [<ffffffff81163fe0>] new_slab+0x540/0x550
[   89.851355]  [<ffffffff8116624d>] ___slab_alloc+0x46d/0x580
[   89.854856]  [<ffffffffa0317180>] ? __nf_ct_ext_add_length+0x1a0/0x1e0 [nf_conntrack]
[   89.858996]  [<ffffffffa0310e2d>] ? __nf_conntrack_alloc.isra.35+0x5d/0x1b0 [nf_conntrack]
[   89.863170]  [<ffffffff8116611f>] ? ___slab_alloc+0x33f/0x580
[   89.866604]  [<ffffffff8110ff20>] ? mempool_alloc_slab+0x10/0x20
[   89.870141]  [<ffffffff8110ff20>] ? mempool_alloc_slab+0x10/0x20
[   89.873866]  [<ffffffff8118435b>] __slab_alloc.isra.68+0x46/0x55
[   89.877354]  [<ffffffffa0317180>] ? __nf_ct_ext_add_length+0x1a0/0x1e0 [nf_conntrack]
[   89.881370]  [<ffffffffa0317180>] ? __nf_ct_ext_add_length+0x1a0/0x1e0 [nf_conntrack]
[   89.885328]  [<ffffffff81166666>] __kmalloc+0x146/0x190
[   89.888559]  [<ffffffffa0317180>] __nf_ct_ext_add_length+0x1a0/0x1e0 [nf_conntrack]
[   89.892538]  [<ffffffffa0310ebb>] ? __nf_conntrack_alloc.isra.35+0xeb/0x1b0 [nf_conntrack]
[   89.896557]  [<ffffffffa031150c>] nf_conntrack_in+0x56c/0x830 [nf_conntrack]
[   89.900166]  [<ffffffffa0330327>] ipv4_conntrack_in+0x17/0x20 [nf_conntrack_ipv4]
[   89.903902]  [<ffffffff81501848>] nf_iterate+0x58/0x70
[   89.906570]  [<ffffffff815018d6>] nf_hook_slow+0x76/0xd0
[   89.908271]  [<ffffffff8150b0a8>] ip_rcv+0x2f8/0x410
[   89.909803]  [<ffffffff8150a7f0>] ? ip_local_deliver_finish+0x1e0/0x1e0
[   89.911516]  [<ffffffff814cc9f4>] __netif_receive_skb_core+0x354/0x9b0
[   89.913284]  [<ffffffff8153c79f>] ? udp4_gro_receive+0x1ef/0x2a0
[   89.914906]  [<ffffffff81544bd2>] ? inet_gro_receive+0x92/0x230
[   89.916542]  [<ffffffff814cefe3>] __netif_receive_skb+0x13/0x60
[   89.918099]  [<ffffffff814cf0a6>] netif_receive_skb_internal+0x76/0xd0
[   89.919710]  [<ffffffff814cfae8>] napi_gro_receive+0x78/0xc0
[   89.921399]  [<ffffffffa0065e43>] e1000_clean_rx_irq+0x153/0x490 [e1000]
[   89.923038]  [<ffffffffa0063ccf>] e1000_clean+0x25f/0x8b0 [e1000]
[   89.924601]  [<ffffffff8107fb31>] ? check_preempt_curr+0x71/0x90
[   89.926098]  [<ffffffff814d0acb>] net_rx_action+0x14b/0x320
[   89.927636]  [<ffffffff81060cd1>] __do_softirq+0xd1/0x250
[   89.929034]  [<ffffffff810610d4>] irq_exit+0xe4/0x100
[   89.930443]  [<ffffffff8101b2bd>] do_IRQ+0x5d/0xf0
[   89.931769]  [<ffffffff815cc6c9>] common_interrupt+0x89/0x89
[   89.933210]  <EOI>  [<ffffffff81022e0b>] ? default_idle+0xb/0x20
[   89.935050]  [<ffffffff8102340a>] arch_cpu_idle+0xa/0x10
[   89.936480]  [<ffffffff81098625>] default_idle_call+0x25/0x30
[   89.938031]  [<ffffffff81098845>] cpu_startup_entry+0x215/0x2a0
[   89.939517]  [<ffffffff8103924b>] start_secondary+0x14b/0x170
[   89.941103] Mem-Info:
[   89.942132] active_anon:288561 inactive_anon:2093 isolated_anon:0
[   89.942132]  active_file:10819 inactive_file:114585 isolated_file:32
[   89.942132]  unevictable:0 dirty:113936 writeback:679 unstable:0
[   89.942132]  slab_reclaimable:5394 slab_unreclaimable:7802
[   89.942132]  mapped:10005 shmem:2159 pagetables:2415 bounce:0
[   89.942132]  free:2367 free_pcp:98 free_cma:0
[   89.950633] Node 0 DMA free:6952kB min:44kB low:56kB high:68kB active_anon:5308kB inactive_anon:140kB active_file:548kB inactive_file:1452kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:1452kB writeback:0kB mapped:540kB shmem:148kB slab_reclaimable:84kB slab_unreclaimable:544kB kernel_stack:384kB pagetables:56kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:12224 all_unreclaimable? yes
[   89.960099] lowmem_reserve[]: 0 1732 1732 1732
[   89.961626] Node 0 DMA32 free:2516kB min:5200kB low:6972kB high:8744kB active_anon:1148936kB inactive_anon:8232kB active_file:42728kB inactive_file:456888kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:2080640kB managed:1775252kB mlocked:0kB dirty:454292kB writeback:2716kB mapped:39480kB shmem:8488kB slab_reclaimable:21492kB slab_unreclaimable:30664kB kernel_stack:20960kB pagetables:9604kB unstable:0kB bounce:0kB free_pcp:392kB local_pcp:88kB free_cma:0kB writeback_tmp:0kB pages_scanned:7473108 all_unreclaimable? yes
[   89.972153] lowmem_reserve[]: 0 0 0 0
[   89.973640] Node 0 DMA: 18*4kB (UM) 18*8kB (UE) 9*16kB (UE) 4*32kB (UE) 5*64kB (UME) 4*128kB (UME) 4*256kB (UE) 5*512kB (UME) 2*1024kB (UE) 0*2048kB 0*4096kB = 6952kB
[   89.978150] Node 0 DMA32: 281*4kB (UME) 172*8kB (UM) 1*16kB (E) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2516kB
[   89.981301] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   89.983498] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   89.985688] 127595 total pagecache pages
[   89.987068] 0 pages in swap cache
[   89.988344] Swap cache stats: add 0, delete 0, find 0/0
[   89.990303] Free swap  = 0kB
[   89.991505] Total swap = 0kB
[   89.992755] 524157 pages RAM
[   89.993945] 0 pages HighMem/MovableOnly
[   89.995279] 76368 pages reserved
[   89.996633] 0 pages hwpoisoned
[   89.997845] SLUB: Unable to allocate memory on node -1, gfp=0x2088020(GFP_ATOMIC|__GFP_ZERO)
[   90.000147]   cache: kmalloc-64, object size: 64, buffer size: 64, default order: 0, min order: 0
[   90.002463]   node 0: slabs: 728, objs: 46592, free: 0
[   90.549072] swapper/2: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[   90.559150] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.5.0-rc7-next-20160311+ #399
----------

While no messages printed under OOM-livelock situation is annoying and
page allocation failure messages by GFP_ATOMIC helps us to know we are
under OOM-livelock situation, we will need to kill more processes if we
allow wb_start_writeback() to consume half of memory reserves.

wb_start_writeback() should not try to consume until min: watermark so
that other GFP_NOIO allocations can succeed. But there is not such gfp
flags.

Anyway, please pick up below patch if you think GFP_NOWAIT is better than
GFP_ATOMIC.
----------------------------------------
>From 5d43acbc5849a63494a732e39374692822145923 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 13 Mar 2016 23:03:05 +0900
Subject: [PATCH] mm,writeback: Don't use memory reserves for
 wb_start_writeback

When writeback operation cannot make forward progress because memory
allocation requests needed for doing I/O cannot be satisfied (e.g.
under OOM-livelock situation), we can observe flood of order-0 page
allocation failure messages caused by complete depletion of memory
reserves.

This is caused by unconditionally allocating "struct wb_writeback_work"
objects using GFP_ATOMIC from PF_MEMALLOC context.

__alloc_pages_nodemask() {
  __alloc_pages_slowpath() {
    __alloc_pages_direct_reclaim() {
      __perform_reclaim() {
        current->flags |= PF_MEMALLOC;
        try_to_free_pages() {
          do_try_to_free_pages() {
            wakeup_flusher_threads() {
              wb_start_writeback() {
                kzalloc(sizeof(*work), GFP_ATOMIC) {
                  /* ALLOC_NO_WATERMARKS via PF_MEMALLOC */
                }
              }
            }
          }
        }
        current->flags &= ~PF_MEMALLOC;
      }
    }
  }
}

Since I/O is stalling, allocating writeback requests forever shall deplete
memory reserves. Fortunately, since wb_start_writeback() can fall back to
wb_wakeup() when allocating "struct wb_writeback_work" failed, we don't
need to allow wb_start_writeback() to use memory reserves.

----------
[   59.562581] Mem-Info:
[   59.563935] active_anon:289393 inactive_anon:2093 isolated_anon:29
[   59.563935]  active_file:10838 inactive_file:113013 isolated_file:859
[   59.563935]  unevictable:0 dirty:108531 writeback:5308 unstable:0
[   59.563935]  slab_reclaimable:5526 slab_unreclaimable:7077
[   59.563935]  mapped:9970 shmem:2159 pagetables:2387 bounce:0
[   59.563935]  free:3042 free_pcp:0 free_cma:0
[   59.574558] Node 0 DMA free:6968kB min:44kB low:52kB high:64kB active_anon:6056kB inactive_anon:176kB active_file:712kB inactive_file:744kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:756kB writeback:0kB mapped:736kB shmem:184kB slab_reclaimable:48kB slab_unreclaimable:208kB kernel_stack:160kB pagetables:144kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:9708 all_unreclaimable? yes
[   59.585464] lowmem_reserve[]: 0 1732 1732 1732
[   59.587123] Node 0 DMA32 free:5200kB min:5200kB low:6500kB high:7800kB active_anon:1151516kB inactive_anon:8196kB active_file:42640kB inactive_file:451076kB unevictable:0kB isolated(anon):116kB isolated(file):3564kB present:2080640kB managed:1775332kB mlocked:0kB dirty:433368kB writeback:21232kB mapped:39144kB shmem:8452kB slab_reclaimable:22056kB slab_unreclaimable:28100kB kernel_stack:20976kB pagetables:9404kB unstable:0kB bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:2701604 all_unreclaimable? no
[   59.599649] lowmem_reserve[]: 0 0 0 0
[   59.601431] Node 0 DMA: 25*4kB (UME) 16*8kB (UME) 3*16kB (UE) 5*32kB (UME) 2*64kB (UM) 2*128kB (ME) 2*256kB (ME) 1*512kB (E) 1*1024kB (E) 2*2048kB (ME) 0*4096kB = 6964kB
[   59.606509] Node 0 DMA32: 925*4kB (UME) 140*8kB (UME) 5*16kB (ME) 5*32kB (M) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5060kB
[   59.610415] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   59.612879] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   59.615308] 126847 total pagecache pages
[   59.616921] 0 pages in swap cache
[   59.618475] Swap cache stats: add 0, delete 0, find 0/0
[   59.620268] Free swap  = 0kB
[   59.621650] Total swap = 0kB
[   59.623011] 524157 pages RAM
[   59.624365] 0 pages HighMem/MovableOnly
[   59.625893] 76348 pages reserved
[   59.627506] 0 pages hwpoisoned
[   59.628838] Out of memory: Kill process 4450 (file_io.00) score 998 or sacrifice child
[   59.631071] Killed process 4450 (file_io.00) total-vm:4308kB, anon-rss:100kB, file-rss:1184kB, shmem-rss:0kB
[   61.526353] kthreadd: page allocation failure: order:0, mode:0x2200020
[   61.527976] file_io.00: page allocation failure: order:0, mode:0x2200020
[   61.527978] CPU: 0 PID: 4457 Comm: file_io.00 Not tainted 4.5.0-rc7+ #45
[   61.527979] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   61.527981]  0000000000000086 000000000005bb2d ffff88006cc5b588 ffffffff812a4d65
[   61.527982]  0000000002200020 0000000000000000 ffff88006cc5b618 ffffffff81106dc7
[   61.527983]  0000000000000000 ffffffffffffffff 00ff880000000000 ffff880000000004
[   61.527983] Call Trace:
[   61.528009]  [<ffffffff812a4d65>] dump_stack+0x4d/0x68
[   61.528012]  [<ffffffff81106dc7>] warn_alloc_failed+0xf7/0x150
[   61.528014]  [<ffffffff81109e3f>] __alloc_pages_nodemask+0x23f/0xa60
[   61.528016]  [<ffffffff81137770>] ? page_check_address_transhuge+0x350/0x350
[   61.528018]  [<ffffffff8111327d>] ? page_evictable+0xd/0x40
[   61.528019]  [<ffffffff8114d927>] alloc_pages_current+0x87/0x110
[   61.528021]  [<ffffffff81155181>] new_slab+0x3a1/0x440
[   61.528023]  [<ffffffff81156fdf>] ___slab_alloc+0x3cf/0x590
[   61.528024]  [<ffffffff811a0999>] ? wb_start_writeback+0x39/0x90
[   61.528027]  [<ffffffff815a7f68>] ? preempt_schedule_common+0x1f/0x37
[   61.528028]  [<ffffffff815a7f9f>] ? preempt_schedule+0x1f/0x30
[   61.528030]  [<ffffffff81001012>] ? ___preempt_schedule+0x12/0x14
[   61.528030]  [<ffffffff811a0999>] ? wb_start_writeback+0x39/0x90
[   61.528032]  [<ffffffff81175536>] __slab_alloc.isra.64+0x18/0x1d
[   61.528033]  [<ffffffff8115778c>] kmem_cache_alloc+0x11c/0x150
[   61.528034]  [<ffffffff811a0999>] wb_start_writeback+0x39/0x90
[   61.528035]  [<ffffffff811a0d9f>] wakeup_flusher_threads+0x7f/0xf0
[   61.528036]  [<ffffffff81115ac9>] do_try_to_free_pages+0x1f9/0x410
[   61.528037]  [<ffffffff81115d74>] try_to_free_pages+0x94/0xc0
[   61.528038]  [<ffffffff8110a166>] __alloc_pages_nodemask+0x566/0xa60
[   61.528040]  [<ffffffff81200878>] ? xfs_bmapi_read+0x208/0x2f0
[   61.528041]  [<ffffffff8114d927>] alloc_pages_current+0x87/0x110
[   61.528042]  [<ffffffff8110092f>] __page_cache_alloc+0xaf/0xc0
[   61.528043]  [<ffffffff811011e8>] pagecache_get_page+0x88/0x260
[   61.528044]  [<ffffffff81101d31>] grab_cache_page_write_begin+0x21/0x40
[   61.528046]  [<ffffffff81222c9f>] xfs_vm_write_begin+0x2f/0xf0
[   61.528047]  [<ffffffff810b14be>] ? current_fs_time+0x1e/0x30
[   61.528048]  [<ffffffff81101eca>] generic_perform_write+0xca/0x1c0
[   61.528050]  [<ffffffff8107c390>] ? wake_up_process+0x10/0x20
[   61.528051]  [<ffffffff8122e01c>] xfs_file_buffered_aio_write+0xcc/0x1f0
[   61.528052]  [<ffffffff81079037>] ? finish_task_switch+0x77/0x280
[   61.528053]  [<ffffffff8122e1c4>] xfs_file_write_iter+0x84/0x140
[   61.528054]  [<ffffffff811777a7>] __vfs_write+0xc7/0x100
[   61.528055]  [<ffffffff811784cd>] vfs_write+0x9d/0x190
[   61.528056]  [<ffffffff810010a1>] ? do_audit_syscall_entry+0x61/0x70
[   61.528057]  [<ffffffff811793c0>] SyS_write+0x50/0xc0
[   61.528059]  [<ffffffff815ab4d7>] entry_SYSCALL_64_fastpath+0x12/0x6a
[   61.528059] Mem-Info:
[   61.528062] active_anon:293335 inactive_anon:2093 isolated_anon:0
[   61.528062]  active_file:10829 inactive_file:110045 isolated_file:32
[   61.528062]  unevictable:0 dirty:109275 writeback:822 unstable:0
[   61.528062]  slab_reclaimable:5489 slab_unreclaimable:10070
[   61.528062]  mapped:9999 shmem:2159 pagetables:2420 bounce:0
[   61.528062]  free:3 free_pcp:0 free_cma:0
[   61.528065] Node 0 DMA free:12kB min:44kB low:52kB high:64kB active_anon:6060kB inactive_anon:176kB active_file:708kB inactive_file:756kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:756kB writeback:0kB mapped:736kB shmem:184kB slab_reclaimable:48kB slab_unreclaimable:7160kB kernel_stack:160kB pagetables:144kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:9844 all_unreclaimable? yes
[   61.528066] lowmem_reserve[]: 0 1732 1732 1732
[   61.528068] Node 0 DMA32 free:0kB min:5200kB low:6500kB high:7800kB active_anon:1167280kB inactive_anon:8196kB active_file:42608kB inactive_file:439424kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:2080640kB managed:1775332kB mlocked:0kB dirty:436344kB writeback:3288kB mapped:39260kB shmem:8452kB slab_reclaimable:21908kB slab_unreclaimable:33120kB kernel_stack:20976kB pagetables:9536kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:11073180 all_unreclaimable? yes
[   61.528069] lowmem_reserve[]: 0 0 0 0
[   61.528072] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   61.528074] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   61.528075] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   61.528075] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   61.528076] 123086 total pagecache pages
[   61.528076] 0 pages in swap cache
[   61.528077] Swap cache stats: add 0, delete 0, find 0/0
[   61.528077] Free swap  = 0kB
[   61.528077] Total swap = 0kB
[   61.528077] 524157 pages RAM
[   61.528078] 0 pages HighMem/MovableOnly
[   61.528078] 76348 pages reserved
[   61.528078] 0 pages hwpoisoned
[   61.528079] SLUB: Unable to allocate memory on node -1 (gfp=0x2088020)
[   61.528080]   cache: kmalloc-64, object size: 64, buffer size: 64, default order: 0, min order: 0
[   61.528080]   node 0: slabs: 3218, objs: 205952, free: 0
[   61.528085] file_io.00: page allocation failure: order:0, mode:0x2200020
[   61.528086] CPU: 0 PID: 4457 Comm: file_io.00 Not tainted 4.5.0-rc7+ #45
----------

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 fs/fs-writeback.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 5c46ed9..21450c7 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -929,7 +929,8 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
-	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	work = kzalloc(sizeof(*work),
+		       GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
 	if (!work) {
 		trace_writeback_nowork(wb);
 		wb_wakeup(wb);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
