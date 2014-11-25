Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id B289F6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 07:13:18 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id pv20so407704lab.9
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:13:18 -0800 (PST)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id pq5si1561349wjc.165.2014.11.25.04.13.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 04:13:17 -0800 (PST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so8893766wib.10
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:13:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141125105953.GC4607@dhcp22.suse.cz>
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
	<20141125105953.GC4607@dhcp22.suse.cz>
Date: Tue, 25 Nov 2014 16:13:16 +0400
Message-ID: <CALYGNiPZmf4Y1_vX_FaiALKp-BPvct7fAiaPEjnDGnVx9paS9w@mail.gmail.com>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: multipart/mixed; boundary=089e0163503c0399e80508add695
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>

--089e0163503c0399e80508add695
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 25, 2014 at 1:59 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 24-11-14 11:09:40, Konstantin Khlebnikov wrote:
>> On Thu, Nov 20, 2014 at 6:03 PM, Konstantin Khlebnikov <koct9i@gmail.com=
> wrote:
>> > On Thu, Nov 20, 2014 at 5:50 PM, Rik van Riel <riel@redhat.com> wrote:
>> >> -----BEGIN PGP SIGNED MESSAGE-----
>> >> Hash: SHA1
>> >>
>> >> On 11/20/2014 09:42 AM, Konstantin Khlebnikov wrote:
>> >>
>> >>> I'm thinking about limitation for reusing anon_vmas which might
>> >>> increase performance without breaking asymptotic estimation of
>> >>> count anon_vma in the worst case. For example this heuristic: allow
>> >>> to reuse only anon_vma with single direct descendant. It seems
>> >>> there will be arount up to two times more anon_vmas but
>> >>> false-aliasing must be much lower.
>>
>> Done. RFC patch in attachment.
>
> This is triggering BUG_ON(anon_vma->degree); in unlink_anon_vmas. I have
> applied the patch on top of 3.18.0-rc6.

It seems I've screwed up with counter if anon_vma is merged in anon_vma_pre=
pare.
Increment must be in the next if block:

--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -182,8 +182,6 @@ int anon_vma_prepare(struct vm_area_struct *vma)
                        if (unlikely(!anon_vma))
                                goto out_enomem_free_avc;
                        allocated =3D anon_vma;
-                       /* Bump degree, root anon_vma is its own parent. */
-                       anon_vma->degree++;
                }

                anon_vma_lock_write(anon_vma);
@@ -192,6 +190,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
                if (likely(!vma->anon_vma)) {
                        vma->anon_vma =3D anon_vma;
                        anon_vma_chain_link(vma, avc, anon_vma);
+                       anon_vma->degree++;
                        allocated =3D NULL;
                        avc =3D NULL;
                }

I've tested it with trinity but probably isn't long enough.

>
> [   12.380189] ------------[ cut here ]------------
> [   12.380221] kernel BUG at mm/rmap.c:385!
> [   12.380239] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [   12.380272] Modules linked in: i915 cfbfillrect cfbimgblt i2c_algo_bit=
 fbcon bitblit softcursor cfbcopyarea font drm_kms_helper drm fb fbdev binf=
