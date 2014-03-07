Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id F17436B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 12:18:33 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id up15so4405876pbc.6
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 09:18:33 -0800 (PST)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id tk9si8949728pac.64.2014.03.07.09.18.32
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 09:18:33 -0800 (PST)
Date: Fri, 7 Mar 2014 11:18:30 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: oops in slab/leaks_show
In-Reply-To: <20140307025703.GA30770@redhat.com>
Message-ID: <alpine.DEB.2.10.1403071117230.21846@nuc>
References: <20140307025703.GA30770@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Dave Jones <davej@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>

Joonsoo recently changed the handling of the freelist in SLAB. CCing him.

On Thu, 6 Mar 2014, Dave Jones wrote:

> I pretty much always use SLUB for my fuzzing boxes, but thought I'd give SLAB a try
> for a change.. It blew up when something tried to read /proc/slab_allocators
> (Just cat it, and you should see the oops below)
>
> Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> Modules linked in: fuse hidp snd_seq_dummy tun rfcomm bnep llc2 af_key can_raw ipt_ULOG can_bcm nfnetlink scsi_transport_iscsi nfc caif_socket caif af_802154 phonet af_rxrpc can pppoe pppox ppp_generic slhc irda crc_ccitt rds rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 xfs coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm crct10dif_pclmul crc32c_intel ghash_clmulni_intel libcrc32c usb_debug microcode snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic pcspkr btusb bluetooth 6lowpan_iphc rfkill snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer e1000e snd ptp shpchp soundcore pps_core serio_raw
> CPU: 1 PID: 9386 Comm: trinity-c33 Not tainted 3.14.0-rc5+ #131
> task: ffff8801aa46e890 ti: ffff880076924000 task.ti: ffff880076924000
> RIP: 0010:[<ffffffffaa1a8f4a>]  [<ffffffffaa1a8f4a>] handle_slab+0x8a/0x180
> RSP: 0018:ffff880076925de0  EFLAGS: 00010002
> RAX: 0000000000001000 RBX: 0000000000000000 RCX: 000000005ce85ce7
> RDX: ffffea00079be100 RSI: 0000000000001000 RDI: ffff880107458000
> RBP: ffff880076925e18 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: 000000000000000f R12: ffff8801e6f84000
> R13: ffffea00079be100 R14: ffff880107458000 R15: ffff88022bb8d2c0
> FS:  00007fb769e45740(0000) GS:ffff88024d040000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffff8801e6f84ff8 CR3: 00000000a22db000 CR4: 00000000001407e0
> DR0: 0000000002695000 DR1: 0000000002695000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000070602
> Stack:
>  ffff8802339dcfc0 ffff88022bb8d2c0 ffff880107458000 ffff88022bb8d2c0
>  ffff8802339dd008 ffff8802339dcfc0 ffffea00079be100 ffff880076925e68
>  ffffffffaa1ad9be ffff880203fe4f00 ffff88022bb8d318 0000000076925e98
> Call Trace:
>  [<ffffffffaa1ad9be>] leaks_show+0xce/0x240
>  [<ffffffffaa1e6c0e>] seq_read+0x28e/0x490
>  [<ffffffffaa23008d>] proc_reg_read+0x3d/0x80
>  [<ffffffffaa1c026b>] vfs_read+0x9b/0x160
>  [<ffffffffaa1c0d88>] SyS_read+0x58/0xb0
>  [<ffffffffaa7420aa>] tracesys+0xd4/0xd9
> Code: f5 00 00 00 0f 1f 44 00 00 48 63 c8 44 3b 0c 8a 0f 84 e3 00 00 00 83 c0 01 44 39 c0 72 eb 41 f6 47 1a 01 0f 84 e9 00 00 00 89 f0 <4d> 8b 4c 04 f8 4d 85 c9 0f 84 88 00 00 00 49 8b 7e 08 4d 8d 46
> RIP  [<ffffffffaa1a8f4a>] handle_slab+0x8a/0x180
>  RSP <ffff880076925de0>
> CR2: ffff8801e6f84ff8
>
>
>   2b:*	4d 8b 4c 04 f8       	mov    -0x8(%r12,%rax,1),%r9     <-- trapping instruction
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
