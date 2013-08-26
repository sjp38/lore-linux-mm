Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id DE3066B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 15:08:33 -0400 (EDT)
Date: Mon, 26 Aug 2013 15:08:22 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130826190757.GB27768@redhat.com>
References: <20130807153030.GA25515@redhat.com>
 <CAJd=RBCyZU8PR7mbFUdKsWq3OH+5HccEWKMEH5u7GNHNy3esWg@mail.gmail.com>
 <20130819231836.GD14369@redhat.com>
 <CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
 <20130821204901.GA19802@redhat.com>
 <CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
 <20130823032127.GA5098@redhat.com>
 <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
 <20130823035344.GB5098@redhat.com>
 <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Aug 26, 2013 at 11:45:53AM +0800, Hillf Danton wrote:
 > On Fri, Aug 23, 2013 at 11:53 AM, Dave Jones <davej@redhat.com> wrote:
 > >
 > > It actually seems worse, seems I can trigger it even easier now, as if
 > > there's a leak.
 > >
 > Can you please try the new fix for TLB flush?
 > 
 > commit  2b047252d087be7f2ba
 > Fix TLB gather virtual address range invalidation corner cases

No luck.

[ 4588.541886] swap_free: Unused swap offset entry 00002d15
[ 4588.541952] BUG: Bad page map in process trinity-kid12  pte:005a2a80 pmd:22c01f067
[ 4588.541979] addr:00007f0e95fa8000 vm_flags:00100073 anon_vma:ffff880217665550 mapping:          (null) index:1a42
[ 4588.542011] Modules linked in: snd_seq_dummy fuse hidp bnep scsi_transport_iscsi rfcomm ipt_ULOG can_bcm can_raw nfnetlink nfc caif_socket caif af_802154 phonet af_rxrpc bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 xfs libcrc32c snd_hda_codec_realtek snd_hda_intel e1000e snd_hda_codec snd_hwdep ptp snd_seq snd_seq_device snd_pcm usb_debug pps_core pcspkr snd_page_alloc snd_timer snd soundcore
[ 4588.542245] CPU: 2 PID: 25390 Comm: trinity-kid12 Not tainted 3.11.0-rc7+ #13 
[ 4588.542321]  0000000000000000 ffff88021ba33c98 ffffffff816f9ddf 00007f0e95fa8000
[ 4588.542354]  ffff88021ba33ce0 ffffffff81177047 00000000005a2a80 0000000000001a42
[ 4588.542386]  00007f0e96000000 ffff88022c01fd40 00000000005a2a80 ffff88021ba33e00
[ 4588.542418] Call Trace:
[ 4588.542435]  [<ffffffff816f9ddf>] dump_stack+0x54/0x74
[ 4588.542457]  [<ffffffff81177047>] print_bad_pte+0x187/0x220
[ 4588.542478]  [<ffffffff81178874>] unmap_single_vma+0x524/0x850
[ 4588.542500]  [<ffffffff81179ac9>] unmap_vmas+0x49/0x90
[ 4588.542521]  [<ffffffff811822c5>] exit_mmap+0xc5/0x170
[ 4588.542542]  [<ffffffff8104ffb7>] mmput+0x77/0x100
[ 4588.542562]  [<ffffffff8105465d>] do_exit+0x28d/0xcd0
[ 4588.542583]  [<ffffffff810c0085>] ? trace_hardirqs_on_caller+0x115/0x1e0
[ 4588.542607]  [<ffffffff810c015d>] ? trace_hardirqs_on+0xd/0x10
[ 4588.542629]  [<ffffffff8105643c>] do_group_exit+0x4c/0xc0
[ 4588.543534]  [<ffffffff810564c4>] SyS_exit_group+0x14/0x20
[ 4588.544438]  [<ffffffff8170d554>] tracesys+0xdd/0xe2

I can reproduce this pretty quickly by driving the system into swapping using
a few instances of 'trinity -C64' (this creates 64 threads) 

I'm not sure how far back this bug goes, so I'll try some older kernels
and see if I can bisect it, because we don't seem to be getting closer
to figuring out what's actually happening..

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