mt_misc fuse uvcvideo videobuf2_vmalloc videobuf2_memops arc4 videobuf2_cor=
e v4l2_common sdhci_pci iwldvm videodev media mac80211 i2c_i801 i2c_core sd=
hci mmc_core iwlwifi cfg80211 snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_=
codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_pcm_oss sn=
d_mixer_oss snd_pcm video backlight snd_timer snd
> [   12.380518] CPU: 1 PID: 3704 Comm: kdm_greet Not tainted 3.18.0-rc6-te=
st-00001-gf5bc00c103ff #409
> [   12.380554] Hardware name: Dell Inc. Latitude E6320/09PHH9, BIOS A08 1=
0/18/2011
> [   12.380584] task: ffff8801272bc2c0 ti: ffff8800bcaf0000 task.ti: ffff8=
800bcaf0000
> [   12.380614] RIP: 0010:[<ffffffff81125f09>]  [<ffffffff81125f09>] unlin=
k_anon_vmas+0x12b/0x169
> [   12.380653] RSP: 0018:ffff8800bcaf3d28  EFLAGS: 00010286
> [   12.380676] RAX: ffff8800bcb3e690 RBX: ffff8800bcb35e28 RCX: ffff88012=
72bcb60
> [   12.380706] RDX: ffff8800bcb38e70 RSI: 0000000000000001 RDI: ffff8800b=
cb38e70
> [   12.380734] RBP: ffff8800bcaf3d78 R08: 0000000000000000 R09: 000000000=
0000000
> [   12.380764] R10: 0000000000000000 R11: ffff8800bcb3e6a0 R12: ffff8800b=
cb3e680
> [   12.380793] R13: ffff8800bcb3e690 R14: ffff8800bcb38e70 R15: ffff8800b=
cb38e70
> [   12.380822] FS:  0000000000000000(0000) GS:ffff88012d440000(0000) knlG=
S:0000000000000000
> [   12.380855] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   12.380880] CR2: 00007fcd2603b0e8 CR3: 0000000001a11000 CR4: 000000000=
00407e0
> [   12.380908] Stack:
> [   12.380918]  ffff8801272e9dc0 ffff8800bcb35e38 ffff8800bcb35e38 ffff88=
00bcb3e680
> [   12.380953]  ffff8800bcaf3d78 ffff8800bcb35dc0 ffff8800bcaf3dd8 000000=
0000000000
> [   12.380989]  0000000000000000 ffff8800bcb35dc0 ffff8800bcaf3dc8 ffffff=
ff81119e26
> [   12.381024] Call Trace:
> [   12.381038]  [<ffffffff81119e26>] free_pgtables+0x8e/0xcc
> [   12.381062]  [<ffffffff81121ac1>] exit_mmap+0x84/0x123
> [   12.381086]  [<ffffffff8103ff09>] mmput+0x5e/0xbb
> [   12.381107]  [<ffffffff81044d8c>] do_exit+0x39c/0x97e
> [   12.381131]  [<ffffffff810f49b4>] ? context_tracking_user_exit+0x79/0x=
116
> [   12.381160]  [<ffffffff8127f43a>] ? __this_cpu_preempt_check+0x13/0x15
> [   12.381188]  [<ffffffff810453f1>] do_group_exit+0x4c/0xc9
> [   12.381212]  [<ffffffff81045482>] SyS_exit_group+0x14/0x14
> [   12.381238]  [<ffffffff81524f52>] system_call_fastpath+0x12/0x17
> [   12.381262] Code: 32 f5 ff 49 8b 45 78 48 8b 18 4c 8d 60 f0 48 83 eb 1=
0 4d 8d 6c 24 10 4c 3b 6d b8 74 3d 49 8b 7c 24 08 83 bf 98 00 00 00 00 74 0=
2 <0f> 0b f0 ff 8f 88 00 00 00 74 1d 4c 89 ef e8 61 96 15 00 4c 89
> [   12.381445] RIP  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
> [   12.381473]  RSP <ffff8800bcaf3d28>
> [   12.386659] ---[ end trace 5761ee18fca12427 ]---
> [   12.386662] Fixing recursive fault but reboot is needed!
> [   13.158240] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
> [   13.259294] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
> [   13.259468] IPv6: ADDRCONF(NETDEV_UP): lan0: link is not ready
> [   16.790917] e1000e: lan0 NIC Link is Up 1000 Mbps Full Duplex, Flow Co=
ntrol: Rx/Tx
> [   16.790957] IPv6: ADDRCONF(NETDEV_CHANGE): lan0: link becomes ready
> [   18.846524] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
> [   18.846742] iwlwifi 0000:02:00.0: Radio type=3D0x0-0x3-0x1
> [   18.941594] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
> [   19.145595] e1000e: lan0 NIC Link is Down
> [   19.287399] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
> [   19.391325] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
> [   19.391475] IPv6: ADDRCONF(NETDEV_UP): lan0: link is not ready
> [   19.573640] e1000e: lan0 NIC Link is Down
> [   19.717813] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
> [   19.819729] e1000e 0000:00:19.0: irq 25 for MSI/MSI-X
> [   19.819883] IPv6: ADDRCONF(NETDEV_UP): lan0: link is not ready
> [   22.938849] e1000e: lan0 NIC Link is Up 1000 Mbps Full Duplex, Flow Co=
ntrol: Rx/Tx
> [   22.938889] IPv6: ADDRCONF(NETDEV_CHANGE): lan0: link becomes ready
> [   23.404027] ------------[ cut here ]------------
> [   23.404056] kernel BUG at mm/rmap.c:385!
> [   23.404074] invalid opcode: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
> [   23.404107] Modules linked in: i915 cfbfillrect cfbimgblt i2c_algo_bit=
 fbcon bitblit softcursor cfbcopyarea font drm_kms_helper drm fb fbdev binf=
mt_misc fuse uvcvideo videobuf2_vmalloc videobuf2_memops arc4 videobuf2_cor=
e v4l2_common sdhci_pci iwldvm videodev media mac80211 i2c_i801 i2c_core sd=
hci mmc_core iwlwifi cfg80211 snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_=
codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_pcm_oss sn=
d_mixer_oss snd_pcm video backlight snd_timer snd
> [   23.404353] CPU: 1 PID: 4506 Comm: synaptikscfg Tainted: G      D     =
   3.18.0-rc6-test-00001-gf5bc00c103ff #409
