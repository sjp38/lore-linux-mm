Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7F16B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:16:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p20so93794091pgd.21
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 00:16:17 -0700 (PDT)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id e11si3285020pgp.351.2017.03.28.00.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 00:16:15 -0700 (PDT)
Received: by mail-pg0-x236.google.com with SMTP id 21so64254827pgg.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 00:16:15 -0700 (PDT)
Date: Tue, 28 Mar 2017 00:16:06 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: ksmd lockup - kernel 4.11-rc series
In-Reply-To: <20170327233617.353obb3m4wz7n5kv@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1703280008020.2599@eggly.anvils>
References: <003401d2a750$19f98190$4dec84b0$@net> <20170327233617.353obb3m4wz7n5kv@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Doug Smythies <dsmythies@telus.net>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

On Tue, 28 Mar 2017, Kirill A. Shutemov wrote:
> On Mon, Mar 27, 2017 at 04:16:00PM -0700, Doug Smythies wrote:
> > Hi,
> > 
> > Note: I am not sure I have the correct e-mail list for this.
> > 
> > As of kernel 4.11-rc1 I have a very infrequent issue (only four times
> > so far, once with -rc1 and three times with -rc2 (I never used -rc3,
> > and am now running -rc4)) where ksmd becomes stuck, the load average
> > goes way up and one CPU keeps hitting the NMI watchdog. I have not
> > been able to figure out a way to recover and end up hitting the reset
> > button on the computer. I am running 2 VM guests on this host server at
> > the time.
> > 
> > Note: these events have always been preceded by some other event, and
> > so something else might be the root issue here. However, the preceding
> > event also seems to be ksm related, not sure.
> > 
> > Since the issue is so infrequent, and the event requires a hard reset,
> > it would be almost impossible to bi-sect the kernel to isolate it.
> > 
> > I am willing to do the work to isolate the issue, I just don't know
> > what to do. While I never had this issue before kernel 4.11-rc1, I also
> > do not run VM guests on this test computer all the time.
> > 
> > Doug Smythies
> > 
> > Log segment for one occurrence:
> > 
> > Mar 27 15:17:07 s15 kernel: [92420.587173] BUG: unable to handle kernel paging request at ffff88e680000000
> > Mar 27 15:17:07 s15 kernel: [92420.587203] IP: page_vma_mapped_walk+0xe6/0x5b0
> > Mar 27 15:17:07 s15 kernel: [92420.587217] PGD ac80a067
> > Mar 27 15:17:07 s15 kernel: [92420.587217] PUD 41f5ff067
> > Mar 27 15:17:07 s15 kernel: [92420.587226] PMD 0
> 
> +Hugh.
> 
> Thanks for report.
> 
> It's likely I've screwed something up with my page_vma_mapped_walk()
> transition. I don't see anything yet. And it's 2:30 AM. I'll look more
> into it tomorrow.

I've known for a while that there's something quite wrong with KSM in
v4.11-rc, but haven't taken out the time to investigate yet (and was
curious to see whether anyone else noticed - thank you Doug).

I've rather supposed that it comes from your walk changes; but that's
nothing more than a guess so far, and I haven't looked to see if what
I hit is the same thing as Doug reports.

I'll look back into it later today, or tomorrow.

Hugh

