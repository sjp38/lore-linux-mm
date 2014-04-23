Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 930FF6B0039
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 11:28:35 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id k15so1016801qaq.1
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 08:28:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z3si643859qcl.8.2014.04.23.08.28.33
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 08:28:33 -0700 (PDT)
Date: Wed, 23 Apr 2014 10:49:01 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.15rc2 hanging processes on exit.
Message-ID: <20140423144901.GA24220@redhat.com>
References: <20140422180308.GA19038@redhat.com>
 <CA+55aFxjADAB80AV6qK-b4QPzP7fgog_EyH-7dSpWVgzpZmL8Q@mail.gmail.com>
 <alpine.LSU.2.11.1404221303060.6220@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404221303060.6220@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, Apr 22, 2014 at 01:17:33PM -0700, Hugh Dickins wrote:
 > On Tue, 22 Apr 2014, Linus Torvalds wrote:

 > (Dave, do you have time to confirm that by running new trinity on 3.14?)

So for reasons I can't figure out, I've not been able to hit it on 3.14
The only 'interesting' thing I've hit in overnight testing is this, which
I'm not sure if I've also seen in my .15rc testing, but it doesn't look
familiar to me.  (Though the vm oopses I've seen the last few months
are starting to all blur together in my memory)


kernel BUG at mm/mlock.c:82!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in: 8021q garp sctp bridge stp dlci snd_seq_dummy fuse rfcomm bnep tun hidp llc2 af_key ipt_ULOG scsi_transport_iscsi can_bcm nfnetlink nfc caif_s
ocket caif af_802154 phonet af_rxrpc can_raw can pppoe pppox ppp_generic slhc irda crc_ccitt rds rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 coretemp 
hwmon x86_pkg_temp_thermal kvm_intel kvm snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_codec xfs snd_hwdep snd_seq snd_seq_device snd_pcm
 e1000e crct10dif_pclmul snd_timer libcrc32c btusb crc32c_intel snd bluetooth usb_debug ghash_clmulni_intel ptp serio_raw soundcore microcode pcspkr shpchp pps_core 6lowpan_iphc rfkill
CPU: 0 PID: 26655 Comm: trinity-c66 Not tainted 3.14.0+ #195
task: ffff8800802a3560 ti: ffff8801b35be000 task.ti: ffff8801b35be000
RIP: 0010:[<ffffffffbe18e383>]  [<ffffffffbe18e383>] mlock_vma_page+0x93/0xa0
RSP: 0000:ffff8801b35bf800  EFLAGS: 00010246
RAX: 001000000038003c RBX: ffffea000064f240 RCX: 000000000064f240
RDX: 80000000193c9827 RSI: 0000000000002000 RDI: ffffea000064f240
RBP: ffff8801b35bf808 R08: 0000000000000000 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000000 R12: ffffea000064f240
R13: ffff88019a63e000 R14: 0000000000a00000 R15: ffff880240281600
FS:  00007f11e9e9d740(0000) GS:ffff880244000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000037c00000 CR3: 000000023b6aa000 CR4: 00000000001407f0
DR0: 0000000001282000 DR1: 00007ff54ceef000 DR2: 000000000092e000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 0000000000a02000 ffff8801b35bf8a8 ffffffffbe196612 ffffffffbe195539
 ffffea00068824c0 0000000000100000 ffff8802387c8988 ffff8802387c89f8
 0000000000020000 ffff88009a3587d0 0000000100000001 0000000000a00000
Call Trace:
 [<ffffffffbe196612>] try_to_unmap_nonlinear+0x2a2/0x530
 [<ffffffffbe195539>] ? __page_check_address+0x39/0x160
 [<ffffffffbe1972a7>] rmap_walk+0x157/0x320
 [<ffffffffbe1976e3>] try_to_unmap+0x93/0xf0
 [<ffffffffbe195ed0>] ? page_remove_rmap+0xe0/0xe0
 [<ffffffffbe195270>] ? invalid_migration_vma+0x30/0x30
 [<ffffffffbe196370>] ? try_to_unmap_one+0x4a0/0x4a0
 [<ffffffffbe196da0>] ? anon_vma_clone+0x140/0x140
 [<ffffffffbe1bb8f6>] migrate_pages+0x3b6/0x7b0
 [<ffffffffbe182930>] ? isolate_freepages_block+0x360/0x360
 [<ffffffffbe183e9a>] compact_zone+0x3aa/0x560
 [<ffffffffbe1840f2>] compact_zone_order+0xa2/0x110
 [<ffffffffbe165aac>] ? get_page_from_freelist+0x12c/0x9d0
 [<ffffffffbe1844c1>] try_to_compact_pages+0x101/0x130
 [<ffffffffbe73c415>] __alloc_pages_direct_compact+0xac/0x1d0
 [<ffffffffbe167330>] __alloc_pages_nodemask+0x910/0xb00
 [<ffffffffbe1acf41>] alloc_pages_vma+0xf1/0x1b0
 [<ffffffffbe1c06bd>] ? do_huge_pmd_anonymous_page+0xfd/0x3b0
 [<ffffffffbe1c06bd>] do_huge_pmd_anonymous_page+0xfd/0x3b0
 [<ffffffffbe18afed>] handle_mm_fault+0x15d/0xc40
 [<ffffffffbe74d91a>] ? __do_page_fault+0x14a/0x610
 [<ffffffffbe74d97e>] __do_page_fault+0x1ae/0x610
 [<ffffffffbe0bfbde>] ? put_lock_stats.isra.23+0xe/0x30
 [<ffffffffbe0c03b6>] ? lock_rel ---[ end trace 5628b2984151295b ]---


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
