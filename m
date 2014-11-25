Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4862E6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 05:59:56 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so1003190wiw.3
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 02:59:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si2415239wiz.104.2014.11.25.02.59.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 02:59:54 -0800 (PST)
Date: Tue, 25 Nov 2014 11:59:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
Message-ID: <20141125105953.GC4607@dhcp22.suse.cz>
References: <CALYGNiM_CsjjiK_36JGirZT8rTP+ROYcH0CSyZjghtSNDU8ptw@mail.gmail.com>
 <546BDB29.9050403@suse.cz>
 <CALYGNiOHXvyqr3+Jq5FsZ_xscsXwrQ_9YCtL2819i6iRkgms2w@mail.gmail.com>
 <546CC0CD.40906@suse.cz>
 <CALYGNiO9_bAVVZ2GdFq=PO2yV3LPs2utsbcb2pFby7MypptLCw@mail.gmail.com>
 <CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com>
 <CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com>
 <546DFFA1.4030700@redhat.com>
 <CALYGNiP_zqAucmN=Gn75Mm2wK1iE6fPNxTsaTRgnUbFbFE7C-g@mail.gmail.com>
 <CALYGNiO9NSpCFcRezArgfqzLQcTx2DnFYWYgpyK2HFyCnuGLOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiO9NSpCFcRezArgfqzLQcTx2DnFYWYgpyK2HFyCnuGLOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>

On Mon 24-11-14 11:09:40, Konstantin Khlebnikov wrote:
> On Thu, Nov 20, 2014 at 6:03 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> > On Thu, Nov 20, 2014 at 5:50 PM, Rik van Riel <riel@redhat.com> wrote:
> >> -----BEGIN PGP SIGNED MESSAGE-----
> >> Hash: SHA1
> >>
> >> On 11/20/2014 09:42 AM, Konstantin Khlebnikov wrote:
> >>
> >>> I'm thinking about limitation for reusing anon_vmas which might
> >>> increase performance without breaking asymptotic estimation of
> >>> count anon_vma in the worst case. For example this heuristic: allow
> >>> to reuse only anon_vma with single direct descendant. It seems
> >>> there will be arount up to two times more anon_vmas but
> >>> false-aliasing must be much lower.
> 
> Done. RFC patch in attachment.

This is triggering BUG_ON(anon_vma->degree); in unlink_anon_vmas. I have
applied the patch on top of 3.18.0-rc6. 

