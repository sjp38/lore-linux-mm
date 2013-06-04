Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id B9E066B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 23:14:58 -0400 (EDT)
Date: Mon, 3 Jun 2013 23:14:56 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1317567060.11044929.1370315696270.JavaMail.root@redhat.com>
In-Reply-To: <20130603040038.GX29466@dastard>
References: <510292845.4997401.1369279175460.JavaMail.root@redhat.com> <1588848128.8530921.1369885528565.JavaMail.root@redhat.com> <20130530052049.GK29466@dastard> <1824023060.8558101.1369892432333.JavaMail.root@redhat.com> <1462663454.9294499.1369969415681.JavaMail.root@redhat.com> <20130531060415.GU29466@dastard> <1517224799.10311874.1370228651422.JavaMail.root@redhat.com> <20130603040038.GX29466@dastard>
Subject: Re: 3.9.4 Oops running xfstests (WAS Re: 3.9.3: Oops running
 xfstests)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, stable@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>



----- Original Message -----
> From: "Dave Chinner" <david@fromorbit.com>
> To: "CAI Qian" <caiqian@redhat.com>
> Cc: xfs@oss.sgi.com, stable@vger.kernel.org, "LKML" <linux-kernel@vger.kernel.org>, "linux-mm" <linux-mm@kvack.org>
> Sent: Monday, June 3, 2013 12:00:38 PM
> Subject: Re: 3.9.4 Oops running xfstests (WAS Re: 3.9.3: Oops running xfstests)
> 
> On Sun, Jun 02, 2013 at 11:04:11PM -0400, CAI Qian wrote:
> > 
> > > There's memory corruption all over the place.  It is most likely
> > > that trinity is causing this - it's purpose is to trigger corruption
> > > issues, but they aren't always immediately seen.  If you can trigger
> > > this xfs trace without trinity having been run and without all the
> > > RCU/idle/scheduler/cgroup issues occuring at the same time, then
> > > it's likely to be caused by XFS. But right now, I'd say XFS is just
> > > an innocent bystander caught in the crossfire. There's nothing I can
> > > do from an XFS persepctive to track this down...
> > OK, this can be reproduced by just running LTP and then xfstests without
> > trinity at all...
> 
> Cai, can you be more precise about what is triggering it?  LTP and
> xfstests do a large amount of stuff, and stack traces do not do not
> help narrow down the cause at all.  Can you provide the follwoing
> information and perform the follwoing steps:
> 
> 	1. What xfstest is tripping over it?
Test #20.
> 	2. Can you reproduce it just by running that one specific test
> 	  on a pristine system (i.e. freshly mkfs'd filesystems,
> 	  immediately after boot)
Yes, it was reproduced without LTP at all.
[   98.534402] XFS (dm-0): Mounting Filesystem
[   98.586673] XFS (dm-0): Ending clean mount
[   99.741704] XFS (dm-2): Mounting Filesystem
[  100.117248] XFS (dm-2): Ending clean mount
[  100.723228] XFS (dm-0): Mounting Filesystem
[  100.775965] XFS (dm-0): Ending clean mount
[  101.980250] BUG: unable to handle kernel NULL pointer dereference at 0000000000000098
[  101.988136] IP: [<ffffffff81098cac>] tg_load_down+0x4c/0x80
[  101.993737] PGD 0 
[  101.995769] Oops: 0002 [#1] SMP 
[  101.999038] Modules linked in: lockd sunrpc nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm hp_wmi sparse_keymap rfkill iTCO_wdt e1000e pcspkr snd_page_alloc iTCO_vendor_support mei ptp pps_core lpc_ich i2c_i801 snd_timer mfd_core microcode(+) snd soundcore xfs libcrc32c sr_mod sd_mod cdrom crc_t10dif nouveau video mxm_wmi i2c_algo_bit drm_kms_helper ahci ata_generic ttm libahci pata_acpi drm i2c_core libata wmi dm_mirror dm_region_hash dm_log dm_mod
[  102.075355] CPU 2 
[  102.077197] Pid: 356, comm: kworker/2:2 Not tainted 3.9.4 #1 Hewlett-Packard HP Z210 Workstation/1587h
[  102.086691] RIP: 0010:[<ffffffff81098cac>]  [<ffffffff81098cac>] tg_load_down+0x4c/0x80
[  102.094705] RSP: 0018:ffff880078307c78  EFLAGS: 00010002
[  102.100020] RAX: 0001f2b5a618ed0f RBX: 0000000000000001 RCX: 000000000000068a
[  102.107157] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8800772ceee8
[  102.114293] RBP: ffff880078307c78 R08: 0000000000000008 R09: ffff88007d094400
[  102.121422] R10: 0000000000000344 R11: 0000000000000001 R12: ffffffff81c78560
[  102.128552] R13: ffffffff8108c460 R14: 0000000000000000 R15: ffff8800772ceee8
[  102.135682] FS:  0000000000000000(0000) GS:ffff88007d100000(0000) knlGS:0000000000000000
[  102.143776] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  102.149524] CR2: 0000000000000098 CR3: 00000000018fa000 CR4: 00000000000407e0
[  102.156654] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  102.163785] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  102.170915] Process kworker/2:2 (pid: 356, threadinfo ffff880078306000, task ffff88007736b580)
[  102.179527] Stack:
[  102.181545]  ffff880078307cc0 ffffffff810926b2 ffffffff81098c60 ffff8800772cf008
[  102.189005]  ffff880079b96f00 000000000000069c ffff880079b96ee8 0000000000014400
[  102.196464]  ffff88007d094400 ffff880078307db0 ffffffff8109f773 ffff88007cc10480
[  102.203920] Call Trace:
[  102.206372]  [<ffffffff810926b2>] walk_tg_tree_from+0x32/0xe0
[  102.212118]  [<ffffffff81098c60>] ? task_waking_fair+0x20/0x20
[  102.217955]  [<ffffffff8109f773>] load_balance+0x2a3/0x7d0
[  102.223444]  [<ffffffff8108fa7c>] ? update_rq_clock.part.67+0x1c/0x170
[  102.229977]  [<ffffffff810a0142>] idle_balance+0x182/0x2f0
[  102.235468]  [<ffffffff8160f1ac>] __schedule+0x7bc/0x7d0
[  102.240786]  [<ffffffff8160f1e9>] schedule+0x29/0x70
[  102.245756]  [<ffffffff8107f404>] worker_thread+0x1b4/0x3d0
[  102.251332]  [<ffffffff8107f250>] ? __alloc_workqueue_key+0x500/0x500
[  102.257777]  [<ffffffff81084240>] kthread+0xc0/0xd0
[  102.262662]  [<ffffffff81084180>] ? insert_kthread_work+0x40/0x40
[  102.268761]  [<ffffffff816192ac>] ret_from_fork+0x7c/0xb0
[  102.274164]  [<ffffffff81084180>] ? insert_kthread_work+0x40/0x40
[  102.280262] Code: 00 00 00 00 48 8b 14 f0 48 8b 0c f1 48 8b 82 98 00 00 00 48 0f af 01 48 8b 0a 31 d2 48 83 c1 01 48 f7 f1 48 8b 57 48 4a 8b 14 02 <48> 89 82 98 00 00 00 31 c0 5d c3 66 0f 1f 84 00 00 00 00 00 48 
[  102.300226] RIP  [<ffffffff81098cac>] tg_load_down+0x4c/0x80
[  102.305906]  RSP <ffff880078307c78>
[  102.309394] CR2: 0000000000000098
[  102.312710] ---[ end trace ba964230a74993fe ]---
[  102.312714] BUG: unable to handle kernel NULL pointer dereference at 0000000000000098
[  102.312719] IP: [<ffffffff81098cac>] tg_load_down+0x4c/0x80
[  102.312720] PGD 0 
[  102.312723] Oops: 0002 [#2] SMP 
[  102.312752] Modules linked in: lockd sunrpc nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm hp_wmi sparse_keymap rfkill iTCO_wdt e1000e pcspkr snd_page_alloc iTCO_vendor_support mei ptp pps_core lpc_ich i2c_i801 snd_timer mfd_core microcode(+) snd soundcore xfs libcrc32c sr_mod sd_mod cdrom crc_t10dif nouveau video mxm_wmi i2c_algo_bit drm_kms_helper ahci ata_generic ttm libahci pata_acpi drm i2c_core libata wmi dm_mirror dm_region_hash dm_log dm_mod
[  102.312758] CPU 0 
[  102.312758] Pid: 78, comm: kworker/0:2 Tainted: G      D      3.9.4 #1 Hewlett-Packard HP Z210 Workstation/1587h
[  102.312762] RIP: 0010:[<ffffffff81098cac>]  [<ffffffff81098cac>] tg_load_down+0x4c/0x80
[  102.312763] RSP: 0018:ffff880036c25c78  EFLAGS: 00010002
[  102.312764] RAX: 0001f2b5a618ed0f RBX: 0000000000000001 RCX: 000000000000068a
[  102.312765] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8800772ceee8
[  102.312766] RBP: ffff880036c25c78 R08: 0000000000000008 R09: ffff88007d094400
[  102.312767] R10: 0000000000000344 R11: 0000000000000001 R12: ffffffff81c78560
[  102.312768] R13: ffffffff8108c460 R14: 0000000000000000 R15: ffff8800772ceee8
[  102.312770] FS:  0000000000000000(0000) GS:ffff88007d000000(0000) knlGS:0000000000000000
[  102.312771] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  102.312772] CR2: 0000000000000098 CR3: 00000000018fa000 CR4: 00000000000407f0
[  102.312773] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  102.312774] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  102.312776] Process kworker/0:2 (pid: 78, threadinfo ffff880036c24000, task ffff8800773c9ac0)
[  102.312776] Stack:
[  102.312779]  ffff880036c25cc0 ffffffff810926b2 ffffffff81098c60 ffff8800772cf008
[  102.312781]  ffff880079b96f00 000000000000069c ffff880079b96ee8 0000000000014400
[  102.312783]  ffff88007d094400 ffff880036c25db0 ffffffff8109f773 ffff88007cc10080
[  102.312783] Call Trace:
[  102.312787]  [<ffffffff810926b2>] walk_tg_tree_from+0x32/0xe0
[  102.312789]  [<ffffffff81098c60>] ? task_waking_fair+0x20/0x20
[  102.312792]  [<ffffffff8109f773>] load_balance+0x2a3/0x7d0
[  102.312795]  [<ffffffff8108fa7c>] ? update_rq_clock.part.67+0x1c/0x170
[  102.312798]  [<ffffffff810a0142>] idle_balance+0x182/0x2f0
[  102.312801]  [<ffffffff8160f1ac>] __schedule+0x7bc/0x7d0
[  102.312803]  [<ffffffff8160f1e9>] schedule+0x29/0x70
[  102.312806]  [<ffffffff8107f404>] worker_thread+0x1b4/0x3d0
[  102.312809]  [<ffffffff8107f250>] ? __alloc_workqueue_key+0x500/0x500
[  102.312811]  [<ffffffff81084240>] kthread+0xc0/0xd0
[  102.312813]  [<ffffffff81084180>] ? insert_kthread_work+0x40/0x40
[  102.312816]  [<ffffffff816192ac>] ret_from_fork+0x7c/0xb0
[  102.312818]  [<ffffffff81084180>] ? insert_kthread_work+0x40/0x40
[  102.312837] Code: 00 00 00 00 48 8b 14 f0 48 8b 0c f1 48 8b 82 98 00 00 00 48 0f af 01 48 8b 0a 31 d2 48 83 c1 01 48 f7 f1 48 8b 57 48 4a 8b 14 02 <48> 89 82 98 00 00 00 31 c0 5d c3 66 0f 1f 84 00 00 00 00 00 48 
[  102.312839] RIP  [<ffffffff81098cac>] tg_load_down+0x4c/0x80
[  102.312840]  RSP <ffff880036c25c78>
[  102.312840] CR2: 0000000000000098
[  102.312842] ---[ end trace ba964230a74993ff ]---
[  102.312866] general protection fault: 0000 [#3] SMP 
[  102.312896] Modules linked in: lockd sunrpc nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm hp_wmi sparse_keymap rfkill iTCO_wdt e1000e pcspkr snd_page_alloc iTCO_vendor_support mei ptp pps_core lpc_ich i2c_i801 snd_timer mfd_core microcode(+) snd soundcore xfs libcrc32c sr_mod sd_mod cdrom crc_t10dif nouveau video mxm_wmi i2c_algo_bit drm_kms_helper ahci ata_generic ttm libahci pata_acpi drm i2c_core libata wmi dm_mirror dm_region_hash dm_log dm_mod
[  102.312903] CPU 1 
[  102.312903] Pid: 1999, comm: attr Tainted: G      D      3.9.4 #1 Hewlett-Packard HP Z210 Workstation/1587h
[  102.312908] RIP: 0010:[<ffffffff810983a9>]  [<ffffffff810983a9>] irqtime_account_process_tick.isra.2+0x239/0x3c0
[  102.312909] =============================================================================
[  102.312910] RSP: 0018:ffff88007d083e08  EFLAGS: 00010003
[  102.312912] BUG kmalloc-1024 (Tainted: G      D     ): Padding overwritten. 0xffff88005b4e7ec0-0xffff88005b4e7fff
[  102.312913] RAX: ffff88005b656288 RBX: ffff880079b43c80 RCX: 00000000000000a7
[  102.312914] -----------------------------------------------------------------------------
[  102.312914] 
[  102.312915] RDX: 6b6b6b6b6b6b6b6b RSI: 0000000000000000 RDI: 0000000000000086
[  102.312917] INFO: Slab 0xffffea00016d3800 objects=24 used=24 fp=0x          (null) flags=0x10000000004080
[  102.312918] RBP: ffff88007d083e40 R08: 0000000000000000 R09: 0000000225c17d03
[  102.312921] Pid: 518, comm: in:imklog Tainted: G    B D      3.9.4 #1
[  102.312922] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88007d08e800
[  102.312922] Call Trace:
[  102.312923] R13: ffff880058063580 R14: 0000000000000000 R15: ffff88007d094c88
[  102.312926] FS:  00007f237404a740(0000) GS:ffff88007d080000(0000) knlGS:0000000000000000
[  102.312931]  [<ffffffff81181ed2>] slab_err+0xc2/0xf0
[  102.312932] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  102.312934] CR2: 00007f2373c352a0 CR3: 0000000063ea9000 CR4: 00000000000407e0
[  102.312937]  [<ffffffff81018018>] ? write_ok_or_segv+0x88/0x90
[  102.312938] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  102.312939] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  102.312943]  [<ffffffff81020c2b>] ? save_stack_trace+0x2b/0x50
[  102.312944] Process attr (pid: 1999, threadinfo ffff88005753e000, task ffff880058063580)
[  102.312945] Stack:
[  102.312947]  [<ffffffff81180911>] ? set_track+0x61/0x1b0
[  102.312949]  ffff88007d08e800
[  102.312952]  [<ffffffff8118176d>] ? init_object+0x3d/0x70
[  102.312953]  0000000000000086 ffff88007d094400
[  102.312956]  [<ffffffff81181ff5>] slab_pad_check.part.41+0xf5/0x170
[  102.312957]  0000000000014400
[  102.312967]  [<ffffffff81063bdc>] ? do_syslog+0x23c/0x5c0
[  102.312968]  ffff880058063580 0000000000000000
[  102.312969]  [<ffffffff811820e3>] check_slab+0x73/0x100
[  102.312970]  00000017979e99b3 ffff88007d083e78
[  102.312970] 
[  102.312972]  [<ffffffff81606b50>] alloc_debug_processing+0x21/0x118
[  102.312973]  ffffffff8109874c
[  102.312974]  [<ffffffff8160772f>] __slab_alloc+0x3b8/0x4a2
[  102.312974]  ffff880058063580 0000000000000000
[  102.312976]  [<ffffffff81063bdc>] ? do_syslog+0x23c/0x5c0
[  102.312976]  0000000000000001
[  102.312977] Call Trace:
[  102.312978]  [<ffffffff810915aa>] ? finish_task_switch+0xba/0xe0
[  102.312979]  <IRQ> 
[  102.312980]  [<ffffffff81184dd1>] kmem_cache_alloc_trace+0x1b1/0x200
[  102.312981]  [<ffffffff8109874c>] account_process_tick+0x11c/0x1d0
[  102.312983]  [<ffffffff81063bdc>] do_syslog+0x23c/0x5c0
[  102.312985]  [<ffffffff81071f0d>] update_process_times+0x2d/0x80
[  102.312986]  [<ffffffff810850e0>] ? wake_up_bit+0x30/0x30
[  102.312988]  [<ffffffff810ba1c5>] tick_sched_handle.isra.13+0x25/0x60
[  102.312991]  [<ffffffff8120ca94>] kmsg_read+0x44/0x60
[  102.312992]  [<ffffffff810ba241>] tick_sched_timer+0x41/0x60
[  102.312994]  [<ffffffff811ffa9a>] proc_reg_read+0x6a/0xa0
[  102.312996]  [<ffffffff81087af4>] __run_hrtimer+0x74/0x1d0
[  102.312997]  [<ffffffff8119c56c>] vfs_read+0x9c/0x170
[  102.312998]  [<ffffffff810ba200>] ? tick_sched_handle.isra.13+0x60/0x60
[  102.313000]  [<ffffffff8119c939>] sys_read+0x49/0xa0
[  102.313001]  [<ffffffff810882d7>] hrtimer_interrupt+0xe7/0x220
[  102.313004]  [<ffffffff810e0ef6>] ? __audit_syscall_exit+0x1f6/0x2a0
[  102.313005]  [<ffffffff8161b0e9>] smp_apic_timer_interrupt+0x69/0x9c
[  102.313007]  [<ffffffff81619359>] system_call_fastpath+0x16/0x1b
[  102.313008]  [<ffffffff81619fdd>] apic_timer_interrupt+0x6d/0x80
[  102.313009] Padding ffff88005b4e7ec0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  102.313010] Padding ffff88005b4e7ed0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  102.313010]  <EOI> 
[  102.313011] Padding ffff88005b4e7ee0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  102.313013]  [<ffffffff813022f6>] ? memmove+0x46/0x1a0
[  102.313013] Padding ffff88005b4e7ef0: 00 00 00 00 00 00 00 00 00 00 00 00 00 29 01 00  .............)..
[  102.313014] Padding ffff88005b4e7f00: 07 1b 04 73 65 6c 69 6e 75 78 73 79 73 74 65 6d  ...selinuxsystem
[  102.313015] Padding ffff88005b4e7f10: 5f 75 3a 6f 62 6a 65 63 74 5f 72 3a 75 73 72 5f  _u:object_r:usr_
[  102.313032]  [<ffffffffa02801a1>] ? xfs_attr_leaf_moveents.isra.2+0x91/0x280 [xfs]
[  102.313032] Padding ffff88005b4e7f20: 74 3a 73 30 00 00 00 00 49 4e 81 a4 02 02 00 00  t:s0....IN......
[  102.313033] Padding ffff88005b4e7f30: 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00  ................
[  102.313033] Padding ffff88005b4e7f40: 00 00 00 00 00 00 00 02 51 47 09 00 00 00 00 00  ........QG......
[  102.313042]  [<ffffffffa0280467>] xfs_attr_leaf_compact+0xd7/0x130 [xfs]
[  102.313043] Padding ffff88005b4e7f50: 51 47 09 00 00 00 00 00 51 ac 1e 27 21 f1 4e ad  QG......Q..'!.N.
[  102.313043] Padding ffff88005b4e7f60: 00 00 00 00 00 00 00 f2 00 00 00 00 00 00 00 01  ................
[  102.313044] Padding ffff88005b4e7f70: 00 00 00 00 00 00 00 01 00 00 0e 01 00 00 00 00  ................
[  102.313053]  [<ffffffffa0281a2e>] xfs_attr_leaf_add+0xce/0x170 [xfs]
[  102.313053] Padding ffff88005b4e7f80: 00 00 00 00 c1 6d 78 44 ff ff ff ff 00 00 00 00  .....mxD........
[  102.313054] Padding ffff88005b4e7f90: 00 00 00 00 00 00 08 10 36 a0 00 01 00 00 00 00  ........6.......
[  102.313062]  [<ffffffffa027d850>] xfs_attr_leaf_addname+0xc0/0x3d0 [xfs]
[  102.313062] Padding ffff88005b4e7fa0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  102.313063] Padding ffff88005b4e7fb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  102.313072]  [<ffffffffa028bd4e>] ? xfs_bmap_one_block+0x3e/0xa0 [xfs]
[  102.313072] Padding ffff88005b4e7fc0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  102.313073] Padding ffff88005b4e7fd0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  102.313074] Padding ffff88005b4e7fe0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  102.313081]  [<ffffffffa027e78c>] xfs_attr_set_int+0x30c/0x420 [xfs]
[  102.313082] Padding ffff88005b4e7ff0: 00 00 00 00 00 00 00 00 00 00 00 00 00 29 01 00  .............)..
[  102.313085]  [<ffffffff811be9f4>] ? setxattr+0xa4/0x1c0
[  102.313085] FIX kmalloc-1024: Restoring 0xffff88005b4e7ec0-0xffff88005b4e7fff=0x5a
[  102.313085] 
[  102.313086] ==========
CAI Qian
> 	3. if you can't reproduce it like that, does it reproduce on
> 	  an xfstest run on a pristine system? If so, what command
> 	  line are you running, and what are the filesystem
> 	  configurations?
> 	4. if you cannot reproduce it just with xfstests and you need
> 	  to run LTP first, then can you just run the xfstest that
> 	  is failing after running LTP and see if that triggers the
> 	  problem. If it does, please take a metadump of the
> 	  filesystems after LTP has run, save them, and if the
> 	  single test then fails send me the metadumps and your
> 	  xfstests command line.
> 	5. If all else fails, bisect the kernel to identify the
> 	  commit that introduces the problem....
> 
> Cheers,
> 
> Dave.
> 
> --
> Dave Chinner
> david@fromorbit.com
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
