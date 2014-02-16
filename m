Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id ED27E6B0071
	for <linux-mm@kvack.org>; Sun, 16 Feb 2014 15:05:10 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id k14so1713591wgh.14
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 12:05:10 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id bc8si8786141wjb.9.2014.02.16.12.05.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Feb 2014 12:05:09 -0800 (PST)
Date: Sun, 16 Feb 2014 20:05:04 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Recent 3.x kernels: Memory leak causing OOMs
Message-ID: <20140216200503.GN30257@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Guys,

I'm seeing a lot of my machines OOM from time to time with recent 3.x
kernels.  Systems which previously ended up with 1400+ days uptime with
older kernels barely manage much more than a month.

This can happen with /any/ workload, though it takes a long time with
128MB of SDRAM - the order of 40 to 60 days.  Workload may depend on how
quickly it shows.

Obviously, if it takes 1-2 months to show with 128MB of RAM, think how
long it would take with 8GB or more... which is why I doubt it's been
seen yet on x86.

I have one platform here (Versatile PB926) who's sole job is monitoring
the power system supplying the test board - it sits there running a
thread which regularly polls two I2C buses via GPIO bitbang.  Userspace
doesn't change its memory requirements very often if at all.  No crond,
no atd.

The only other thing which happens is the occasional network connection
to tell it to power a board up or down, or to download the power logs.

Yet somehow, this platform tonight has gone into OOM when I telnetted
to it to get a shell.  See the log below.

Now, this runs cramfs with no swap, but that's irrelevent.

I have another machine which OOM'd a week ago with plenty of unused swap
- it uses ext3 on raid1 and is a more busy system.  That took 41 days
to show, and upon reboot, it got a kernel with kmemleak enabled.  So far,
after 7 days, kmemleak has found nothing at all.

I've previously seen it on my old firewall - which had less RAM, but I
had put that down to the workload not fitting in RAM - now I'm less sure
that was the problem.

CPU doesn't matter - I've now seen it with StrongARMs and ARM926s, so it
can't be low-vectors issues.

It is quite clear to me that there is something really bad with 3.x
kernels.  Exactly when this started, I can't say - and with it taking
of the order of a month or more to show, it's not something which can be
bisected.

ash invoked oom-killer: gfp_mask=0x201d0, order=0, oom_score_adj=0
CPU: 0 PID: 598 Comm: ash Tainted: G           O 3.13.0-rc3+ #663
Backtrace:
[<c0016da4>] (dump_backtrace) from [<c0017150>] (show_stack+0x18/0x1c)
 r6:00000000 r5:00000000 r4:c7b8e000 r3:00400100
[<c0017138>] (show_stack) from [<c0322c94>] (dump_stack+0x20/0x2c)
[<c0322c74>] (dump_stack) from [<c0073d98>] (dump_header.clone.13+0x6c/0x1d8)
[<c0073d2c>] (dump_header.clone.13) from [<c00740f8>] (oom_kill_process+0x9c/0x3bc)
 r10:000201d0 r9:00000000 r8:00000000 r7:00000000 r6:00000380 r5:c7b7b800
 r4:000201d0
[<c007405c>] (oom_kill_process) from [<c00748d8>] (out_of_memory+0x2d4/0x338)
 r10:000201d0 r9:000201d0 r8:00000000 r7:00007556 r6:00006924 r5:c7b7b800
 r4:c7b7b800
[<c0074604>] (out_of_memory) from [<c0078408>] (__alloc_pages_nodemask+0x5cc/0x6bc)
 r10:00000000 r9:00000000 r8:c04862c0 r7:00000000 r6:00000000 r5:c7b8e000
 r4:000201d0
[<c0077e3c>] (__alloc_pages_nodemask) from [<c0071824>] (do_read_cache_page+0x50/0x178)
 r10:000200d0 r9:000201d0 r8:c00d414c r7:00000000 r6:c74027dc r5:00000035
 r4:00000000
[<c00717d4>] (do_read_cache_page) from [<c007199c>] (read_cache_page_async+0x20/0x28)
 r10:00000886 r9:c782dd28 r8:c782dd30 r7:00000132 r6:c74027dc r5:c7b73000
 r4:00001070
