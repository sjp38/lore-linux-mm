Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC306B01E3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 05:40:30 -0400 (EDT)
Date: Tue, 27 Apr 2010 10:40:02 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache  pages
Message-ID: <20100427094002.GD4895@csn.ul.ie>
References: <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com> <1271946226.2100.211.camel@barrios-desktop> <1271947206.2100.216.camel@barrios-desktop> <20100422154443.GD30306@csn.ul.ie> <20100423183135.GT32034@random.random> <20100423192311.GC14351@csn.ul.ie> <20100423193948.GU32034@random.random> <20100423213549.GV32034@random.random> <20100424105226.GF14351@csn.ul.ie> <20100425144113.GB5789@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100425144113.GB5789@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 25, 2010 at 04:41:13PM +0200, Andrea Arcangeli wrote:
> On Sat, Apr 24, 2010 at 11:52:27AM +0100, Mel Gorman wrote:
> > It should be. I expect that's why you have never seen the bugon in
> > swapops.
> 
> Oh I just got the very crash you're talking about with aa.git with
> your v8 code. Weird that I never reproduced it before! I think it's
> because I fixed gcc to be fully backed by hugepages always (without
> khugepaged) and I was rebuilding a couple of packages, and that now
> triggers memory compaction much more, but mixed with heavy
> fork/execve. This is the only instability I managed to reproduce over
> 24 hours of stress testing and it's clearly not related to transparent
> hugepage support but it's either a bug in migrate.c (more likely) or
> memory compaction.
> 
> Note that I'm running with the 2.6.33 anon-vma code, so it will
> relieve you to know it's not the anon-vma recent changes causing this
> (well I can't rule out anon-vma bugs, but if it's anon-vma, it's a
> longstanding one).
> 
> kernel BUG at include/linux/swapops.h:105!
> invalid opcode: 0000 [#1] SMP 
> last sysfs file: /sys/devices/pci0000:00/0000:00:12.0/host0/target0:0:0/0:0:0:0/block/sr0/size
> CPU 0 
> Modules linked in: nls_iso8859_1 loop twofish twofish_common tun bridge stp llc bnep sco rfcomm l2cap bluetooth snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss usbhid gspca_pac207 gspca_main videodev v4l1_compat v4l2_compat_ioctl32 snd_hda_codec_realtek ohci_hcd snd_hda_intel ehci_hcd usbcore snd_hda_codec snd_pcm snd_timer snd snd_page_alloc sg psmouse sr_mod pcspkr
> 
> Pid: 13351, comm: basename Not tainted 2.6.34-rc5 #23 M2A-VM/System Product Name
> RIP: 0010:[<ffffffff810e66b0>]  [<ffffffff810e66b0>] migration_entry_wait+0x170/0x180
> RSP: 0000:ffff88009ab6fa58  EFLAGS: 00010246
> RAX: ffffea0000000000 RBX: ffffea000234eed8 RCX: ffff8800aaa95298
> RDX: 00000000000a168d RSI: ffff88000411ae28 RDI: ffffea00025550a8
> RBP: ffffea0002555098 R08: ffff88000411ae28 R09: 0000000000000000
> R10: 0000000000000008 R11: 0000000000000009 R12: 00000000aaa95298
> R13: 00007ffff8a53000 R14: ffff88000411ae28 R15: ffff88011108a7c0
> FS:  00002adf29469b90(0000) GS:ffff880001a00000(0000) knlGS:0000000055700d50
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007ffff8a53000 CR3: 0000000004f80000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process basename (pid: 13351, threadinfo ffff88009ab6e000, task ffff88009ab96c70)
> Stack:
> ffff8800aaa95280 ffffffff810ce472 ffff8801134a7ce8 0000000000000000
> <0> 00000000142d1a3e ffffffff810c2e35 79f085e9c08a4db7 62d38944fd014000
> <0> 76b07a274b0c057a ffffea00025649f8 f8000000000a168d d19934e84d2a74f3
> Call Trace:
> [<ffffffff810ce472>] ? page_add_new_anon_rmap+0x72/0xc0
> [<ffffffff810c2e35>] ? handle_pte_fault+0x7a5/0x7d0
> [<ffffffff8150506d>] ? do_page_fault+0x13d/0x420
> [<ffffffff8150215f>] ? page_fault+0x1f/0x30
> [<ffffffff81273bfb>] ? strnlen_user+0x4b/0x80
> [<ffffffff81131f4e>] ? load_elf_binary+0x12be/0x1c80
> [<ffffffff810f426d>] ? search_binary_handler+0xad/0x2c0
> [<ffffffff810f5ce7>] ? do_execve+0x247/0x320
> [<ffffffff8100ab16>] ? sys_execve+0x36/0x60
> [<ffffffff8100314a>] ? stub_execve+0x6a/0xc0
> Code: 5e ff ff ff 8d 41 01 89 4c 24 08 89 44 24 04 8b 74 24 04 8b 44 24 08 f0 0f b1 32 89 44 24 0c 8b 44 24 0c 39 c8 74 a4 89 c1 eb d1 <0f> 0b eb fe 66 66 66 2e 0f 1f 84 00 00 00 00 00 41 54 49 89 d4 
> RIP  [<ffffffff810e66b0>] migration_entry_wait+0x170/0x180
> RSP <ffff88009ab6fa58>
> ---[ end trace 840ce8bc6f6dc402 ]---
> 
> It doesn't look like a coincidence the page that had the migration PTE
> set was the argv in the user stack during execve. The bug has to be
> there. Or maybe it's a coincidence and it will mislead us. If you've
> other stack traces please post them so I can have more info (I'll post
> more stack traces if I get them again, it doesn't look easy to
> reproduce, supposedly the bug has always been there since the first
> time I used memory compaction, and this is the first time I reproduce
> it).
> 

The oopses I am getting look very similar. The page is encountered in
the stack while copying the arguements in. I don't think it's a
coincidence.

[17831.496941] ------------[ cut here ]------------
[17831.532517] kernel BUG at include/linux/swapops.h:105!
[17831.532517] invalid opcode: 0000 [#1] PREEMPT SMP 
[17831.532517] last sysfs file: /sys/block/sde/size
[17831.532517] CPU 0 
[17831.532517] Modules linked in: kvm_amd kvm dm_crypt loop evdev tpm_tis i2c_piix4 shpchp tpm wmi tpm_bios serio_raw i2c_core pci_hotplug processor button ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod raid10 raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx raid1 raid0 multipath linear md_mod sg sr_mod sd_mod cdrom ata_generic ahci libahci ide_pci_generic libata r8169 mii ide_core ehci_hcd scsi_mod ohci_hcd floppy thermal fan thermal_sys
[17831.532517] 
[17831.532517] Pid: 31028, comm: make Not tainted 2.6.34-rc4-mm1-fix-swapops #2 GA-MA790GP-UD4H/GA-MA790GP-UD4H
[17831.532517] RIP: 0010:[<ffffffff811094fb>]  [<ffffffff811094fb>] migration_entry_wait+0xc1/0x129
[17831.532517] RSP: 0018:ffff88007ebfd9d8  EFLAGS: 00010246
[17831.532517] RAX: ffffea0000000000 RBX: ffffea0000199368 RCX: 00000000000389f0
[17831.532517] RDX: 0000000000199368 RSI: ffffffff81826558 RDI: 0000000000e9d63e
[17831.532517] RBP: ffff88007ebfda08 R08: ffff88007e334ec0 R09: ffff88007ebfd9e8
[17831.532517] R10: 00000000b411a2ca R11: 0000000000000246 R12: 0000000036f44000
[17831.532517] R13: ffff88007d164088 R14: f8000000000074eb R15: 0000000000e9d63e
[17831.532517] FS:  00002abc5c083f90(0000) GS:ffff880002200000(0000) knlGS:0000000000000000
[17831.532517] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[17831.532517] CR2: 00007fff3fb8cd1c CR3: 000000007d12d000 CR4: 00000000000006f0
[17831.532517] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[17831.532517] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[17831.532517] Process make (pid: 31028, threadinfo ffff88007ebfc000, task ffff88007e334ec0)
[17831.532517] Stack:
[17831.532517]  ffff88007ebfdb98 ffff88007ebfda18 ffff88007ebfdbe8 0000000000000600
[17831.532517] <0> ffff880036f44c60 00007fff3fb8cd1c ffff88007ebfdaa8 ffffffff810e951a
[17831.532517] <0> ffff88007ebfda88 0000000000000246 0000000000000000 ffffffff8130c542
[17831.532517] Call Trace:
[17831.532517]  [<ffffffff810e951a>] handle_mm_fault+0x3f8/0x76a
[17831.532517]  [<ffffffff8130c542>] ? do_page_fault+0x26a/0x46e
[17831.532517]  [<ffffffff8130c722>] do_page_fault+0x44a/0x46e
[17831.532517]  [<ffffffff813086fd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[17831.532517]  [<ffffffff81309935>] page_fault+0x25/0x30
[17831.532517]  [<ffffffff811c1dc7>] ? strnlen_user+0x3f/0x57
[17831.532517]  [<ffffffff8114de0d>] load_elf_binary+0x1508/0x190b
[17831.532517]  [<ffffffff81113297>] search_binary_handler+0x173/0x313
[17831.532517]  [<ffffffff8114c905>] ? load_elf_binary+0x0/0x190b
[17831.532517]  [<ffffffff81114892>] do_execve+0x219/0x30a
[17831.532517]  [<ffffffff8111887b>] ? getname+0x14d/0x1b3
[17831.532517]  [<ffffffff8100a5c6>] sys_execve+0x43/0x5e
[17831.532517]  [<ffffffff8100320a>] stub_execve+0x6a/0xc0
[17831.532517] Code: 74 05 83 f8 1f 75 68 48 b8 ff ff ff ff ff ff ff 07 48 21 c2 48 b8 00 00 00 00 00 ea ff ff 48 6b d2 38 48 8d 1c 02 f6 03 01 75 04 <0f> 0b eb fe 8b 4b 08 48 8d 73 08 85 c9 74 35 8d 41 01 89 4d e0 
[17831.532517] RIP  [<ffffffff811094fb>] migration_entry_wait+0xc1/0x129
[17831.532517]  RSP <ffff88007ebfd9d8>
[17835.075942] ---[ end trace 6c659d3989ca12d3 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