> 
> Meanwhile, could you check where the page_vma_mapped_walk+0xe6 is in your
> build:
> 
> ./scripts/faddr2line <your vmlinux> page_vma_mapped_walk+0xe6
> 
> > Mar 27 15:17:07 s15 kernel: [92420.587235]
> > Mar 27 15:17:07 s15 kernel: [92420.587248] Oops: 0000 [#1] SMP
> > Mar 27 15:17:07 s15 kernel: [92420.587259] Modules linked in: ufs qnx4 hfsplus hfs minix ntfs msdos jfs xfs
> >  cpuid vhost_net vhost tap xt_conntrack ipt_REJECT nf_reject_ipv4 ebtable_filter ebtables ip6_tables
> >  xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4
> >  nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack xt_tcpudp iptable_filter ip_tables
> >  x_tables snd_hda_codec_hdmi snd_hda_codec_realtek intel_rapl eeepc_wmi asus_wmi sparse_keymap
> >  snd_hda_codec_generic x86_pkg_temp_thermal snd_hda_intel snd_hda_codec intel_powerclamp bridge stp llc
> >  coretemp snd_hda_core snd_hwdep snd_pcm snd_timer snd soundcore intel_cstate ppdev mei_me mei shpchp
> >  input_leds intel_rapl_perf kvm_intel kvm irqbypass serio_raw parport_pc lpc_ich parport mac_hid
> >  tpm_infineon ib_iser rdma_cm iw_cm ib_cm ib_core configfs iscsi_tcp
> > Mar 27 15:17:07 s15 kernel: [92420.587467]  libiscsi_tcp libiscsi scsi_transport_iscsi autofs4 btrfs raid10
> >  raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx xor raid6_pq libcrc32c raid1 raid0
> >  multipath linear i915 crct10dif_pclmul crc32_pclmul ghash_clmulni_intel i2c_algo_bit pcbc drm_kms_helper
> >  aesni_intel e1000e syscopyarea aes_x86_64 sysfillrect sysimgblt crypto_simd fb_sys_fops ahci glue_helper
> >  ptp r8169 cryptd libahci mii pps_core pata_acpi drm wmi fjes video
> > Mar 27 15:17:07 s15 kernel: [92420.587587] CPU: 1 PID: 81 Comm: kswapd0 Not tainted 4.11.0-rc2-stock #218
> > Mar 27 15:17:07 s15 kernel: [92420.587607] Hardware name: System manufacturer System Product Name/P8Z68-M PRO, BIOS 4003 05/09/2013
> > Mar 27 15:17:07 s15 kernel: [92420.587632] task: ffff88ea4cab9680 task.stack: ffffb10c01e10000
> > Mar 27 15:17:07 s15 kernel: [92420.587650] RIP: 0010:page_vma_mapped_walk+0xe6/0x5b0
> > Mar 27 15:17:07 s15 kernel: [92420.587665] RSP: 0018:ffffb10c01e13a48 EFLAGS: 00010206
> > Mar 27 15:17:07 s15 kernel: [92420.587681] RAX: ffff88e67ffffff8 RBX: ffffb10c01e13a98 RCX: ffff88e680000000
> > Mar 27 15:17:07 s15 kernel: [92420.587701] RDX: 0017ffffc004005d RSI: 00003ffffffff000 RDI: ffffe4f74fc00080
> > Mar 27 15:17:07 s15 kernel: [92420.587721] RBP: ffffb10c01e13a78 R08: 0000000000000000 R09: 0000000000000000
> > Mar 27 15:17:07 s15 kernel: [92420.587749] R10: 0000000000000000 R11: 0000000000000289 R12: ffffe4f74fc00080
> > Mar 27 15:17:07 s15 kernel: [92420.587770] R13: ffffe4f74fc00080 R14: 00007f2e32400200 R15: ffff88e91e77c840
> > Mar 27 15:17:07 s15 kernel: [92420.587806] FS:  0000000000000000(0000) GS:ffff88ea5f240000(0000) knlGS:0000000000000000
> > Mar 27 15:17:07 s15 kernel: [92420.587829] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > Mar 27 15:17:07 s15 kernel: [92420.587845] CR2: ffff88e680000000 CR3: 00000000ac209000 CR4: 00000000000426e0
> > Mar 27 15:17:07 s15 kernel: [92420.587865] Call Trace:
> > Mar 27 15:17:07 s15 kernel: [92420.587876]  page_referenced_one+0x91/0x1a0
> > Mar 27 15:17:07 s15 kernel: [92420.587890]  rmap_walk_ksm+0x100/0x190
> > Mar 27 15:17:07 s15 kernel: [92420.587902]  rmap_walk+0x4f/0x60
> > Mar 27 15:17:07 s15 kernel: [92420.587913]  page_referenced+0x149/0x170
> > Mar 27 15:17:07 s15 kernel: [92420.587926]  ? invalid_page_referenced_vma+0x80/0x80
> > Mar 27 15:17:07 s15 kernel: [92420.587941]  ? page_get_anon_vma+0x90/0x90
> > Mar 27 15:17:07 s15 kernel: [92420.587955]  shrink_active_list+0x1c2/0x430
> > Mar 27 15:17:07 s15 kernel: [92420.587969]  shrink_node_memcg+0x67a/0x7a0
> > Mar 27 15:17:07 s15 kernel: [92420.587983]  shrink_node+0xe1/0x320
> > Mar 27 15:17:07 s15 kernel: [92420.587995]  kswapd+0x34b/0x720
> > Mar 27 15:17:07 s15 kernel: [92420.588007]  kthread+0x101/0x140
> > Mar 27 15:17:07 s15 kernel: [92420.588018]  ? mem_cgroup_shrink_node+0x180/0x180
> > Mar 27 15:17:07 s15 kernel: [92420.588032]  ? kthread_create_on_node+0x60/0x60
> > Mar 27 15:17:07 s15 kernel: [92420.588048]  ret_from_fork+0x2c/0x40
> > Mar 27 15:17:07 s15 kernel: [92420.588059] Code: 08 00 00 20 00 49 39 c6 0f 83 7a ff ff ff 4c 8b 73 10 41 f7 c6
> >  ff ff 1f 00 0f 84 87 02 00 00 48 8b 43 20 48 8d 48 08 48 89 4b 20 <48> f7 40 08 9f ff ff ff 0f 85 92 02 00 00
> >  49 81 c6 00 10 00 00
> > Mar 27 15:17:07 s15 kernel: [92420.588125] RIP: page_vma_mapped_walk+0xe6/0x5b0 RSP: ffffb10c01e13a48
> > Mar 27 15:17:07 s15 kernel: [92420.588144] CR2: ffff88e680000000
> > Mar 27 15:17:07 s15 kernel: [92420.595225] ---[ end trace 6e15d07cde4cc6de ]---
> > Mar 27 15:17:35 s15 kernel: [92448.572972] NMI watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [ksmd:64]
> > Mar 27 15:17:35 s15 kernel: [92448.574115] Modules linked in: ... deleted... see above
> > Mar 27 15:17:35 s15 kernel: [92448.583245] CPU: 2 PID: 64 Comm: ksmd Tainted: G      D         4.11.0-rc2-stock #218
> > Mar 27 15:17:35 s15 kernel: [92448.584616] Hardware name: System manufacturer System Product Name/P8Z68-M PRO, BIOS 4003 05/09/2013
> > Mar 27 15:17:35 s15 kernel: [92448.586014] task: ffff88ea4c822d00 task.stack: ffffb10c01af8000
> > Mar 27 15:17:35 s15 kernel: [92448.587452] RIP: 0010:native_queued_spin_lock_slowpath+0x17c/0x1a0
> > Mar 27 15:17:35 s15 kernel: [92448.588853] RSP: 0018:ffffb10c01afbd70 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
> > Mar 27 15:17:35 s15 kernel: [92448.590300] RAX: 0000000000000101 RBX: ffff88e6757d7e10 RCX: 0000000000000001
> > Mar 27 15:17:35 s15 kernel: [92448.591766] RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffffe4f740d5f5f0
> > Mar 27 15:17:35 s15 kernel: [92448.593215] RBP: ffffb10c01afbd70 R08: 0000000000000101 R09: ffff88e91e5c7b48
> > Mar 27 15:17:35 s15 kernel: [92448.594687] R10: 0000000000000000 R11: 00000000000003bd R12: ffffe4f740d5f5f0
> > Mar 27 15:17:35 s15 kernel: [92448.596111] R13: 0000000000000004 R14: ffff88e91e5c7b48 R15: ffffc00000000fff
> > Mar 27 15:17:35 s15 kernel: [92448.597571] FS:  0000000000000000(0000) GS:ffff88ea5f280000(0000) knlGS:0000000000000000
> > Mar 27 15:17:35 s15 kernel: [92448.599026] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > Mar 27 15:17:35 s15 kernel: [92448.600449] CR2: 00007fb04f4a51e4 CR3: 00000000ac209000 CR4: 00000000000426e0
> > Mar 27 15:17:35 s15 kernel: [92448.601893] Call Trace:
> > Mar 27 15:17:35 s15 kernel: [92448.603395]  _raw_spin_lock+0x20/0x30
> > Mar 27 15:17:35 s15 kernel: [92448.604819]  follow_page_pte+0x10c/0x650
> > Mar 27 15:17:35 s15 kernel: [92448.606300]  follow_page_mask+0x1ee/0x5b0
> > Mar 27 15:17:35 s15 kernel: [92448.607693]  ? find_vma+0x68/0x70
> > Mar 27 15:17:35 s15 kernel: [92448.609078]  ksm_scan_thread+0xc08/0x12a0
> > Mar 27 15:17:35 s15 kernel: [92448.610476]  ? wake_atomic_t_function+0x60/0x60
> > Mar 27 15:17:35 s15 kernel: [92448.611789]  kthread+0x101/0x140
> > Mar 27 15:17:35 s15 kernel: [92448.613086]  ? try_to_merge_with_ksm_page+0xa0/0xa0
> > Mar 27 15:17:35 s15 kernel: [92448.614337]  ? kthread_create_on_node+0x60/0x60
> > Mar 27 15:17:35 s15 kernel: [92448.615535]  ret_from_fork+0x2c/0x40
> > Mar 27 15:17:35 s15 kernel: [92448.616707] Code: c0 74 e6 4d 85 c9 c6 07 01 74 30 41 c7 41 08 01 00 00 00 e9 51
> >  ff ff ff 83 fa 01 0f 84 af fe ff ff 8b 07 84 c0 74 08 f3 90 8b 07 <84> c0 75 f8 b8 01 00 00 00 66 89 07 5d c3
> >  f3 90 4c 8b 09 4d 85
> > Mar 27 15:18:03 s15 kernel: [92476.574198] NMI watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [ksmd:64]
> > Mar 27 15:18:03 s15 kernel: [92476.575563] Modules linked in: ... deleted ... see above
> > Mar 27 15:18:03 s15 kernel: [92476.585693] CPU: 2 PID: 64 Comm: ksmd Tainted: G      D      L  4.11.0-rc2-stock #218
> > Mar 27 15:18:03 s15 kernel: [92476.587255] Hardware name: System manufacturer System Product Name/P8Z68-M PRO, BIOS 4003 05/09/2013
> > Mar 27 15:18:03 s15 kernel: [92476.588763] task: ffff88ea4c822d00 task.stack: ffffb10c01af8000
> > Mar 27 15:18:03 s15 kernel: [92476.590350] RIP: 0010:native_queued_spin_lock_slowpath+0x17c/0x1a0
> > Mar 27 15:18:03 s15 kernel: [92476.591862] RSP: 0018:ffffb10c01afbd70 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
> > Mar 27 15:18:03 s15 kernel: [92476.593367] RAX: 0000000000000101 RBX: ffff88e6757d7e10 RCX: 0000000000000001
> > Mar 27 15:18:03 s15 kernel: [92476.594974] RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffffe4f740d5f5f0
> > Mar 27 15:18:03 s15 kernel: [92476.596494] RBP: ffffb10c01afbd70 R08: 0000000000000101 R09: ffff88e91e5c7b48
> > Mar 27 15:18:03 s15 kernel: [92476.598088] R10: 0000000000000000 R11: 00000000000003bd R12: ffffe4f740d5f5f0
> > Mar 27 15:18:03 s15 kernel: [92476.599686] R13: 0000000000000004 R14: ffff88e91e5c7b48 R15: ffffc00000000fff
> > Mar 27 15:18:03 s15 kernel: [92476.601246] FS:  0000000000000000(0000) GS:ffff88ea5f280000(0000) knlGS:0000000000000000
> > Mar 27 15:18:03 s15 kernel: [92476.602880] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > Mar 27 15:18:03 s15 kernel: [92476.604438] CR2: 00007fb04f4a51e4 CR3: 00000000ac209000 CR4: 00000000000426e0
> > Mar 27 15:18:03 s15 kernel: [92476.606060] Call Trace:
> > Mar 27 15:18:03 s15 kernel: [92476.607677]  _raw_spin_lock+0x20/0x30
> > Mar 27 15:18:03 s15 kernel: [92476.609306]  follow_page_pte+0x10c/0x650
> > Mar 27 15:18:03 s15 kernel: [92476.610918]  follow_page_mask+0x1ee/0x5b0
> > Mar 27 15:18:03 s15 kernel: [92476.612464]  ? find_vma+0x68/0x70
> > Mar 27 15:18:03 s15 kernel: [92476.614038]  ksm_scan_thread+0xc08/0x12a0
> > Mar 27 15:18:03 s15 kernel: [92476.615522]  ? wake_atomic_t_function+0x60/0x60
> > Mar 27 15:18:03 s15 kernel: [92476.617007]  kthread+0x101/0x140
> > Mar 27 15:18:03 s15 kernel: [92476.618473]  ? try_to_merge_with_ksm_page+0xa0/0xa0
> > Mar 27 15:18:03 s15 kernel: [92476.619923]  ? kthread_create_on_node+0x60/0x60
> > Mar 27 15:18:03 s15 kernel: [92476.621415]  ret_from_fork+0x2c/0x40
> > Mar 27 15:18:03 s15 kernel: [92476.622838] Code: c0 74 e6 4d 85 c9 c6 07 01 74 30 41 c7 41 08 01 00 00 00 e9 51 ff ff ff 83
> >  fa 01 0f 84 af fe ff ff 8b 07 84 c0 74 08 f3 90 8b 07 <84> c0 75 f8 b8 01 00 00 00 66 89 07 5d c3 f3 90 4c 8b 09 4d 85
> > Mar 27 15:18:07 s15 kernel: [92480.606373] INFO: rcu_sched self-detected stall on CPU
> > Mar 27 15:18:07 s15 kernel: [92480.607801]      2-...: (14977 ticks this GP) idle=851/140000000000001/0 softirq=1548471/1548471
> > fqs=7220
> > Mar 27 15:18:07 s15 kernel: [92480.609207]       (t=15001 jiffies g=271179 c=271178 q=2337)
> > Mar 27 15:18:07 s15 kernel: [92480.610374] INFO: rcu_sched detected stalls on CPUs/tasks:
> > Mar 27 15:18:07 s15 kernel: [92480.610377]      2-...: (14977 ticks this GP) idle=851/140000000000001/0 softirq=1548471/1548471
> > fqs=7220
> > Mar 27 15:18:07 s15 kernel: [92480.610378]      (detected by 0, t=15002 jiffies, g=271179, c=271178, q=2337)
> > Mar 27 15:18:07 s15 kernel: [92480.610381] Sending NMI from CPU 0 to CPUs 2:
> > Mar 27 15:18:07 s15 kernel: [92480.611374] NMI backtrace for cpu 2
> > Mar 27 15:18:07 s15 kernel: [92480.611375] CPU: 2 PID: 64 Comm: ksmd Tainted: G      D      L  4.11.0-rc2-stock #218
> > Mar 27 15:18:07 s15 kernel: [92480.611375] Hardware name: System manufacturer System Product Name/P8Z68-M PRO, BIOS 4003 05/09/2013
> > Mar 27 15:18:07 s15 kernel: [92480.611376] task: ffff88ea4c822d00 task.stack: ffffb10c01af8000
> > Mar 27 15:18:07 s15 kernel: [92480.611376] RIP: 0010:cfb_imageblit+0x4aa/0x4e0
> > Mar 27 15:18:07 s15 kernel: [92480.611376] RSP: 0018:ffff88ea5f283960 EFLAGS: 00000002
> > Mar 27 15:18:07 s15 kernel: [92480.611376] RAX: 0000000000010101 RBX: 0000000000000000 RCX: 0000000000000002
> > Mar 27 15:18:07 s15 kernel: [92480.611377] RDX: ffffb10c10584cb4 RSI: 0000000000010101 RDI: 0000000000000001
> > Mar 27 15:18:07 s15 kernel: [92480.611377] RBP: ffff88ea5f2839d8 R08: ffff88ea4485b15b R09: 0000000000cdcdcd
> > Mar 27 15:18:07 s15 kernel: [92480.611377] R10: ffffffff83a84580 R11: 0000000000000001 R12: ffffb10c10584cb8
> > Mar 27 15:18:07 s15 kernel: [92480.611377] R13: ffffb10c10584d40 R14: ffff88ea4485b150 R15: ffffb10c10584b40
> > Mar 27 15:18:07 s15 kernel: [92480.611378] FS:  0000000000000000(0000) GS:ffff88ea5f280000(0000) knlGS:0000000000000000
> > Mar 27 15:18:07 s15 kernel: [92480.611378] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > Mar 27 15:18:07 s15 kernel: [92480.611378] CR2: 00007fb04f4a51e4 CR3: 00000000ac209000 CR4: 00000000000426e0
> > Mar 27 15:18:07 s15 kernel: [92480.611378] Call Trace:
> > Mar 27 15:18:07 s15 kernel: [92480.611378]  <IRQ>
> > Mar 27 15:18:07 s15 kernel: [92480.611379]  drm_fb_helper_cfb_imageblit+0x17/0x40 [drm_kms_helper]
> > Mar 27 15:18:07 s15 kernel: [92480.611379]  bit_putcs+0x2f2/0x560
> > Mar 27 15:18:07 s15 kernel: [92480.611379]  ? soft_cursor+0x1ad/0x230
> > Mar 27 15:18:07 s15 kernel: [92480.611379]  ? bit_cursor+0x646/0x680
> > Mar 27 15:18:07 s15 kernel: [92480.611379]  ? bit_clear+0x110/0x110
> > Mar 27 15:18:07 s15 kernel: [92480.611380]  fbcon_putcs+0xfd/0x130
> > Mar 27 15:18:07 s15 kernel: [92480.611380]  fbcon_redraw.isra.23+0xe2/0x1d0
> > Mar 27 15:18:07 s15 kernel: [92480.611380]  fbcon_scroll+0x10f/0xd60
> > Mar 27 15:18:07 s15 kernel: [92480.611380]  con_scroll+0x16a/0x180
> > Mar 27 15:18:07 s15 kernel: [92480.611380]  lf+0xa1/0xb0
> > Mar 27 15:18:07 s15 kernel: [92480.611381]  vt_console_print+0x2b9/0x3e0
> > Mar 27 15:18:07 s15 kernel: [92480.611381]  console_unlock+0x3f3/0x4d0
> > Mar 27 15:18:07 s15 kernel: [92480.611381]  vprintk_emit+0x2d4/0x380
> > Mar 27 15:18:07 s15 kernel: [92480.611381]  vprintk_default+0x29/0x50
> > Mar 27 15:18:07 s15 kernel: [92480.611381]  vprintk_func+0x20/0x50
> > Mar 27 15:18:07 s15 kernel: [92480.611381]  printk+0x52/0x6e
> > Mar 27 15:18:07 s15 kernel: [92480.611382]  rcu_check_callbacks+0x74f/0x8b0
> > Mar 27 15:18:07 s15 kernel: [92480.611382]  ? account_system_index_time+0x63/0x70
> > Mar 27 15:18:07 s15 kernel: [92480.611382]  ? tick_sched_handle.isra.15+0x60/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.611382]  update_process_times+0x2f/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.611383]  tick_sched_handle.isra.15+0x25/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.611383]  tick_sched_timer+0x3d/0x70
> > Mar 27 15:18:07 s15 kernel: [92480.611383]  __hrtimer_run_queues+0xe5/0x250
> > Mar 27 15:18:07 s15 kernel: [92480.611383]  hrtimer_interrupt+0xb1/0x200
> > Mar 27 15:18:07 s15 kernel: [92480.611383]  local_apic_timer_interrupt+0x38/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.611384]  smp_apic_timer_interrupt+0x38/0x50
> > Mar 27 15:18:07 s15 kernel: [92480.611384]  apic_timer_interrupt+0x89/0x90
> > Mar 27 15:18:07 s15 kernel: [92480.611384] RIP: 0010:native_queued_spin_lock_slowpath+0x17a/0x1a0
> > Mar 27 15:18:07 s15 kernel: [92480.611384] RSP: 0018:ffffb10c01afbd70 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
> > Mar 27 15:18:07 s15 kernel: [92480.611385] RAX: 0000000000000101 RBX: ffff88e6757d7e10 RCX: 0000000000000001
> > Mar 27 15:18:07 s15 kernel: [92480.611385] RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffffe4f740d5f5f0
> > Mar 27 15:18:07 s15 kernel: [92480.611385] RBP: ffffb10c01afbd70 R08: 0000000000000101 R09: ffff88e91e5c7b48
> > Mar 27 15:18:07 s15 kernel: [92480.611385] R10: 0000000000000000 R11: 00000000000003bd R12: ffffe4f740d5f5f0
> > Mar 27 15:18:07 s15 kernel: [92480.611386] R13: 0000000000000004 R14: ffff88e91e5c7b48 R15: ffffc00000000fff
> > Mar 27 15:18:07 s15 kernel: [92480.611386]  </IRQ>
> > Mar 27 15:18:07 s15 kernel: [92480.611386]  _raw_spin_lock+0x20/0x30
> > Mar 27 15:18:07 s15 kernel: [92480.611386]  follow_page_pte+0x10c/0x650
> > Mar 27 15:18:07 s15 kernel: [92480.611386]  follow_page_mask+0x1ee/0x5b0
> > Mar 27 15:18:07 s15 kernel: [92480.611387]  ? find_vma+0x68/0x70
> > Mar 27 15:18:07 s15 kernel: [92480.611387]  ksm_scan_thread+0xc08/0x12a0
> > Mar 27 15:18:07 s15 kernel: [92480.611387]  ? wake_atomic_t_function+0x60/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.611387]  kthread+0x101/0x140
> > Mar 27 15:18:07 s15 kernel: [92480.611387]  ? try_to_merge_with_ksm_page+0xa0/0xa0
> > Mar 27 15:18:07 s15 kernel: [92480.611388]  ? kthread_create_on_node+0x60/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.611388]  ret_from_fork+0x2c/0x40
> > Mar 27 15:18:07 s15 kernel: [92480.611388] Code: 4d 89 f0 b9 08 00 00 00 89 5d d0 4d 8d 2c 07 eb 2c 41 0f be 00 29 f9 4c 8d
> >  62 04 d3 f8 44 21 d8 41 8b 1c 82 44 21 cb 89 d8 31 f0 <89> 02 85 c9 75 09 49 83 c0 01 b9 08 00 00 00 4c 89 e2 49 39 d5
> > Mar 27 15:18:07 s15 kernel: [92480.682314] NMI backtrace for cpu 2
> > Mar 27 15:18:07 s15 kernel: [92480.683111] CPU: 2 PID: 64 Comm: ksmd Tainted: G      D      L  4.11.0-rc2-stock #218
> > Mar 27 15:18:07 s15 kernel: [92480.683894] Hardware name: System manufacturer System Product Name/P8Z68-M PRO, BIOS 4003 05/09/2013
> > Mar 27 15:18:07 s15 kernel: [92480.684685] Call Trace:
> > Mar 27 15:18:07 s15 kernel: [92480.685523]  <IRQ>
> > Mar 27 15:18:07 s15 kernel: [92480.686304]  dump_stack+0x63/0x90
> > Mar 27 15:18:07 s15 kernel: [92480.687092]  nmi_cpu_backtrace+0x95/0xa0
> > Mar 27 15:18:07 s15 kernel: [92480.687849]  ? irq_force_complete_move+0x140/0x140
> > Mar 27 15:18:07 s15 kernel: [92480.688609]  nmi_trigger_cpumask_backtrace+0xe7/0x120
> > Mar 27 15:18:07 s15 kernel: [92480.689418]  arch_trigger_cpumask_backtrace+0x19/0x20
> > Mar 27 15:18:07 s15 kernel: [92480.690179]  rcu_dump_cpu_stacks+0x9d/0xda
> > Mar 27 15:18:07 s15 kernel: [92480.690955]  rcu_check_callbacks+0x75f/0x8b0
> > Mar 27 15:18:07 s15 kernel: [92480.691704]  ? account_system_index_time+0x63/0x70
> > Mar 27 15:18:07 s15 kernel: [92480.692449]  ? tick_sched_handle.isra.15+0x60/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.693283]  update_process_times+0x2f/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.694016]  tick_sched_handle.isra.15+0x25/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.694771]  tick_sched_timer+0x3d/0x70
> > Mar 27 15:18:07 s15 kernel: [92480.695500]  __hrtimer_run_queues+0xe5/0x250
> > Mar 27 15:18:07 s15 kernel: [92480.696224]  hrtimer_interrupt+0xb1/0x200
> > Mar 27 15:18:07 s15 kernel: [92480.696998]  local_apic_timer_interrupt+0x38/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.697743]  smp_apic_timer_interrupt+0x38/0x50
> > Mar 27 15:18:07 s15 kernel: [92480.698502]  apic_timer_interrupt+0x89/0x90
> > Mar 27 15:18:07 s15 kernel: [92480.699240] RIP: 0010:native_queued_spin_lock_slowpath+0x17a/0x1a0
> > Mar 27 15:18:07 s15 kernel: [92480.699990] RSP: 0018:ffffb10c01afbd70 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
> > Mar 27 15:18:07 s15 kernel: [92480.700820] RAX: 0000000000000101 RBX: ffff88e6757d7e10 RCX: 0000000000000001
> > Mar 27 15:18:07 s15 kernel: [92480.701592] RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffffe4f740d5f5f0
> > Mar 27 15:18:07 s15 kernel: [92480.702379] RBP: ffffb10c01afbd70 R08: 0000000000000101 R09: ffff88e91e5c7b48
> > Mar 27 15:18:07 s15 kernel: [92480.703184] R10: 0000000000000000 R11: 00000000000003bd R12: ffffe4f740d5f5f0
> > Mar 27 15:18:07 s15 kernel: [92480.703970] R13: 0000000000000004 R14: ffff88e91e5c7b48 R15: ffffc00000000fff
> > Mar 27 15:18:07 s15 kernel: [92480.704811]  </IRQ>
> > Mar 27 15:18:07 s15 kernel: [92480.705605]  _raw_spin_lock+0x20/0x30
> > Mar 27 15:18:07 s15 kernel: [92480.706431]  follow_page_pte+0x10c/0x650
> > Mar 27 15:18:07 s15 kernel: [92480.707233]  follow_page_mask+0x1ee/0x5b0
> > Mar 27 15:18:07 s15 kernel: [92480.708092]  ? find_vma+0x68/0x70
> > Mar 27 15:18:07 s15 kernel: [92480.708918]  ksm_scan_thread+0xc08/0x12a0
> > Mar 27 15:18:07 s15 kernel: [92480.709720]  ? wake_atomic_t_function+0x60/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.710557]  kthread+0x101/0x140
> > Mar 27 15:18:07 s15 kernel: [92480.711364]  ? try_to_merge_with_ksm_page+0xa0/0xa0
> > Mar 27 15:18:07 s15 kernel: [92480.712221]  ? kthread_create_on_node+0x60/0x60
> > Mar 27 15:18:07 s15 kernel: [92480.713038]  ret_from_fork+0x2c/0x40
> > 
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
