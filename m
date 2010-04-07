Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4C5346B01EE
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 03:00:57 -0400 (EDT)
Date: Wed, 7 Apr 2010 15:00:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: 32GB SSD on USB1.1 P3/700 == ___HELL___ (2.6.34-rc3)
Message-ID: <20100407070050.GA10527@localhost>
References: <20100404221349.GA18036@rhlx01.hs-esslingen.de> <20100405105319.GA16528@rhlx01.hs-esslingen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100405105319.GA16528@rhlx01.hs-esslingen.de>
Sender: owner-linux-mm@kvack.org
To: Andreas Mohr <andi@lisas.de>
Cc: Jens Axboe <axboe@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andreas,

On Mon, Apr 05, 2010 at 06:53:20PM +0800, Andreas Mohr wrote:
> On Mon, Apr 05, 2010 at 12:13:49AM +0200, Andreas Mohr wrote:
> > Having an attempt at writing a 300M /dev/zero file to the SSD's filesystem
> > was even worse (again tons of unresponsiveness), combined with multiple
> > OOM conditions flying by (I/O to the main HDD was minimal, its LED was
> > almost always _off_, yet everything stuck to an absolute standstill).
> >
> > Clearly there's a very, very important limiter somewhere in bio layer
> > missing or broken, a 300M dd /dev/zero should never manage to put
> > such an onerous penalty on a system, IMHO.
> 
> Seems this issue is a variation of the usual "ext3 sync" problem,
> but in overly critical and unexpected ways (full lockup of almost everything,
> and multiple OOMs).
> 
> I retried writing the 300M file with a freshly booted system, and there
> were _no_ suspicious issues to be observed (free memory went all down to
> 5M, not too problematic), well, that is, until I launched Firefox
> (the famous sync-happy beast).
> After Firefox startup, I had these long freezes again when trying to
> do transfers with the _UNRELATED_ main HDD of the system
> (plus some OOMs, again)
> 
> Setup: USB SSD ext4 non-journal, system HDD ext3, SSD unused except for
> this one ext4 partition (no swap partition activated there).
> 
> Of course I can understand and tolerate the existing "ext3 sync" issue,
> but what's special about this case is that large numbers of bio to
> a _separate_ _non_-ext3 device seem to put so much memory and I/O pressure
> on a system that the existing _lightly_ loaded ext3 device gets completely
> stuck for much longer than I'd usually naively expect an ext3 sync to an isolated
> device to take - not to mention the OOMs (which are probably causing
> swap partition handling on the main HDD to contribute to the contention).
> 
> IOW, we seem to still have too much ugly lock contention interaction
> between expectedly isolated parts of the system.
> 
> OTOH the main problem likely still is overly large pressure induced by a
> thoroughly unthrottled dd 300M, resulting in sync-challenged ext3 and swap
> activity (this time on the same device!) to break completely, and also OOMs to occur.
> 
> Probably overly global ext3 sync handling manages to grab a couple
> more global system locks (bdi, swapping, page handling, ...)
> before being contended, causing other, non-ext3-challenged
> parts of the system (e.g. the swap partition on the _same_ device)
> to not make any progress in the meantime.
> 
> per-bdi writeback patches (see
> http://www.serverphorums.com/read.php?12,32355,33238,page=2 ) might
> have handled a related issue.
> 
> 
> Following is a SysRq-W trace (plus OOM traces) at a problematic moment during 300M copy
> after firefox - and thus sync invocation - launch (there's a backtrace of an "ls" that
> got stuck for perhaps half a minute on the main, _unaffected_, ext3
> HDD - and almost all other traces here are ext3-bound as well).
> 
> 
> SysRq : HELP : loglevel(0-9) reBoot Crash show-all-locks(D) terminate-all-tasks(E) memory-full-oom-kill(F) kill-all-tasks(I) thaw-filesystems(J) saK show-memory-usage(M) nice-all-RT-tasks(N) powerOff show-registers(P) show-all-timers(Q) unRaw Sync show-task-states(T) Unmount show-blocked-tasks(W)
> ata1: clearing spurious IRQ
> ata1: clearing spurious IRQ
> Xorg invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0

This is GFP_KERNEL.

> Pid: 2924, comm: Xorg Tainted: G        W  2.6.34-rc3 #8
> Call Trace:
>  [<c105d881>] T.382+0x44/0x110
>  [<c105d978>] T.381+0x2b/0xe1
>  [<c105db2e>] __out_of_memory+0x100/0x112
>  [<c105dbb4>] out_of_memory+0x74/0x9c
>  [<c105fd41>] __alloc_pages_nodemask+0x3c5/0x493
>  [<c105fe1e>] __get_free_pages+0xf/0x2c
>  [<c1086400>] __pollwait+0x4c/0xa4
>  [<c120130e>] unix_poll+0x1a/0x93
>  [<c11a6a77>] sock_poll+0x12/0x15
>  [<c1085d21>] do_select+0x336/0x53a
>  [<c10ec5c4>] ? cfq_set_request+0x1d8/0x2ec
>  [<c10863b4>] ? __pollwait+0x0/0xa4
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c1086458>] ? pollwake+0x0/0x60
>  [<c10f46c9>] ? _copy_from_user+0x42/0x127
>  [<c10860cc>] core_sys_select+0x1a7/0x291
>  [<c1214063>] ? _raw_spin_unlock_irq+0x1d/0x21
>  [<c1026b7f>] ? do_setitimer+0x160/0x18c
>  [<c103b066>] ? ktime_get_ts+0xba/0xc4
>  [<c108635e>] sys_select+0x68/0x84
>  [<c1002690>] sysenter_do_call+0x12/0x31
> Mem-Info:
> DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd:  46
> active_anon:34886 inactive_anon:41460 isolated_anon:1
>  active_file:13576 inactive_file:27884 isolated_file:65
>  unevictable:0 dirty:4788 writeback:5675 unstable:0
>  free:1198 slab_reclaimable:1952 slab_unreclaimable:2594
>  mapped:10152 shmem:56 pagetables:742 bounce:0
> DMA free:2052kB min:84kB low:104kB high:124kB active_anon:940kB inactive_anon:3876kB active_file:212kB inactive_file:8224kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15804kB mlocked:0kB dirty:3448kB writeback:752kB mapped:80kB shmem:0kB slab_reclaimable:160kB slab_unreclaimable:124kB kernel_stack:40kB pagetables:48kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:20096 all_unreclaimable? yes
> lowmem_reserve[]: 0 492 492
> Normal free:2740kB min:2792kB low:3488kB high:4188kB active_anon:138604kB inactive_anon:161964kB active_file:54092kB inactive_file:103312kB unevictable:0kB isolated(anon):4kB isolated(file):260kB present:503848kB mlocked:0kB dirty:15704kB writeback:21948kB mapped:40528kB shmem:224kB slab_reclaimable:7648kB slab_unreclaimable:10252kB kernel_stack:1632kB pagetables:2920kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:73056 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0
> DMA: 513*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2052kB
> Normal: 685*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2740kB
> 56122 total pagecache pages
> 14542 pages in swap cache
> Swap cache stats: add 36404, delete 21862, find 8669/10118
> Free swap  = 671696kB
> Total swap = 755048kB
> 131034 pages RAM
> 3214 pages reserved
> 94233 pages shared
> 80751 pages non-shared
> Out of memory: kill process 3462 (kdeinit4) score 95144 or a child