[<c007197c>] (read_cache_page_async) from [<c010049c>] (cramfs_read+0x104/0x21c)[<c0100398>] (cramfs_read) from [<c0100bdc>] (cramfs_readpage+0xe8/0x1a4)
 r10:000c6628 r9:c0a9f4a0 r8:c7b73000 r7:0012f886 r6:00000a4d r5:c7d25000
 r4:c0a9f4a0
[<c0100af4>] (cramfs_readpage) from [<c0072bd4>] (filemap_fault+0x298/0x394)
 r10:c7b9a318 r8:00000004 r7:c7417ea4 r6:000000b6 r5:c7417ea4 r4:c7bc0cc0
[<c007293c>] (filemap_fault) from [<c008aa3c>] (__do_fault+0xa8/0x490)
 r10:c7b9edb8 r9:000005b7 r8:000000b6 r7:000000a8 r6:c7b83d40 r5:00000000
 r4:c7b9a318
[<c008a994>] (__do_fault) from [<c008df3c>] (handle_mm_fault+0x3b8/0x854)
 r10:00000000 r9:000005b7 r8:000000b6 r7:b6f0c000 r6:c7b83d40 r5:c7bb0430
 r4:c7b9a318
[<c008db84>] (handle_mm_fault) from [<c001b3e8>] (do_page_fault+0x12c/0x28c)
 r10:80000005 r9:c7b9a318 r8:c7b83d40 r7:000000a8 r6:c78257e0 r5:b6f0ced8
 r4:c782dfb0
[<c001b2bc>] (do_page_fault) from [<c001b5e0>] (do_translation_fault+0x24/0xac)
 r10:bef2bc70 r9:00009f30 r8:bef2bc6c r7:c782dfb0 r6:b6f0ced8 r5:c0459ad4
 r4:80000005
[<c001b5bc>] (do_translation_fault) from [<c00086bc>] (do_PrefetchAbort+0x3c/0xa0)
 r7:c782dfb0 r6:b6f0ced8 r5:c0459ad4 r4:00000005
[<c0008680>] (do_PrefetchAbort) from [<c0017fb8>] (ret_from_exception+0x0/0x10)
Exception stack(0xc782dfb0 to 0xc782dff8)
dfa0:                                     00000003 bef2b920 bef2bb98 00000003
dfc0: bef2bb98 00016658 00016880 000000c3 bef2bc6c 00009f30 bef2bc70 00016880
dfe0: 00000000 bef2b920 b6f05dbc b6f0ced8 60000010 ffffffff
 r7:000000c3 r6:ffffffff r5:60000010 r4:b6f0ced8
Mem-info:
Normal per-cpu:
CPU    0: hi:   42, btch:   7 usd:  36
active_anon:28041 inactive_anon:104 isolated_anon:0
 active_file:11 inactive_file:11 isolated_file:0
 unevictable:0 dirty:1 writeback:6 unstable:0
 free:342 slab_reclaimable:170 slab_unreclaimable:570
 mapped:13 shmem:139 pagetables:95 bounce:0
 free_cma:0
