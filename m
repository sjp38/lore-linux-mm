Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 19DB06B005D
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 18:41:00 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so1743534pbb.14
        for <linux-mm@kvack.org>; Sun, 09 Sep 2012 15:40:59 -0700 (PDT)
Date: Sun, 9 Sep 2012 15:40:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: iwl3945: order 5 allocation during ifconfig up; vm problem?
In-Reply-To: <20120909213228.GA5538@elf.ucw.cz>
Message-ID: <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com>
References: <20120909213228.GA5538@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: sgruszka@redhat.com, linux-wireless@vger.kernel.org, johannes.berg@intel.com, wey-yi.w.guy@intel.com, ilw@linux.intel.com, Andrew Morton <akpm@osdl.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 9 Sep 2012, Pavel Machek wrote:

> On 3.6.0-rc2+, I tried to turn on the wireless, but got
> 
> root@amd:~# ifconfig wlan0 10.0.0.6 up
> SIOCSIFFLAGS: Cannot allocate memory
> SIOCSIFFLAGS: Cannot allocate memory
> root@amd:~# 
> 
> It looks like it uses "a bit too big" allocations to allocate
> firmware...? Order five allocation....
> 
> Hmm... then I did "echo 3  > /proc/sys/vm/drop_caches" and now the
> network works. Is it VM problem that it failed to allocate memory when
> it was freeable?
> 

Do you have CONFIG_COMPACTION enabled?

> iwl3945 0000:03:00.0: failed to allocate pci memory
> iwl3945 0000:03:00.0: Could not read microcode: -12
> firmware 0000:03:00.0: firmware_loading_store: vmap() failed
> iwl3945 0000:03:00.0: iwlwifi-3945-2.ucode firmware file req failed:
> -2
> iwl3945 0000:03:00.0: Loaded firmware iwlwifi-3945-1.ucode, which is
> deprecated.  Please use API v2 instead.
> iwl3945 0000:03:00.0: loaded firmware version 15.32.2.9
> ifconfig: page allocation failure: order:5, mode:0x80d0
> Pid: 21116, comm: ifconfig Tainted: G        W    3.6.0-rc2+ #228
> Call Trace:
>  [<c029ebf6>] warn_alloc_failed+0xb6/0x100
>  [<c02a0321>] __alloc_pages_nodemask+0x4c1/0x6e0
>  [<c020699c>] dma_generic_alloc_coherent+0x8c/0xc0
>  [<c05c4d59>] il3945_mac_start+0x1269/0x1280
>  [<c0206910>] ? dma_generic_free_coherent+0x30/0x30
>  [<c0800f64>] ? packet_notifier+0xc4/0x1a0
>  [<c088094c>] ieee80211_do_open+0x28c/0x840
>  [<c087f399>] ? ieee80211_check_concurrent_iface+0x19/0x190
>  [<c024c7ea>] ? raw_notifier_call_chain+0x1a/0x20
>  [<c0880f3b>] ieee80211_open+0x3b/0x80
>  [<c0769966>] __dev_open+0x96/0xf0
>  [<c08c73a5>] ? _raw_spin_unlock_bh+0x25/0x30
>  [<c076633d>] __dev_change_flags+0x7d/0x150
>  [<c076988e>] dev_change_flags+0x1e/0x60
>  [<c07d819d>] devinet_ioctl+0x69d/0x770
>  [<c076b026>] ? dev_ioctl+0x336/0x740
>  [<c07d959a>] inet_ioctl+0x9a/0xc0
>  [<c0756a33>] sock_ioctl+0x63/0x240
>  [<c07569d0>] ? sock_fasync+0x80/0x80
>  [<c02d91a3>] do_vfs_ioctl+0x83/0x570
>  [<c0223a50>] ? mm_fault_error+0x170/0x170
>  [<c024ba86>] ? up_read+0x16/0x30
>  [<c0223bcc>] ? do_page_fault+0x17c/0x3b0
>  [<c02d96c9>] sys_ioctl+0x39/0x70
>  [<c08c7c10>] sysenter_do_call+0x12/0x31
> Mem-Info:
> DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd:  30
> CPU    1: hi:  186, btch:  31 usd:   0
> HighMem per-cpu:
> CPU    0: hi:  186, btch:  31 usd:   0
> CPU    1: hi:  186, btch:  31 usd:   0
> active_anon:250783 inactive_anon:118977 isolated_anon:0
>  active_file:14686 inactive_file:13826 isolated_file:0
>  unevictable:0 dirty:3050 writeback:0 unstable:0
>  free:30113 slab_reclaimable:43820 slab_unreclaimable:34426
>  mapped:11898 shmem:19084 pagetables:3043 bounce:0
> DMA free:1580kB min:64kB low:80kB high:96kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> isolated(anon):0kB isolated(file):0kB present:15788kB mlocked:0kB
> dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
> slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB
> bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> lowmem_reserve[]: 0 864 2005 2005
> Normal free:115348kB min:3728kB low:4660kB high:5592kB
> active_anon:193616kB inactive_anon:192540kB active_file:19528kB
> inactive_file:12916kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:885072kB mlocked:0kB dirty:5388kB
> writeback:0kB mapped:9212kB shmem:29100kB slab_reclaimable:175280kB
> slab_unreclaimable:137704kB kernel_stack:6032kB pagetables:12172kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? no
> lowmem_reserve[]: 0 0 9125 9125
> HighMem free:3524kB min:512kB low:1740kB high:2972kB
> active_anon:809516kB inactive_anon:283368kB active_file:39216kB
> inactive_file:42388kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:1168080kB mlocked:0kB dirty:6812kB
> writeback:0kB mapped:38380kB shmem:47236kB slab_reclaimable:0kB
> slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB
> bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> DMA: 1*4kB 1*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB
> 0*2048kB 0*4096kB = 1580kB
> Normal: 4729*4kB 8354*8kB 1683*16kB 74*32kB 4*64kB 0*128kB 0*256kB
> 0*512kB 0*1024kB 0*2048kB 0*4096kB = 115300kB
> HighMem: 537*4kB 118*8kB 27*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
> 0*1024kB 0*2048kB 0*4096kB = 3524kB
> 62305 total pagecache pages
> 14672 pages in swap cache
> Swap cache stats: add 96156, delete 81484, find 3042279/3044117
> Free swap  = 480024kB
> Total swap = 779148kB
> 521920 pages RAM
> 294610 pages HighMem
> 9083 pages reserved
> 244243 pages shared
> 450983 pages non-shared
> iwl3945 0000:03:00.0: failed to allocate pci memory
> iwl3945 0000:03:00.0: Could not read microcode: -12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
