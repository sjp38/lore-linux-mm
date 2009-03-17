Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0C8626B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 05:51:23 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: oom-killer killing even if memory is available?
Date: Tue, 17 Mar 2009 20:51:13 +1100
References: <20090317100049.33f67964@osiris.boeblingen.de.ibm.com>
In-Reply-To: <20090317100049.33f67964@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903172051.13907.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andreas Krebbel <krebbel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 20:00:49 Heiko Carstens wrote:
> Hi all,
>
> the below looks like there is some bug in the memory management code.
> Even if there seems to be plenty of memory available the oom-killer
> kills processes.
>
> The below happened after 27 days uptime, memory seems to be heavily
> fragmented,

What slab allocator are you using?


> but there are stills larger portions of memory free that
> could satisfy an order 2 allocation. Any idea why this fails?

We still keep some watermarks around for higher order pages (for
GFP_ATOMIC and page reclaim etc purposes).

Possibly it is being a bit aggressive with the higher orders; when I
added it I just made a guess at a sane function. See
mm/page_alloc.c:zone_watermark_ok(). In particular, the for loop at the
end of the function is the slowpath where it is calculating higher
order watermarks. The min >>= 1 statement, 1 could be replaced with 2.
Or we could just keep reserves for 0..PAGE_ALLOC_COSTLY_ORDER and then
give away _any_ free pages for higher orders than that.

