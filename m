Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C05176B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 00:51:24 -0400 (EDT)
Date: Fri, 3 Jun 2011 00:50:58 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <953608207.378209.1307076658294.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110602143622.GE19505@random.random>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrea Righi <andrea@betterlinux.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>



----- Original Message -----
> On Thu, Jun 02, 2011 at 07:31:43AM -0700, Chris Wright wrote:
> > * CAI Qian (caiqian@redhat.com) wrote:
> > > madvise(0x2210000, 4096, 0xc /* MADV_??? */) = 0
> > > --- SIGSEGV (Segmentation fault) @ 0 (0) ---
> >
> > Right, that's just what the program is trying to do, segfault.
> >
> > > +++ killed by SIGSEGV (core dumped) +++
> > > Segmentation fault (core dumped)
> > >
> > > Did I miss anything?
> >
> > I found it works but not 100% of the time.
> >
> > So I just run the bug in a loop.
> 
> echo 0 >scan_millisecs helps.
Thanks. Indeed.

NULL pointer dereference at 0000000000000060
IP: [<ffffffff814d2659>] down_read+0x19/0x30
PGD 0 
Oops: 0002 [#1] SMP 
CPU 0 
Modules linked in: autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ipv6 dm_mirror dm_region_hash dm_log cdc_ether usbnet mii microcode serio_raw pcspkr i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support sg shpchp ioatdma dca i7core_edac edac_core bnx2 ext4 mbcache jbd2 sd_mod crc_t10dif pata_acpi ata_generic ata_piix mptsas mptscsih mptbase scsi_transport_sas dm_mod [last unloaded: scsi_wait_scan]

Pid: 103, comm: ksmd Not tainted 3.0.0-rc1+ #6 IBM System x3550 M3 -[7944I21]-/69Y4438     
RIP: 0010:[<ffffffff814d2659>]  [<ffffffff814d2659>] down_read+0x19/0x30
RSP: 0018:ffff880271307e00  EFLAGS: 00010246
RAX: 0000000000000060 RBX: 0000000000000060 RCX: 00000000000000db
RDX: 0000000000000000 RSI: 0000000000000282 RDI: 0000000000000060
RBP: ffff880271307e10 R08: 00000000000000df R09: ffff88026fcff400
R10: 0001b690ffffff90 R11: 0001b690ffffff90 R12: ffff880271307ea8
R13: 0000000000000050 R14: 0000000000000000 R15: ffffffff81a54960
FS:  0000000000000000(0000) GS:ffff88027fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000060 CR3: 0000000001a03000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ksmd (pid: 103, threadinfo ffff880271306000, task ffff8802712fc0c0)
Stack:
 ffff880271307e10 ffff8802712fc0c0 ffff880271307e60 ffffffff81146e09
 ffff8802712fc0c0 0000000000000060 ffff880271307e80 ffff8802712fc0c0
 ffff880271307e80 ffff8802712fc0c0 ffff8802712fc0c0 0000000000000063
Call Trace:
 [<ffffffff81146e09>] scan_get_next_rmap_item+0x59/0x400
 [<ffffffff811476ce>] ksm_scan_thread+0xfe/0x2c0
 [<ffffffff81084d50>] ? wake_up_bit+0x40/0x40
 [<ffffffff811475d0>] ? cmp_and_merge_page+0x420/0x420
 [<ffffffff810846d6>] kthread+0x96/0xa0
 [<ffffffff814dc544>] kernel_thread_helper+0x4/0x10
 [<ffffffff81084640>] ? kthread_worker_fn+0x1a0/0x1a0
 [<ffffffff814dc540>] ? gs_change+0x13/0x13
Code: 9e cd d6 ff 48 83 c4 08 5b c9 c3 0f 1f 80 00 00 00 00 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 48 89 fb e8 0a ee ff ff 48 89 d8 <f0> 48 ff 00 79 05 e8 3c cd d6 ff 48 83 c4 08 5b c9 c3 00 00 00 
RIP  [<ffffffff814d2659>] down_read+0x19/0x30
 RSP <ffff880271307e00>
CR2: 0000000000000060
---[ end trace a6feafc139ba5f85 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
