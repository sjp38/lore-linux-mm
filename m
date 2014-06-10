Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 45C176B00B0
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 23:19:26 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so5560442pdi.41
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 20:19:25 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id fb5si32746437pbd.178.2014.06.09.20.19.24
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 20:19:25 -0700 (PDT)
Date: Tue, 10 Jun 2014 12:23:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: rb_erase oops.
Message-ID: <20140610032314.GD19036@js1304-P5Q-DELUXE>
References: <20140609223028.GA13109@redhat.com>
 <alpine.DEB.2.02.1406091606080.5271@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1406091606080.5271@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 09, 2014 at 04:09:38PM -0700, David Rientjes wrote:
> On Mon, 9 Jun 2014, Dave Jones wrote:
> 
> > Kernel based on v3.15-7257-g963649d735c8
> > 
> > 	Dave
> > 
> > Oops: 0000 [#1] PREEMPT SMP 
> > Modules linked in: dlci 8021q garp snd_seq_dummy bnep llc2 af_key bridge stp fuse tun scsi_transport_iscsi ipt_ULOG nfnetlink rfcomm can_raw hidp can_bcm nfc caif_socket caif af_802154 ieee802154 phonet af_rxrpc can pppoe pppox ppp_generic slhc irda crc_ccitt rds rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 coretemp cfg80211 hwmon x86_pkg_temp_thermal kvm_intel kvm snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic btusb bluetooth snd_hda_intel xfs snd_hda_controller snd_hda_codec snd_hwdep snd_seq e1000e snd_seq_device crct10dif_pclmul crc32c_intel ghash_clmulni_intel snd_pcm snd_timer snd 6lowpan_iphc usb_debug rfkill libcrc32c ptp pps_core microcode shpchp pcspkr serio_raw soundcore
> > CPU: 3 PID: 2049 Comm: kworker/3:1 Not tainted 3.15.0+ #231
> > Workqueue: events free_work
> > task: ffff880100944260 ti: ffff88009ed9c000 task.ti: ffff88009ed9c000
> > RIP: 0010:[<ffffffff8a326619>]  [<ffffffff8a326619>] rb_erase+0xb9/0x380
> > RSP: 0000:ffff88009ed9fcc0  EFLAGS: 00010202
> > RAX: ffff8802396b0018 RBX: ffff88024176b008 RCX: 0000000000000000
> > RDX: ffffc90010fe1bf0 RSI: ffffffff8afb3178 RDI: 0000000000000001
> > RBP: ffff88009ed9fcc0 R08: ffff88023b122e58 R09: ffff88024176ae58
> > R10: 0000000000000000 R11: ffff880245801dc0 R12: ffff88024176b020
> > R13: ffff88009ed9fd80 R14: ffff88009ed9fd88 R15: ffff88024e397100
> > FS:  0000000000000000(0000) GS:ffff88024e380000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000000000000001 CR3: 000000000ac10000 CR4: 00000000001407e0
> > DR0: 00000000024cc000 DR1: 00000000024c2000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> > Stack:
> >  ffff88009ed9fce0 ffffffff8a195674 ffff88024176ae40 ffffffff8ac64260
> >  ffff88009ed9fd70 ffffffff8a19631d ffff88009ed9fd88 ffff88009ed9fd80
> >  ffff88009ed9fd10 ffff880244b93750 0000000000000000 ffff880244b93750
> > Call Trace:
> >  [<ffffffff8a195674>] __free_vmap_area+0x54/0xf0
> >  [<ffffffff8a19631d>] __purge_vmap_area_lazy+0x15d/0x4a0
> >  [<ffffffff8a1966e1>] free_vmap_area_noflush+0x81/0x90
> >  [<ffffffff8a197dae>] remove_vm_area+0x5e/0x70
> >  [<ffffffff8a197dee>] __vunmap+0x2e/0x100
> >  [<ffffffff8a197eed>] free_work+0x2d/0x40
> >  [<ffffffff8a08df11>] process_one_work+0x171/0x4d0
> >  [<ffffffff8a08eeac>] worker_thread+0x12c/0x3d0
> >  [<ffffffff8a0bc4b2>] ? complete+0x42/0x50
> >  [<ffffffff8a08ed80>] ? manage_workers.isra.25+0x2d0/0x2d0
> >  [<ffffffff8a095b3f>] kthread+0xff/0x120
> >  [<ffffffff8a095a40>] ? kthread_create_on_node+0x1c0/0x1c0
> >  [<ffffffff8a741eec>] ret_from_fork+0x7c/0xb0
> >  [<ffffffff8a095a40>] ? kthread_create_on_node+0x1c0/0x1c0
> > Code: 85 d2 74 0e 48 83 c8 01 48 89 0a 49 89 02 5d c3 66 90 48 8b 3a 48 89 0a 83 e7 01 74 f1 31 c9 eb 40 90 48 8b 7a 08 48 85 ff 74 09 <f6> 07 01 0f 84 a3 01 00 00 48 8b 4a 10 48 85 c9 74 09 f6 01 01 
> > RIP  [<ffffffff8a326619>] rb_erase+0xb9/0x380
> >  RSP <ffff88009ed9fcc0>
> > 
> 
> Adding Joonsoo to the cc.
> 
> I haven't looked very closely, and it may be unrelated, but perhaps this 
> is a race because of a failed radix_tree_preload() in new_vmap_block() and 
> this happens in low on memory conditions (and would be tough to reproduce 
> because of a race with the rcu-protected vmap_area_list iteration in
> __purge_vmap_area_lazy() and the actual freeing of the vmap_area under 
> vmap_area_lock).

Hello, David.

I think that the race you mentioned is impossible. When
radix_tree_preload() is failed in new_vmap_block(), flag of that
vmap_area would be 0, so __purge_vmap_area_lazy() would not try to
purge that vmap_area.

Anyway, I have no idea what causes this problem now.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
