Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D7F296B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:14:41 -0400 (EDT)
Date: Tue, 31 May 2011 00:14:32 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1582158305.317043.1306815272554.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <4DE46A4B.40401@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system
 have > gigabytes memory  (aka CAI founded issue)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa hiroyu <kamezawa.hiroyu@jp.fujitsu.com>, minchan kim <minchan.kim@gmail.com>, oleg@redhat.com



----- Original Message -----
> (2011/05/31 10:33), CAI Qian wrote:
> > Hello,
> >
> > Have tested those patches rebased from KOSAKI for the latest
> > mainline.
> > It still killed random processes and recevied a panic at the end by
> > using root user. The full oom output can be found here.
> > http://people.redhat.com/qcai/oom
> 
> You ran fork-bomb as root. Therefore unprivileged process was killed
> at first.
> It's no random. It's intentional and desirable. I mean
> 
> - If you run the same progream as non-root, python will be killed at
> first.
> Because it consume a lot of memory than daemons.
> - If you run the same program as root, non root process and privilege
> explicit
> dropping processes (e.g. irqbalance) will be killed at first.
> 
> 
> Look, your log says, highest oom score process was killed first.
> 
> Out of memory: Kill process 5462 (abrtd) points:393 total-vm:262300kB,
> anon-rss:1024kB, file-rss:0kB
> Out of memory: Kill process 5277 (hald) points:303 total-vm:25444kB,
> anon-rss:1116kB, file-rss:0kB
> Out of memory: Kill process 5720 (sshd) points:258 total-vm:97684kB,
> anon-rss:824kB, file-rss:0kB
> Out of memory: Kill process 5457 (pickup) points:236 total-vm:78672kB,
> anon-rss:768kB, file-rss:0kB
> Out of memory: Kill process 5451 (master) points:235 total-vm:78592kB,
> anon-rss:796kB, file-rss:0kB
> Out of memory: Kill process 5458 (qmgr) points:233 total-vm:78740kB,
> anon-rss:764kB, file-rss:0kB
> Out of memory: Kill process 5353 (sshd) points:189 total-vm:63992kB,
> anon-rss:620kB, file-rss:0kB
> Out of memory: Kill process 1626 (dhclient) points:129
> total-vm:9148kB, anon-rss:484kB, file-rss:0kB
OK, there was also a panic at the end. Is that expected?

