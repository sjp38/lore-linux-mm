Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BE7546B004F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 00:54:47 -0400 (EDT)
Date: Fri, 22 May 2009 13:39:06 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] synchrouns swap freeing at zapping vmas
Message-Id: <20090522133906.66fea0fe.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 21 May 2009 16:41:00 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> In these 6-7 weeks, we tried to fix memcg's swap-leak race by checking
> swap is valid or not after I/O. But Andrew Morton pointed out that
> "trylock in free_swap_and_cache() is not good"
> Oh, yes. it's not good.
> 
> Then, this patch series is a trial to remove trylock for swapcache AMAP.
> Patches are more complex and larger than expected but the behavior itself is
> much appreciate than prevoius my posts for memcg...
>  
> This series contains 2 patches.
>   1. change refcounting in swap_map.
>      This is for allowing swap_map to indicate there is swap reference/cache.
>   2. synchronous freeing of swap entries.
>      For avoiding race, free swap_entries in appropriate way with lock_page().
>      After this patch, race between swapin-readahead v.s. zap_page_range()
>      will go away.
>      Note: the whole code for zap_page_range() will not work until the system
>      or cgroup is very swappy. So, no influence in typical case.
> 
> There are used trylocks more than this patch treats. But IIUC, they are not
> racy with memcg and I don't care them.
> (And....I have no idea to remove trylock() in free_pages_and_swapcache(),
>  which is called via tlb_flush_mmu()....preemption disabled and using percpu.)
> 
> These patches + Nishimura-san's writeback fix will do complete work, I think.
> But test is not enough.
> 
I've not reviewed those patches(especially 2/2) in detail, I run some tests
and saw some strange behaviors.

