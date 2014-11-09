Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4688682BEF
	for <linux-mm@kvack.org>; Sat,  8 Nov 2014 23:47:35 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fa1so6018193pad.25
        for <linux-mm@kvack.org>; Sat, 08 Nov 2014 20:47:34 -0800 (PST)
Received: from out4133-98.mail.aliyun.com (out4133-98.mail.aliyun.com. [42.120.133.98])
        by mx.google.com with ESMTP id fd10si13138610pdb.189.2014.11.08.20.47.30
        for <linux-mm@kvack.org>;
        Sat, 08 Nov 2014 20:47:32 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
Date: Sun, 09 Nov 2014 12:47:26 +0800
Message-ID: <00a801cffbd8$434189b0$c9c49d10$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'P. Christeas'" <xrg@linux.gr>
Cc: 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, linux-kernel <linux-kernel@vger.kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

> > Can you please try the following patch?
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1325,13 +1325,6 @@ unsigned long try_to_compact_pages(struct =
zonelist
> > -			compaction_defer_reset(zone, order, false);
>=20
> NACK :(
>=20
> I just got again into a state that some task was spinning out of =
control, and
> blocking the rest of the desktop.
>=20
Would you please try the diff(against 3.18-rc3) if no other progress?

--- a/mm/compaction.c	Sun Nov  9 12:02:59 2014
+++ b/mm/compaction.c	Sun Nov  9 12:07:30 2014
@@ -1070,12 +1070,12 @@ static int compact_finished(struct zone=20
 	if (cc->order =3D=3D -1)
 		return COMPACT_CONTINUE;
=20
-	/* Compaction run is not finished if the watermark is not met */
+	/* Compaction run is skipped if the watermark is not met */
 	watermark =3D low_wmark_pages(zone);
 	watermark +=3D (1 << cc->order);
=20
 	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
-		return COMPACT_CONTINUE;
+		return COMPACT_SKIPPED;
=20
 	/* Direct compactor: Is a suitable page free? */
 	for (order =3D cc->order; order < MAX_ORDER; order++) {
--

> You will see me trying a few things, apparently the first OOM managed =
to
> unblock something, but a few seconds later the system "stepped" on =
some other
> blocking task.
>=20
> See attached log, it may only give you some hint; the problem could =
well be in
> some other part of the kernel.
>=20
> In the meanwhile, I'm pulling linus/master ...
>=20
> SysRq : Show backtrace of all active CPUs
> sending NMI to all CPUs:
> NMI backtrace for cpu 1
> CPU: 1 PID: 13544 Comm: python Not tainted 3.18.0-rc3+ #46
> Hardware name: Acer            TravelMate 5720                =
/Columbia                       , BIOS V1.34           04/15/2008
> task: ffff88000c78ee40 ti: ffff88000e5f8000 task.ti: ffff88000e5f8000
> RIP: 0010:[<ffffffff811df888>]  [<ffffffff811df888>] =
delay_tsc+0x28/0xa2
> RSP: 0000:ffff8800bf303b28  EFLAGS: 00000002
> RAX: 000000006bd322e8 RBX: 0000000000002710 RCX: 0000000000000007
> RDX: 000000000000021d RSI: ffffffff8151623e RDI: ffffffff8152fea5
> RBP: ffff8800bf303b48 R08: 0000000000000400 R09: 00000000ffffffff
> R10: 0000000000000046 R11: 0000000000000046 R12: 0000000000185ac0
> R13: 0000000000000001 R14: 0000000000000001 R15: ffffffff81668f90
> FS:  00007f1570ed1700(0000) GS:ffff8800bf300000(0000) =
knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f7cd966b000 CR3: 00000000740c9000 CR4: 00000000000007e0
> Stack:
>  0000000000002710 0000000000000003 000000000000006c 0000000000000001
>  ffff8800bf303b58 ffffffff811df814 ffff8800bf303b68 ffffffff811df83d
>  ffff8800bf303b88 ffffffff81025de1 0000000080010002 ffffffff816692b0
> Call Trace:
>  <IRQ>
>=20
>  [<ffffffff811df814>] __delay+0xa/0xc
>  [<ffffffff811df83d>] __const_udelay+0x27/0x29
>  [<ffffffff81025de1>] arch_trigger_all_cpu_backtrace+0xa8/0xd2
>  [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
>  [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
>  [<ffffffff8126c329>] sysrq_filter+0xee/0x287
>  [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
>  [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
>  [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
>  [<ffffffff812c3f19>] input_event+0x55/0x6f
>  [<ffffffff812c6fb5>] input_sync+0xf/0x11
>  [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
>  [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
>  [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
>  [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
>  [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
>  [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
>  [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
>  [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
>  [<ffffffff81004679>] handle_irq+0x158/0x16d
>  [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
>  [<ffffffff81003f71>] do_IRQ+0x58/0xda
>  [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
>  <EOI>
>=20
>  [<ffffffff810ee503>] ? rcu_read_unlock_sched_notrace+0x17/0x17
>  [<ffffffff810ef46a>] ? compact_zone+0x2a8/0x4b2
>  [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
>  [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
>  [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
>  [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
>  [<ffffffff810fdd84>] ? anon_vma_prepare+0xf5/0x12c
>  [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
>  [<ffffffff810faa65>] ? mmap_region+0x171/0x458
>  [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
>  [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
>  [<ffffffff810fb004>] ? do_mmap_pgoff+0x2b8/0x306
>  [<ffffffff810e88dd>] ? vm_mmap_pgoff+0x82/0xaa
>  [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
>  [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
>  [<ffffffff813bb162>] page_fault+0x22/0x30
> Code: ff 5d c3 55 48 89 e5 41 56 41 55 41 54 41 89 fc bf 01 00 00 00 =
53 e8 f7 6f e7 ff e8 9a 9c 00 00 41 89 c5 0f 1f 00 0f ae e8 0f 31 <89> =
c3 0f
> 1f 00 0f ae e8 0f 31 48 c1 e2 20 89 c0 48 09 c2 41 89
> NMI backtrace for cpu 0
> CPU: 0 PID: 13788 Comm: net_applet Not tainted 3.18.0-rc3+ #46
> Hardware name: Acer            TravelMate 5720                =
/Columbia                       , BIOS V1.34           04/15/2008
> task: ffff8800067a3720 ti: ffff88000e20c000 task.ti: ffff88000e20c000
> RIP: 0010:[<ffffffff810ef586>]  [<ffffffff810ef586>] =
compact_zone+0x3c4/0x4b2
> RSP: 0000:ffff88000e20fa18  EFLAGS: 00000202
> RAX: 00000000ffffffff RBX: ffffffff8168be40 RCX: 0000000000000008
> RDX: 0000000000000380 RSI: 0000000000000009 RDI: ffffffff8168be40
> RBP: ffff88000e20fa78 R08: 0000000000000000 R09: fffffffffffffef5
> R10: 0000000000000038 R11: ffffffff8168be40 R12: 00000000000bf800
> R13: 00000000000bf600 R14: ffff88000e20fa98 R15: 0000160000000000
> FS:  00007ff9cbe92700(0000) GS:ffff8800bf200000(0000) =
knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007ff3a52f0000 CR3: 000000000af17000 CR4: 00000000000007f0
> Stack:
>  ffff88000e20fa18 ffffea0002fd0000 0000000000000020 ffff8800067a3720
>  0000000000000004 ffff88000e20faa8 0000000000000000 0000000000000000
>  0000000000000009 ffff88000e20fccc 0000000000000002 0000000000000000
> Call Trace:
>  [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
>  [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
>  [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
>  [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
>  [<ffffffff810d458c>] ? unlock_page+0x1f/0x23
>  [<ffffffff81116903>] do_huge_pmd_wp_page+0x127/0x4eb
>  [<ffffffff810f65fc>] handle_mm_fault+0x151/0x808
>  [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
>  [<ffffffff8102ddf8>] ? do_page_fault+0xc/0xe
>  [<ffffffff813bb162>] ? page_fault+0x22/0x30
>  [<ffffffff811e0740>] ? __put_user_4+0x20/0x30
>  [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
>  [<ffffffff813bb162>] page_fault+0x22/0x30
> Code: 8b 7b 08 44 89 e6 ff 13 48 83 c3 10 48 83 3b 00 eb eb 41 83 7e =
40 01 4d 8b 6e 38 19 c0 89 45 c0 4d 8d a5 00 02 00 00 83 65 c0 04 <49>
> 81 e4 00 fe ff ff e9 b2 fe ff ff 41 80 7e 44 00 74 09 41 83
>=20
> SysRq : Changing Loglevel
> Loglevel set to 8
>=20
> SysRq : Show backtrace of all active CPUs
> sending NMI to all CPUs:
> NMI backtrace for cpu 1
> CPU: 1 PID: 13544 Comm: python Not tainted 3.18.0-rc3+ #46
> Hardware name: Acer            TravelMate 5720                =
/Columbia                       , BIOS V1.34           04/15/2008
> task: ffff88000c78ee40 ti: ffff88000e5f8000 task.ti: ffff88000e5f8000
> RIP: 0010:[<ffffffff811df817>]  [<ffffffff811df817>] =
__const_udelay+0x1/0x29
> RSP: 0000:ffff8800bf303b68  EFLAGS: 00000006
> RAX: 0000000000000000 RBX: 0000000000002710 RCX: 0000000000000007
> RDX: 0000000080010003 RSI: 0000000000000c00 RDI: 0000000000418958
> RBP: ffff8800bf303b88 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000046 R11: 0000000000000046 R12: 0000000000000008
> R13: 000000000000006c R14: 0000000000000001 R15: ffffffff81668f90
> FS:  00007f1570ed1700(0000) GS:ffff8800bf300000(0000) =
knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f7cd966b000 CR3: 00000000740c9000 CR4: 00000000000007e0
> Stack:
>  ffff8800bf303b88 ffffffff81025de1 0000000080010002 ffffffff816692b0
>  ffff8800bf303b98 ffffffff8126bc4f ffff8800bf303bc8 ffffffff8126c186
>  ffff88003781c200 0000000000000001 0000000000000026 ffff88003781c201
> Call Trace:
>  <IRQ>
>=20
>  [<ffffffff81025de1>] ? arch_trigger_all_cpu_backtrace+0xa8/0xd2
>  [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
>  [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
>  [<ffffffff8126c329>] sysrq_filter+0xee/0x287
>  [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
>  [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
>  [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
>  [<ffffffff812c3f19>] input_event+0x55/0x6f
>  [<ffffffff812c6fb5>] input_sync+0xf/0x11
>  [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
>  [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
>  [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
>  [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
>  [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
>  [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
>  [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
>  [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
>  [<ffffffff81004679>] handle_irq+0x158/0x16d
>  [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
>  [<ffffffff81003f71>] do_IRQ+0x58/0xda
>  [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
>  <EOI>
>=20
>  [<ffffffff813b6b95>] ? preempt_schedule_irq+0x3c/0x59
>  [<ffffffff810d75b5>] ? __zone_watermark_ok+0x63/0x85
>  [<ffffffff810d839e>] zone_watermark_ok+0x1a/0x1c
>  [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
>  [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
>  [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
>  [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
>  [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
>  [<ffffffff810fdd84>] ? anon_vma_prepare+0xf5/0x12c
>  [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
>  [<ffffffff810faa65>] ? mmap_region+0x171/0x458
>  [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
>  [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
>  [<ffffffff810fb004>] ? do_mmap_pgoff+0x2b8/0x306
>  [<ffffffff810e88dd>] ? vm_mmap_pgoff+0x82/0xaa
>  [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
>  [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
>  [<ffffffff813bb162>] page_fault+0x22/0x30
> Code: eb 02 66 90 eb 0e 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 =
ff c8 75 fb 48 ff c8 5d c3 55 48 89 e5 ff 15 a4 0c 48 00 5d c3 55 <48> =
8d
> 04 bd 00 00 00 00 48 89 e5 65 48 8b 14 25 20 26 01 00 48
> NMI backtrace for cpu 0
> CPU: 0 PID: 11733 Comm: kwin Not tainted 3.18.0-rc3+ #46
> Hardware name: Acer            TravelMate 5720                =
/Columbia                       , BIOS V1.34           04/15/2008
> task: ffff8800055e7620 ti: ffff88009dc78000 task.ti: ffff88009dc78000
> RIP: 0010:[<ffffffff810ee567>]  [<ffffffff810ee567>] =
acct_isolated+0x64/0x6b
> RSP: 0000:ffff88009dc7ba08  EFLAGS: 00000246
> RAX: ffff88009dc7bac8 RBX: ffffffff8168be40 RCX: ffff88009dc7bac8
> RDX: 0000000000000380 RSI: ffff88009dc7bab8 RDI: ffffffff8168be40
> RBP: ffff88009dc7ba28 R08: 0000000000000000 R09: ffffffffffffff01
> R10: 0000000000000038 R11: ffffffff8168be40 R12: 00000000000bf800
> R13: 00000000000bf600 R14: ffff88009dc7bab8 R15: 0000160000000000
> FS:  00007facfaf397c0(0000) GS:ffff8800bf200000(0000) =
knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f9d5781d910 CR3: 0000000025c25000 CR4: 00000000000007f0
> Stack:
>  0000000000000000 0000000000000000 ffff88009dc7ba28 ffffffff8168be40
>  ffff88009dc7ba98 ffffffff810ef46a ffff88008035e660 ffffea0002fd0000
>  0000000000000020 ffff8800055e7620 0000000000000004 ffff88009dc7bac8
> Call Trace:
>  [<ffffffff810ef46a>] compact_zone+0x2a8/0x4b2
>  [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
>  [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
>  [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
>  [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
>  [<ffffffff810fdcba>] ? anon_vma_prepare+0x2b/0x12c
>  [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
>  [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
>  [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
>  [<ffffffff810fb004>] ? do_mmap_pgoff+0x2b8/0x306
>  [<ffffffff810e88dd>] ? vm_mmap_pgoff+0x82/0xaa
>  [<ffffffff813b9028>] ? _raw_spin_unlock_irq+0x14/0x27
>  [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
>  [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
>  [<ffffffff813bb162>] page_fault+0x22/0x30
> Code: f7 d2 83 e2 01 ff 44 95 e8 eb dd 8b 55 e8 be 16 00 00 00 48 89 =
df e8 7d b3 ff ff 8b 55 ec be 17 00 00 00 48 89 df e8 6d b3 ff ff <48> =
83
> c4 18 5b 5d c3 83 7a 40 00 55 48 89 e5 41 54 49 89 d4 53
> INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too =
long to run: 91.545 msecs
>=20
> SysRq : Show backtrace of all active CPUs
> sending NMI to all CPUs:
>=20
> NMI backtrace for cpu 0
> CPU: 0 PID: 11733 Comm: kwin Not tainted 3.18.0-rc3+ #46
> Hardware name: Acer            TravelMate 5720                =
/Columbia                       , BIOS V1.34           04/15/2008
> task: ffff8800055e7620 ti: ffff88009dc78000 task.ti: ffff88009dc78000
> RIP: 0010:[<ffffffff810ef586>]  [<ffffffff810ef586>] =
compact_zone+0x3c4/0x4b2
> RSP: 0000:ffff88009dc7ba38  EFLAGS: 00000202
> RAX: 00000000ffffffff RBX: ffffffff8168be40 RCX: 0000000000000008
> RDX: 0000000000000380 RSI: 0000000000000009 RDI: ffffffff8168be40
> RBP: ffff88009dc7ba98 R08: 0000000000000000 R09: ffffffffffffff01
> R10: 0000000000000038 R11: ffffffff8168be40 R12: 00000000000bf800
> R13: 00000000000bf600 R14: ffff88009dc7bab8 R15: 0000160000000000
> FS:  00007facfaf397c0(0000) GS:ffff8800bf200000(0000) =
knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007fe8952e5000 CR3: 0000000025c25000 CR4: 00000000000007f0
> Stack:
>  ffff88008035e660 ffffea0002fd0000 0000000000000020 ffff8800055e7620
>  0000000000000004 ffff88009dc7bac8 0000000000000234 0000000000000000
>  0000000000000009 ffff88009dc7bcec 0000000000000002 0000000000000000
> Call Trace:
>  [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
>  [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
>  [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
>  [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
>  [<ffffffff810fdcba>] ? anon_vma_prepare+0x2b/0x12c
>  [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
>  [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
>  [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
>  [<ffffffff810fb004>] ? do_mmap_pgoff+0x2b8/0x306
>  [<ffffffff810e88dd>] ? vm_mmap_pgoff+0x82/0xaa
>  [<ffffffff813b9028>] ? _raw_spin_unlock_irq+0x14/0x27
>  [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
>  [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
>  [<ffffffff813bb162>] page_fault+0x22/0x30
> Code: 8b 7b 08 44 89 e6 ff 13 48 83 c3 10 48 83 3b 00 eb eb 41 83 7e =
40 01 4d 8b 6e 38 19 c0 89 45 c0 4d 8d a5 00 02 00 00 83 65 c0 04 <49>
> 81 e4 00 fe ff ff e9 b2 fe ff ff 41 80 7e 44 00 74 09 41 83
> NMI backtrace for cpu 1
> CPU: 1 PID: 13544 Comm: python Not tainted 3.18.0-rc3+ #46
> Hardware name: Acer            TravelMate 5720                =
/Columbia                       , BIOS V1.34           04/15/2008
> task: ffff88000c78ee40 ti: ffff88000e5f8000 task.ti: ffff88000e5f8000
> RIP: 0010:[<ffffffff811df82b>]  [<ffffffff811df82b>] =
__const_udelay+0x15/0x29
> RSP: 0000:ffff8800bf303b68  EFLAGS: 00000006
> RAX: 0000000001062560 RBX: 0000000000002710 RCX: 0000000000000007
> RDX: 0000000000185ab3 RSI: 0000000000000c00 RDI: 0000000000418958
> RBP: ffff8800bf303b68 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000046 R11: 0000000000000046 R12: 0000000000000008
> R13: 000000000000006c R14: 0000000000000001 R15: ffffffff81668f90
> FS:  00007f1570ed1700(0000) GS:ffff8800bf300000(0000) =
knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f38f594a000 CR3: 00000000740c9000 CR4: 00000000000007e0
> Stack:
>  ffff8800bf303b88 ffffffff81025de1 0000000080010002 ffffffff816692b0
>  ffff8800bf303b98 ffffffff8126bc4f ffff8800bf303bc8 ffffffff8126c186
>  ffff88003781c200 0000000000000001 0000000000000026 ffff88003781c201
> Call Trace:
>  <IRQ>
>=20
>  [<ffffffff81025de1>] arch_trigger_all_cpu_backtrace+0xa8/0xd2
>  [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
>  [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
>  [<ffffffff8126c329>] sysrq_filter+0xee/0x287
>  [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
>  [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
>  [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
>  [<ffffffff812c3f19>] input_event+0x55/0x6f
>  [<ffffffff812c6fb5>] input_sync+0xf/0x11
>  [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
>  [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
>  [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
>  [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
>  [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
>  [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
>  [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
>  [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
>  [<ffffffff81004679>] handle_irq+0x158/0x16d
>  [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
>  [<ffffffff81003f71>] do_IRQ+0x58/0xda
>  [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
>  <EOI>
>=20
>  [<ffffffff810d75ad>] ? __zone_watermark_ok+0x5b/0x85
>  [<ffffffff810d839e>] zone_watermark_ok+0x1a/0x1c
>  [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
>  [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
>  [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
>  [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
>  [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
>  [<ffffffff810fdd84>] ? anon_vma_prepare+0xf5/0x12c
>  [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
>  [<ffffffff810faa65>] ? mmap_region+0x171/0x458
>  [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
>  [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
>  [<ffffffff810fb004>] ? do_mmap_pgoff+0x2b8/0x306
>  [<ffffffff810e88dd>] ? vm_mmap_pgoff+0x82/0xaa
>  [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
>  [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
>  [<ffffffff813bb162>] page_fault+0x22/0x30
> Code: 48 ff c8 75 fb 48 ff c8 5d c3 55 48 89 e5 ff 15 a4 0c 48 00 5d =
c3 55 48 8d 04 bd 00 00 00 00 48 89 e5 65 48 8b 14 25 20 26 01 00 <48> =
69
> d2 fa 00 00 00 f7 e2 48 8d 7a 01 e8 cd ff ff ff 5d c3 48
> INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too =
long to run: 163.331 msecs
>=20
> SysRq : Manual OOM execution
> Purging GPU memory, 4186 bytes freed, 4243456 bytes still pinned.
>=20
> SysRq : HELP : loglevel(0-9) reboot(b) crash(c) terminate-all-tasks(e) =
memory-full-oom-kill(f) kill-all-tasks(i) thaw-filesystems(j) sak(k)
> show-backtrace-all-active-cpus(l) show-memory-usage(m) =
nice-all-RT-tasks(n) poweroff(o) show-registers(p) show-all-timers(q)
> unraw(r) sync(s) show-task-states(t) unmount(u) force-fb(V) =
show-blocked-tasks(w) dump-ftrace-buffer(z)
> SysRq : Manual OOM execution
>=20
> Purging GPU memory, 0 bytes freed, 4243456 bytes still pinned.
>=20
> kworker/1:0 invoked oom-killer: gfp_mask=3D0xd0, order=3D0, =
oom_score_adj=3D0
> kworker/1:0 cpuset=3D/ mems_allowed=3D0
> CPU: 1 PID: 13984 Comm: kworker/1:0 Not tainted 3.18.0-rc3+ #46
> Hardware name: Acer            TravelMate 5720                =
/Columbia                       , BIOS V1.34           04/15/2008
> Workqueue: events moom_callback
>  ffff8800067a1600 ffff88000dadfc58 ffffffff813b4868 0000000000000001
>  ffff8800067a0fc0 ffff88000dadfce8 ffffffff813b2e37 000000000023222e
>  ffffffff8163e380 000000000023222e 0000000000000206 ffff88000dadfca8
> Call Trace:
>  [<ffffffff813b4868>] dump_stack+0x4f/0x7c
>  [<ffffffff813b2e37>] dump_header.isra.11+0x71/0x1d7
>  [<ffffffff813b8ffe>] ? _raw_spin_unlock_irqrestore+0x1b/0x31
>  [<ffffffff811db724>] ? ___ratelimit+0xb9/0xc7
>  [<ffffffff810d6ca8>] oom_kill_process+0x60/0x310
>  [<ffffffff810d6b5a>] ? oom_badness+0xb1/0xfb
>  [<ffffffff810d733d>] out_of_memory+0x282/0x29b
>  [<ffffffff8126bd74>] moom_callback+0x1f/0x21
>  [<ffffffff8104b077>] process_one_work+0x156/0x29c
>  [<ffffffff8104b978>] worker_thread+0x1eb/0x2c2
>  [<ffffffff8104b78d>] ? cancel_delayed_work_sync+0x10/0x10
>  [<ffffffff8104f502>] kthread+0xbb/0xc3
>  [<ffffffff8104f447>] ? __kthread_parkme+0x5c/0x5c
>  [<ffffffff813b96ac>] ret_from_fork+0x7c/0xb0
>  [<ffffffff8104f447>] ? __kthread_parkme+0x5c/0x5c
> Mem-Info:
> DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> DMA32 per-cpu:
> CPU    0: hi:  186, btch:  31 usd:  97
> CPU    1: hi:  186, btch:  31 usd: 183
> active_anon:286387 inactive_anon:87475 isolated_anon:0
>  active_file:174069 inactive_file:43465 isolated_file:0
>  unevictable:0 dirty:30 writeback:0 unstable:0
>  free:80502 slab_reclaimable:58629 slab_unreclaimable:10926
>  mapped:98606 shmem:48888 pagetables:17014 bounce:0
>  free_cma:0
> DMA free:12216kB min:232kB low:288kB high:348kB active_anon:540kB =
inactive_anon:804kB active_file:1056kB inactive_file:760kB
> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB =
managed:15908kB mlocked:0kB dirty:0kB writeback:0kB
> mapped:892kB shmem:372kB slab_reclaimable:148kB =
slab_unreclaimable:88kB kernel_stack:16kB pagetables:92kB unstable:0kB
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 =
all_unreclaimable? no
> lowmem_reserve[]: 0 2984 2984 2984
> DMA32 free:309792kB min:44820kB low:56024kB high:67228kB =
active_anon:1145008kB inactive_anon:349096kB active_file:695220kB
> inactive_file:173100kB unevictable:0kB isolated(anon):0kB =
isolated(file):0kB present:3119936kB managed:3057340kB mlocked:0kB
> dirty:120kB writeback:0kB mapped:393532kB shmem:195180kB =
slab_reclaimable:234368kB slab_unreclaimable:43616kB
> kernel_stack:7360kB pagetables:67964kB unstable:0kB bounce:0kB =
free_cma:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> DMA: 10*4kB (UEM) 6*8kB (UM) 2*16kB (EM) 8*32kB (UEM) 3*64kB (UEM) =
1*128kB (E) 1*256kB (M) 2*512kB (EM) 2*1024kB (UE)
> 2*2048kB (ER) 1*4096kB (M) =3D 12216kB
> DMA32: 3084*4kB (UEMR) 8564*8kB (UEMR) 6169*16kB (UEMR) 2174*32kB =
(UEMR) 402*64kB (UEM) 139*128kB (UEMR) 49*256kB
> (UEMR) 7*512kB (UEM) 1*1024kB (M) 0*2048kB 0*4096kB =3D 309792kB
> Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=3D0 =
hugepages_size=3D2048kB
> 266800 total pagecache pages
> 376 pages in swap cache
> Swap cache stats: add 12077, delete 11701, find 857/1253
> Free swap  =3D 6092348kB
> Total swap =3D 6136792kB
> 783982 pages RAM
> 0 pages HighMem/MovableOnly
> 15649 pages reserved
> 0 pages hwpoisoned
> [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj =
name
> [  492]     0   492    10595     2553      23       19             0 =
systemd-journal
> [  544]     0   544     8460      747      20       22         -1000 =
systemd-udevd
> [  738]     0   738     4743      696      14       19             0 =
alsactl
> [  761]     0   761     5848      855      16       28             0 =
bluetoothd
> [  762]     0   762     8185      723      21       69             0 =
abrtd
> [  766]     0   766     4827      581      15       30             0 =
irqbalance
> [  788]     0   788     3814      709      12       97             0 =
smartd
> [  789]     0   789     1827      365       9      811             0 =
hddtemp
> [  795]     0   795     5423      624      16       11             0 =
systemd-logind
> [  796]     0   796    48410     1889      31       74             0 =
udisks-daemon
> [  797]   499   797     3638      754      12       10          -900 =
dbus-daemon
> [  799]     0   799     1071      382       8       13             0 =
acpid
> [  811]     0   811    26132     4425      53      472             0 =
cupsd
> [  813]     0   813    56404     1572      41      647             0 =
upowerd
> [  815]     0   815     6159      545      17       15             0 =
kdm
> [  831]     0   831   173245      498      34       30             0 =
nscd
> [  904]     0   904    11431        4      26       78             0 =
udisks-daemon
> [ 1005]   497  1005    91379     3112      41     1379             0 =
polkitd
> [ 1113]     0  1113     1586      287       8       22             0 =
ifplugd
> [ 1212]     0  1212     8029      408      18      126             0 =
wpa_supplicant
> [ 1214]     0  1214     1586      288       9       22             0 =
ifplugd
> [ 1324]     0  1324    28065     1115      26      387             0 =
cf-execd
> [ 1333]     0  1333    12113      541      24     1150             0 =
cf-serverd
> [ 1479]     0  1479     3117       98      10     1610             0 =
dhclient
> [ 1579]     0  1579    87422     2054     107      925             0 =
libvirtd
> [ 1584]     0  1584    10579      942      25      135         -1000 =
sshd
> [ 1592]     0  1592     2846      401      11       42             0 =
xinetd
> [ 1598]   491  1598     6250      412      14       70             0 =
rpcbind
> [ 1602]     0  1602     3851        0      12       38             0 =
rpc.idmapd
> [ 1611]   488  1611     8360      544      21      141             0 =
rpc.statd
> [ 1614]    80  1614     7989     1084      20      167             0 =
pgpool
> [ 1615]    80  1615     8029      475      19      181             0 =
pgpool
> [ 1616]    80  1616     8029      475      19      181             0 =
pgpool
> [ 1617]    80  1617     8029      475      20      181             0 =
pgpool
> [ 1618]    80  1618     8029      475      19      181             0 =
pgpool
> [ 1619]    80  1619     7989      327      18      172             0 =
pgpool
> [ 1620]    80  1620     7989       11      18      163             0 =
pgpool
> [ 1622]    80  1622    47318     4356      34      123         -1000 =
postgres
> [ 1636]     0  1636     2941      405      12      120             0 =
crond
> [ 1643]   487  1643     5374      578      15       33             0 =
ntpd
> [ 1647]     0  1647     5408     2340      16       23             0 =
preload
> [ 1680]    80  1680    47350     6430      66      106         -1000 =
postgres
> [ 1681]    80  1681    47318     9645      90      109         -1000 =
postgres
> [ 1682]    80  1682    47318      785      25      146         -1000 =
postgres
> [ 1683]    80  1683    47447     1683      39      148         -1000 =
postgres
> [ 1684]    80  1684    11074      609      23      131         -1000 =
postgres
> [ 1685]    80  1685    11146      954      23      118         -1000 =
postgres
> [ 1803]   493  1803    70606     1317      41      377             0 =
colord
> [ 1812]     0  1812     9046      792      24      234             0 =
systemd
> [ 1815]     0  1815    14697      157      31      453             0 =
(sd-pam)
> [ 2445]     0  2445     4228       12      12       38             0 =
gpg-agent
> [ 5893]     0  5893    12071     1997      29      236             0 =
cf-monitord
> [ 8691]   500  8691     9233     1169      22       19             0 =
systemd
> [ 8692]   500  8692    14769      177      31      487             0 =
(sd-pam)
> [ 8759]   500  8759     3170        7       9       63             0 =
ssh-agent
> [ 8784]   500  8784     3459      393      14       34             0 =
gpg-agent
> [ 9260]     0  9260     1975      400       9        0             0 =
agetty
> [ 9262]     0  9262     1975      393       9        0             0 =
agetty
> [ 9367]   500  9367     3098      684      11        0             0 =
gam_server
> [ 9976]     0  9976    88063     2116      38        0             0 =
udisksd
> [11283]     0 11283    47144    13442      89        0             0 X
> [11297]     0 11297    19771     1253      44        6             0 =
kdm
> [11507]   500 11507     3191      735      12        0             0 =
startkde
> [11602]   500 11602     3987      460      13        0             0 =
dbus-launch
> [11603]   500 11603     3907     1011      13        0             0 =
dbus-daemon
> [11634]   500 11634    34515     1861      67        0             0 =
s2u
> [11690]   500 11690     1028       20       6        0             0 =
start_kdeinit
> [11691]   500 11691    95918     8995     150        0             0 =
kdeinit4
> [11692]   500 11692    97137     6446     140        0             0 =
klauncher
> [11694]   500 11694   260253    17122     254        0             0 =
kded4
> [11697]   500 11697   118836     9730     181        0             0 =
kglobalaccel
> [11700]   500 11700     5856      676      17        0             0 =
obexd
> [11707]   500 11707    72764     6751     125        0             0 =
bluedevil-monol
> [11718]   500 11718   228901     9415     160        0             0 =
kactivitymanage
> [11721]   500 11721     1062      162       8        0             0 =
kwrapper4
> [11724]   500 11724   139507     9588     188        0             0 =
ksmserver
> [11733]   500 11733   683159    22362     242        0             0 =
kwin
> [11737]   500 11737   821255    39358     343        0             0 =
plasma-desktop
> [11740]   500 11740     2491      606      10        0             0 =
ksysguardd
> [11742]   500 11742   185670    14918     241        0             0 =
krunner
> [11836]   500 11836    66336     1673      33        0             0 =
mission-control
> [11900]   500 11900    71627     7762     130        0             0 =
kuiserver
> [11902]   500 11902    39315     2928      38        0             0 =
akonadi_control
> [11904]   500 11904     3190      688      12        0             0 =
akonadiserver
> [11905]   500 11905   364072     7154     110        0             0 =
akonadiserver
> [11907]    80 11907    48978    37329      98       90         -1000 =
postgres
> [11916]   500 11916    71126     7723     127        0             0 =
ksyndaemon
> [11924]   500 11924    94819     2524      88        0             0 =
pulseaudio
> [11925]   492 11925    40153      566      15        0             0 =
rtkit-daemon
> [11938]    80 11938    47549     2575      34       95         -1000 =
postgres
> [11939]    80 11939    47549     2619      34       95         -1000 =
postgres
> [11940]    80 11940    47549     2619      34       95         -1000 =
postgres
> [11943]   500 11943    80114     9317     112        0             0 =
akonadi_agent_l
> [11944]   500 11944    80111     9358     108        0             0 =
akonadi_agent_l
> [11945]   500 11945   149309    16150     260        0             0 =
akonadi_archive
> [11948]   500 11948    80738    10447     147        0             0 =
akonadi_birthda
> [11949]   500 11949    80046     9859     108        0             0 =
akonadi_agent_l
> [11950]   500 11950   149456    15918     259        0             0 =
akonadi_foldera
> [11952]   500 11952   119534    12515     160        0             0 =
akonadi_imap_re
> [11953]   500 11953   138083    12936     163        0             0 =
akonadi_imap_re
> [11954]   500 11954   137951    12152     158        0             0 =
akonadi_imap_re
> [11955]   500 11955    74613     8962     134        0             0 =
akonadi_localbo
> [11956]   500 11956    20123      790      42        0             0 =
gconf-helper
> [11958]   500 11958    11393     1256      27        0             0 =
gconfd-2
> [11959]   500 11959    80110     9345     111        0             0 =
akonadi_agent_l
> [11960]   500 11960    80110     9316     112        0             0 =
akonadi_agent_l
> [11961]   500 11961    88890    10322     156        0             0 =
akonadi_maildis
> [11962]   500 11962   150003    16953     260        0             0 =
akonadi_mailfil
> [11963]   500 11963    75882     9862     142        0             0 =
akonadi_migrati
> [11964]   500 11964    80530    10776     142        0             0 =
akonadi_mixedma
> [11965]   500 11965    82835    12607     151        0             0 =
akonadi_mixedma
> [11966]   500 11966   144439    13711     197        0             0 =
konsole
> [11973]   500 11973    76667    10080     139        0             0 =
akonadi_nepomuk
> [11974]   500 11974   100405    11536     184        0             0 =
akonadi_newmail
> [11975]   500 11975    79291     9474     108        0             0 =
akonadi_agent_l
> [11976]   500 11976    76551     9175     140        0             0 =
akonadi_pop3_re
> [11977]   500 11977    76535     9251     139        0             0 =
akonadi_pop3_re
> [11978]   500 11978    77748    10430     141        0             0 =
akonadi_pop3_re
> [11979]   500 11979   138554    13963     242        0             0 =
akonadi_sendlat
> [11981]   500 11981    78493     9240     109        0             0 =
akonadi_agent_l
> [11982]   500 11982    80012     9799     113        0             0 =
akonadi_agent_l
> [11983]   500 11983   177548    11542     195        0             0 =
kmix
> [11984]   500 11984   180599    14445     204        0             0 =
dolphin
> [11993]   500 11993    74732     8349     133        0             0 =
akonaditray
> [11997]   500 11997   107450    11140     188        0             0 =
knotes
> [11999]   500 11999     3649     1186      12        0             0 =
bash
> [12011]   500 12011     3585     1095      12        0             0 =
bash
> [12025]   500 12025     3585     1076      12        0             0 =
bash
> [12047]   500 12047     3585     1116      11        0             0 =
bash
> [12186]   500 12186   116692    12696     175        0             0 =
kgpg
> [12293]   500 12293     3585     1117      12        0             0 =
bash
> [12317]   500 12317     3585     1113      13        0             0 =
bash
> [12356]   500 12356     3585     1102      12        0             0 =
bash
> [12405]   500 12405     3585     1086      13        0             0 =
bash
> [12506]   500 12506     3585     1073      11        0             0 =
bash
> [12645]   500 12645   122416    29665     208        0             0 =
choqok
> [12673]   500 12673     3585     1115      13        0             0 =
bash
> [12718]   500 12718     3585     1104      13        0             0 =
bash
> [12771]   500 12771     3585     1075      12        0             0 =
bash
> [12843]   500 12843     3585     1087      12        0             0 =
bash
> [13020]   500 13020   686067    27224     266        0             0 =
kate
> [13027]   500 13027   121357    10647     186        0             0 =
kwalletd
> [13029]    80 13029    47607     3959      41       92         -1000 =
postgres
> [13033]    80 13033    47549     2573      34       95         -1000 =
postgres
> [13052]   500 13052   138593     9489     158        0             0 =
knotify4
> [13053]    80 13053    47602     3917      40       92         -1000 =
postgres
> [13054]    80 13054    47602     3920      40       93         -1000 =
postgres
> [13055]    80 13055    47835     7071      72       92         -1000 =
postgres
> [13058]    80 13058    47831     4688      51       92         -1000 =
postgres
> [13059]    80 13059    47602     3919      40       92         -1000 =
postgres
> [13061]   500 13061   121241    17287     186        0             0 =
konversation
> [13062]    80 13062    47583     3456      39       95         -1000 =
postgres
> [13076]    80 13076    47745     6832      72       92         -1000 =
postgres
> [13080]    80 13080    47629     4038      42       93         -1000 =
postgres
> [13081]   500 13081   701137    24187     260        0             0 =
kate
> [13082]    80 13082    47866     8228      73       92         -1000 =
postgres
> [13083]    80 13083    47623     3981      40       92         -1000 =
postgres
> [13085]    80 13085    47830     8033      67       92         -1000 =
postgres
> [13087]    80 13087    47549     2587      34       95         -1000 =
postgres
> [13088]    80 13088    47828     5052      52       92         -1000 =
postgres
> [13089]    80 13089    47549     2601      34       95         -1000 =
postgres
> [13090]    80 13090    47684     9326      79       92         -1000 =
postgres
> [13091]    80 13091    47581     3365      39       95         -1000 =
postgres
> [13092]    80 13092    47651     4875      59       92         -1000 =
postgres
> [13093]    80 13093    47769     5336      62       92         -1000 =
postgres
> [13094]    80 13094    47670     4777      55       93         -1000 =
postgres
> [13095]    80 13095    47582     3205      39       95         -1000 =
postgres
> [13096]    80 13096    47596     3887      44       93         -1000 =
postgres
> [13097]    80 13097    47835     4919      50       92         -1000 =
postgres
> [13098]    80 13098    47900    22860      93       89         -1000 =
postgres
> [13100]    80 13100    47581     3364      39       95         -1000 =
postgres
> [13102]    80 13102    47549     2586      34       95         -1000 =
postgres
> [13103]    80 13103    47549     2586      34       95         -1000 =
postgres
> [13105]   500 13105   578961    40138     324        0             0 =
rekonq
> [13106]    80 13106    47595     3889      44       93         -1000 =
postgres
> [13107]    80 13107    47549     2586      34       95         -1000 =
postgres
> [13108]    80 13108    47549     2586      34       95         -1000 =
postgres
> [13109]    80 13109    49319    34543      99       92         -1000 =
postgres
> [13111]    80 13111    47549     2571      34       95         -1000 =
postgres
> [13112]    80 13112    49304    35409      99       92         -1000 =
postgres
> [13114]    80 13114    49304    36076      99       92         -1000 =
postgres
> [13115]    80 13115    47862     5758      65       92         -1000 =
postgres
> [13116]   500 13116   113252    14152     201        0             0 =
kaddressbook
> [13122]   500 13122   493943    33314     323        0             0 =
kmail
> [13126]   500 13126   123010    12244     188        0             0 =
konqueror
> [13140]   500 13140    64238     5816      96        0             0 =
applet.py
> [13141]   500 13141   115594    19636     162        0             0 =
net_applet
> [13143]   500 13143    95177     8297     141        0             0 =
polkit-kde-auth
> [13148]   500 13148    66455     1821      32        0             0 =
xsettings-kde
> [13149]   500 13149    10882     1157      27        0             0 =
xload
> [13155]    80 13155    47803     4595      53       93         -1000 =
postgres
> [13156]    80 13156    47973    11993      86       92         -1000 =
postgres
> [13171]   500 13171    73289     9621     132        0             0 =
kwalletmanager
> [13178]   500 13178    84306     1842      35        0             0 =
at-spi-bus-laun
> [13182]   500 13182     3403      569      12        0             0 =
dbus-daemon
> [13185]   500 13185    31230     1213      31        0             0 =
at-spi2-registr
> [13189]   500 13189    46019     1304      27        0             0 =
gvfsd
> [13231]    80 13231    48340    35725      97       92         -1000 =
postgres
> [13233]    80 13233    47925    24455      91       92         -1000 =
postgres
> [13309]    80 13309    47549     2555      34       95         -1000 =
postgres
> [13442]   500 13442   260391    19500     137        0           200 =
python
> [13447]    80 13447    49761    29978     101       83         -1000 =
postgres
> [13470]   500 13470   122584     8709     157        0             0 =
kio_http
> [13482]    80 13482    48989    18272      99       83         -1000 =
postgres
> [13501]   500 13501   122587     8695     157        0             0 =
kio_http
> [13505]   500 13505   122584     8710     157        0             0 =
kio_http
> [13512]   500 13512   122585     8694     157        0             0 =
kio_http
> [13523]   500 13523   122584     8686     157        0             0 =
kio_http
> [13526]   500 13526   122584     8702     157        0             0 =
kio_http
> [13788]   500 13788   115594    13290     145        0             0 =
net_applet
> [13815]   500 13815    40303     3579      48        0             0 =
netmon_cron_par
> [13830]   500 13830    23067     3637      47        0             0 =
content_index.p
> [13843]   500 13843    21772     3377      46        0             0 =
decode-hardware
> [13863]   500 13863    24181     3735      52        0             0 =
netmon_decode.p
> [13909]   500 13909    21912     3505      47        0             0 =
python
> [13914]   500 13914     2330      599      10        0             0 =
mails-process-n
> [13925]   500 13925    24138     3722      53        0             0 =
netmon_cflastse
> [13989]     0 13989     1975      438       9        0             0 =
agetty
> [13994]   500 13994    34668     3038      66        0             0 =
kcminit
> [13995]   500 13995    43712     4218      78        0             0 =
kcminit
> [13996]   500 13996     4623      678      13        0             0 =
setxkbmap
> [13997]     0 13997     4582      268      13        0             0 =
xkbcomp
> Out of memory: Kill process 13442 (python) score 208 or sacrifice =
child
> Killed process 13442 (python) total-vm:1041564kB, anon-rss:67284kB, =
file-rss:10716kB
>=20
> SysRq : HELP : loglevel(0-9) reboot(b) crash(c) terminate-all-tasks(e) =
memory-full-oom-kill(f) kill-all-tasks(i) thaw-filesystems(j) sak(k)
> show-backtrace-all-active-cpus(l) show-memory-usage(m) =
nice-all-RT-tasks(n) poweroff(o) show-registers(p) show-all-timers(q)
> unraw(r) sync(s) show-task-states(t) unmount(u) force-fb(V) =
show-blocked-tasks(w) dump-ftrace-buffer(z)
> SysRq : HELP : loglevel(0-9) reboot(b) crash(c) terminate-all-tasks(e) =
memory-full-oom-kill(f) kill-all-tasks(i) thaw-filesystems(j) sak(k)
> show-backtrace-all-active-cpus(l) show-memory-usage(m) =
nice-all-RT-tasks(n) poweroff(o) show-registers(p) show-all-timers(q)
> unraw(r) sync(s) show-task-states(t) unmount(u) force-fb(V) =
show-blocked-tasks(w) dump-ftrace-buffer(z)
> SysRq : HELP : loglevel(0-9) reboot(b) crash(c) terminate-all-tasks(e) =
memory-full-oom-kill(f) kill-all-tasks(i) thaw-filesystems(j) sak(k)
> show-backtrace-all-active-cpus(l) show-memory-usage(m) =
nice-all-RT-tasks(n) poweroff(o) show-registers(p) show-all-timers(q)
> unraw(r) sync(s) show-task-states(t) unmount(u) force-fb(V) =
show-blocked-tasks(w) dump-ftrace-buffer(z)
> SysRq : Restore framebuffer console
> SysRq : HELP : loglevel(0-9) reboot(b) crash(c) terminate-all-tasks(e) =
memory-full-oom-kill(f) kill-all-tasks(i) thaw-filesystems(j) sak(k)
> show-backtrace-all-active-cpus(l) show-memory-usage(m) =
nice-all-RT-tasks(n) poweroff(o) show-registers(p) show-all-timers(q)
> unraw(r) sync(s) show-task-states(t) unmount(u) force-fb(V) =
show-blocked-tasks(w) dump-ftrace-buffer(z)
> SysRq : Keyboard mode set to system default
>=20
> -- Reboot --
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