BUG: unable to handle kernel NULL pointer dereference at 00000000000002a8
IP: [<ffffffff811227d4>] get_mm_counter+0x14/0x30
PGD 0 
Oops: 0000 [#1] SMP 
CPU 7 
Modules linked in: autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ipv6 dm_mirror dm_region_hash dm_log microcode serio_raw pcspkr cdc_ether usbnet mii i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support sg shpchp ioatdma dca i7core_edac edac_core bnx2 ext4 mbcache jbd2 sd_mod crc_t10dif pata_acpi ata_generic ata_piix mptsas mptscsih mptbase scsi_transport_sas dm_mod [last unloaded: scsi_wait_scan]

Pid: 5232, comm: dbus-daemon Not tainted 3.0.0-rc1+ #3 IBM System x3550 M3 -[7944I21]-/69Y4438     
RIP: 0010:[<ffffffff811227d4>]  [<ffffffff811227d4>] get_mm_counter+0x14/0x30
RSP: 0000:ffff88027116b828  EFLAGS: 00010286
RAX: 00000000000002a0 RBX: ffff880470cd8a80 RCX: 0000000000000003
RDX: 000000000000000e RSI: 0000000000000002 RDI: 0000000000000000
RBP: ffff88027116b828 R08: 0000000000000000 R09: 0000000000000010
R10: 0000000000000000 R11: 0000000000000007 R12: ffff88027116b880
R13: 0000000000000000 R14: 0000000000000000 R15: ffff880270df2100
FS:  00007f78a3837700(0000) GS:ffff88047fc60000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000000002a8 CR3: 000000047238f000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process dbus-daemon (pid: 5232, threadinfo ffff88027116a000, task ffff880270df2100)
Stack:
 ffff88027116b8b8 ffffffff81104c60 0000000000000000 0000000000000000
 ffff8802704c4680 0000000000000000 ffff8802705161c0 0000000000000000
 0000000000000000 0000000000000000 0000000000000286 ffff880470cd8e98
Call Trace:
 [<ffffffff81104c60>] dump_tasks+0xa0/0x160
 [<ffffffff81104dd5>] dump_header+0xb5/0xd0
 [<ffffffff81104f15>] oom_kill_process+0xa5/0x1c0
 [<ffffffff811055ef>] out_of_memory+0xff/0x220
 [<ffffffff8110a962>] __alloc_pages_slowpath+0x632/0x6b0
 [<ffffffff8110ab84>] __alloc_pages_nodemask+0x1a4/0x1f0
 [<ffffffff81147d52>] kmem_getpages+0x62/0x170
 [<ffffffff8114886a>] fallback_alloc+0x1ba/0x270
 [<ffffffff811482e3>] ? cache_grow+0x2c3/0x2f0
 [<ffffffff811485f5>] ____cache_alloc_node+0x95/0x150
 [<ffffffff8114901d>] kmem_cache_alloc+0xfd/0x190
 [<ffffffff810d20ed>] taskstats_exit+0x1cd/0x240
 [<ffffffff81066667>] do_exit+0x177/0x430
 [<ffffffff81066971>] do_group_exit+0x51/0xc0
 [<ffffffff81078583>] get_signal_to_deliver+0x203/0x470
 [<ffffffff8100b939>] do_signal+0x69/0x190
 [<ffffffff8100bac5>] do_notify_resume+0x65/0x80
 [<ffffffff814db6d0>] int_signal+0x12/0x17
Code: 48 8b 00 c9 48 d1 e8 83 e0 01 c3 0f 1f 40 00 31 c0 c9 c3 0f 1f 40 00 55 48 89 e5 66 66 66 66 90 48 63 f6 48 8d 84 f7 90 02 00 00 
 8b 50 08 31 c0 c9 48 85 d2 48 0f 49 c2 c3 66 66 66 66 2e 0f 
RIP  [<ffffffff811227d4>] get_mm_counter+0x14/0x30
 RSP <ffff88027116b828>
CR2: 00000000000002a8
---[ end trace 742b26ee0c4fab73 ]---
Fixing recursive fault but reboot is needed!
Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu 0
Pid: 4, comm: kworker/0:0 Tainted: G      D     3.0.0-rc1+ #3
Call Trace:
 <NMI>  [<ffffffff814d062f>] panic+0x91/0x1a8
 [<ffffffff810c76e1>] watchdog_overflow_callback+0xb1/0xc0
 [<ffffffff810fbbdd>] __perf_event_overflow+0x9d/0x250
 [<ffffffff810fc1c4>] perf_event_overflow+0x14/0x20
 [<ffffffff8101df36>] intel_pmu_handle_irq+0x326/0x530
 [<ffffffff814d4ba9>] perf_event_nmi_handler+0x29/0xa0
 [<ffffffff814d6f65>] notifier_call_chain+0x55/0x80
 [<ffffffff814d6fca>] atomic_notifier_call_chain+0x1a/0x20
 [<ffffffff814d6ffe>] notify_die+0x2e/0x30
 [<ffffffff814d4199>] default_do_nmi+0x39/0x1f0
 [<ffffffff814d43d0>] do_nmi+0x80/0xa0
 [<ffffffff814d3b90>] nmi+0x20/0x30
 [<ffffffff8123f379>] ? __write_lock_failed+0x9/0x20
 <<EOE>>  [<ffffffff814d32de>] ? _raw_write_lock_irq+0x1e/0x20
 [<ffffffff81065cec>] forget_original_parent+0x3c/0x330
 [<ffffffff81065ffb>] exit_notify+0x1b/0x190
 [<ffffffff810666ed>] do_exit+0x1fd/0x430
 [<ffffffff8107fae0>] ? manage_workers+0x120/0x120
 [<ffffffff810846ce>] kthread+0x8e/0xa0
 [<ffffffff814dc544>] kernel_thread_helper+0x4/0x10
 [<ffffffff81084640>] ? kthread_worker_fn+0x1a0/0x1a0
 [<ffffffff814dc540>] ? gs_change+0x13/0x13

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
