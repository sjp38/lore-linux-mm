Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1811D6B0035
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 20:06:43 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so10123480pbb.40
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 17:06:42 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id tk5si11668526pbc.123.2014.04.15.17.06.40
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 17:06:42 -0700 (PDT)
Date: Wed, 16 Apr 2014 09:07:08 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: oops in slab/leaks_show
Message-ID: <20140416000708.GB14564@js1304-P5Q-DELUXE>
References: <20140307025703.GA30770@redhat.com>
 <alpine.DEB.2.10.1403071117230.21846@nuc>
 <20140311003459.GA25657@lge.com>
 <20140311010135.GA25845@lge.com>
 <20140311012455.GA5151@redhat.com>
 <20140311025811.GA601@lge.com>
 <20140311083009.GA32004@lge.com>
 <53479B7B.6050008@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53479B7B.6050008@iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Apr 11, 2014 at 10:36:27AM +0300, Pekka Enberg wrote:
> On 03/11/2014 10:30 AM, Joonsoo Kim wrote:
> >---------8<---------------------
> > From ff6fe77fb764ca5bf8705bf53d07d38e4111e84c Mon Sep 17 00:00:00 2001
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >Date: Tue, 11 Mar 2014 14:14:25 +0900
> >Subject: [PATCH] slab: remove kernel_map_pages() optimization in slab
> >  poisoning
> >
> >If CONFIG_DEBUG_PAGEALLOC enables, slab poisoning functionality uses
> >kernel_map_pages(), instead of real poisoning, to detect memory corruption
> >with low overhead. But, in that case, slab leak detector trigger oops.
> >Reason is that slab leak detector accesses all active objects, especially
> >including objects in cpu slab caches to get the caller information.
> >These objects are already unmapped via kernel_map_pages() to detect memory
> >corruption, so oops could be triggered.
> >
> >Following is oops message reported from Dave.
> >
> >It blew up when something tried to read /proc/slab_allocators
> >(Just cat it, and you should see the oops below)
> >
> >   Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> >   Modules linked in: fuse hidp snd_seq_dummy tun rfcomm bnep llc2 af_key can_raw ipt_ULOG can_bcm nfnetlink scsi_transport_iscsi nfc caif_socket caif af_802154 phonet af_rxrpc can pppoe pppox ppp_generic
> >   +slhc irda crc_ccitt rds rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 xfs coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm crct10dif_pclmul crc32c_intel ghash_clmulni_intel
> >   +libcrc32c usb_debug microcode snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic pcspkr btusb bluetooth 6lowpan_iphc rfkill snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm
> >   +snd_timer e1000e snd ptp shpchp soundcore pps_core serio_raw
> >   CPU: 1 PID: 9386 Comm: trinity-c33 Not tainted 3.14.0-rc5+ #131
> >   task: ffff8801aa46e890 ti: ffff880076924000 task.ti: ffff880076924000
> >   RIP: 0010:[<ffffffffaa1a8f4a>]  [<ffffffffaa1a8f4a>] handle_slab+0x8a/0x180
> >   RSP: 0018:ffff880076925de0  EFLAGS: 00010002
> >   RAX: 0000000000001000 RBX: 0000000000000000 RCX: 000000005ce85ce7
> >   RDX: ffffea00079be100 RSI: 0000000000001000 RDI: ffff880107458000
> >   RBP: ffff880076925e18 R08: 0000000000000001 R09: 0000000000000000
> >   R10: 0000000000000000 R11: 000000000000000f R12: ffff8801e6f84000
> >   R13: ffffea00079be100 R14: ffff880107458000 R15: ffff88022bb8d2c0
> >   FS:  00007fb769e45740(0000) GS:ffff88024d040000(0000) knlGS:0000000000000000
> >   CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >   CR2: ffff8801e6f84ff8 CR3: 00000000a22db000 CR4: 00000000001407e0
> >   DR0: 0000000002695000 DR1: 0000000002695000 DR2: 0000000000000000
> >   DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000070602
> >   Stack:
> >    ffff8802339dcfc0 ffff88022bb8d2c0 ffff880107458000 ffff88022bb8d2c0
> >    ffff8802339dd008 ffff8802339dcfc0 ffffea00079be100 ffff880076925e68
> >    ffffffffaa1ad9be ffff880203fe4f00 ffff88022bb8d318 0000000076925e98
> >   Call Trace:
> >    [<ffffffffaa1ad9be>] leaks_show+0xce/0x240
> >    [<ffffffffaa1e6c0e>] seq_read+0x28e/0x490
> >    [<ffffffffaa23008d>] proc_reg_read+0x3d/0x80
> >    [<ffffffffaa1c026b>] vfs_read+0x9b/0x160
> >    [<ffffffffaa1c0d88>] SyS_read+0x58/0xb0
> >    [<ffffffffaa7420aa>] tracesys+0xd4/0xd9
> >   Code: f5 00 00 00 0f 1f 44 00 00 48 63 c8 44 3b 0c 8a 0f 84 e3 00 00 00 83 c0 01 44 39 c0 72 eb 41 f6 47 1a 01 0f 84 e9 00 00 00 89 f0 <4d> 8b 4c 04 f8 4d 85 c9 0f 84 88 00 00 00 49 8b 7e 08 4d 8d 46
> >   RIP  [<ffffffffaa1a8f4a>] handle_slab+0x8a/0x180
> >    RSP <ffff880076925de0>
> >   CR2: ffff8801e6f84ff8
> >
> >There are two solutions to fix the problem. One is to disable
> >CONFIG_DEBUG_SLAB_LEAK if CONFIG_DEBUG_PAGEALLOC=y. The other is to remove
> >kernel_map_pages() optimization in slab poisoning. I think that
> >second one is better, since we can use all functionality with some more
> >overhead. slab poisoning is already heavy operation, so adding more
> >overhead doesn't weaken their value.
> >
> >Reported-by: Dave Jones <davej@redhat.com>
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Joonsoo, can you please resend against slab/next? I'm seeing some
> rejects here.
> 

Hello Pekka.

I send different patch to fix this bug.
You can see it on following link.
https://lkml.org/lkml/2014/4/15/727

With some more study, I found that using DEBUG_PAGEALLOC on SLAB is
for not only optimization but also easily detection who corrupt memory.
So, I change the solution to fix this bug. Please refer it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