[   12.380189] ------------[ cut here ]------------
[   12.380221] kernel BUG at mm/rmap.c:385!
[   12.380239] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   12.380272] Modules linked in: i915 cfbfillrect cfbimgblt i2c_algo_bit fbcon bitblit softcursor cfbcopyarea font drm_kms_helper drm fb fbdev binfmt_misc fuse uvcvideo videobuf2_vmalloc videobuf2_memops arc4 videobuf2_core v4l2_common sdhci_pci iwldvm videodev media mac80211 i2c_i801 i2c_core sdhci mmc_core iwlwifi cfg80211 snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm video backlight snd_timer snd
[   12.380518] CPU: 1 PID: 3704 Comm: kdm_greet Not tainted 3.18.0-rc6-test-00001-gf5bc00c103ff #409
[   12.380554] Hardware name: Dell Inc. Latitude E6320/09PHH9, BIOS A08 10/18/2011
[   12.380584] task: ffff8801272bc2c0 ti: ffff8800bcaf0000 task.ti: ffff8800bcaf0000
[   12.380614] RIP: 0010:[<ffffffff81125f09>]  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
[   12.380653] RSP: 0018:ffff8800bcaf3d28  EFLAGS: 00010286
[   12.380676] RAX: ffff8800bcb3e690 RBX: ffff8800bcb35e28 RCX: ffff8801272bcb60
[   12.380706] RDX: ffff8800bcb38e70 RSI: 0000000000000001 RDI: ffff8800bcb38e70
[   12.380734] RBP: ffff8800bcaf3d78 R08: 0000000000000000 R09: 0000000000000000
[   12.380764] R10: 0000000000000000 R11: ffff8800bcb3e6a0 R12: ffff8800bcb3e680
[   12.380793] R13: ffff8800bcb3e690 R14: ffff8800bcb38e70 R15: ffff8800bcb38e70
[   12.380822] FS:  0000000000000000(0000) GS:ffff88012d440000(0000) knlGS:0000000000000000
[   12.380855] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   12.380880] CR2: 00007fcd2603b0e8 CR3: 0000000001a11000 CR4: 00000000000407e0
[   12.380908] Stack:
[   12.380918]  ffff8801272e9dc0 ffff8800bcb35e38 ffff8800bcb35e38 ffff8800bcb3e680
[   12.380953]  ffff8800bcaf3d78 ffff8800bcb35dc0 ffff8800bcaf3dd8 0000000000000000
[   12.380989]  0000000000000000 ffff8800bcb35dc0 ffff8800bcaf3dc8 ffffffff81119e26
[   12.381024] Call Trace:
[   12.381038]  [<ffffffff81119e26>] free_pgtables+0x8e/0xcc
[   12.381062]  [<ffffffff81121ac1>] exit_mmap+0x84/0x123
[   12.381086]  [<ffffffff8103ff09>] mmput+0x5e/0xbb
[   12.381107]  [<ffffffff81044d8c>] do_exit+0x39c/0x97e
[   12.381131]  [<ffffffff810f49b4>] ? context_tracking_user_exit+0x79/0x116
[   12.381160]  [<ffffffff8127f43a>] ? __this_cpu_preempt_check+0x13/0x15
[   12.381188]  [<ffffffff810453f1>] do_group_exit+0x4c/0xc9
[   12.381212]  [<ffffffff81045482>] SyS_exit_group+0x14/0x14
[   12.381238]  [<ffffffff81524f52>] system_call_fastpath+0x12/0x17
[   12.381262] Code: 32 f5 ff 49 8b 45 78 48 8b 18 4c 8d 60 f0 48 83 eb 10 4d 8d 6c 24 10 4c 3b 6d b8 74 3d 49 8b 7c 24 08 83 bf 98 00 00 00 00 74 02 <0f> 0b f0 ff 8f 88 00 00 00 74 1d 4c 89 ef e8 61 96 15 00 4c 89 
[   12.381445] RIP  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
[   12.381473]  RSP <ffff8800bcaf3d28>
[   12.386659] ---[ end trace 5761ee18fca12427 ]---
[   12.386662] Fixing recursive fault but reboot is needed!
[   13.158240] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
[   13.259294] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
[   13.259468] IPv6: ADDRCONF(NETDEV_UP): lan0: link is not ready
[   16.790917] e1000e: lan0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
[   16.790957] IPv6: ADDRCONF(NETDEV_CHANGE): lan0: link becomes ready
[   18.846524] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[   18.846742] iwlwifi 0000:02:00.0: Radio type=0x0-0x3-0x1
[   18.941594] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   19.145595] e1000e: lan0 NIC Link is Down
[   19.287399] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
[   19.391325] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
[   19.391475] IPv6: ADDRCONF(NETDEV_UP): lan0: link is not ready
[   19.573640] e1000e: lan0 NIC Link is Down
[   19.717813] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
[   19.819729] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
[   19.819883] IPv6: ADDRCONF(NETDEV_UP): lan0: link is not ready
[   22.938849] e1000e: lan0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
[   22.938889] IPv6: ADDRCONF(NETDEV_CHANGE): lan0: link becomes ready
[   23.404027] ------------[ cut here ]------------
[   23.404056] kernel BUG at mm/rmap.c:385!
[   23.404074] invalid opcode: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
[   23.404107] Modules linked in: i915 cfbfillrect cfbimgblt i2c_algo_bit fbcon bitblit softcursor cfbcopyarea font drm_kms_helper drm fb fbdev binfmt_misc fuse uvcvideo videobuf2_vmalloc videobuf2_memops arc4 videobuf2_core v4l2_common sdhci_pci iwldvm videodev media mac80211 i2c_i801 i2c_core sdhci mmc_core iwlwifi cfg80211 snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm video backlight snd_timer snd
[   23.404353] CPU: 1 PID: 4506 Comm: synaptikscfg Tainted: G      D        3.18.0-rc6-test-00001-gf5bc00c103ff #409
[   23.404395] Hardware name: Dell Inc. Latitude E6320/09PHH9, BIOS A08 10/18/2011
[   23.404425] task: ffff8800a337c2c0 ti: ffff88009f4ec000 task.ti: ffff88009f4ec000
[   23.404455] RIP: 0010:[<ffffffff81125f09>]  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
[   23.404494] RSP: 0018:ffff88009f4efd28  EFLAGS: 00010282
[   23.405766] RAX: ffff88009f54d010 RBX: ffff88009f54c488 RCX: 0000000000000000
[   23.407062] RDX: ffff88009f5a3a50 RSI: 0000000000000001 RDI: ffff88009f5a3a50
[   23.408352] RBP: ffff88009f4efd78 R08: 0000000000000000 R09: 0000000000000000
[   23.409597] R10: 0000000000000000 R11: ffff88009f54d020 R12: ffff88009f54d000
[   23.410816] R13: ffff88009f54d010 R14: ffff88009f5a3a50 R15: ffff88009f5a3a50
[   23.411998] FS:  0000000000000000(0000) GS:ffff88012d440000(0000) knlGS:0000000000000000
[   23.413167] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   23.414320] CR2: 00007f7a855608f0 CR3: 00000000a328c000 CR4: 00000000000407e0
[   23.415471] Stack:
[   23.416603]  ffff8800a3390e00 ffff88009f54c498 ffff88009f54c498 ffff88009f54d000
[   23.417747]  ffff88009f4efd78 ffff88009f54c420 ffff88009f4efdd8 0000000000000000
[   23.418892]  0000000000000000 ffff88009f54c420 ffff88009f4efdc8 ffffffff81119e26
[   23.420027] Call Trace:
[   23.421153]  [<ffffffff81119e26>] free_pgtables+0x8e/0xcc
[   23.422273]  [<ffffffff81121ac1>] exit_mmap+0x84/0x123
[   23.423411]  [<ffffffff81044d48>] ? do_exit+0x358/0x97e
[   23.424537]  [<ffffffff8103ff09>] mmput+0x5e/0xbb
[   23.425665]  [<ffffffff81044d8c>] do_exit+0x39c/0x97e
[   23.426766]  [<ffffffff810f49b4>] ? context_tracking_user_exit+0x79/0x116
[   23.427866]  [<ffffffff8127f43a>] ? __this_cpu_preempt_check+0x13/0x15
[   23.428962]  [<ffffffff810453f1>] do_group_exit+0x4c/0xc9
[   23.430064]  [<ffffffff81045482>] SyS_exit_group+0x14/0x14
[   23.431162]  [<ffffffff81524f52>] system_call_fastpath+0x12/0x17
[   23.432262] Code: 32 f5 ff 49 8b 45 78 48 8b 18 4c 8d 60 f0 48 83 eb 10 4d 8d 6c 24 10 4c 3b 6d b8 74 3d 49 8b 7c 24 08 83 bf 98 00 00 00 00 74 02 <0f> 0b f0 ff 8f 88 00 00 00 74 1d 4c 89 ef e8 61 96 15 00 4c 89 
[   23.434722] RIP  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
[   23.435924]  RSP <ffff88009f4efd28>
[   23.441996] ---[ end trace 5761ee18fca12428 ]---
[   23.442001] Fixing recursive fault but reboot is needed!
[  838.179454] ------------[ cut here ]------------
[  838.180658] kernel BUG at mm/rmap.c:385!
[  838.181843] invalid opcode: 0000 [#3] PREEMPT SMP DEBUG_PAGEALLOC
[  838.183046] Modules linked in: i915 cfbfillrect cfbimgblt i2c_algo_bit fbcon bitblit softcursor cfbcopyarea font drm_kms_helper drm fb fbdev binfmt_misc fuse uvcvideo videobuf2_vmalloc videobuf2_memops arc4 videobuf2_core v4l2_common sdhci_pci iwldvm videodev media mac80211 i2c_i801 i2c_core sdhci mmc_core iwlwifi cfg80211 snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm video backlight snd_timer snd
[  838.186983] CPU: 1 PID: 6643 Comm: colord-sane Tainted: G      D        3.18.0-rc6-test-00001-gf5bc00c103ff #409
[  838.188240] Hardware name: Dell Inc. Latitude E6320/09PHH9, BIOS A08 10/18/2011
[  838.189503] task: ffff8800c4fd8000 ti: ffff880079c6c000 task.ti: ffff880079c6c000
[  838.190765] RIP: 0010:[<ffffffff81125f09>]  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
[  838.192045] RSP: 0018:ffff880079c6fb68  EFLAGS: 00010286
[  838.193324] RAX: ffff8800c5a70150 RBX: ffff8800a6fd5748 RCX: 0000000000000000
[  838.194616] RDX: ffff8800a5379840 RSI: 0000000000000001 RDI: ffff8800a5379840
[  838.195879] RBP: ffff880079c6fbb8 R08: 0000000000000000 R09: 0000000000000000
[  838.197100] R10: 0000000000000000 R11: ffff8800c5a70160 R12: ffff8800c5a70140
[  838.198289] R13: ffff8800c5a70150 R14: ffff8800a5379840 R15: ffff8800a5379840
[  838.199448] FS:  0000000000000000(0000) GS:ffff88012d440000(0000) knlGS:0000000000000000
[  838.200604] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  838.201753] CR2: 00007fdfd692cde8 CR3: 0000000079d0d000 CR4: 00000000000407e0
[  838.202902] Stack:
[  838.204029]  ffff88011e6fc540 ffff8800a6fd5758 ffff8800a6fd5758 ffff8800c5a70140
[  838.205180]  ffff880079c6fbb8 ffff8800a6fd56e0 ffff880079c6fc18 0000000000000000
[  838.206328]  0000000000000000 ffff8800a6fd56e0 ffff880079c6fc08 ffffffff81119e26
[  838.207477] Call Trace:
[  838.208614]  [<ffffffff81119e26>] free_pgtables+0x8e/0xcc
[  838.209762]  [<ffffffff81121ac1>] exit_mmap+0x84/0x123
[  838.210897]  [<ffffffff81044d48>] ? do_exit+0x358/0x97e
[  838.212020]  [<ffffffff8103ff09>] mmput+0x5e/0xbb
[  838.213132]  [<ffffffff81044d8c>] do_exit+0x39c/0x97e
[  838.214232]  [<ffffffff8104ea16>] ? get_signal+0xdb/0x68a
[  838.215324]  [<ffffffff8115de6d>] ? poll_select_copy_remaining+0xfe/0xfe
[  838.216420]  [<ffffffff810453f1>] do_group_exit+0x4c/0xc9
[  838.217521]  [<ffffffff8104ef82>] get_signal+0x647/0x68a
[  838.218612]  [<ffffffff810f48bd>] ? context_tracking_user_enter+0xdb/0x159
[  838.219705]  [<ffffffff8100228f>] do_signal+0x28/0x657
[  838.220796]  [<ffffffff810c1e10>] ? __acct_update_integrals+0xbf/0xd4
[  838.221894]  [<ffffffff81063e43>] ? preempt_count_sub+0xcd/0xdb
[  838.222998]  [<ffffffff8106972e>] ? vtime_account_user+0x88/0x95
[  838.224105]  [<ffffffff815243a3>] ? _raw_spin_unlock+0x32/0x47
[  838.225205]  [<ffffffff810f49b4>] ? context_tracking_user_exit+0x79/0x116
[  838.226308]  [<ffffffff810f49b4>] ? context_tracking_user_exit+0x79/0x116
[  838.227401]  [<ffffffff810028fd>] do_notify_resume+0x3f/0x94
[  838.228495]  [<ffffffff81525218>] int_signal+0x12/0x17
[  838.229581] Code: 32 f5 ff 49 8b 45 78 48 8b 18 4c 8d 60 f0 48 83 eb 10 4d 8d 6c 24 10 4c 3b 6d b8 74 3d 49 8b 7c 24 08 83 bf 98 00 00 00 00 74 02 <0f> 0b f0 ff 8f 88 00 00 00 74 1d 4c 89 ef e8 61 96 15 00 4c 89 
[  838.231909] RIP  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
[  838.233003]  RSP <ffff880079c6fb68>
[  838.234248] ---[ end trace 5761ee18fca12429 ]---
[  838.234251] Fixing recursive fault but reboot is needed!
[ 1806.784267] ------------[ cut here ]------------
[ 1806.785322] kernel BUG at mm/rmap.c:385!
[ 1806.786361] invalid opcode: 0000 [#4] PREEMPT SMP DEBUG_PAGEALLOC
[ 1806.787397] Modules linked in: i915 cfbfillrect cfbimgblt i2c_algo_bit fbcon bitblit softcursor cfbcopyarea font drm_kms_helper drm fb fbdev binfmt_misc fuse uvcvideo videobuf2_vmalloc videobuf2_memops arc4 videobuf2_core v4l2_common sdhci_pci iwldvm videodev media mac80211 i2c_i801 i2c_core sdhci mmc_core iwlwifi cfg80211 snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm video backlight snd_timer snd
[ 1806.790682] CPU: 1 PID: 8135 Comm: DNS Resolver #7 Tainted: G      D        3.18.0-rc6-test-00001-gf5bc00c103ff #409
[ 1806.791728] Hardware name: Dell Inc. Latitude E6320/09PHH9, BIOS A08 10/18/2011
[ 1806.792779] task: ffff8800b3d40000 ti: ffff880079e34000 task.ti: ffff880079e34000
[ 1806.793816] RIP: 0010:[<ffffffff81125f09>]  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
[ 1806.794863] RSP: 0018:ffff880079e37d38  EFLAGS: 00010282
[ 1806.795894] RAX: ffff8800b508d790 RBX: ffff8800bcaa4e28 RCX: 0000000000000000
[ 1806.796948] RDX: ffff880124ce0f20 RSI: 0000000000000001 RDI: ffff880124ce0f20
[ 1806.798011] RBP: ffff880079e37d88 R08: 0000000000000000 R09: 0000000000000000
[ 1806.799048] R10: 00007fc2827f9db0 R11: ffff8800b508d7a0 R12: ffff8800b508d780
[ 1806.800105] R13: ffff8800b508d790 R14: ffff880124ce0f20 R15: ffff880124ce0f20
[ 1806.801143] FS:  00007fc2827fa700(0000) GS:ffff88012d440000(0000) knlGS:0000000000000000
[ 1806.802206] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1806.803244] CR2: 00007fc2c6b87000 CR3: 00000000a3063000 CR4: 00000000000407e0
[ 1806.804305] Stack:
[ 1806.805329]  00007fc280754000 ffff8800bcaa4e38 ffff8800bcaa4e38 ffff8800b508d780
[ 1806.806382]  0000000081098bfb ffff8800bcaa4dc0 ffff880079e37df8 00007fc27ff00000
[ 1806.807467]  00007fc280a00000 ffff8800bcaa4dc0 ffff880079e37dd8 ffffffff81119e26
[ 1806.808536] Call Trace:
[ 1806.809570]  [<ffffffff81119e26>] free_pgtables+0x8e/0xcc
[ 1806.810617]  [<ffffffff8111fe4c>] unmap_region+0xc8/0xec
[ 1806.811658]  [<ffffffff81270329>] ? __rb_erase_color+0x122/0x1f9
[ 1806.812724]  [<ffffffff8112192b>] do_munmap+0x275/0x2f7
[ 1806.813792]  [<ffffffff811219f5>] vm_munmap+0x48/0x61
[ 1806.814841]  [<ffffffff81121a34>] SyS_munmap+0x26/0x2f
[ 1806.815884]  [<ffffffff81524f52>] system_call_fastpath+0x12/0x17
[ 1806.816951] Code: 32 f5 ff 49 8b 45 78 48 8b 18 4c 8d 60 f0 48 83 eb 10 4d 8d 6c 24 10 4c 3b 6d b8 74 3d 49 8b 7c 24 08 83 bf 98 00 00 00 00 74 02 <0f> 0b f0 ff 8f 88 00 00 00 74 1d 4c 89 ef e8 61 96 15 00 4c 89 
[ 1806.819300] RIP  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
[ 1806.820457]  RSP <ffff880079e37d38>
[ 1806.822068] ---[ end trace 5761ee18fca1242a ]---
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