- system global oom was invoked after a few minites. I've never seen even memcg's oom
  in this test.

        page01 invoked oom-killer: gfp_mask=0x0, order=0, oomkilladj=0
        Pid: 20485, comm: page01 Not tainted 2.6.30-rc5-69e923d8 #2
        Call Trace:
         [<ffffffff804ee0ed>] ? _spin_unlock+0x17/0x20
         [<ffffffff8028f702>] ? oom_kill_process+0x96/0x265
         [<ffffffff8028fbf5>] ? __out_of_memory+0x31/0x81
         [<ffffffff80290062>] ? pagefault_out_of_memory+0x64/0x92
         [<ffffffff804eea9f>] ? page_fault+0x1f/0x30
        Node 0 DMA per-cpu:
        CPU    0: hi:    0, btch:   1 usd:   0
        CPU    1: hi:    0, btch:   1 usd:   0
        CPU    2: hi:    0, btch:   1 usd:   0
        CPU    3: hi:    0, btch:   1 usd:   0
        CPU    4: hi:    0, btch:   1 usd:   0
        CPU    5: hi:    0, btch:   1 usd:   0
        CPU    6: hi:    0, btch:   1 usd:   0
        CPU    7: hi:    0, btch:   1 usd:   0
        CPU    8: hi:    0, btch:   1 usd:   0
        CPU    9: hi:    0, btch:   1 usd:   0
        CPU   10: hi:    0, btch:   1 usd:   0
        CPU   11: hi:    0, btch:   1 usd:   0
        CPU   12: hi:    0, btch:   1 usd:   0
        CPU   13: hi:    0, btch:   1 usd:   0
        CPU   14: hi:    0, btch:   1 usd:   0
        CPU   15: hi:    0, btch:   1 usd:   0
        Node 0 DMA32 per-cpu:
        CPU    0: hi:  186, btch:  31 usd:  69
        CPU    1: hi:  186, btch:  31 usd:  77
        CPU    2: hi:  186, btch:  31 usd: 144
        CPU    3: hi:  186, btch:  31 usd:  19
        CPU    4: hi:  186, btch:  31 usd:  59
        CPU    5: hi:  186, btch:  31 usd:  41
        CPU    6: hi:  186, btch:  31 usd:   0
        CPU    7: hi:  186, btch:  31 usd:  38
        CPU    8: hi:  186, btch:  31 usd: 117
        CPU    9: hi:  186, btch:  31 usd:  75
        CPU   10: hi:  186, btch:  31 usd: 106
        CPU   11: hi:  186, btch:  31 usd: 117
        CPU   12: hi:  186, btch:  31 usd: 159
        CPU   13: hi:  186, btch:  31 usd: 142
        CPU   14: hi:  186, btch:  31 usd: 161
        CPU   15: hi:  186, btch:  31 usd: 160
        Node 0 Normal per-cpu:
        CPU    0: hi:   90, btch:  15 usd:  32
        CPU    1: hi:   90, btch:  15 usd:  49
        CPU    2: hi:   90, btch:  15 usd:  57
        CPU    3: hi:   90, btch:  15 usd:  94
        CPU    4: hi:   90, btch:  15 usd:  54
        CPU    5: hi:   90, btch:  15 usd:  80
        CPU    6: hi:   90, btch:  15 usd:  49
        CPU    7: hi:   90, btch:  15 usd:  89
        CPU    8: hi:   90, btch:  15 usd:  37
        CPU    9: hi:   90, btch:  15 usd:  76
        CPU   10: hi:   90, btch:  15 usd:  45
        CPU   11: hi:   90, btch:  15 usd:  57
        CPU   12: hi:   90, btch:  15 usd: 100
        CPU   13: hi:   90, btch:  15 usd:  74
        CPU   14: hi:   90, btch:  15 usd:  73
        CPU   15: hi:   90, btch:  15 usd:  47
        Node 1 Normal per-cpu:
        CPU    0: hi:  186, btch:  31 usd:   0
        CPU    1: hi:  186, btch:  31 usd:   0
        CPU    2: hi:  186, btch:  31 usd:   0
        CPU    3: hi:  186, btch:  31 usd:   0
        CPU    4: hi:  186, btch:  31 usd:   0
        CPU    5: hi:  186, btch:  31 usd:   0
        CPU    6: hi:  186, btch:  31 usd:   0
        CPU    7: hi:  186, btch:  31 usd:   0
        CPU    8: hi:  186, btch:  31 usd:   0
        CPU    9: hi:  186, btch:  31 usd:   0
        CPU   10: hi:  186, btch:  31 usd:   0
        CPU   11: hi:  186, btch:  31 usd:   0
        CPU   12: hi:  186, btch:  31 usd:   0
        CPU   13: hi:  186, btch:  31 usd:   0
        CPU   14: hi:  186, btch:  31 usd:   0
        CPU   15: hi:  186, btch:  31 usd:   0
        Node 2 Normal per-cpu:
        CPU    0: hi:  186, btch:  31 usd:   0
        CPU    1: hi:  186, btch:  31 usd:   0
        CPU    2: hi:  186, btch:  31 usd:   0
        CPU    3: hi:  186, btch:  31 usd:   0
        CPU    4: hi:  186, btch:  31 usd:   0
        CPU    5: hi:  186, btch:  31 usd:   0
        CPU    6: hi:  186, btch:  31 usd:   0
        CPU    7: hi:  186, btch:  31 usd:   0
        CPU    8: hi:  186, btch:  31 usd:   0
        CPU    9: hi:  186, btch:  31 usd:   0
        CPU   10: hi:  186, btch:  31 usd:   0
        CPU   11: hi:  186, btch:  31 usd:   0
        CPU   12: hi:  186, btch:  31 usd:   0
        CPU   13: hi:  186, btch:  31 usd:   0
        CPU   14: hi:  186, btch:  31 usd:   0
        CPU   15: hi:  186, btch:  31 usd:   0
        Node 3 Normal per-cpu:
        CPU    0: hi:  186, btch:  31 usd:   0
        CPU    1: hi:  186, btch:  31 usd:   0
        CPU    2: hi:  186, btch:  31 usd: 164
        CPU    3: hi:  186, btch:  31 usd:   0
        CPU    4: hi:  186, btch:  31 usd:   0
        CPU    5: hi:  186, btch:  31 usd:   0
        CPU    6: hi:  186, btch:  31 usd:   0
        CPU    7: hi:  186, btch:  31 usd:   0
        CPU    8: hi:  186, btch:  31 usd:   0
        CPU    9: hi:  186, btch:  31 usd:   0
        CPU   10: hi:  186, btch:  31 usd:   0
        CPU   11: hi:  186, btch:  31 usd:   0
        CPU   12: hi:  186, btch:  31 usd:  86
        CPU   13: hi:  186, btch:  31 usd:  36
        CPU   14: hi:  186, btch:  31 usd: 179
        CPU   15: hi:  186, btch:  31 usd: 120
        Active_anon:49386 active_file:7453 inactive_anon:4256
         inactive_file:62010 unevictable:0 dirty:0 writeback:10 unstable:0
         free:3319229 slab:12952 mapped:9282 pagetables:4893 bounce:0
        Node 0 DMA free:3784kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15100kB pages_scanned:0 all_unreclaimable? no
        lowmem_reserve[]: 0 3204 3453 3453
        Node 0 DMA32 free:2938020kB min:3472kB low:4340kB high:5208kB active_anon:24280kB inactive_anon:17024kB active_file:1600kB inactive_file:44032kB unevictable:0kB present:3281248kB pages_scanned:0 all_unreclaimable? no
        lowmem_reserve[]: 0 0 249 249
        Node 0 Normal free:292kB min:268kB low:332kB high:400kB active_anon:29872kB inactive_anon:0kB active_file:23096kB inactive_file:152440kB unevictable:0kB present:255488kB pages_scanned:0 all_unreclaimable? no
        lowmem_reserve[]: 0 0 0 0
        Node 1 Normal free:3522552kB min:3784kB low:4728kB high:5676kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3576832kB pages_scanned:0 all_unreclaimable? no
        lowmem_reserve[]: 0 0 0 0
        Node 2 Normal free:3520304kB min:3784kB low:4728kB high:5676kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3576832kB pages_scanned:0 all_unreclaimable? no
        lowmem_reserve[]: 0 0 0 0
        Node 3 Normal free:3291964kB min:3784kB low:4728kB high:5676kB active_anon:143392kB inactive_anon:0kB active_file:5116kB inactive_file:51568kB unevictable:0kB present:3576832kB pages_scanned:0 all_unreclaimable? no
        lowmem_reserve[]: 0 0 0 0
        Node 0 DMA: 2*4kB 4*8kB 2*16kB 4*32kB 2*64kB 3*128kB 2*256kB 1*512kB 2*1024kB 0*2048kB 0*4096kB = 3784kB
        Node 0 DMA32: 59*4kB 29*8kB 17*16kB 40*32kB 29*64kB 3*128kB 4*256kB 2*512kB 1*1024kB 3*2048kB 714*4096kB = 2938020kB
        Node 0 Normal: 35*4kB 9*8kB 3*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 292kB
        Node 1 Normal: 8*4kB 9*8kB 9*16kB 6*32kB 5*64kB 6*128kB 4*256kB 3*512kB 6*1024kB 3*2048kB 856*4096kB = 3522552kB
        Node 2 Normal: 10*4kB 9*8kB 6*16kB 7*32kB 6*64kB 8*128kB 4*256kB 4*512kB 5*1024kB 2*2048kB 856*4096kB = 3520304kB
        Node 3 Normal: 70*4kB 23*8kB 9*16kB 8*32kB 7*64kB 2*128kB 3*256kB 3*512kB 3*1024kB 4*2048kB 800*4096kB = 3291936kB
        73041 total pagecache pages
        3220 pages in swap cache
        Swap cache stats: add 2206323, delete 2203103, find 1254789/1376833
        Free swap  = 1978488kB
        Total swap = 2000888kB