Normal free:1368kB min:1384kB low:1728kB high:2076kB active_anon:112164kB inactive_anon:416kB active_file:44kB inactive_file:44kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:131072kB managed:120152kB mlocked:0kB dirty:4kB
writeback:24kB mapped:52kB shmem:556kB slab_reclaimable:680kB slab_unreclaimable:2280kB kernel_stack:248kB pagetables:380kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:136 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0
Normal: 4*4kB (R) 1*8kB (R) 0*16kB 0*32kB 1*64kB (R) 0*128kB 1*256kB (R) 0*512kB 1*1024kB (R) 0*2048kB 0*4096kB = 1368kB
161 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
32768 pages of RAM
448 free pages
2730 reserved pages
681 slab pages
261905 pages shared
0 pages swap cached
[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[  519]     1   519      425       17       3        0             0 portmap
[  529]     0   529      480       24       4        0             0 inetd
[  562]     0   562      397       15       4        0             0 getty
[  563]     0   563      397       15       3        0             0 getty
[  564]     0   564      397       15       3        0             0 getty
[  565]     0   565      397       15       4        0             0 getty
[  566]     0   566      414       14       4        0             0 user_interface.
[  570]     0   570      397       15       3        0             0 getty
[  702]     0   702      543       41       3        0             0 in.telnetd
[  703]     0   703     1023       57       4        0             0 ash
[  756]     0   756    28163    27776      57        0             0 ld-linux.so.2
Out of memory: Kill process 756 (ld-linux.so.2) score 896 or sacrifice child
Killed process 756 (ld-linux.so.2) total-vm:112652kB, anon-rss:111052kB, file-rss:52kB
INFO: task ld-linux.so.2:842 blocked for more than 120 seconds.
      Tainted: G           O 3.13.0-rc3+ #663
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ld-linux.so.2   D c032364c     0   842      1 0x00000000
Backtrace:
[<c03232a4>] (__schedule) from [<c03237d8>] (schedule+0x98/0x9c)
 r10:00000001 r9:c7b83054 r8:00000002 r7:c720fdac r6:c0071240 r5:c0aa6060
 r4:c720e000 r3:00000000
[<c0323740>] (schedule) from [<c032384c>] (io_schedule+0x70/0xa8)
[<c03237dc>] (io_schedule) from [<c0071250>] (sleep_on_page+0x10/0x18)
 r4:c720fda4 r3:0000000d
[<c0071240>] (sleep_on_page) from [<c0323d48>] (__wait_on_bit+0x5c/0xa4)
[<c0323cec>] (__wait_on_bit) from [<c0071544>] (wait_on_page_bit+0x98/0xa8)
 r10:07f9518f r8:c71661cc r7:c7290820 r6:c0aa42a0 r5:c720fda4 r4:00000001
[<c00714ac>] (wait_on_page_bit) from [<c010b480>] (nfs_vm_page_mkwrite+0x80/0x158)
 r7:c711d600 r6:c0aa42a0 r5:c7bd5318 r4:c74bbad0
[<c010b400>] (nfs_vm_page_mkwrite) from [<c008bd04>] (do_wp_page+0x238/0x7d0)
 r7:c7b83020 r6:b6673000 r5:c7bd5318 r4:c0aa42a0
[<c008bacc>] (do_wp_page) from [<c008e320>] (handle_mm_fault+0x79c/0x854)
 r10:07f9518f r9:c7b83054 r8:00000001 r7:b6673000 r6:c7b83020 r5:c71661cc
 r4:c7bd5318
[<c008db84>] (handle_mm_fault) from [<c001b3e8>] (do_page_fault+0x12c/0x28c)
 r10:0000081f r9:c7bd5318 r8:c7b83020 r7:000000a9 r6:c7290820 r5:b667300c
 r4:c720ffb0
[<c001b2bc>] (do_page_fault) from [<c0008618>] (do_DataAbort+0x38/0xa0)
 r10:00000003 r9:00016944 r8:c720ffb0 r7:c0459a84 r6:b667300c r5:0000000f
 r4:0000081f
[<c00085e0>] (do_DataAbort) from [<c0017de0>] (__dabt_usr+0x40/0x60)
Exception stack(0xc720ffb0 to 0xc720fff8)
ffa0:                                     00019f0a 0000186a 0067daea 00000000
ffc0: 8407ace5 0001bf16 00000000 0000186a becdf9b4 00016944 00000003 becdf980
ffe0: b6673000 becdf958 b667300c 0000a4b4 80000010 ffffffff
 r8:becdf9b4 r7:0000186a r6:ffffffff r5:80000010 r4:0000a4b4
1 lock held by ld-linux.so.2/842:
 #0:  (&mm->mmap_sem){++++++}, at: [<c001b35c>] do_page_fault+0xa0/0x28c
INFO: task ld-linux.so.2:842 blocked for more than 120 seconds.
      Tainted: G           O 3.13.0-rc3+ #663
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ld-linux.so.2   D c032364c     0   842      1 0x00000000
Backtrace:
[<c03232a4>] (__schedule) from [<c03237d8>] (schedule+0x98/0x9c)
 r10:00000001 r9:c7b83054 r8:00000002 r7:c720fdac r6:c0071240 r5:c0aa5728
 r4:c720e000 r3:00000000
[<c0323740>] (schedule) from [<c032384c>] (io_schedule+0x70/0xa8)
[<c03237dc>] (io_schedule) from [<c0071250>] (sleep_on_page+0x10/0x18)
 r4:c720fda4 r3:0000000d
[<c0071240>] (sleep_on_page) from [<c0323d48>] (__wait_on_bit+0x5c/0xa4)
[<c0323cec>] (__wait_on_bit) from [<c0071544>] (wait_on_page_bit+0x98/0xa8)
 r10:05e3e18f r8:c70ac1a4 r7:c7290820 r6:c0a617c0 r5:c720fda4 r4:00000001
[<c00714ac>] (wait_on_page_bit) from [<c010b480>] (nfs_vm_page_mkwrite+0x80/0x158)
 r7:c711d280 r6:c0a617c0 r5:c7bd5420 r4:c74bcaf0
[<c010b400>] (nfs_vm_page_mkwrite) from [<c008bd04>] (do_wp_page+0x238/0x7d0)
 r7:c7b83020 r6:b5269000 r5:c7bd5420 r4:c0a617c0
[<c008bacc>] (do_wp_page) from [<c008e320>] (handle_mm_fault+0x79c/0x854)
 r10:05e3e18f r9:c7b83054 r8:00000001 r7:b5269000 r6:c7b83020 r5:c70ac1a4
 r4:c7bd5420
[<c008db84>] (handle_mm_fault) from [<c001b3e8>] (do_page_fault+0x12c/0x28c)
 r10:0000081f r9:c7bd5420 r8:c7b83020 r7:000000a9 r6:c7290820 r5:b526900c
 r4:c720ffb0
[<c001b2bc>] (do_page_fault) from [<c0008618>] (do_DataAbort+0x38/0xa0)
 r10:00000003 r9:00016944 r8:c720ffb0 r7:c0459a84 r6:b526900c r5:0000000f
 r4:0000081f
[<c00085e0>] (do_DataAbort) from [<c0017de0>] (__dabt_usr+0x40/0x60)
Exception stack(0xc720ffb0 to 0xc720fff8)
ffa0:                                     00000000 00000000 00000000 00000000
ffc0: ff9c57d8 00010f33 00000000 00000000 becdf9b4 00016944 00000003 becdf980
ffe0: b5269000 becdf958 b526900c 0000a4b4 80000010 ffffffff
 r8:becdf9b4 r7:00000000 r6:ffffffff r5:80000010 r4:0000a4b4
[<c010b400>] (nfs_vm_page_mkwrite) from [<c008bd04>] (do_wp_page+0x238/0x7d0)
 r7:c7b83020 r6:b5269000 r5:c7bd5420 r4:c0a617c0
[<c008bacc>] (do_wp_page) from [<c008e320>] (handle_mm_fault+0x79c/0x854)
 r10:05e3e18f r9:c7b83054 r8:00000001 r7:b5269000 r6:c7b83020 r5:c70ac1a4
 r4:c7bd5420
[<c008db84>] (handle_mm_fault) from [<c001b3e8>] (do_page_fault+0x12c/0x28c)
 r10:0000081f r9:c7bd5420 r8:c7b83020 r7:000000a9 r6:c7290820 r5:b526900c
 r4:c720ffb0
[<c001b2bc>] (do_page_fault) from [<c0008618>] (do_DataAbort+0x38/0xa0)
 r10:00000003 r9:00016944 r8:c720ffb0 r7:c0459a84 r6:b526900c r5:0000000f
 r4:0000081f
[<c00085e0>] (do_DataAbort) from [<c0017de0>] (__dabt_usr+0x40/0x60)
Exception stack(0xc720ffb0 to 0xc720fff8)
ffa0:                                     00000000 00000000 00000000 00000000
ffc0: ff9c57d8 00010f33 00000000 00000000 becdf9b4 00016944 00000003 becdf980
ffe0: b5269000 becdf958 b526900c 0000a4b4 80000010 ffffffff
 r8:becdf9b4 r7:00000000 r6:ffffffff r5:80000010 r4:0000a4b4
1 lock held by ld-linux.so.2/842:
 #0:  (&mm->mmap_sem){++++++}, at: [<c001b35c>] do_page_fault+0xa0/0x28c
nfs: server flint not responding, still trying
nfs: server flint OK
[sched_delayed] sched: RT throttling activated

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