shmem=56 is ignorable, and 
active_file+inactive_file=13576+27884=41460 < 56122 total pagecache pages.

Where are the 14606 file pages gone?

> Killed process 3524 (kio_http) vsz:43448kB, anon-rss:1668kB, file-rss:6388kB
> SysRq : Show Blocked State
>   task                PC stack   pid father
> tclsh         D df888d98     0  2038      1 0x00000000
>  de781ee8 00000046 00000000 df888d98 4e3b903d 000002df df888b20 df888b20
>  dfbf6dc0 c1bff180 de781ef4 c1212374 de781f24 de781efc c105b8f3 de781f18
>  c121277b c105b8be de781f2c 00000060 dfbf6dc0 c137f88c de781f48 c105b8aa
> Call Trace:
>  [<c1212374>] io_schedule+0x47/0x7d
>  [<c105b8f3>] sync_page+0x35/0x39
>  [<c121277b>] __wait_on_bit_lock+0x34/0x6f
>  [<c105b8be>] ? sync_page+0x0/0x39
>  [<c105b8aa>] __lock_page+0x6b/0x73
>  [<c1033d28>] ? wake_bit_function+0x0/0x37
>  [<c106aede>] handle_mm_fault+0x2fc/0x4f6
>  [<c1018239>] ? do_page_fault+0xe4/0x279
>  [<c10183b8>] do_page_fault+0x263/0x279
>  [<c1018155>] ? do_page_fault+0x0/0x279
>  [<c121456e>] error_code+0x5e/0x64
>  [<c1018155>] ? do_page_fault+0x0/0x279
> console-kit-d D df970368     0  2760      1 0x00000000
>  d9aa7c0c 00000046 00000000 df970368 bcc125ae 000002de df9700f0 df9700f0
>  00000000 d9aa7c50 d9aa7c18 c1212374 d9aa7c48 d9aa7c20 c105b8f3 d9aa7c3c
>  c121288c c105b8be c1bfe5f8 0000000e d9aa7c48 d9aa7c64 d9aa7c70 c105baf7
> Call Trace:
>  [<c1212374>] io_schedule+0x47/0x7d
>  [<c105b8f3>] sync_page+0x35/0x39
>  [<c121288c>] __wait_on_bit+0x34/0x5b
>  [<c105b8be>] ? sync_page+0x0/0x39
>  [<c105baf7>] wait_on_page_bit+0x7a/0x83
>  [<c1033d28>] ? wake_bit_function+0x0/0x37
>  [<c1063610>] shrink_page_list+0x115/0x3c3
>  [<c10511fb>] ? __delayacct_blkio_end+0x2f/0x35
>  [<c1068083>] ? congestion_wait+0x5d/0x67
>  [<c1063ba9>] shrink_inactive_list+0x2eb/0x476
>  [<c105117e>] ? delayacct_end+0x66/0x8d
>  [<c1063f69>] shrink_zone+0x235/0x2d6
>  [<c1033cf9>] ? autoremove_wake_function+0x0/0x2f
>  [<c10647e8>] do_try_to_free_pages+0x12c/0x229
>  [<c10649ed>] try_to_free_pages+0x6a/0x72
>  [<c1062889>] ? isolate_pages_global+0x0/0x1a2
>  [<c105fc64>] __alloc_pages_nodemask+0x2e8/0x493
>  [<c105fe1e>] __get_free_pages+0xf/0x2c
>  [<c1021fb6>] copy_process+0x9e/0xcc5
>  [<c1022cf1>] do_fork+0x114/0x25e
>  [<c106b07b>] ? handle_mm_fault+0x499/0x4f6
>  [<c1018239>] ? do_page_fault+0xe4/0x279
>  [<c10372bc>] ? up_read+0x16/0x2a
>  [<c1007752>] sys_clone+0x1b/0x20
>  [<c1002765>] ptregs_clone+0x15/0x30
>  [<c12141b5>] ? syscall_call+0x7/0xb