- Using shmem caused a BUG.

        BUG: sleeping function called from invalid context at include/linux/pagemap.h:327
        in_atomic(): 1, irqs_disabled(): 0, pid: 1113, name: shmem_test_02
        no locks held by shmem_test_02/1113.
        Pid: 1113, comm: shmem_test_02 Not tainted 2.6.30-rc5-69e923d8 #2
        Call Trace:
         [<ffffffff802ad004>] ? free_swap_batch+0x40/0x7f
         [<ffffffff80299b58>] ? shmem_free_swp+0xac/0xca
         [<ffffffff8029a0f1>] ? shmem_truncate_range+0x57b/0x7af
         [<ffffffff80378393>] ? __percpu_counter_add+0x3e/0x5c
         [<ffffffff8029c458>] ? shmem_delete_inode+0x77/0xd3
         [<ffffffff8029c3e1>] ? shmem_delete_inode+0x0/0xd3
         [<ffffffff802d3ab7>] ? generic_delete_inode+0xe0/0x178
         [<ffffffff802d0dda>] ? d_kill+0x24/0x46
         [<ffffffff802d2212>] ? dput+0x134/0x141
         [<ffffffff802c3504>] ? __fput+0x189/0x1ba
         [<ffffffff802a50e4>] ? remove_vma+0x4e/0x83
         [<ffffffff802a5224>] ? exit_mmap+0x10b/0x129
         [<ffffffff80238fbd>] ? mmput+0x41/0x9f
         [<ffffffff8023cf37>] ? exit_mm+0x101/0x10c
         [<ffffffff8023e439>] ? do_exit+0x1a0/0x61a
         [<ffffffff80259253>] ? trace_hardirqs_on_caller+0x113/0x13e
         [<ffffffff8023e926>] ? do_group_exit+0x73/0xa5
         [<ffffffff8023e96a>] ? sys_exit_group+0x12/0x16
         [<ffffffff8020b96b>] ? system_call_fastpath+0x16/0x1b

(include/linux/pagemap.h)
    325 static inline void lock_page(struct page *page)
    326 {
    327         might_sleep();
    328         if (!trylock_page(page))
    329                 __lock_page(page);
    330 }
    331


I hope they would be some help for you.

Thanks,
Daisuke Nishimura.

> Any comments are welcome. 
> 
> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