> [   23.404395] Hardware name: Dell Inc. Latitude E6320/09PHH9, BIOS A08 1=
0/18/2011
> [   23.404425] task: ffff8800a337c2c0 ti: ffff88009f4ec000 task.ti: ffff8=
8009f4ec000
> [   23.404455] RIP: 0010:[<ffffffff81125f09>]  [<ffffffff81125f09>] unlin=
k_anon_vmas+0x12b/0x169
> [   23.404494] RSP: 0018:ffff88009f4efd28  EFLAGS: 00010282
> [   23.405766] RAX: ffff88009f54d010 RBX: ffff88009f54c488 RCX: 000000000=
0000000
> [   23.407062] RDX: ffff88009f5a3a50 RSI: 0000000000000001 RDI: ffff88009=
f5a3a50
> [   23.408352] RBP: ffff88009f4efd78 R08: 0000000000000000 R09: 000000000=
0000000
> [   23.409597] R10: 0000000000000000 R11: ffff88009f54d020 R12: ffff88009=
f54d000
> [   23.410816] R13: ffff88009f54d010 R14: ffff88009f5a3a50 R15: ffff88009=
f5a3a50
> [   23.411998] FS:  0000000000000000(0000) GS:ffff88012d440000(0000) knlG=
S:0000000000000000
> [   23.413167] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   23.414320] CR2: 00007f7a855608f0 CR3: 00000000a328c000 CR4: 000000000=
00407e0
> [   23.415471] Stack:
> [   23.416603]  ffff8800a3390e00 ffff88009f54c498 ffff88009f54c498 ffff88=
009f54d000
> [   23.417747]  ffff88009f4efd78 ffff88009f54c420 ffff88009f4efdd8 000000=
0000000000
> [   23.418892]  0000000000000000 ffff88009f54c420 ffff88009f4efdc8 ffffff=
ff81119e26
> [   23.420027] Call Trace:
> [   23.421153]  [<ffffffff81119e26>] free_pgtables+0x8e/0xcc
> [   23.422273]  [<ffffffff81121ac1>] exit_mmap+0x84/0x123
> [   23.423411]  [<ffffffff81044d48>] ? do_exit+0x358/0x97e
> [   23.424537]  [<ffffffff8103ff09>] mmput+0x5e/0xbb
> [   23.425665]  [<ffffffff81044d8c>] do_exit+0x39c/0x97e
> [   23.426766]  [<ffffffff810f49b4>] ? context_tracking_user_exit+0x79/0x=
116
> [   23.427866]  [<ffffffff8127f43a>] ? __this_cpu_preempt_check+0x13/0x15
> [   23.428962]  [<ffffffff810453f1>] do_group_exit+0x4c/0xc9
> [   23.430064]  [<ffffffff81045482>] SyS_exit_group+0x14/0x14
> [   23.431162]  [<ffffffff81524f52>] system_call_fastpath+0x12/0x17
> [   23.432262] Code: 32 f5 ff 49 8b 45 78 48 8b 18 4c 8d 60 f0 48 83 eb 1=
0 4d 8d 6c 24 10 4c 3b 6d b8 74 3d 49 8b 7c 24 08 83 bf 98 00 00 00 00 74 0=
2 <0f> 0b f0 ff 8f 88 00 00 00 74 1d 4c 89 ef e8 61 96 15 00 4c 89
> [   23.434722] RIP  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
> [   23.435924]  RSP <ffff88009f4efd28>
> [   23.441996] ---[ end trace 5761ee18fca12428 ]---
> [   23.442001] Fixing recursive fault but reboot is needed!
> [  838.179454] ------------[ cut here ]------------
> [  838.180658] kernel BUG at mm/rmap.c:385!
> [  838.181843] invalid opcode: 0000 [#3] PREEMPT SMP DEBUG_PAGEALLOC
> [  838.183046] Modules linked in: i915 cfbfillrect cfbimgblt i2c_algo_bit=
 fbcon bitblit softcursor cfbcopyarea font drm_kms_helper drm fb fbdev binf=
mt_misc fuse uvcvideo videobuf2_vmalloc videobuf2_memops arc4 videobuf2_cor=
e v4l2_common sdhci_pci iwldvm videodev media mac80211 i2c_i801 i2c_core sd=
hci mmc_core iwlwifi cfg80211 snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_=
codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_pcm_oss sn=
d_mixer_oss snd_pcm video backlight snd_timer snd
> [  838.186983] CPU: 1 PID: 6643 Comm: colord-sane Tainted: G      D      =
  3.18.0-rc6-test-00001-gf5bc00c103ff #409
> [  838.188240] Hardware name: Dell Inc. Latitude E6320/09PHH9, BIOS A08 1=
0/18/2011
> [  838.189503] task: ffff8800c4fd8000 ti: ffff880079c6c000 task.ti: ffff8=
80079c6c000
> [  838.190765] RIP: 0010:[<ffffffff81125f09>]  [<ffffffff81125f09>] unlin=
k_anon_vmas+0x12b/0x169
> [  838.192045] RSP: 0018:ffff880079c6fb68  EFLAGS: 00010286
> [  838.193324] RAX: ffff8800c5a70150 RBX: ffff8800a6fd5748 RCX: 000000000=
0000000
> [  838.194616] RDX: ffff8800a5379840 RSI: 0000000000000001 RDI: ffff8800a=
5379840
> [  838.195879] RBP: ffff880079c6fbb8 R08: 0000000000000000 R09: 000000000=
0000000
> [  838.197100] R10: 0000000000000000 R11: ffff8800c5a70160 R12: ffff8800c=
5a70140
> [  838.198289] R13: ffff8800c5a70150 R14: ffff8800a5379840 R15: ffff8800a=
5379840
> [  838.199448] FS:  0000000000000000(0000) GS:ffff88012d440000(0000) knlG=
S:0000000000000000
> [  838.200604] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  838.201753] CR2: 00007fdfd692cde8 CR3: 0000000079d0d000 CR4: 000000000=
00407e0
> [  838.202902] Stack:
> [  838.204029]  ffff88011e6fc540 ffff8800a6fd5758 ffff8800a6fd5758 ffff88=
00c5a70140
> [  838.205180]  ffff880079c6fbb8 ffff8800a6fd56e0 ffff880079c6fc18 000000=
0000000000
> [  838.206328]  0000000000000000 ffff8800a6fd56e0 ffff880079c6fc08 ffffff=
ff81119e26
> [  838.207477] Call Trace:
> [  838.208614]  [<ffffffff81119e26>] free_pgtables+0x8e/0xcc
> [  838.209762]  [<ffffffff81121ac1>] exit_mmap+0x84/0x123
> [  838.210897]  [<ffffffff81044d48>] ? do_exit+0x358/0x97e
> [  838.212020]  [<ffffffff8103ff09>] mmput+0x5e/0xbb
> [  838.213132]  [<ffffffff81044d8c>] do_exit+0x39c/0x97e
> [  838.214232]  [<ffffffff8104ea16>] ? get_signal+0xdb/0x68a
> [  838.215324]  [<ffffffff8115de6d>] ? poll_select_copy_remaining+0xfe/0x=
fe
> [  838.216420]  [<ffffffff810453f1>] do_group_exit+0x4c/0xc9
> [  838.217521]  [<ffffffff8104ef82>] get_signal+0x647/0x68a
> [  838.218612]  [<ffffffff810f48bd>] ? context_tracking_user_enter+0xdb/0=
x159
> [  838.219705]  [<ffffffff8100228f>] do_signal+0x28/0x657
> [  838.220796]  [<ffffffff810c1e10>] ? __acct_update_integrals+0xbf/0xd4
> [  838.221894]  [<ffffffff81063e43>] ? preempt_count_sub+0xcd/0xdb
> [  838.222998]  [<ffffffff8106972e>] ? vtime_account_user+0x88/0x95
> [  838.224105]  [<ffffffff815243a3>] ? _raw_spin_unlock+0x32/0x47
> [  838.225205]  [<ffffffff810f49b4>] ? context_tracking_user_exit+0x79/0x=
116
> [  838.226308]  [<ffffffff810f49b4>] ? context_tracking_user_exit+0x79/0x=
116
> [  838.227401]  [<ffffffff810028fd>] do_notify_resume+0x3f/0x94
> [  838.228495]  [<ffffffff81525218>] int_signal+0x12/0x17
> [  838.229581] Code: 32 f5 ff 49 8b 45 78 48 8b 18 4c 8d 60 f0 48 83 eb 1=
0 4d 8d 6c 24 10 4c 3b 6d b8 74 3d 49 8b 7c 24 08 83 bf 98 00 00 00 00 74 0=
2 <0f> 0b f0 ff 8f 88 00 00 00 74 1d 4c 89 ef e8 61 96 15 00 4c 89
> [  838.231909] RIP  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
> [  838.233003]  RSP <ffff880079c6fb68>
> [  838.234248] ---[ end trace 5761ee18fca12429 ]---
> [  838.234251] Fixing recursive fault but reboot is needed!
> [ 1806.784267] ------------[ cut here ]------------
> [ 1806.785322] kernel BUG at mm/rmap.c:385!
> [ 1806.786361] invalid opcode: 0000 [#4] PREEMPT SMP DEBUG_PAGEALLOC
> [ 1806.787397] Modules linked in: i915 cfbfillrect cfbimgblt i2c_algo_bit=
 fbcon bitblit softcursor cfbcopyarea font drm_kms_helper drm fb fbdev binf=
mt_misc fuse uvcvideo videobuf2_vmalloc videobuf2_memops arc4 videobuf2_cor=
e v4l2_common sdhci_pci iwldvm videodev media mac80211 i2c_i801 i2c_core sd=
hci mmc_core iwlwifi cfg80211 snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_=
codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_pcm_oss sn=
d_mixer_oss snd_pcm video backlight snd_timer snd
> [ 1806.790682] CPU: 1 PID: 8135 Comm: DNS Resolver #7 Tainted: G      D  =
      3.18.0-rc6-test-00001-gf5bc00c103ff #409
> [ 1806.791728] Hardware name: Dell Inc. Latitude E6320/09PHH9, BIOS A08 1=
0/18/2011
> [ 1806.792779] task: ffff8800b3d40000 ti: ffff880079e34000 task.ti: ffff8=
80079e34000
> [ 1806.793816] RIP: 0010:[<ffffffff81125f09>]  [<ffffffff81125f09>] unlin=
k_anon_vmas+0x12b/0x169
> [ 1806.794863] RSP: 0018:ffff880079e37d38  EFLAGS: 00010282
> [ 1806.795894] RAX: ffff8800b508d790 RBX: ffff8800bcaa4e28 RCX: 000000000=
0000000
> [ 1806.796948] RDX: ffff880124ce0f20 RSI: 0000000000000001 RDI: ffff88012=
4ce0f20
> [ 1806.798011] RBP: ffff880079e37d88 R08: 0000000000000000 R09: 000000000=
0000000
> [ 1806.799048] R10: 00007fc2827f9db0 R11: ffff8800b508d7a0 R12: ffff8800b=
508d780
> [ 1806.800105] R13: ffff8800b508d790 R14: ffff880124ce0f20 R15: ffff88012=
4ce0f20
> [ 1806.801143] FS:  00007fc2827fa700(0000) GS:ffff88012d440000(0000) knlG=
S:0000000000000000
> [ 1806.802206] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1806.803244] CR2: 00007fc2c6b87000 CR3: 00000000a3063000 CR4: 000000000=
00407e0
> [ 1806.804305] Stack:
> [ 1806.805329]  00007fc280754000 ffff8800bcaa4e38 ffff8800bcaa4e38 ffff88=
00b508d780
> [ 1806.806382]  0000000081098bfb ffff8800bcaa4dc0 ffff880079e37df8 00007f=
c27ff00000
> [ 1806.807467]  00007fc280a00000 ffff8800bcaa4dc0 ffff880079e37dd8 ffffff=
ff81119e26
> [ 1806.808536] Call Trace:
> [ 1806.809570]  [<ffffffff81119e26>] free_pgtables+0x8e/0xcc
> [ 1806.810617]  [<ffffffff8111fe4c>] unmap_region+0xc8/0xec
> [ 1806.811658]  [<ffffffff81270329>] ? __rb_erase_color+0x122/0x1f9
> [ 1806.812724]  [<ffffffff8112192b>] do_munmap+0x275/0x2f7
> [ 1806.813792]  [<ffffffff811219f5>] vm_munmap+0x48/0x61
> [ 1806.814841]  [<ffffffff81121a34>] SyS_munmap+0x26/0x2f
> [ 1806.815884]  [<ffffffff81524f52>] system_call_fastpath+0x12/0x17
> [ 1806.816951] Code: 32 f5 ff 49 8b 45 78 48 8b 18 4c 8d 60 f0 48 83 eb 1=
0 4d 8d 6c 24 10 4c 3b 6d b8 74 3d 49 8b 7c 24 08 83 bf 98 00 00 00 00 74 0=
2 <0f> 0b f0 ff 8f 88 00 00 00 74 1d 4c 89 ef e8 61 96 15 00 4c 89
> [ 1806.819300] RIP  [<ffffffff81125f09>] unlink_anon_vmas+0x12b/0x169
> [ 1806.820457]  RSP <ffff880079e37d38>
> [ 1806.822068] ---[ end trace 5761ee18fca1242a ]---
> --
> Michal Hocko
> SUSE Labs