Many applications (this one and below) are stuck in
wait_on_page_writeback(). I guess this is why "heavy write to
irrelevant partition stalls the whole system".  They are stuck on page
allocation. Your 512MB system memory is a bit tight, so reclaim
pressure is a bit high, which triggers the wait-on-writeback logic.

Thanks,
Fengguang

> usb-storage   D df04cd18     0  3039      2 0x00000000
>  d734fdcc 00000046 00000000 df04cd18 4cf496d1 000002df df04caa0 7fffffff
>  7fffffff df04caa0 d734fe20 c12125e3 00000001 d734fe04 00000046 00000000
>  00000001 00000001 00000000 c1212440 00000000 de794dec 00000046 00000001
> Call Trace:
>  [<c12125e3>] schedule_timeout+0x17/0x139
>  [<c1212440>] ? wait_for_common+0x31/0x110
>  [<c12124c6>] wait_for_common+0xb7/0x110
>  [<c101f127>] ? default_wake_function+0x0/0xd
>  [<c1212591>] wait_for_completion+0x12/0x14
>  [<e0ba1b2e>] usb_sg_wait+0x123/0x132 [usbcore]
>  [<e0862f72>] usb_stor_bulk_transfer_sglist+0x5f/0x9a [usb_storage]
>  [<e0862fc9>] usb_stor_bulk_srb+0x1c/0x2c [usb_storage]
>  [<e0863149>] usb_stor_Bulk_transport+0x102/0x24a [usb_storage]
>  [<e0864219>] ? usb_stor_control_thread+0x0/0x196 [usb_storage]
>  [<e0862bf0>] usb_stor_invoke_transport+0x17/0x292 [usb_storage]
>  [<e0864269>] ? usb_stor_control_thread+0x50/0x196 [usb_storage]
>  [<e0864219>] ? usb_stor_control_thread+0x0/0x196 [usb_storage]
>  [<e08627de>] usb_stor_transparent_scsi_command+0x8/0xa [usb_storage]
>  [<e086432f>] usb_stor_control_thread+0x116/0x196 [usb_storage]
>  [<c12122f9>] ? schedule+0x3b9/0x3ed
>  [<e0864219>] ? usb_stor_control_thread+0x0/0x196 [usb_storage]
>  [<c1033a71>] kthread+0x5e/0x63
>  [<c1033a13>] ? kthread+0x0/0x63
>  [<c1002bb6>] kernel_thread_helper+0x6/0x10
> x-terminal-em D d722a368     0  3049      1 0x00000000
>  d99a3a28 00000046 00000000 d722a368 995859cf 000002dc d722a0f0 d722a0f0
>  00000000 d99a3a6c d99a3a34 c1212374 d99a3a64 d99a3a3c c105b8f3 d99a3a58
>  c121288c c105b8be c1c01a6c 00000183 d99a3a64 d99a3a80 d99a3a8c c105baf7
> Call Trace:
>  [<c1212374>] io_schedule+0x47/0x7d
>  [<c105b8f3>] sync_page+0x35/0x39
>  [<c121288c>] __wait_on_bit+0x34/0x5b
>  [<c105b8be>] ? sync_page+0x0/0x39
>  [<c105baf7>] wait_on_page_bit+0x7a/0x83
>  [<c1033d28>] ? wake_bit_function+0x0/0x37
>  [<c1063610>] shrink_page_list+0x115/0x3c3
>  [<c10511fb>] ? __delayacct_blkio_end+0x2f/0x35
>  [<c1068083>] ? congestion_wait+0x5d/0x67
>  [<c1063ba9>] shrink_inactive_list+0x2eb/0x476
>  [<c10608ab>] ? determine_dirtyable_memory+0xf/0x16
>  [<c1063f69>] shrink_zone+0x235/0x2d6
>  [<c10647e8>] do_try_to_free_pages+0x12c/0x229
>  [<c10649ed>] try_to_free_pages+0x6a/0x72
>  [<c1062889>] ? isolate_pages_global+0x0/0x1a2
>  [<c105fc64>] __alloc_pages_nodemask+0x2e8/0x493
>  [<c1077acd>] cache_alloc_refill+0x235/0x3e1
>  [<c1077d00>] __kmalloc+0x87/0xae
>  [<c11adcd5>] __alloc_skb+0x4c/0x110
>  [<c11a9f9f>] sock_alloc_send_pskb+0x99/0x24c
>  [<c11aa160>] sock_alloc_send_skb+0xe/0x10
>  [<c1202399>] unix_stream_sendmsg+0x147/0x2b0
>  [<c11a6c2b>] sock_aio_write+0xeb/0xf4
>  [<c1079c5a>] do_sync_readv_writev+0x83/0xb6
>  [<c10f46c9>] ? _copy_from_user+0x42/0x127
>  [<c1079b3d>] ? rw_copy_check_uvector+0x55/0xc2
>  [<c107a25c>] do_readv_writev+0x7e/0x146
>  [<c11a6b40>] ? sock_aio_write+0x0/0xf4
>  [<c107ad10>] ? fget_light+0x3a/0xbb
>  [<c107a35a>] vfs_writev+0x36/0x44
>  [<c107a436>] sys_writev+0x3b/0x8d
>  [<c1002690>] sysenter_do_call+0x12/0x31
>  [<c121007b>] ? sio_via_probe+0x56/0x33e
> konqueror     D d722ad78     0  3457   3074 0x00000000
>  d997fa28 00200046 00000000 d722ad78 1a466bec 000002de d722ab00 d722ab00
>  00000000 d997fa6c d997fa34 c1212374 d997fa64 d997fa3c c105b8f3 d997fa58
>  c121288c c105b8be c1c00890 00000104 d997fa64 d997fa80 d997fa8c c105baf7
> Call Trace:
>  [<c1212374>] io_schedule+0x47/0x7d
>  [<c105b8f3>] sync_page+0x35/0x39
>  [<c121288c>] __wait_on_bit+0x34/0x5b
>  [<c105b8be>] ? sync_page+0x0/0x39
>  [<c105baf7>] wait_on_page_bit+0x7a/0x83
>  [<c1033d28>] ? wake_bit_function+0x0/0x37
>  [<c1063610>] shrink_page_list+0x115/0x3c3
>  [<c1068083>] ? congestion_wait+0x5d/0x67
>  [<c1063ba9>] shrink_inactive_list+0x2eb/0x476
>  [<c10608ab>] ? determine_dirtyable_memory+0xf/0x16
>  [<c1063f69>] shrink_zone+0x235/0x2d6
>  [<c10647e8>] do_try_to_free_pages+0x12c/0x229
>  [<c10649ed>] try_to_free_pages+0x6a/0x72
>  [<c1062889>] ? isolate_pages_global+0x0/0x1a2
>  [<c105fc64>] __alloc_pages_nodemask+0x2e8/0x493
>  [<c1077acd>] cache_alloc_refill+0x235/0x3e1
>  [<c1077d00>] __kmalloc+0x87/0xae
>  [<c11adcd5>] __alloc_skb+0x4c/0x110
>  [<c11a9f9f>] sock_alloc_send_pskb+0x99/0x24c
>  [<c11aa160>] sock_alloc_send_skb+0xe/0x10
>  [<c1202399>] unix_stream_sendmsg+0x147/0x2b0
>  [<c11a6c2b>] sock_aio_write+0xeb/0xf4
>  [<c101fd0a>] ? T.939+0xa3/0xab
>  [<c1079c5a>] do_sync_readv_writev+0x83/0xb6
>  [<c1005f21>] ? pit_next_event+0x10/0x37
>  [<c10f46c9>] ? _copy_from_user+0x42/0x127
>  [<c1079b3d>] ? rw_copy_check_uvector+0x55/0xc2
>  [<c107a25c>] do_readv_writev+0x7e/0x146
>  [<c11a6b40>] ? sock_aio_write+0x0/0xf4
>  [<c107ad10>] ? fget_light+0x3a/0xbb
>  [<c107a35a>] vfs_writev+0x36/0x44
>  [<c107a436>] sys_writev+0x3b/0x8d
>  [<c1002690>] sysenter_do_call+0x12/0x31
>  [<c1210000>] ? sio_ite_8872_probe+0x229/0x24e