Still would seem to just prolong the inevitable? Exploding after 27 days
of uptime is rather sad :(


> [root@t6360003 ~]# uptime
>  09:33:41 up 27 days, 22:55,  1 user,  load average: 0.00, 0.00, 0.00
>
> Mar 16 21:40:40 t6360003 kernel: basename invoked oom-killer:
> gfp_mask=0xd0, order=2, oomkilladj=0 Mar 16 21:40:40 t6360003 kernel: CPU:

order 2, __GFP_WAIT|__GFP_IO|__GFP_FS.


> 0 Not tainted 2.6.28 #1
> Mar 16 21:40:40 t6360003 kernel: Process basename (pid: 30555, task:
> 000000007baa6838, ksp: 0000000063867968) Mar 16 21:40:40 t6360003 kernel:
> 0700000084a8c238 0000000063867a90 0000000000000002 0000000000000000 Mar 16
> 21:40:40 t6360003 kernel:        0000000063867b30 0000000063867aa8
> 0000000063867aa8 000000000010534e Mar 16 21:40:40 t6360003 kernel:       
> 0000000000000000 0000000063867968 0000000000000000 000000000000000a Mar 16
> 21:40:40 t6360003 kernel:        000000000000000d 0000000000000000
> 0000000063867a90 0000000063867b08 Mar 16 21:40:40 t6360003 kernel:       
> 00000000004a5ab0 000000000010534e 0000000063867a90 0000000063867ae0 Mar 16
> 21:40:40 t6360003 kernel: Call Trace:
> Mar 16 21:40:40 t6360003 kernel: ([<0000000000105248>]
> show_trace+0xf4/0x144) Mar 16 21:40:40 t6360003 kernel: 
> [<0000000000105300>] show_stack+0x68/0xf4 Mar 16 21:40:40 t6360003 kernel: 
> [<000000000049c84c>] dump_stack+0xb0/0xc0 Mar 16 21:40:40 t6360003 kernel: 
> [<000000000019235e>] oom_kill_process+0x9e/0x220 Mar 16 21:40:40 t6360003
> kernel:  [<0000000000192c30>] out_of_memory+0x17c/0x264 Mar 16 21:40:40
> t6360003 kernel:  [<000000000019714e>] __alloc_pages_internal+0x4f6/0x534
> Mar 16 21:40:40 t6360003 kernel:  [<0000000000104058>]
> crst_table_alloc+0x48/0x108 Mar 16 21:40:40 t6360003 kernel: 
> [<00000000001a3f60>] __pmd_alloc+0x3c/0x1a8 Mar 16 21:40:40 t6360003
> kernel:  [<00000000001a802e>] handle_mm_fault+0x262/0x9cc Mar 16 21:40:40
> t6360003 kernel:  [<00000000004a1a7a>] do_dat_exception+0x30a/0x41c Mar 16
> 21:40:40 t6360003 kernel:  [<0000000000115e5c>] sysc_return+0x0/0x8 Mar 16
> 21:40:40 t6360003 kernel:  [<0000004d193bfae0>] 0x4d193bfae0 Mar 16
> 21:40:40 t6360003 kernel: Mem-Info:
> Mar 16 21:40:40 t6360003 kernel: DMA per-cpu:
> Mar 16 21:40:40 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: Normal per-cpu:
> Mar 16 21:40:40 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:  30
> Mar 16 21:40:40 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:   0
> Mar 16 21:40:40 t6360003 kernel: Active_anon:372 active_file:45
> inactive_anon:154 Mar 16 21:40:40 t6360003 kernel:  inactive_file:152
> unevictable:987 dirty:0 writeback:188 unstable:0 Mar 16 21:40:40 t6360003
> kernel:  free:146348 slab:875833 mapped:805 pagetables:378 bounce:0 Mar 16
> 21:40:40 t6360003 kernel: DMA free:467728kB min:4064kB low:5080kB
> high:6096kB active_anon:0kB inactive_anon:0kB active_file:0kB
> inactive_file:116kB unevictable:0kB present:2068480kB pages_scanned:0
> all_unreclaimable? no Mar 16 21:40:40 t6360003 kernel: lowmem_reserve[]: 0
> 2020 2020
> Mar 16 21:40:40 t6360003 kernel: Normal free:117664kB min:4064kB low:5080kB
> high:6096kB active_anon:1488kB inactive_anon:616kB active_file:188kB
> inactive_file:492kB unevictable:3948kB present:2068480kB pages_scanned:128
> all_unreclaimable? no Mar 16 21:40:40 t6360003 kernel: lowmem_reserve[]: 0
> 0 0
> Mar 16 21:40:40 t6360003 kernel: DMA: 101853*4kB 7419*8kB 2*16kB 2*32kB
> 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB = 467692kB Mar 16 21:40:40 t6360003
> kernel: Normal: 28880*4kB 121*8kB 1*16kB 1*32kB 0*64kB 1*128kB 1*256kB
> 0*512kB 1*1024kB = 117944kB Mar 16 21:40:40 t6360003 kernel: 1688 total
> pagecache pages
> Mar 16 21:40:40 t6360003 kernel: 564 pages in swap cache
> Mar 16 21:40:40 t6360003 kernel: Swap cache stats: add 1106206, delete
> 1105642, find 599107/618721 Mar 16 21:40:40 t6360003 kernel: Free swap  =
> 1959300kB
> Mar 16 21:40:40 t6360003 kernel: Total swap = 1999992kB
> Mar 16 21:40:40 t6360003 kernel: 1048576 pages RAM
> Mar 16 21:40:40 t6360003 kernel: 20255 pages reserved
> Mar 16 21:40:40 t6360003 kernel: 10560 pages shared
> Mar 16 21:40:40 t6360003 kernel: 878998 pages non-shared
> Mar 16 21:40:40 t6360003 kernel: Out of memory: kill process 30502 (cc1)
> score 3672 or a child Mar 16 21:40:40 t6360003 kernel: Killed process 30502
> (cc1)
> Mar 17 01:33:12 t6360003 kernel: sh invoked oom-killer: gfp_mask=0xd0,
> order=2, oomkilladj=0 Mar 17 01:33:12 t6360003 kernel: CPU: 5 Not tainted
> 2.6.28 #1
> Mar 17 01:33:12 t6360003 kernel: Process sh (pid: 16756, task:
> 0000000004852738, ksp: 0000000050b7d738) Mar 17 01:33:12 t6360003 kernel:
> 07000000fbb28238 0000000050b7d860 0000000000000002 0000000000000000 Mar 17
> 01:33:12 t6360003 kernel:        0000000050b7d900 0000000050b7d878
> 0000000050b7d878 000000000010534e Mar 17 01:33:12 t6360003 kernel:       
> 0000000000000000 0000000050b7d738 0000000000000000 000000000000000a Mar 17
> 01:33:12 t6360003 kernel:        000000000000000d 0000000000000000
> 0000000050b7d860 0000000050b7d8d8 Mar 17 01:33:12 t6360003 kernel:       
> 00000000004a5ab0 000000000010534e 0000000050b7d860 0000000050b7d8b0 Mar 17
> 01:33:12 t6360003 kernel: Call Trace:
> Mar 17 01:33:12 t6360003 kernel: ([<0000000000105248>]
> show_trace+0xf4/0x144) Mar 17 01:33:12 t6360003 kernel: 
> [<0000000000105300>] show_stack+0x68/0xf4 Mar 17 01:33:12 t6360003 kernel: 
> [<000000000049c84c>] dump_stack+0xb0/0xc0 Mar 17 01:33:12 t6360003 kernel: 
> [<000000000019235e>] oom_kill_process+0x9e/0x220 Mar 17 01:33:12 t6360003
> kernel:  [<0000000000192c30>] out_of_memory+0x17c/0x264 Mar 17 01:33:12
> t6360003 kernel:  [<000000000019714e>] __alloc_pages_internal+0x4f6/0x534
> Mar 17 01:33:12 t6360003 kernel:  [<0000000000104058>]
> crst_table_alloc+0x48/0x108 Mar 17 01:33:12 t6360003 kernel: 
> [<00000000001a3f60>] __pmd_alloc+0x3c/0x1a8 Mar 17 01:33:12 t6360003
> kernel:  [<00000000001aa8ac>] copy_page_range+0x9ac/0xadc Mar 17 01:33:12
> t6360003 kernel:  [<000000000013db32>] dup_mm+0x342/0x604 Mar 17 01:33:12
> t6360003 kernel:  [<000000000013ef70>] copy_process+0x1118/0x1158 Mar 17
> 01:33:12 t6360003 kernel:  [<000000000013f046>] do_fork+0x96/0x2dc Mar 17
> 01:33:12 t6360003 kernel:  [<000000000010a402>] sys_clone+0x6a/0x78 Mar 17
> 01:33:12 t6360003 kernel:  [<0000000000115e56>] sysc_noemu+0x10/0x16 Mar 17
> 01:33:12 t6360003 kernel:  [<0000004d1949a152>] 0x4d1949a152 Mar 17
> 01:33:12 t6360003 kernel: Mem-Info:
> Mar 17 01:33:12 t6360003 kernel: DMA per-cpu:
> Mar 17 01:33:12 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: Normal per-cpu:
> Mar 17 01:33:12 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:  30
> Mar 17 01:33:12 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:12 t6360003 kernel: Active_anon:1057 active_file:85
> inactive_anon:457 Mar 17 01:33:12 t6360003 kernel:  inactive_file:163
> unevictable:987 dirty:6 writeback:414 unstable:0 Mar 17 01:33:12 t6360003
> kernel:  free:136683 slab:884736 mapped:832 pagetables:375 bounce:0 Mar 17
> 01:33:12 t6360003 kernel: DMA free:445420kB min:4064kB low:5080kB
> high:6096kB active_anon:0kB inactive_anon:8kB active_file:32kB
> inactive_file:4kB unevictable:0kB present:2068480kB pages_scanned:0
> all_unreclaimable? no Mar 17 01:33:12 t6360003 kernel: lowmem_reserve[]: 0
> 2020 2020
> Mar 17 01:33:12 t6360003 kernel: Normal free:101312kB min:4064kB low:5080kB
> high:6096kB active_anon:4228kB inactive_anon:1820kB active_file:308kB
> inactive_file:648kB unevictable:3948kB present:2068480kB pages_scanned:0
> all_unreclaimable? no Mar 17 01:33:12 t6360003 kernel: lowmem_reserve[]: 0
> 0 0
> Mar 17 01:33:12 t6360003 kernel: DMA: 100796*4kB 5166*8kB 5*16kB 1*32kB
> 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB = 445648kB Mar 17 01:33:12 t6360003
> kernel: Normal: 24811*4kB 56*8kB 1*16kB 4*32kB 0*64kB 1*128kB 0*256kB
> 1*512kB 1*1024kB = 101500kB Mar 17 01:33:12 t6360003 kernel: 2265 total
> pagecache pages
> Mar 17 01:33:12 t6360003 kernel: 1197 pages in swap cache
> Mar 17 01:33:12 t6360003 kernel: Swap cache stats: add 3336530, delete
> 3335333, find 2045244/2201205 Mar 17 01:33:12 t6360003 kernel: Free swap  =
> 1971336kB
> Mar 17 01:33:12 t6360003 kernel: Total swap = 1999992kB
> Mar 17 01:33:12 t6360003 kernel: 1048576 pages RAM
> Mar 17 01:33:12 t6360003 kernel: 20255 pages reserved
> Mar 17 01:33:12 t6360003 kernel: 9350 pages shared
> Mar 17 01:33:12 t6360003 kernel: 888261 pages non-shared
> Mar 17 01:33:12 t6360003 kernel: Out of memory: kill process 27449
> (rpmbuild) score 3460 or a child Mar 17 01:33:12 t6360003 kernel: Killed
> process 27519 (sh)
> Mar 17 01:33:13 t6360003 kernel: as invoked oom-killer: gfp_mask=0xd0,
> order=2, oomkilladj=0 Mar 17 01:33:13 t6360003 kernel: CPU: 2 Not tainted
> 2.6.28 #1
> Mar 17 01:33:13 t6360003 kernel: Process as (pid: 16914, task:
> 0000000084aba338, ksp: 000000000e3c76d8) Mar 17 01:33:13 t6360003 kernel:
> 0700000035e74138 000000000e3c7800 0000000000000002 0000000000000000 Mar 17
> 01:33:13 t6360003 kernel:        000000000e3c78a0 000000000e3c7818
> 000000000e3c7818 000000000010534e Mar 17 01:33:13 t6360003 kernel:       
> 0000000000000000 000000000e3c76d8 0000000000000000 000000000000000a Mar 17
> 01:33:13 t6360003 kernel:        000000000000000d 0000000000000000
> 000000000e3c7800 000000000e3c7878 Mar 17 01:33:13 t6360003 kernel:       
> 00000000004a5ab0 000000000010534e 000000000e3c7800 000000000e3c7850 Mar 17
> 01:33:13 t6360003 kernel: Call Trace:
> Mar 17 01:33:13 t6360003 kernel: ([<0000000000105248>]
> show_trace+0xf4/0x144) Mar 17 01:33:13 t6360003 kernel: 
> [<0000000000105300>] show_stack+0x68/0xf4 Mar 17 01:33:13 t6360003 kernel: 
> [<000000000049c84c>] dump_stack+0xb0/0xc0 Mar 17 01:33:13 t6360003 kernel: 
> [<000000000019235e>] oom_kill_process+0x9e/0x220 Mar 17 01:33:13 t6360003
> kernel:  [<0000000000192c30>] out_of_memory+0x17c/0x264 Mar 17 01:33:13
> t6360003 kernel:  [<000000000019714e>] __alloc_pages_internal+0x4f6/0x534
> Mar 17 01:33:13 t6360003 kernel:  [<0000000000104058>]
> crst_table_alloc+0x48/0x108 Mar 17 01:33:13 t6360003 kernel: 
> [<00000000001a3f60>] __pmd_alloc+0x3c/0x1a8 Mar 17 01:33:13 t6360003
> kernel:  [<00000000001a802e>] handle_mm_fault+0x262/0x9cc Mar 17 01:33:13
> t6360003 kernel:  [<00000000001a894e>] __get_user_pages+0x1b6/0x574 Mar 17
> 01:33:13 t6360003 kernel:  [<00000000001a8d5a>] get_user_pages+0x4e/0x60
> Mar 17 01:33:13 t6360003 kernel:  [<00000000001d58c4>]
> get_arg_page+0x6c/0xe8 Mar 17 01:33:13 t6360003 kernel: 
> [<00000000001d5c3a>] copy_strings+0x1aa/0x290 Mar 17 01:33:13 t6360003
> kernel:  [<00000000001d5d7e>] copy_strings_kernel+0x5e/0xb0 Mar 17 01:33:13
> t6360003 kernel:  [<00000000001d78b0>] do_execve+0x1c8/0x254 Mar 17
> 01:33:13 t6360003 kernel:  [<000000000010a2f8>] sys_execve+0x80/0xb8 Mar 17
> 01:33:13 t6360003 kernel:  [<0000000000115e56>] sysc_noemu+0x10/0x16 Mar 17
> 01:33:13 t6360003 kernel:  [<0000004d1949a40c>] 0x4d1949a40c Mar 17
> 01:33:13 t6360003 kernel: Mem-Info:
> Mar 17 01:33:13 t6360003 kernel: DMA per-cpu:
> Mar 17 01:33:13 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: Normal per-cpu:
> Mar 17 01:33:13 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:13 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:  12
> Mar 17 01:33:13 t6360003 kernel: Active_anon:274 active_file:126
> inactive_anon:92 Mar 17 01:33:13 t6360003 kernel:  inactive_file:110
> unevictable:987 dirty:20 writeback:222 unstable:0 Mar 17 01:33:13 t6360003
> kernel:  free:137753 slab:884727 mapped:901 pagetables:318 bounce:0 Mar 17
> 01:33:13 t6360003 kernel: DMA free:445604kB min:4064kB low:5080kB
> high:6096kB active_anon:8kB inactive_anon:0kB active_file:0kB
> inactive_file:104kB unevictable:0kB present:2068480kB pages_scanned:0
> all_unreclaimable? no Mar 17 01:33:13 t6360003 kernel: lowmem_reserve[]: 0
> 2020 2020
> Mar 17 01:33:13 t6360003 kernel: Normal free:105408kB min:4064kB low:5080kB
> high:6096kB active_anon:1088kB inactive_anon:368kB active_file:504kB
> inactive_file:336kB unevictable:3948kB present:2068480kB pages_scanned:450
> all_unreclaimable? no Mar 17 01:33:13 t6360003 kernel: lowmem_reserve[]: 0
> 0 0
> Mar 17 01:33:13 t6360003 kernel: DMA: 100811*4kB 5173*8kB 6*16kB 0*32kB
> 1*64kB 0*128kB 0*256kB 0*512kB 1*1024kB = 445812kB Mar 17 01:33:13 t6360003
> kernel: Normal: 25877*4kB 62*8kB 1*16kB 1*32kB 1*64kB 0*128kB 0*256kB
> 1*512kB 1*1024kB = 105652kB Mar 17 01:33:13 t6360003 kernel: 1477 total
> pagecache pages
> Mar 17 01:33:13 t6360003 kernel: 398 pages in swap cache
> Mar 17 01:33:13 t6360003 kernel: Swap cache stats: add 3343439, delete
> 3343041, find 2048863/2205415 Mar 17 01:33:13 t6360003 kernel: Free swap  =
> 1960020kB
> Mar 17 01:33:13 t6360003 kernel: Total swap = 1999992kB
> Mar 17 01:33:13 t6360003 kernel: 1048576 pages RAM
> Mar 17 01:33:13 t6360003 kernel: 20255 pages reserved
> Mar 17 01:33:13 t6360003 kernel: 9549 pages shared
> Mar 17 01:33:13 t6360003 kernel: 887159 pages non-shared
> Mar 17 01:33:13 t6360003 kernel: Out of memory: kill process 29305 (make)
> score 3403 or a child Mar 17 01:33:13 t6360003 kernel: Killed process 29320
> (sh)
> Mar 17 01:33:14 t6360003 kernel: sh invoked oom-killer: gfp_mask=0xd0,
> order=2, oomkilladj=0 Mar 17 01:33:14 t6360003 kernel: CPU: 4 Not tainted
> 2.6.28 #1
> Mar 17 01:33:14 t6360003 kernel: Process sh (pid: 16922, task:
> 0000000084ab6138, ksp: 0000000060781738) Mar 17 01:33:14 t6360003 kernel:
> 070000003d7a0438 0000000060781860 0000000000000002 0000000000000000 Mar 17
> 01:33:14 t6360003 kernel:        0000000060781900 0000000060781878
> 0000000060781878 000000000010534e Mar 17 01:33:14 t6360003 kernel:       
> 0000000000000000 0000000060781738 0000000000000000 000000000000000a Mar 17
> 01:33:14 t6360003 kernel:        000000000000000d 0000000000000000
> 0000000060781860 00000000607818d8 Mar 17 01:33:14 t6360003 kernel:       
> 00000000004a5ab0 000000000010534e 0000000060781860 00000000607818b0 Mar 17
> 01:33:14 t6360003 kernel: Call Trace:
> Mar 17 01:33:14 t6360003 kernel: ([<0000000000105248>]
> show_trace+0xf4/0x144) Mar 17 01:33:14 t6360003 kernel: 
> [<0000000000105300>] show_stack+0x68/0xf4 Mar 17 01:33:14 t6360003 kernel: 
> [<000000000049c84c>] dump_stack+0xb0/0xc0 Mar 17 01:33:14 t6360003 kernel: 
> [<000000000019235e>] oom_kill_process+0x9e/0x220 Mar 17 01:33:14 t6360003
> kernel:  [<0000000000192c30>] out_of_memory+0x17c/0x264 Mar 17 01:33:14
> t6360003 kernel:  [<000000000019714e>] __alloc_pages_internal+0x4f6/0x534
> Mar 17 01:33:14 t6360003 kernel:  [<0000000000104058>]
> crst_table_alloc+0x48/0x108 Mar 17 01:33:14 t6360003 kernel: 
> [<00000000001a3f60>] __pmd_alloc+0x3c/0x1a8 Mar 17 01:33:14 t6360003
> kernel:  [<00000000001aa8ac>] copy_page_range+0x9ac/0xadc Mar 17 01:33:14
> t6360003 kernel:  [<000000000013db32>] dup_mm+0x342/0x604 Mar 17 01:33:14
> t6360003 kernel:  [<000000000013ef70>] copy_process+0x1118/0x1158 Mar 17
> 01:33:14 t6360003 kernel:  [<000000000013f046>] do_fork+0x96/0x2dc Mar 17
> 01:33:14 t6360003 kernel:  [<000000000010a402>] sys_clone+0x6a/0x78 Mar 17
> 01:33:14 t6360003 kernel:  [<0000000000115e56>] sysc_noemu+0x10/0x16 Mar 17
> 01:33:14 t6360003 kernel:  [<0000004d1949a152>] 0x4d1949a152 Mar 17
> 01:33:14 t6360003 kernel: Mem-Info:
> Mar 17 01:33:14 t6360003 kernel: DMA per-cpu:
> Mar 17 01:33:14 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: Normal per-cpu:
> Mar 17 01:33:14 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:  42
> Mar 17 01:33:14 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:  50
> Mar 17 01:33:14 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:   0
> Mar 17 01:33:14 t6360003 kernel: Active_anon:171 active_file:100
> inactive_anon:74 Mar 17 01:33:14 t6360003 kernel:  inactive_file:78
> unevictable:987 dirty:0 writeback:146 unstable:0 Mar 17 01:33:14 t6360003
> kernel:  free:137942 slab:884626 mapped:858 pagetables:357 bounce:0 Mar 17
> 01:33:14 t6360003 kernel: DMA free:445612kB min:4064kB low:5080kB
> high:6096kB active_anon:0kB inactive_anon:8kB active_file:104kB
> inactive_file:0kB unevictable:0kB present:2068480kB pages_scanned:0
> all_unreclaimable? no Mar 17 01:33:14 t6360003 kernel: lowmem_reserve[]: 0
> 2020 2020
> Mar 17 01:33:14 t6360003 kernel: Normal free:106156kB min:4064kB low:5080kB
> high:6096kB active_anon:684kB inactive_anon:288kB active_file:296kB
> inactive_file:312kB unevictable:3948kB present:2068480kB pages_scanned:544
> all_unreclaimable? no Mar 17 01:33:14 t6360003 kernel: lowmem_reserve[]: 0
> 0 0
> Mar 17 01:33:14 t6360003 kernel: DMA: 100818*4kB 5175*8kB 2*16kB 3*32kB
> 1*64kB 0*128kB 0*256kB 0*512kB 1*1024kB = 445888kB Mar 17 01:33:14 t6360003
> kernel: Normal: 25978*4kB 76*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
> 1*512kB 1*1024kB = 106184kB Mar 17 01:33:14 t6360003 kernel: 1315 total
> pagecache pages
> Mar 17 01:33:14 t6360003 kernel: 321 pages in swap cache
> Mar 17 01:33:14 t6360003 kernel: Swap cache stats: add 3349005, delete
> 3348684, find 2049544/2206461 Mar 17 01:33:14 t6360003 kernel: Free swap  =
> 1947096kB
> Mar 17 01:33:14 t6360003 kernel: Total swap = 1999992kB
> Mar 17 01:33:14 t6360003 kernel: 1048576 pages RAM
> Mar 17 01:33:14 t6360003 kernel: 20255 pages reserved
> Mar 17 01:33:14 t6360003 kernel: 9878 pages shared
> Mar 17 01:33:14 t6360003 kernel: 887456 pages non-shared
> Mar 17 01:33:14 t6360003 kernel: Out of memory: kill process 16782 (cc1)
> score 3375 or a child Mar 17 01:33:14 t6360003 kernel: Killed process 16782
> (cc1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
