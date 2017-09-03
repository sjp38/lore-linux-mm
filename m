Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B42F16B025F
	for <linux-mm@kvack.org>; Sun,  3 Sep 2017 03:43:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r7so11093970pfj.5
        for <linux-mm@kvack.org>; Sun, 03 Sep 2017 00:43:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r8si3126416pgn.175.2017.09.03.00.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Sep 2017 00:43:08 -0700 (PDT)
Date: Sun, 3 Sep 2017 00:43:06 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Message-ID: <20170903074306.GA8351@infradead.org>
References: <CABXGCsOL+_OgC0dpO1+Zeg=iu7ryZRZT4S7k-io8EGB0ZRgZGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CABXGCsOL+_OgC0dpO1+Zeg=iu7ryZRZT4S7k-io8EGB0ZRgZGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Sun, Sep 03, 2017 at 09:22:17AM +0500, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> [281502.961248] ------------[ cut here ]------------
> [281502.961257] kernel BUG at fs/xfs/xfs_aops.c:853!

This is:

	bh = head = page_buffers(page);

Which looks odd and like some sort of VM/writeback change might
have triggered that we get a page without buffers, despite always
creating buffers in iomap_begin/end and page_mkwrite.

Ccing linux-mm if anything odd happen in that area recently.

Can you tell anything about the workload you are running?

> [281502.961263] invalid opcode: 0000 [#1] SMP
> [281502.961299] Modules linked in: xt_CHECKSUM ipt_MASQUERADE
> nf_nat_masquerade_ipv4 tun nls_utf8 isofs rfcomm fuse
> nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT ip6t_rpfilter
> ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat
> ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6
> nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw
> ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4
> nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw
> iptable_security ebtable_filter ebtables ip6table_filter ip6_tables
> bnep sunrpc vfat fat xfs libcrc32c snd_usb_audio snd_usbmidi_lib
> snd_rawmidi intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp
> kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul btrfs
> ghash_clmulni_intel intel_cstate iTCO_wdt iTCO_vendor_support
> [281502.961684]  ppdev intel_uncore xor intel_rapl_perf i2c_i801
> huawei_cdc_ncm option raid6_pq cdc_wdm joydev cdc_ncm btusb usb_wwan
> snd_hda_codec_hdmi snd_hda_codec_realtek btrtl btbcm
> snd_hda_codec_ca0132 btintel snd_hda_codec_generic bluetooth
> gspca_zc3xx gspca_main v4l2_common snd_hda_intel videodev cdc_ether
> snd_hda_codec usbnet media ecdh_generic snd_hda_core rfkill snd_hwdep
> snd_seq snd_seq_device snd_pcm snd_timer mei_me snd mei lpc_ich
> soundcore shpchp parport_pc parport tpm_infineon tpm_tis tpm_tis_core
> tpm binfmt_misc hid_logitech_hidpp hid_logitech_dj uas usb_storage
> i915 crc32c_intel i2c_algo_bit drm_kms_helper drm r8169 mii video bfq
> [281502.962014] CPU: 7 PID: 81 Comm: kswapd0 Not tainted
> 4.13.0-0.rc6.git4.1.fc28.x86_64 #1
> [281502.962052] Hardware name: Gigabyte Technology Co., Ltd.
> Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [281502.962094] task: ffff9f5b31acb300 task.stack: ffffabcd43e48000
> [281502.962161] RIP: 0010:xfs_do_writepage+0x735/0x830 [xfs]
> [281502.962188] RSP: 0018:ffffabcd43e4b988 EFLAGS: 00010246
> [281502.962216] RAX: 0000000000001000 RBX: ffffabcd43e4ba98 RCX:
> 000000000000000c
> [281502.962251] RDX: 0017ffffc0030009 RSI: ffffe8881f3cf900 RDI:
> 0000000000000246
> [281502.962287] RBP: ffffabcd43e4ba30 R08: ffffe8881f3cf900 R09:
> 0000000000000002
> [281502.962321] R10: ffffabcd43e4b9e0 R11: 0000000000000000 R12:
> ffff9f57fa7b6110
> [281502.962356] R13: ffffabcd43e4bc40 R14: ffffabcd43e4ba40 R15:
> ffffe8881f3cf920
> [281502.962392] FS:  0000000000000000(0000) GS:ffff9f5b5da00000(0000)
> knlGS:0000000000000000
> [281502.962430] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [281502.962458] CR2: 00007ff86cb39018 CR3: 0000000815e11000 CR4:
> 00000000001426e0
> [281502.962494] Call Trace:
> [281502.962515]  ? sched_clock+0x9/0x10
> [281502.962539]  ? clear_page_dirty_for_io+0x140/0x2b0
> [281502.962590]  xfs_vm_writepage+0x3b/0x70 [xfs]
> [281502.962618]  pageout.isra.54+0x103/0x420
> [281502.962646]  shrink_page_list+0x982/0xdf0
> [281502.962674]  shrink_inactive_list+0x225/0x630
> [281502.962704]  shrink_node_memcg+0x36c/0x770
> [281502.962734]  shrink_node+0xf7/0x2f0
> [281502.962753]  ? shrink_node+0xf7/0x2f0
> [281502.962779]  kswapd+0x325/0x990
> [281502.962804]  kthread+0x133/0x150
> [281502.962824]  ? mem_cgroup_shrink_node+0x330/0x330
> [281502.962849]  ? kthread_create_on_node+0x70/0x70
> [281502.962875]  ret_from_fork+0x2a/0x40
> [281502.962898] Code: ce 48 c7 00 00 00 00 00 48 c7 44 30 f8 00 00 00
> 00 48 83 e7 f8 48 29 f8 01 c1 89 c8 c1 e8 03 89 c1 31 c0 f3 48 ab e9
> 0f fe ff ff <0f> 0b e8 54 44 3a d9 85 c0 0f 85 44 fe ff ff 48 c7 c2 48
> a2 df
> [281502.963085] RIP: xfs_do_writepage+0x735/0x830 [xfs] RSP: ffffabcd43e4b988
> [281502.972614] ---[ end trace 1ba3042d56323a9c ]---
> 
> 
> Anybody can look what is culprit here?
> 
> 
> --
> Best Regards,
> Mike Gavrilov.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
