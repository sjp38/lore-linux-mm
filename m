Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 467A36B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 04:41:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b80so740373wme.1
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 01:41:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r71si3759311wmb.13.2016.10.04.01.41.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Oct 2016 01:41:37 -0700 (PDT)
Date: Tue, 4 Oct 2016 10:41:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Frequent ext4 oopses with 4.4.0 on Intel NUC6i3SYB
Message-ID: <20161004084136.GD17515@quack2.suse.cz>
References: <fcb653b9-cd9e-5cec-1036-4b4c9e1d3e7b@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fcb653b9-cd9e-5cec-1036-4b4c9e1d3e7b@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Bauer <dfnsonfsduifb@gmx.de>
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org

Hi!

On Mon 03-10-16 12:52:20, Johannes Bauer wrote:
> I have recently bought an Intel NUC6i3SYB. That's essentially a small
> form-factor x86_64 PC. That device runs Linux Mint. Unfortunately I see
> frequent kernel oopses within the ext4 subsystem and consequently loss
> of data, corrupted files and complete system crashes. Here's a recent
> call trace:

The problem looks like memory corruption:

> [ 3405.666456] general protection fault: 0000 [#1] SMP
<snip>
> [ 3405.667929] CPU: 3 PID: 2261 Comm: hexchat Not tainted
> 4.4.0-21-generic #37-Ubuntu
> [ 3405.667998] Hardware name:                  /NUC6i3SYB, BIOS
> SYSKLi35.86A.0042.2016.0409.1246 04/09/2016
> [ 3405.668082] task: ffff88003565ac40 ti: ffff8804332e8000 task.ti:
> ffff8804332e8000
> [ 3405.668148] RIP: 0010:[<ffffffff811eb027>]  [<ffffffff811eb027>]
> kmem_cache_alloc+0x77/0x1f0

So we crash in kmem_cache_alloc(), looking at the disassebly at:

mov    (%r9,%rax,1),%rbx

Now look at register contents:

> [ 3405.668234] RSP: 0018:ffff8804332eba88  EFLAGS: 00010282
> [ 3405.668282] RAX: 0000000000000000 RBX: 0000000002408040 RCX:
> 00000000000e1547
> [ 3405.668345] RDX: 00000000000e1546 RSI: 0000000002408040 RDI:
> 000000000001a940
> [ 3405.668408] RBP: ffff8804332ebab8 R08: ffff88046ed9a940 R09:
> ffdb88033bb3a3a8

So %rax is 0, %r9 is ffdb88033bb3a3a8 - that's a problem because this is
not a valid kernel pointer. Well, actually it is but it points somewhere to
a vmalloc area and that particular place is apparently unmapped. I don't
think anything in that path should be doing anything with vmalloc so I'd
rather think that something corrupted the pointer. Hum, and looking into
the oops you pasted below, there %r9 is ddff88007f5aff08 - that's
definitely a corrupted pointer.

Anyway, adding linux-mm to CC since this does not look ext4 related but
rather mm related issue.

Bugs like these are always hard to catch, usually it's some flaky device
driver, sometimes also flaky HW. You can try running kernel with various
debug options enabled in a hope to catch the code corrupting memory
earlier - e.g. CONFIG_DEBUG_PAGE_ALLOC sometimes catches something,
CONFIG_SLAB_DEBUG can be useful as well. Another option is to get a
crashdump when the oops happens (although that's going to be a pain to
setup on such a small machine) and then look at which places point to
the corrupted memory - sometimes you can find old structures pointing to
the place and find the use-after-free issue or stuff like that...

								Honza

> [ 3405.668470] R10: ffff8804591a4ed0 R11: ffffffff81ccc462 R12:
> 0000000002408040
> [ 3405.668533] R13: ffffffff81243351 R14: ffff88045e08bc00 R15:
> ffff88045e08bc00
> [ 3405.668597] FS:  00007f1df9704a40(0000) GS:ffff88046ed80000(0000)
> knlGS:0000000000000000
> [ 3405.668668] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3405.668719] CR2: 00007fd945ecebd6 CR3: 0000000456a48000 CR4:
> 00000000003406e0
> [ 3405.668782] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [ 3405.668844] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
> 0000000000000400
> [ 3405.668906] Stack:
> [ 3405.668926]  01ff880438ee2508 0000000000001000 ffff8803344df000
> ffffea000cd137c0
> [ 3405.669003]  0000000000000000 0000000000000000 ffff8804332ebad0
> ffffffff81243351
> [ 3405.669080]  ffff8800354bd024 ffff8804332ebb18 ffffffff81243829
> 00000001332ebb70
> [ 3405.669156] Call Trace:
> [ 3405.669186]  [<ffffffff81243351>] alloc_buffer_head+0x21/0x60
> [ 3405.669240]  [<ffffffff81243829>] alloc_page_buffers+0x79/0xe0
> [ 3405.669294]  [<ffffffff812438ae>] create_empty_buffers+0x1e/0xc0
> [ 3405.669351]  [<ffffffff812979cc>] ext4_block_write_begin+0x3cc/0x4d0
> [ 3405.669410]  [<ffffffff812e74db>] ? jbd2__journal_start+0xdb/0x1e0
> [ 3405.669469]  [<ffffffff81296e10>] ?
> ext4_inode_attach_jinode.part.60+0xb0/0xb0
> [ 3405.669536]  [<ffffffff812cb83d>] ? __ext4_journal_start_sb+0x6d/0x120
> [ 3405.669596]  [<ffffffff8129d574>] ext4_da_write_begin+0x154/0x320
> [ 3405.669656]  [<ffffffff8118d4de>] generic_perform_write+0xce/0x1c0
> [ 3405.669713]  [<ffffffff8118f382>] __generic_file_write_iter+0x1a2/0x1e0
> [ 3405.669773]  [<ffffffff81291ffc>] ext4_file_write_iter+0xfc/0x460
> [ 3405.669833]  [<ffffffff81794d6e>] ? inet_recvmsg+0x7e/0xb0
> [ 3405.669885]  [<ffffffff816fdb6b>] ? sock_recvmsg+0x3b/0x50
> [ 3405.669938]  [<ffffffff8120bedb>] new_sync_write+0x9b/0xe0
> [ 3405.669990]  [<ffffffff8120bf46>] __vfs_write+0x26/0x40
> [ 3405.670040]  [<ffffffff8120c8c9>] vfs_write+0xa9/0x1a0
> [ 3405.672397]  [<ffffffff8120c776>] ? vfs_read+0x86/0x130
> [ 3405.674693]  [<ffffffff8120d585>] SyS_write+0x55/0xc0
> [ 3405.676925]  [<ffffffff818244f2>] entry_SYSCALL_64_fastpath+0x16/0x71
> [ 3405.679111] Code: 08 65 4c 03 05 83 f1 e1 7e 49 83 78 10 00 4d 8b 08
> 0f 84 29 01 00 00 4d 85 c9 0f 84 20 01 00 00 49 63 47 20 48 8d 4a 01 49
> 8b 3f <49> 8b 1c 01 4c 89 c8 65 48 0f c7 0f 0f 94 c0 84 c0 74 bb 49 63
> [ 3405.683725] RIP  [<ffffffff811eb027>] kmem_cache_alloc+0x77/0x1f0
> [ 3405.685876]  RSP <ffff8804332eba88>
> [ 3405.696001] ---[ end trace 4968a9119e168c92 ]---
> 
> After this occurs, the system becomes extremely unstable, i.e., the
> filesystem cannot be read properly anymore (e.g., ssh logins usually do
> not work anymore, most binaries just segfault). After a reboot (which
> has to be done manually, "shutdown -r now" also segfaults) it works fine
> again (until the problem comes back).
> 
> Since the hardware is fairly new, I cannot exclude a hardware defect as
> of now. I've thouroughly tested the RAM though and not found any defect
> there (ran MemTest86+ for 24 hours). One curious thing is that someone
> else seems to have run into this before. Searching for the symbols in
> the stackframe I came upon this:
> 
> http://pastebin.com/BJbu35H4
> 
> Which, quoting in full:
> 
> Jul 16 14:28:29 nuc kernel: [  370.642612] general protection fault:
> 0000 [#1] SMP
> Jul 16 14:28:29 nuc kernel: [  370.642657] Modules linked in: arc4
> intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel
> iwlmvm kvm mac80211 irqbypass crct10dif_pclmul crc32_pclmul iwlwifi
> aesni_intel aes_x86_64 snd_hda_codec_hdmi btusb btrtl
> snd_hda_codec_realtek btbcm btintel lrw gf128mul snd_hda_codec_generic
> ir_xmp_decoder glue_helper ablk_helper ir_lirc_codec cryptd mei_me
> lirc_dev ir_mce_kbd_decoder ir_sharp_decoder ir_sanyo_decoder bluetooth
> cfg80211 snd_hda_intel ir_sony_decoder mei ir_jvc_decoder ir_rc6_decoder
> ir_rc5_decoder ir_nec_decoder lpc_ich snd_hda_codec shpchp
> snd_soc_rt5640 snd_hda_core snd_soc_rl6231 snd_hwdep snd_soc_core
> snd_compress ac97_bus snd_pcm_dmaengine rc_rc6_mce dw_dmac snd_pcm
> nuvoton_cir rc_core snd_timer dw_dmac_core snd elan_i2c soundcore
> snd_soc_sst_acpi spi_pxa2xx_platform i2c_designware_platform
> i2c_designware_core 8250_dw mac_hid ip6t_REJECT nf_reject_ipv6
> nf_log_ipv6 xt_hl ip6t_rt nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT
> nf_reject_ipv4 xt_comment nf_log_ipv4 nf_log_common xt_LOG xt_multiport
> xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4
> xt_conntrack ip6table_filter ip6_tables nf_conntrack_netbios_ns
> nf_conntrack_broadcast nf_nat_ftp nf_nat sunrpc nf_conntrack_ftp
> nf_conntrack iptable_filter ip_tables x_tables autofs4 btrfs xor
> raid6_pq i915 i2c_algo_bit drm_kms_helper e1000e syscopyarea sysfillrect
> sysimgblt uas fb_sys_fops ptp ahci sdhci_acpi usb_storage libahci drm
> pps_core video i2c_hid sdhci hid fjes
> Jul 16 14:28:29 nuc kernel: [  370.643778] CPU: 3 PID: 1505 Comm: dd Not
> tainted 4.4.0-31-generic #50-Ubuntu
> Jul 16 14:28:29 nuc kernel: [  370.643822] Hardware name:
>   /D54250WYK, BIOS WYLPT10H.86A.0041.2015.0720.1108 07/20/2015
> Jul 16 14:28:29 nuc kernel: [  370.643878] task: ffff88040aa90000 ti:
> ffff880407b98000 task.ti: ffff880407b98000
> Jul 16 14:28:29 nuc kernel: [  370.643923] RIP:
> 0010:[<ffffffff811eb987>]  [<ffffffff811eb987>] kmem_cache_alloc+0x77/0x1f0
> Jul 16 14:28:29 nuc kernel: [  370.643982] RSP: 0018:ffff880407b9ba80
> EFLAGS: 00010282
> Jul 16 14:28:29 nuc kernel: [  370.644015] RAX: 0000000000000000 RBX:
> 0000000002408040 RCX: 00000000000bb283
> Jul 16 14:28:29 nuc kernel: [  370.644054] RDX: 00000000000bb282 RSI:
> 0000000002408040 RDI: 000000000001a940
> Jul 16 14:28:29 nuc kernel: [  370.644076] RBP: ffff880407b9bab0 R08:
> ffff88041fb9a940 R09: ddff88007f5aff08
> Jul 16 14:28:29 nuc kernel: [  370.644097] R10: ffff8800d522d060 R11:
> ffffffff81ccf1ea R12: 0000000002408040
> Jul 16 14:28:29 nuc kernel: [  370.644119] R13: ffffffff81243ea1 R14:
> ffff88040f08bc00 R15: ffff88040f08bc00
> Jul 16 14:28:29 nuc kernel: [  370.644141] FS:  00007fa227587700(0000)
> GS:ffff88041fb80000(0000) knlGS:0000000000000000
> Jul 16 14:28:29 nuc kernel: [  370.644165] CS:  0010 DS: 0000 ES: 0000
> CR0: 0000000080050033
> Jul 16 14:28:29 nuc kernel: [  370.644183] CR2: 0000000000a08000 CR3:
> 000000040aaac000 CR4: 00000000001406e0
> Jul 16 14:28:29 nuc kernel: [  370.644205] Stack:
> Jul 16 14:28:29 nuc kernel: [  370.644213]  01ff8803fef10a00
> 0000000000001000 ffff88007b89f000 ffffea0001ee27c0
> Jul 16 14:28:29 nuc kernel: [  370.644241]  0000000000000000
> 0000000000000000 ffff880407b9bac8 ffffffff81243ea1
> Jul 16 14:28:29 nuc kernel: [  370.644270]  ffff8804099b8024
> ffff880407b9bb10 ffffffff81244379 0000000107b9bb68
> Jul 16 14:28:29 nuc kernel: [  370.644298] Call Trace:
> Jul 16 14:28:29 nuc kernel: [  370.644311]  [<ffffffff81243ea1>]
> alloc_buffer_head+0x21/0x60
> Jul 16 14:28:29 nuc kernel: [  370.644329]  [<ffffffff81244379>]
> alloc_page_buffers+0x79/0xe0
> Jul 16 14:28:29 nuc kernel: [  370.644349]  [<ffffffff812443fe>]
> create_empty_buffers+0x1e/0xc0
> Jul 16 14:28:29 nuc kernel: [  370.644369]  [<ffffffff812987fc>]
> ext4_block_write_begin+0x3cc/0x4e0
> Jul 16 14:28:29 nuc kernel: [  370.644390]  [<ffffffff812e8afb>] ?
> jbd2__journal_start+0xdb/0x1e0
> Jul 16 14:28:29 nuc kernel: [  370.644410]  [<ffffffff81297c40>] ?
> ext4_inode_attach_jinode.part.60+0xb0/0xb0
> Jul 16 14:28:29 nuc kernel: [  370.644434]  [<ffffffff812ccc2d>] ?
> __ext4_journal_start_sb+0x6d/0x120
> Jul 16 14:28:29 nuc kernel: [  370.644456]  [<ffffffff8129e61d>]
> ext4_da_write_begin+0x15d/0x340
> Jul 16 14:28:29 nuc kernel: [  370.644477]  [<ffffffff8118db4e>]
> generic_perform_write+0xce/0x1c0
> Jul 16 14:28:29 nuc kernel: [  370.644498]  [<ffffffff8118f9f2>]
> __generic_file_write_iter+0x1a2/0x1e0
> Jul 16 14:28:29 nuc kernel: [  370.644518]  [<ffffffff81292d72>]
> ext4_file_write_iter+0x102/0x470
> Jul 16 14:28:29 nuc kernel: [  370.644540]  [<ffffffff81403f37>] ?
> iov_iter_zero+0x67/0x200
> Jul 16 14:28:29 nuc kernel: [  370.644560]  [<ffffffff8120c94b>]
> new_sync_write+0x9b/0xe0
> Jul 16 14:28:29 nuc kernel: [  370.644578]  [<ffffffff8120c9b6>]
> __vfs_write+0x26/0x40
> Jul 16 14:28:29 nuc kernel: [  370.645377]  [<ffffffff8120d339>]
> vfs_write+0xa9/0x1a0
> Jul 16 14:28:29 nuc kernel: [  370.646174]  [<ffffffff8120d274>] ?
> vfs_read+0x114/0x130
> Jul 16 14:28:29 nuc kernel: [  370.646973]  [<ffffffff8120dff5>]
> SyS_write+0x55/0xc0
> Jul 16 14:28:29 nuc kernel: [  370.647766]  [<ffffffff8182db32>]
> entry_SYSCALL_64_fastpath+0x16/0x71
> Jul 16 14:28:29 nuc kernel: [  370.648547] Code: 08 65 4c 03 05 23 e8 e1
> 7e 49 83 78 10 00 4d 8b 08 0f 84 29 01 00 00 4d 85 c9 0f 84 20 01 00 00
> 49 63 47 20 48 8d 4a 01 49 8b 3f <49> 8b 1c 01 4c 89 c8 65 48 0f c7 0f
> 0f 94 c0 84 c0 74 bb 49 63
> Jul 16 14:28:29 nuc kernel: [  370.650215] RIP  [<ffffffff811eb987>]
> kmem_cache_alloc+0x77/0x1f0
> Jul 16 14:28:29 nuc kernel: [  370.650985]  RSP <ffff880407b9ba80>
> Jul 16 14:28:29 nuc kernel: [  370.651755] ---[ end trace
> 639091250fabe2af ]---
> 
> Shows also a stacktrace with the same call path, also running on a
> (different) Intel NUC, also running a 4.4.0 kernel. This pastebin is
> nowhere referenced however, so I'm unsure who found it and where exactly
> it was posted. Since the offending process in the unknown guy or girl's
> pastebin was dd, however, I believe that he or she tried to deliberately
> reproduce the problem.
> 
> The problem occurs only when the system is under heavy disk load for me
> (usually after an hour of activity). I've a process running which
> frequently does sqlite3 commits about every 10 seconds. Having it run
> overnight with almost no load led to no oooops.
> 
> Any and all advice is greatly appreciated.
> Cheers,
> Johannes
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
