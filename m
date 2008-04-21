Date: Mon, 21 Apr 2008 17:01:23 +1000
From: David Chinner <dgc@sgi.com>
Subject: OOM killer doesn't kill the right task....
Message-ID: <20080421070123.GM108924158@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: xfs-oss <xfs@oss.sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Running in a 512MB UML system without swap, XFSQA test 084 reliably
kills the kernel completely as the OOM killer is unable to find a
task to kill. log output is below.

I don't know when it started failing - ISTR this working just fine
on 2.6.24 kernels.

Test program is here:

http://oss.sgi.com/cgi-bin/cvsweb.cgi/xfs-cmds/xfstests/src/resvtest.c?rev=1.3

And it is invoked with two different command lines from the test
suite (not sure which one triggers the failure):

$ ./resvtest -i 20 -b $pagesize <file_on_xfs_filesystem>

and

$ ./resvtest -i 40 -b 512 <file_on_xfs_filesystem>

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

[ 1061.900000] resvtest invoked oom-killer: gfp_mask=0x1200d2, order=0, oomkilladj=-17
[ 1061.900000] Call Trace:
[ 1061.900000] 6792bb58:  [<60037a85>] printk_ratelimit+0x15/0x20
[ 1061.900000] 6792bb68:  [<60063895>] oom_kill_process+0x125/0x160
[ 1061.900000] 6792bbb8:  [<60063a83>] out_of_memory+0xa3/0x140
[ 1061.900000] 6792bc08:  [<6006567e>] __alloc_pages+0x2ae/0x3d0
[ 1061.900000] 6792bc38:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1061.900000] 6792bc78:  [<60076a82>] anon_vma_prepare+0x32/0x120
[ 1061.900000] 6792bcb8:  [<60070e5b>] do_anonymous_page+0x4b/0x1b0
[ 1061.900000] 6792bd18:  [<600718db>] handle_mm_fault+0x26b/0x2e0
[ 1061.900000] 6792bd28:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1061.900000] 6792bd88:  [<6001725b>] handle_page_fault+0x18b/0x240
[ 1061.900000] 6792bdf8:  [<600175e2>] segv+0x1b2/0x2d0
[ 1061.900000] 6792bee8:  [<6001742b>] segv_handler+0x7b/0x80
[ 1061.900000] 6792bf18:  [<6002b2be>] userspace+0x22e/0x300
[ 1061.900000] 6792bfc8:  [<60014992>] fork_handler+0x62/0x70
[ 1061.900000]
[ 1061.900000] Mem-info:
[ 1061.900000] Normal per-cpu:
[ 1061.900000] CPU    0: hi:  186, btch:  31 usd: 132
[ 1061.900000] Active:121370 inactive:41 dirty:0 writeback:0 unstable:0
[ 1061.900000]  free:714 slab:1492 mapped:14 pagetables:416 bounce:0
[ 1061.900000] Normal free:2856kB min:2876kB low:3592kB high:4312kB active:485480kB inactive:164kB present:517120kB pages_scanned:788832 all_unreclaimable? yes
[ 1061.900000] lowmem_reserve[]: 0 0
[ 1061.900000] Normal: 2*4kB 2*8kB 1*16kB 4*32kB 0*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2856kB
[ 1061.900000] 121 total pagecache pages
[ 1061.900000] Swap cache: add 0, delete 0, find 0/0
[ 1061.900000] Free swap  = 0kB
[ 1061.900000] Total swap = 0kB
[ 1061.900000] Free swap:            0kB
[ 1061.900000] 131072 pages of RAM
[ 1061.900000] 0 pages of HIGHMEM
[ 1061.900000] 5047 reserved pages
[ 1061.900000] 202 pages shared
[ 1061.900000] 0 pages swap cached
[ 1061.900000] Out of memory: kill process 1039 (uml_switch) score 936 or a child
[ 1061.900000] Killed process 1039 (uml_switch)
[ 1061.910000] resvtest invoked oom-killer: gfp_mask=0x1200d2, order=0, oomkilladj=-17
[ 1061.910000] Call Trace:
[ 1061.910000] 6792bb58:  [<60037a85>] printk_ratelimit+0x15/0x20
[ 1061.910000] 6792bb68:  [<60063895>] oom_kill_process+0x125/0x160
[ 1061.910000] 6792bbb8:  [<60063a83>] out_of_memory+0xa3/0x140
[ 1061.910000] 6792bc08:  [<6006567e>] __alloc_pages+0x2ae/0x3d0
[ 1061.910000] 6792bc38:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1061.910000] 6792bc78:  [<60076a82>] anon_vma_prepare+0x32/0x120
[ 1061.910000] 6792bcb8:  [<60070e5b>] do_anonymous_page+0x4b/0x1b0
[ 1061.910000] 6792bd18:  [<600718db>] handle_mm_fault+0x26b/0x2e0
[ 1061.910000] 6792bd28:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1061.910000] 6792bd88:  [<6001725b>] handle_page_fault+0x18b/0x240
[ 1061.910000] 6792bdf8:  [<600175e2>] segv+0x1b2/0x2d0
[ 1061.910000] 6792bee8:  [<6001742b>] segv_handler+0x7b/0x80
[ 1061.910000] 6792bf18:  [<6002b2be>] userspace+0x22e/0x300
[ 1061.910000] 6792bfc8:  [<60014992>] fork_handler+0x62/0x70
[ 1061.910000]
[ 1061.910000] Mem-info:
[ 1061.910000] Normal per-cpu:
[ 1061.910000] CPU    0: hi:  186, btch:  31 usd: 166
[ 1061.910000] Active:121348 inactive:41 dirty:0 writeback:0 unstable:0
[ 1061.910000]  free:714 slab:1492 mapped:6 pagetables:409 bounce:0
[ 1061.910000] Normal free:2856kB min:2876kB low:3592kB high:4312kB active:485392kB inactive:164kB present:517120kB pages_scanned:789072 all_unreclaimable? yes
[ 1061.910000] lowmem_reserve[]: 0 0
[ 1061.910000] Normal: 2*4kB 2*8kB 1*16kB 4*32kB 0*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2856kB
[ 1061.910000] 121 total pagecache pages
[ 1061.910000] Swap cache: add 0, delete 0, find 0/0
[ 1061.910000] Free swap  = 0kB
[ 1061.910000] Total swap = 0kB
[ 1061.910000] Free swap:            0kB
[ 1061.910000] 131072 pages of RAM
[ 1061.910000] 0 pages of HIGHMEM
[ 1061.910000] 5047 reserved pages
[ 1061.910000] 194 pages shared
[ 1061.910000] 0 pages swap cached
[ 1061.910000] Out of memory: kill process 1061 (cron) score 315 or a child
[ 1061.910000] Killed process 1061 (cron)
[ 1062.240000] init invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0
[ 1062.240000] Call Trace:
[ 1062.240000] 7fc239d8:  [<60037a85>] printk_ratelimit+0x15/0x20
[ 1062.240000] 7fc239e8:  [<60063895>] oom_kill_process+0x125/0x160
[ 1062.240000] 7fc23a38:  [<60063a83>] out_of_memory+0xa3/0x140
[ 1062.240000] 7fc23a88:  [<6006567e>] __alloc_pages+0x2ae/0x3d0
[ 1062.240000] 7fc23af8:  [<600681b1>] read_pages+0x41/0xe0
[ 1062.240000] 7fc23b38:  [<60068354>] __do_page_cache_readahead+0x104/0x1d0
[ 1062.240000] 7fc23bd8:  [<6006851c>] do_page_cache_readahead+0x5c/0x80
[ 1062.240000] 7fc23c08:  [<60060e30>] filemap_fault+0x1a0/0x2f0
[ 1062.240000] 7fc23c68:  [<60071027>] __do_fault+0x67/0x480
[ 1062.240000] 7fc23c88:  [<6002a5ff>] map+0x11f/0x140
[ 1062.240000] 7fc23cf8:  [<6007147c>] do_linear_fault+0x3c/0x40
[ 1062.240000] 7fc23d08:  [<6031638e>] _spin_unlock_irq+0xe/0x10
[ 1062.240000] 7fc23d18:  [<600717b3>] handle_mm_fault+0x143/0x2e0
[ 1062.240000] 7fc23d28:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1062.240000] 7fc23d88:  [<6001725b>] handle_page_fault+0x18b/0x240
[ 1062.240000] 7fc23df8:  [<600175e2>] segv+0x1b2/0x2d0
[ 1062.240000] 7fc23ee8:  [<6001742b>] segv_handler+0x7b/0x80
[ 1062.240000] 7fc23f18:  [<6002b2be>] userspace+0x22e/0x300
[ 1062.240000] 7fc23f58:  [<60000a90>] kernel_init+0x0/0x80
[ 1062.240000] 7fc23fc8:  [<60014914>] new_thread_handler+0x84/0xa0
[ 1062.240000]
[ 1062.240000] Mem-info:
[ 1062.240000] Normal per-cpu:
[ 1062.240000] CPU    0: hi:  186, btch:  31 usd: 148
[ 1062.240000] Active:121456 inactive:1 dirty:0 writeback:0 unstable:0
[ 1062.240000]  free:703 slab:1461 mapped:0 pagetables:396 bounce:0
[ 1062.240000] Normal free:2812kB min:2876kB low:3592kB high:4312kB active:485824kB inactive:4kB present:517120kB pages_scanned:755399 all_unreclaimable? yes
[ 1062.240000] lowmem_reserve[]: 0 0
[ 1062.240000] Normal: 3*4kB 2*8kB 0*16kB 3*32kB 0*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2812kB
[ 1062.240000] 75 total pagecache pages
[ 1062.240000] Swap cache: add 0, delete 0, find 0/0
[ 1062.240000] Free swap  = 0kB
[ 1062.240000] Total swap = 0kB
[ 1062.240000] Free swap:            0kB
[ 1062.240000] 131072 pages of RAM
[ 1062.240000] 0 pages of HIGHMEM
[ 1062.240000] 5047 reserved pages
[ 1062.240000] 181 pages shared
[ 1062.240000] 0 pages swap cached
[ 1062.240000] Out of memory: kill process 1029 (inetd) score 157 or a child
[ 1062.240000] Killed process 1029 (inetd)
[ 1062.490000] init invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0
[ 1062.490000] Call Trace:
[ 1062.490000] 7fc239d8:  [<60037a85>] printk_ratelimit+0x15/0x20
[ 1062.490000] 7fc239e8:  [<60063895>] oom_kill_process+0x125/0x160
[ 1062.490000] 7fc23a38:  [<60063a83>] out_of_memory+0xa3/0x140
[ 1062.490000] 7fc23a88:  [<6006567e>] __alloc_pages+0x2ae/0x3d0
[ 1062.490000] 7fc23aa8:  [<6001828b>] do_op_one_page+0x13b/0x150
[ 1062.490000] 7fc23ab8:  [<60018390>] copy_chunk_from_user+0x0/0x40
[ 1062.490000] 7fc23b38:  [<60068354>] __do_page_cache_readahead+0x104/0x1d0
[ 1062.490000] 7fc23bd8:  [<6006851c>] do_page_cache_readahead+0x5c/0x80
[ 1062.490000] 7fc23c08:  [<60060e30>] filemap_fault+0x1a0/0x2f0
[ 1062.490000] 7fc23c68:  [<60071027>] __do_fault+0x67/0x480
[ 1062.490000] 7fc23c88:  [<6002a5ff>] map+0x11f/0x140
[ 1062.490000] 7fc23cf8:  [<6007147c>] do_linear_fault+0x3c/0x40
[ 1062.490000] 7fc23d08:  [<6031638e>] _spin_unlock_irq+0xe/0x10
[ 1062.490000] 7fc23d18:  [<600717b3>] handle_mm_fault+0x143/0x2e0
[ 1062.490000] 7fc23d28:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1062.490000] 7fc23d88:  [<6001725b>] handle_page_fault+0x18b/0x240
[ 1062.490000] 7fc23df8:  [<600175e2>] segv+0x1b2/0x2d0
[ 1062.490000] 7fc23ee8:  [<6001742b>] segv_handler+0x7b/0x80
[ 1062.490000] 7fc23f18:  [<6002b2be>] userspace+0x22e/0x300
[ 1062.490000] 7fc23f58:  [<60000a90>] kernel_init+0x0/0x80
[ 1062.490000] 7fc23fc8:  [<60014914>] new_thread_handler+0x84/0xa0
[ 1062.490000]
[ 1062.490000] Mem-info:
[ 1062.490000] Normal per-cpu:
[ 1062.490000] CPU    0: hi:  186, btch:  31 usd: 147
[ 1062.490000] Active:121400 inactive:75 dirty:0 writeback:0 unstable:0
[ 1062.490000]  free:707 slab:1461 mapped:0 pagetables:387 bounce:0
[ 1062.490000] Normal free:2828kB min:2876kB low:3592kB high:4312kB active:485600kB inactive:300kB present:517120kB pages_scanned:874765 all_unreclaimable? yes
[ 1062.490000] lowmem_reserve[]: 0 0
[ 1062.490000] Normal: 3*4kB 2*8kB 1*16kB 3*32kB 0*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2828kB
[ 1062.490000] 75 total pagecache pages
[ 1062.490000] Swap cache: add 0, delete 0, find 0/0
[ 1062.490000] Free swap  = 0kB
[ 1062.490000] Total swap = 0kB
[ 1062.490000] Free swap:            0kB
[ 1062.490000] 131072 pages of RAM
[ 1062.490000] 0 pages of HIGHMEM
[ 1062.490000] 5047 reserved pages
[ 1062.490000] 181 pages shared
[ 1062.490000] 0 pages swap cached
[ 1062.490000] Out of memory: kill process 1001 (syslogd) score 91 or a child
[ 1062.490000] Killed process 1001 (syslogd)
[ 1062.770000] klogd invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0
[ 1062.770000] Call Trace:
[ 1062.770000] 7e9ef9d8:  [<60037a85>] printk_ratelimit+0x15/0x20
[ 1062.770000] 7e9ef9e8:  [<60063895>] oom_kill_process+0x125/0x160
[ 1062.770000] 7e9efa38:  [<60063a83>] out_of_memory+0xa3/0x140
[ 1062.770000] 7e9efa88:  [<6006567e>] __alloc_pages+0x2ae/0x3d0
[ 1062.770000] 7e9efab8:  [<603143ef>] schedule+0x16f/0x260
[ 1062.770000] 7e9efb38:  [<60068354>] __do_page_cache_readahead+0x104/0x1d0
[ 1062.770000] 7e9efbd8:  [<6006851c>] do_page_cache_readahead+0x5c/0x80
[ 1062.770000] 7e9efc08:  [<60060e30>] filemap_fault+0x1a0/0x2f0
[ 1062.770000] 7e9efc68:  [<60071027>] __do_fault+0x67/0x480
[ 1062.770000] 7e9efc88:  [<6002a5ff>] map+0x11f/0x140
[ 1062.770000] 7e9efcf8:  [<6007147c>] do_linear_fault+0x3c/0x40
[ 1062.770000] 7e9efd08:  [<6031638e>] _spin_unlock_irq+0xe/0x10
[ 1062.770000] 7e9efd18:  [<600717b3>] handle_mm_fault+0x143/0x2e0
[ 1062.770000] 7e9efd28:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1062.770000] 7e9efd88:  [<6001725b>] handle_page_fault+0x18b/0x240
[ 1062.770000] 7e9efdf8:  [<600175e2>] segv+0x1b2/0x2d0
[ 1062.770000] 7e9efee8:  [<6001742b>] segv_handler+0x7b/0x80
[ 1062.770000] 7e9eff18:  [<6002b2be>] userspace+0x22e/0x300
[ 1062.770000] 7e9effc8:  [<60014992>] fork_handler+0x62/0x70
[ 1062.770000]
[ 1062.770000] Mem-info:
[ 1062.770000] Normal per-cpu:
[ 1062.770000] CPU    0: hi:  186, btch:  31 usd: 158
[ 1062.770000] Active:121480 inactive:12 dirty:0 writeback:0 unstable:0
[ 1062.770000]  free:711 slab:1453 mapped:0 pagetables:379 bounce:0
[ 1062.770000] Normal free:2844kB min:2876kB low:3592kB high:4312kB active:485920kB inactive:48kB present:517120kB pages_scanned:850578 all_unreclaimable? yes
[ 1062.770000] lowmem_reserve[]: 0 0
[ 1062.770000] Normal: 3*4kB 2*8kB 2*16kB 3*32kB 0*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2844kB
[ 1062.770000] 75 total pagecache pages
[ 1062.770000] Swap cache: add 0, delete 0, find 0/0
[ 1062.770000] Free swap  = 0kB
[ 1062.770000] Total swap = 0kB
[ 1062.770000] Free swap:            0kB
[ 1062.770000] 131072 pages of RAM
[ 1062.770000] 0 pages of HIGHMEM
[ 1062.770000] 5047 reserved pages
[ 1062.770000] 181 pages shared
[ 1062.770000] 0 pages swap cached
[ 1062.770000] Out of memory: kill process 1008 (klogd) score 58 or a child
[ 1062.770000] Killed process 1008 (klogd)
[ 1063.270000] resvtest invoked oom-killer: gfp_mask=0x1200d2, order=0, oomkilladj=-17
[ 1063.270000] Call Trace:
[ 1063.270000] 6792bb58:  [<60037a85>] printk_ratelimit+0x15/0x20
[ 1063.270000] 6792bb68:  [<60063895>] oom_kill_process+0x125/0x160
[ 1063.270000] 6792bbb8:  [<60063a83>] out_of_memory+0xa3/0x140
[ 1063.270000] 6792bc08:  [<6006567e>] __alloc_pages+0x2ae/0x3d0
[ 1063.270000] 6792bc38:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1063.270000] 6792bc78:  [<60076a82>] anon_vma_prepare+0x32/0x120
[ 1063.270000] 6792bcb8:  [<60070e5b>] do_anonymous_page+0x4b/0x1b0
[ 1063.270000] 6792bd18:  [<600718db>] handle_mm_fault+0x26b/0x2e0
[ 1063.270000] 6792bd28:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1063.270000] 6792bd88:  [<6001725b>] handle_page_fault+0x18b/0x240
[ 1063.270000] 6792bdf8:  [<600175e2>] segv+0x1b2/0x2d0
[ 1063.270000] 6792bee8:  [<6001742b>] segv_handler+0x7b/0x80
[ 1063.270000] 6792bf18:  [<6002b2be>] userspace+0x22e/0x300
[ 1063.270000] 6792bfc8:  [<60014992>] fork_handler+0x62/0x70
[ 1063.270000]
[ 1063.270000] Mem-info:
[ 1063.270000] Normal per-cpu:
[ 1063.270000] CPU    0: hi:  186, btch:  31 usd: 174
[ 1063.270000] Active:121437 inactive:75 dirty:0 writeback:0 unstable:0
[ 1063.270000]  free:715 slab:1453 mapped:0 pagetables:372 bounce:0
[ 1063.270000] Normal free:2860kB min:2876kB low:3592kB high:4312kB active:485748kB inactive:300kB present:517120kB pages_scanned:941856 all_unreclaimable? yes
[ 1063.270000] lowmem_reserve[]: 0 0
[ 1063.270000] Normal: 3*4kB 2*8kB 3*16kB 3*32kB 0*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2860kB
[ 1063.270000] 75 total pagecache pages
[ 1063.270000] Swap cache: add 0, delete 0, find 0/0
[ 1063.270000] Free swap  = 0kB
[ 1063.270000] Total swap = 0kB
[ 1063.270000] Free swap:            0kB
[ 1063.270000] 131072 pages of RAM
[ 1063.270000] 0 pages of HIGHMEM
[ 1063.270000] 5047 reserved pages
[ 1063.270000] 181 pages shared
[ 1063.270000] 0 pages swap cached
[ 1063.270000] Out of memory: kill process 1081 (getty) score 58 or a child
[ 1063.270000] Killed process 1081 (getty)
[ 1063.620000] Kernel panic - not syncing: Out of memory and no killable processes...
[ 1063.620000]
[ 1063.620000]
[ 1063.620000] Pid: 5888, comm: resvtest Not tainted 2.6.25-xfs-btree
[ 1063.620000] RIP: 0033:[<000000004028d60b>]
[ 1063.620000] RSP: 0000007fbfd6b640  EFLAGS: 00010206
[ 1063.620000] RAX: 0000000000001011 RBX: 000000001dd12370 RCX: 000000001dd13380
[ 1063.620000] RDX: 0000000000000000 RSI: 0000000000000010 RDI: 0000000000000004
[ 1063.620000] RBP: 0000000000001000 R08: 0000000000000003 R09: 0000007fbfd6b510
[ 1063.620000] R10: 0000000000000008 R11: 0000000000000206 R12: 000000004055fa00
[ 1063.620000] R13: 000000004055f9a0 R14: 0000000000016c81 R15: 0000000000001010
[ 1063.620000] Call Trace:
[ 1063.620000] 6792ba48:  [<600179df>] panic_exit+0x2f/0x50
[ 1063.620000] 6792ba68:  [<600514b5>] notifier_call_chain+0x45/0x90
[ 1063.620000] 6792baa8:  [<600515bd>] __atomic_notifier_call_chain+0xd/0x10
[ 1063.620000] 6792bab8:  [<600515d1>] atomic_notifier_call_chain+0x11/0x20
[ 1063.620000] 6792bac8:  [<60035f26>] panic+0xe6/0x1a0
[ 1063.620000] 6792bb28:  [<6005038c>] ktime_get_ts+0x4c/0x60
[ 1063.620000] 6792bb48:  [<60063406>] select_bad_process+0x36/0x110
[ 1063.620000] 6792bbb8:  [<60063b00>] out_of_memory+0x120/0x140
[ 1063.620000] 6792bc08:  [<6006567e>] __alloc_pages+0x2ae/0x3d0
[ 1063.620000] 6792bc38:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1063.620000] 6792bc78:  [<60076a82>] anon_vma_prepare+0x32/0x120
[ 1063.620000] 6792bcb8:  [<60070e5b>] do_anonymous_page+0x4b/0x1b0
[ 1063.620000] 6792bd18:  [<600718db>] handle_mm_fault+0x26b/0x2e0
[ 1063.620000] 6792bd28:  [<6003310c>] __might_sleep+0xdc/0x120
[ 1063.620000] 6792bd88:  [<6001725b>] handle_page_fault+0x18b/0x240
[ 1063.620000] 6792bdf8:  [<600175e2>] segv+0x1b2/0x2d0
[ 1063.620000] 6792bee8:  [<6001742b>] segv_handler+0x7b/0x80
[ 1063.620000] 6792bf18:  [<6002b2be>] userspace+0x22e/0x300
[ 1063.620000] 6792bfc8:  [<60014992>] fork_handler+0x62/0x70
[ 1063.620000]
Terminated

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