> flush-8:16    D caaaccf8     0  4032      2 0x00000000
>  c5b73ba4 00000046 00000000 caaaccf8 4525f418 000002df caaaca80 caaaca80
>  c5b73bc8 c5b73bdc c5b73bb0 c1212374 de60c070 c5b73be8 c10e4d23 caaaca80
>  df368ac0 de60c098 00000001 00000001 caaaca80 c1033cf9 de60c0b4 de60c0b4
> Call Trace:
>  [<c1212374>] io_schedule+0x47/0x7d
>  [<c10e4d23>] get_request_wait+0x8a/0x102
>  [<c1033cf9>] ? autoremove_wake_function+0x0/0x2f
>  [<c10e4fea>] __make_request+0x24f/0x33f
>  [<c10e3ca4>] generic_make_request+0x275/0x2cb
>  [<c105d04f>] ? mempool_alloc_slab+0xe/0x10
>  [<c105d169>] ? mempool_alloc+0x56/0xe3
>  [<c10e3d9b>] submit_bio+0xa1/0xa9
>  [<c1098431>] ? bio_alloc_bioset+0x37/0x94
>  [<c1095598>] ? end_buffer_async_write+0x0/0xdb
>  [<c109450e>] submit_bh+0xec/0x10c
>  [<c1095598>] ? end_buffer_async_write+0x0/0xdb
>  [<c1096886>] __block_write_full_page+0x1e5/0x2bc
>  [<e08d6d88>] ? noalloc_get_block_write+0x0/0x53 [ext4]
>  [<c1096a02>] block_write_full_page_endio+0xa5/0xaf
>  [<c1095598>] ? end_buffer_async_write+0x0/0xdb
>  [<e08d6d88>] ? noalloc_get_block_write+0x0/0x53 [ext4]
>  [<c1096a19>] block_write_full_page+0xd/0xf
>  [<c1095598>] ? end_buffer_async_write+0x0/0xdb
>  [<e08d5228>] ext4_writepage+0x324/0x35a [ext4]
>  [<e08d4eaf>] mpage_da_submit_io+0x91/0xd5 [ext4]
>  [<e08d6a39>] ext4_da_writepages+0x298/0x3d5 [ext4]
>  [<c10607ec>] do_writepages+0x17/0x24
>  [<c108fe3c>] writeback_single_inode+0xc6/0x273
>  [<c1090925>] writeback_inodes_wb+0x326/0x3ff
>  [<c1090ae3>] wb_writeback+0xe5/0x143
>  [<c1090bbc>] ? wb_clear_pending+0x6a/0x6f
>  [<c1090c26>] wb_do_writeback+0x65/0x152
>  [<c1090d3a>] bdi_writeback_task+0x27/0x83
>  [<c106892f>] ? bdi_start_fn+0x0/0xad
>  [<c1068986>] bdi_start_fn+0x57/0xad
>  [<c106892f>] ? bdi_start_fn+0x0/0xad
>  [<c1033a71>] kthread+0x5e/0x63
>  [<c1033a13>] ? kthread+0x0/0x63
>  [<c1002bb6>] kernel_thread_helper+0x6/0x10
> firefox-bin   D cc6443a8     0  4049   3734 0x00000000
>  de431e04 00000046 00000000 cc6443a8 51878f6d 000002df cc644130 cc644130
>  c1b95da0 c1c010b8 de431e10 c1212374 de431e48 de431e18 c105b8f3 de431e20
>  c105b8ff de431e3c c121277b c105b8f7 de431e50 0000013e c1b95da0 c137f88c
> Call Trace:
>  [<c1212374>] io_schedule+0x47/0x7d
>  [<c105b8f3>] sync_page+0x35/0x39
>  [<c105b8ff>] sync_page_killable+0x8/0x29
>  [<c121277b>] __wait_on_bit_lock+0x34/0x6f
>  [<c105b8f7>] ? sync_page_killable+0x0/0x29
>  [<c105b838>] __lock_page_killable+0x6e/0x75
>  [<c1033d28>] ? wake_bit_function+0x0/0x37
>  [<c105ce61>] generic_file_aio_read+0x358/0x503
>  [<c1079dda>] do_sync_read+0x89/0xc4
>  [<c12140aa>] ? _raw_spin_unlock+0x1d/0x20
>  [<c10786b9>] ? fd_install+0x43/0x49
>  [<c107a868>] vfs_read+0x88/0x139
>  [<c1079d51>] ? do_sync_read+0x0/0xc4
>  [<c107a9b0>] sys_read+0x3b/0x60
>  [<c12141b5>] syscall_call+0x7/0xb
> ls            D ccc41788     0  4057   3261 0x00000000
>  de641e50 00000046 00000000 ccc41788 4ac9a691 000002df ccc41510 ccc41510
>  df58b230 c1bffe28 de641e5c c1212374 de641e8c de641e64 c105b8f3 de641e80
>  c121277b c105b8be de641e94 000000ba df58b230 c137f88c de641eb0 c105b8aa
> Call Trace:
>  [<c1212374>] io_schedule+0x47/0x7d
>  [<c105b8f3>] sync_page+0x35/0x39
>  [<c121277b>] __wait_on_bit_lock+0x34/0x6f
>  [<c105b8be>] ? sync_page+0x0/0x39
>  [<c105b8aa>] __lock_page+0x6b/0x73
>  [<c1033d28>] ? wake_bit_function+0x0/0x37
>  [<c105ba02>] find_lock_page+0x40/0x5c
>  [<c105bfea>] filemap_fault+0x1ad/0x311
>  [<c10697d5>] __do_fault+0x3b/0x333
>  [<c106adf9>] handle_mm_fault+0x217/0x4f6
>  [<c1018239>] ? do_page_fault+0xe4/0x279
>  [<c10183b8>] do_page_fault+0x263/0x279
>  [<c1018155>] ? do_page_fault+0x0/0x279
>  [<c121456e>] error_code+0x5e/0x64
>  [<c1018155>] ? do_page_fault+0x0/0x279
> Sched Debug Version: v0.09, 2.6.34-rc3 #8
> now at 3158210.914290 msecs
>   .jiffies                                 : 285818
>   .sysctl_sched_latency                    : 5.000000
>   .sysctl_sched_min_granularity            : 1.000000
>   .sysctl_sched_wakeup_granularity         : 1.000000
>   .sysctl_sched_child_runs_first           : 0.000000
>   .sysctl_sched_features                   : 7917179
>   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
> 
> cpu#0, 698.433 MHz
>   .nr_running                    : 2
>   .load                          : 2048
>   .nr_switches                   : 2095347
>   .nr_load_updates               : 240414
>   .nr_uninterruptible            : 8
>   .next_balance                  : 0.000000
>   .curr->pid                     : 2825
>   .clock                         : 3158187.674744
>   .cpu_load[0]                   : 1024
>   .cpu_load[1]                   : 1029
>   .cpu_load[2]                   : 1048
>   .cpu_load[3]                   : 1073
>   .cpu_load[4]                   : 1024
>   .yld_count                     : 0
>   .sched_switch                  : 0
>   .sched_count                   : 2148427
>   .sched_goidle                  : 698042
>   .ttwu_count                    : 0
>   .ttwu_local                    : 0
>   .bkl_count                     : 0
> 
> cfs_rq[0]:
>   .exec_clock                    : 1031666.973419
>   .MIN_vruntime                  : 846287.573662
>   .min_vruntime                  : 846280.117314
>   .max_vruntime                  : 846287.573662
>   .spread                        : 0.000000
>   .spread0                       : 0.000000
>   .nr_running                    : 2
>   .load                          : 2048
>   .nr_spread_over                : 1768
> 
> rt_rq[0]:
>   .rt_nr_running                 : 0
>   .rt_throttled                  : 0
>   .rt_time                       : 0.000000
>   .rt_runtime                    : 950.000000
> 
> runnable tasks:
>             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> ----------------------------------------------------------------------------------------------------------
> R           bash  2825    846277.617314       391   120    846277.617314      1362.246731   3073863.564008
>               dd  4031    846287.573662      2432   120    846287.573662      4709.200175    121646.537749

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