--089e0163503c0399e80508add695
Content-Type: application/octet-stream;
	name=mm-prevent-endless-growth-of-anon_vma-hierarchy-v2
Content-Disposition: attachment;
	filename=mm-prevent-endless-growth-of-anon_vma-hierarchy-v2
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i2x84ucm0

bW06IHByZXZlbnQgZW5kbGVzcyBncm93dGggb2YgYW5vbl92bWEgaGllcmFyY2h5CgpGcm9tOiBL
b25zdGFudGluIEtobGVibmlrb3YgPGtvY3Q5aUBnbWFpbC5jb20+CgpDb25zdGFudGx5IGZvcmtp
bmcgdGFzayBjYXVzZXMgdW5saW1pdGVkIGdyb3cgb2YgYW5vbl92bWEgY2hhaW4uCkVhY2ggbmV4
dCBjaGlsZCBhbGxvY2F0ZSBuZXcgbGV2ZWwgb2YgYW5vbl92bWFzIGFuZCBsaW5rcyB2bWFzIHRv
IGFsbApwcmV2aW91cyBsZXZlbHMgYmVjYXVzZSBpdCBpbmhlcml0cyBwYWdlcyBmcm9tIHRoZW0u
IE5vbmUgb2YgYW5vbl92bWFzCmNhbm5vdCBiZSBmcmVlZCBiZWNhdXNlIHRoZXJlIG1pZ2h0IGJl
IHBhZ2VzIHdoaWNoIHBvaW50cyB0byB0aGVtLgoKVGhpcyBwYXRjaCBhZGRzIGhldXJpc3RpYyB3
aGljaCBkZWNpZGVzIHRvIHJldXNlIGV4aXN0aW5nIGFub25fdm1hIGluc3RlYWQKb2YgZm9ya2lu
ZyBuZXcgb25lLiBJdCBjb3VudHMgdm1hcyBhbmQgZGlyZWN0IGRlc2NlbmRhbnRzIGZvciBlYWNo
IGFub25fdm1hLgpBbm9uX3ZtYSB3aXRoIGRlZ3JlZSBsb3dlciB0aGFuIHR3byB3aWxsIGJlIHJl
dXNlZCBhdCBuZXh0IGZvcmsuCkFzIGEgcmVzdWx0IGVhY2ggYW5vbl92bWEgaGFzIGVpdGhlciBh
bGl2ZSB2bWEgb3IgYXQgbGVhc3QgdHdvIGRlc2NlbmRhbnRzLAplbmRsZXNzIGNoYWlucyBhcmUg
bm8gbG9uZ2VyIHBvc3NpYmxlIGFuZCBjb3VudCBvZiBhbm9uX3ZtYXMgaXMgbm8gbW9yZSB0aGFu
CnR3byB0aW1lcyBtb3JlIHRoYW4gY291bnQgb2Ygdm1hcy4KCnYyOiB1cGRhdGUgZGVncmVlIGlu
IGFub25fdm1hX3ByZXBhcmUgZm9yIG1lcmdlZCBhbm9uX3ZtYQoKU2lnbmVkLW9mZi1ieTogS29u
c3RhbnRpbiBLaGxlYm5pa292IDxrb2N0OWlAZ21haWwuY29tPgpMaW5rOiBodHRwOi8vbGttbC5r
ZXJuZWwub3JnL3IvMjAxMjA4MTYwMjQ2MTAuR0E1MzUwQGV2ZXJncmVlbi5zc2VjLndpc2MuZWR1
Ci0tLQogaW5jbHVkZS9saW51eC9ybWFwLmggfCAgIDE2ICsrKysrKysrKysrKysrKysKIG1tL3Jt
YXAuYyAgICAgICAgICAgIHwgICAzMCArKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0KIDIg
ZmlsZXMgY2hhbmdlZCwgNDUgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAtLWdp
dCBhL2luY2x1ZGUvbGludXgvcm1hcC5oIGIvaW5jbHVkZS9saW51eC9ybWFwLmgKaW5kZXggYzBj
MmJjZS4uYjFkMTQwYyAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9ybWFwLmgKKysrIGIvaW5j
bHVkZS9saW51eC9ybWFwLmgKQEAgLTQ1LDYgKzQ1LDIyIEBAIHN0cnVjdCBhbm9uX3ZtYSB7CiAJ
ICogbW1fdGFrZV9hbGxfbG9ja3MoKSAobW1fYWxsX2xvY2tzX211dGV4KS4KIAkgKi8KIAlzdHJ1
Y3QgcmJfcm9vdCByYl9yb290OwkvKiBJbnRlcnZhbCB0cmVlIG9mIHByaXZhdGUgInJlbGF0ZWQi
IHZtYXMgKi8KKworCS8qCisJICogQ291bnQgb2YgY2hpbGQgYW5vbl92bWFzIGFuZCBWTUFzIHdo
aWNoIHBvaW50cyB0byB0aGlzIGFub25fdm1hLgorCSAqCisJICogVGhpcyBjb3VudGVyIGlzIHVz
ZWQgZm9yIG1ha2luZyBkZWNpc2lvbiBhYm91dCByZXVzaW5nIG9sZCBhbm9uX3ZtYQorCSAqIGlu
c3RlYWQgb2YgZm9ya2luZyBuZXcgb25lLiBJdCBhbGxvd3MgdG8gZGV0ZWN0IGFub25fdm1hcyB3
aGljaCBoYXZlCisJICoganVzdCBvbmUgZGlyZWN0IGRlc2NlbmRhbnQgYW5kIG5vIHZtYXMuIFJl
dXNpbmcgc3VjaCBhbm9uX3ZtYSBub3QKKwkgKiBsZWFkcyB0byBzaWduaWZpY2FudCBwcmVmb3Jt
YW5jZSByZWdyZXNzaW9uIGJ1dCBwcmV2ZW50cyBkZWdyYWRhdGlvbgorCSAqIG9mIGFub25fdm1h
IGhpZXJhcmNoeSB0byBlbmRsZXNzIGxpbmVhciBjaGFpbi4KKwkgKgorCSAqIFJvb3QgYW5vbl92
bWEgaXMgbmV2ZXIgcmV1c2VkIGJlY2F1c2UgaXQgaXMgaXRzIG93biBwYXJlbnQgYW5kIGl0IGhh
cworCSAqIGF0IGxlYXQgb25lIHZtYSBvciBjaGlsZCwgdGh1cyBhdCBmb3JrIGl0J3MgZGVncmVl
IGlzIGF0IGxlYXN0IDIuCisJICovCisJdW5zaWduZWQgZGVncmVlOworCisJc3RydWN0IGFub25f
dm1hICpwYXJlbnQ7CS8qIFBhcmVudCBvZiB0aGlzIGFub25fdm1hICovCiB9OwogCiAvKgpkaWZm
IC0tZ2l0IGEvbW0vcm1hcC5jIGIvbW0vcm1hcC5jCmluZGV4IDE5ODg2ZmIuLmRmNWM0NGUgMTAw
NjQ0Ci0tLSBhL21tL3JtYXAuYworKysgYi9tbS9ybWFwLmMKQEAgLTcyLDYgKzcyLDggQEAgc3Rh
dGljIGlubGluZSBzdHJ1Y3QgYW5vbl92bWEgKmFub25fdm1hX2FsbG9jKHZvaWQpCiAJYW5vbl92
bWEgPSBrbWVtX2NhY2hlX2FsbG9jKGFub25fdm1hX2NhY2hlcCwgR0ZQX0tFUk5FTCk7CiAJaWYg
KGFub25fdm1hKSB7CiAJCWF0b21pY19zZXQoJmFub25fdm1hLT5yZWZjb3VudCwgMSk7CisJCWFu
b25fdm1hLT5kZWdyZWUgPSAxOwkvKiBSZWZlcmVuY2UgZm9yIGZpcnN0IHZtYSAqLworCQlhbm9u
X3ZtYS0+cGFyZW50ID0gYW5vbl92bWE7CiAJCS8qCiAJCSAqIEluaXRpYWxpc2UgdGhlIGFub25f
dm1hIHJvb3QgdG8gcG9pbnQgdG8gaXRzZWxmLiBJZiBjYWxsZWQKIAkJICogZnJvbSBmb3JrLCB0
aGUgcm9vdCB3aWxsIGJlIHJlc2V0IHRvIHRoZSBwYXJlbnRzIGFub25fdm1hLgpAQCAtMTg4LDYg
KzE5MCw4IEBAIGludCBhbm9uX3ZtYV9wcmVwYXJlKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1h
KQogCQlpZiAobGlrZWx5KCF2bWEtPmFub25fdm1hKSkgewogCQkJdm1hLT5hbm9uX3ZtYSA9IGFu
b25fdm1hOwogCQkJYW5vbl92bWFfY2hhaW5fbGluayh2bWEsIGF2YywgYW5vbl92bWEpOworCQkJ
Lyogdm1hIGxpbmsgaWYgbWVyZ2VkIG9yIGNoaWxkIGxpbmsgZm9yIG5ldyByb290ICovCisJCQlh
bm9uX3ZtYS0+ZGVncmVlKys7CiAJCQlhbGxvY2F0ZWQgPSBOVUxMOwogCQkJYXZjID0gTlVMTDsK
IAkJfQpAQCAtMjU2LDcgKzI2MCwxNyBAQCBpbnQgYW5vbl92bWFfY2xvbmUoc3RydWN0IHZtX2Fy
ZWFfc3RydWN0ICpkc3QsIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqc3JjKQogCQlhbm9uX3ZtYSA9
IHBhdmMtPmFub25fdm1hOwogCQlyb290ID0gbG9ja19hbm9uX3ZtYV9yb290KHJvb3QsIGFub25f
dm1hKTsKIAkJYW5vbl92bWFfY2hhaW5fbGluayhkc3QsIGF2YywgYW5vbl92bWEpOworCisJCS8q
CisJCSAqIFJldXNlIGV4aXN0aW5nIGFub25fdm1hIGlmIGl0cyBkZWdyZWUgbG93ZXIgdGhhbiB0
d28sCisJCSAqIHRoYXQgbWVhbnMgaXQgaGFzIG5vIHZtYSBhbmQganVzdCBvbmUgYW5vbl92bWEg
Y2hpbGQuCisJCSAqLworCQlpZiAoIWRzdC0+YW5vbl92bWEgJiYgYW5vbl92bWEgIT0gc3JjLT5h
bm9uX3ZtYSAmJgorCQkJCWFub25fdm1hLT5kZWdyZWUgPCAyKQorCQkJZHN0LT5hbm9uX3ZtYSA9
IGFub25fdm1hOwogCX0KKwlpZiAoZHN0LT5hbm9uX3ZtYSkKKwkJZHN0LT5hbm9uX3ZtYS0+ZGVn
cmVlKys7CiAJdW5sb2NrX2Fub25fdm1hX3Jvb3Qocm9vdCk7CiAJcmV0dXJuIDA7CiAKQEAgLTI3
OSw2ICsyOTMsOSBAQCBpbnQgYW5vbl92bWFfZm9yayhzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZt
YSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICpwdm1hKQogCWlmICghcHZtYS0+YW5vbl92bWEpCiAJ
CXJldHVybiAwOwogCisJLyogRHJvcCBpbmhlcml0ZWQgYW5vbl92bWEsIHdlJ2xsIHJldXNlIG9s
ZCBvbmUgb3IgYWxsb2NhdGUgbmV3LiAqLworCXZtYS0+YW5vbl92bWEgPSBOVUxMOworCiAJLyoK
IAkgKiBGaXJzdCwgYXR0YWNoIHRoZSBuZXcgVk1BIHRvIHRoZSBwYXJlbnQgVk1BJ3MgYW5vbl92
bWFzLAogCSAqIHNvIHJtYXAgY2FuIGZpbmQgbm9uLUNPV2VkIHBhZ2VzIGluIGNoaWxkIHByb2Nl
c3Nlcy4KQEAgLTI4Niw2ICszMDMsMTAgQEAgaW50IGFub25fdm1hX2Zvcmsoc3RydWN0IHZtX2Fy
ZWFfc3RydWN0ICp2bWEsIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqcHZtYSkKIAlpZiAoYW5vbl92
bWFfY2xvbmUodm1hLCBwdm1hKSkKIAkJcmV0dXJuIC1FTk9NRU07CiAKKwkvKiBBbiBvbGQgYW5v
bl92bWEgaGFzIGJlZW4gcmV1c2VkLiAqLworCWlmICh2bWEtPmFub25fdm1hKQorCQlyZXR1cm4g
MDsKKwogCS8qIFRoZW4gYWRkIG91ciBvd24gYW5vbl92bWEuICovCiAJYW5vbl92bWEgPSBhbm9u
X3ZtYV9hbGxvYygpOwogCWlmICghYW5vbl92bWEpCkBAIC0yOTksNiArMzIwLDcgQEAgaW50IGFu
b25fdm1hX2Zvcmsoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHN0cnVjdCB2bV9hcmVhX3N0
cnVjdCAqcHZtYSkKIAkgKiBsb2NrIGFueSBvZiB0aGUgYW5vbl92bWFzIGluIHRoaXMgYW5vbl92
bWEgdHJlZS4KIAkgKi8KIAlhbm9uX3ZtYS0+cm9vdCA9IHB2bWEtPmFub25fdm1hLT5yb290Owor
CWFub25fdm1hLT5wYXJlbnQgPSBwdm1hLT5hbm9uX3ZtYTsKIAkvKgogCSAqIFdpdGggcmVmY291
bnRzLCBhbiBhbm9uX3ZtYSBjYW4gc3RheSBhcm91bmQgbG9uZ2VyIHRoYW4gdGhlCiAJICogcHJv
Y2VzcyBpdCBiZWxvbmdzIHRvLiBUaGUgcm9vdCBhbm9uX3ZtYSBuZWVkcyB0byBiZSBwaW5uZWQg
dW50aWwKQEAgLTMwOSw2ICszMzEsNyBAQCBpbnQgYW5vbl92bWFfZm9yayhzdHJ1Y3Qgdm1fYXJl
YV9zdHJ1Y3QgKnZtYSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICpwdm1hKQogCXZtYS0+YW5vbl92
bWEgPSBhbm9uX3ZtYTsKIAlhbm9uX3ZtYV9sb2NrX3dyaXRlKGFub25fdm1hKTsKIAlhbm9uX3Zt
YV9jaGFpbl9saW5rKHZtYSwgYXZjLCBhbm9uX3ZtYSk7CisJYW5vbl92bWEtPnBhcmVudC0+ZGVn
cmVlKys7CiAJYW5vbl92bWFfdW5sb2NrX3dyaXRlKGFub25fdm1hKTsKIAogCXJldHVybiAwOwpA
QCAtMzM5LDEyICszNjIsMTYgQEAgdm9pZCB1bmxpbmtfYW5vbl92bWFzKHN0cnVjdCB2bV9hcmVh
X3N0cnVjdCAqdm1hKQogCQkgKiBMZWF2ZSBlbXB0eSBhbm9uX3ZtYXMgb24gdGhlIGxpc3QgLSB3
ZSdsbCBuZWVkCiAJCSAqIHRvIGZyZWUgdGhlbSBvdXRzaWRlIHRoZSBsb2NrLgogCQkgKi8KLQkJ
aWYgKFJCX0VNUFRZX1JPT1QoJmFub25fdm1hLT5yYl9yb290KSkKKwkJaWYgKFJCX0VNUFRZX1JP
T1QoJmFub25fdm1hLT5yYl9yb290KSkgeworCQkJYW5vbl92bWEtPnBhcmVudC0+ZGVncmVlLS07
CiAJCQljb250aW51ZTsKKwkJfQogCiAJCWxpc3RfZGVsKCZhdmMtPnNhbWVfdm1hKTsKIAkJYW5v
bl92bWFfY2hhaW5fZnJlZShhdmMpOwogCX0KKwlpZiAodm1hLT5hbm9uX3ZtYSkKKwkJdm1hLT5h
bm9uX3ZtYS0+ZGVncmVlLS07CiAJdW5sb2NrX2Fub25fdm1hX3Jvb3Qocm9vdCk7CiAKIAkvKgpA
QCAtMzU1LDYgKzM4Miw3IEBAIHZvaWQgdW5saW5rX2Fub25fdm1hcyhzdHJ1Y3Qgdm1fYXJlYV9z
dHJ1Y3QgKnZtYSkKIAlsaXN0X2Zvcl9lYWNoX2VudHJ5X3NhZmUoYXZjLCBuZXh0LCAmdm1hLT5h
bm9uX3ZtYV9jaGFpbiwgc2FtZV92bWEpIHsKIAkJc3RydWN0IGFub25fdm1hICphbm9uX3ZtYSA9
IGF2Yy0+YW5vbl92bWE7CiAKKwkJQlVHX09OKGFub25fdm1hLT5kZWdyZWUpOwogCQlwdXRfYW5v
bl92bWEoYW5vbl92bWEpOwogCiAJCWxpc3RfZGVsKCZhdmMtPnNhbWVfdm1hKTsK
--089e0163503c0399e80508add695--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
