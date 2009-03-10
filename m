Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC946B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:14:20 -0400 (EDT)
Message-ID: <49B69FE5.1080301@hp.com>
Date: Tue, 10 Mar 2009 13:14:13 -0400
From: "Alan D. Brunelle" <Alan.Brunelle@hp.com>
MIME-Version: 1.0
Subject: Re: PROBLEM: kernel BUG at mm/slab.c:3002!
References: <49B68450.9000505@hp.com>
In-Reply-To: <49B68450.9000505@hp.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan D. Brunelle wrote:
> Running blktrace & I/O loads cause a kernel BUG at mm/slab.c:3002!.
> 
> I'm running some moderate I/O loads (using 12 devices behind a Smart
> Array on a 16-way x86_64 box, I'm doing asynchronous direct sequential
> reads to each disk in parallel), and whilst attempting to get blktrace
> data I routinely run into this.
> 
> I first started seeing this in 2.6.29-rc6, so I bumped to 2.6.29-rc7 and
>  made a couple of successful runs, then ran into it again. (I've
> attached the script I was using, but I'm not sure it's very helpful...)
> 
> The environment the system under test is in is rather difficult to
> bisect in, but if need be, I can certainly go through the (painful)
> motions to do so...
> 
> I only ran this a couple of times on 2.6.27.7-4 (SLESS 11 b6 kernel),
> and both times it worked there - not sure how far back the problem occurs...
> 
> I'm open to any SLAB debug tracing options that may help with this...
> 
> Alan D.Brunelle
> Hewlett-Packard
> 

Hm, it isn't SLAB-related: reconfigured w/ SLUB and got:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000030g
IP: [<ffffffff802d0fda>] deactivate_super+0x11/0x8cg
PGD 1867047067 PUD 1853074067 PMD 0 g
Oops: 0000 [#1] SMP g
last sysfs file:
/sys/devices/pci0000:40/0000:40:10.0/0000:41:02.0/local_cpusg
CPU 15 g
Modules linked in: xfs exportfs fuse ext2 loop dm_mod sd_mod crc_t10dif
qla2xxx sg bnx2 scsi_transport_fc rtc_cmos sr_mod ipmi_si rtc_core
pcspkr ipmi_msghandler hpwdt hpilo container shpchp serio_raw scsi_tgt
rtc_lib button cdrom pci_hotplug usbhid hid uhci_hcd ohci_hcd ehci_hcd
usbcore edd ext3 mbcache jbd fan ide_pci_generic amd74xx ide_core
pata_amd thermal processor thermal_sys hwmon cciss ata_generic libata
scsi_modg
Pid: 12527, comm: blktrace Not tainted 2.6.29-rc7 #4 ProLiant DL585 G5   g
RIP: 0010:[<ffffffff802d0fda>]  [<ffffffff802d0fda>]
deactivate_super+0x11/0x8cg
RSP: 0018:ffff88087a4e1b38  EFLAGS: 00010246g
RAX: ffff881829debf00 RBX: 0000000000000000 RCX: 00000000fffffffeg
RDX: 0000000000000d74 RSI: ffffffff80ab4b00 RDI: 0000000000000000g
RBP: ffff88087a4e1b48 R08: 0000000000000000 R09: 0000000000000000g
R10: ffff88107cc3d760 R11: ffff88187b84deb8 R12: ffff881829debf00g
R13: 0000000000000200 R14: ffffffff809a7d00 R15: ffff881829debfd8g
FS:  00007fab4778f6f0(0000) GS:ffff88207c202380(0000)
knlGS:0000000000000000g
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003bg
CR2: 0000000000000030 CR3: 0000001801474000 CR4: 00000000000006e0g
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000g
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400g
Process blktrace (pid: 12527, threadinfo ffff88087a4e0000, task
ffff880821e70000)g
Stack:g
 ffff88189c255d00 ffff881829debf00 ffff88087a4e1b88 ffffffff802e4f22g
 0000000000000000 ffffffff80ab82b8 ffffffff80ab82b0 ffff881829debf00g
 ffff8820798f6148 0000000000000016 ffff88087a4e1bb8 ffffffff802e8faeg
Call Trace:g
 [<ffffffff802e4f22>] mntput_no_expire+0x144/0x18fg
 [<ffffffff802e8fae>] simple_release_fs+0x68/0x70g
 [<ffffffff8032cd10>] debugfs_remove+0x5b/0x60g
 [<ffffffff80289c02>] ? relay_remove_buf+0x0/0x2cg
 [<ffffffff8036c255>] blk_remove_buf_file_callback+0x1a/0x20g
 [<ffffffff80289c21>] relay_remove_buf+0x1f/0x2cg
 [<ffffffff8037155d>] kref_put+0x4b/0x57g
 [<ffffffff80289c85>] relay_close_buf+0x35/0x3ag
 [<ffffffff8028a08c>] relay_close+0x5e/0xecg
 [<ffffffff8036ca9f>] blk_trace_remove+0x50/0x1e3g
 [<ffffffff8036cd0f>] blk_trace_ioctl+0xb3/0xcfg
 [<ffffffffa03aa4c5>] ? xfs_write+0x6c8/0x6e3 [xfs]g
 [<ffffffff80363d78>] blkdev_ioctl+0x803/0x853g
 [<ffffffff804b1100>] ? _spin_lock+0x17/0x1ag
 [<ffffffff803702ac>] ? kobject_put+0x47/0x4bg
 [<ffffffff803f6e38>] ? put_device+0x15/0x17g
 [<ffffffffa000017a>] ? scsi_device_put+0x3d/0x42 [scsi_mod]g
 [<ffffffffa0312bcb>] ? scsi_disk_put+0x3a/0x3f [sd_mod]g
 [<ffffffff802f30a3>] block_ioctl+0x38/0x3cg
 [<ffffffff802db638>] vfs_ioctl+0x2a/0x78g
 [<ffffffff802dbacc>] do_vfs_ioctl+0x446/0x482g
 [<ffffffff802cfc80>] ? __fput+0x18c/0x199g
 [<ffffffff802dbb5d>] sys_ioctl+0x55/0x77g
 [<ffffffff8020c42a>] system_call_fastpath+0x16/0x1bg
Code: 48 8b 7f 68 48 85 ff 74 05 e8 45 cb 00 00 48 89 df e8 8d ff ff ff
5b 5b c9 c3 55 48 c7 c6 00 4b ab 80 48 89 e5 41 54 53 48 89 fb <4c> 8b
67 30 48 8d bf a8 00 00 00 e8 0a de 09 00 85 c0 74 62 81 g
RIP  [<ffffffff802d0fda>] deactivate_super+0x11/0x8cg
 RSP <ffff88087a4e1b38>g
CR2: 0000000000000030g

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
