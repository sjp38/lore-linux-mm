Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 24B0F6B0037
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:16:02 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id to1so1595262ieb.4
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 08:16:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lo5si4456713icc.32.2013.12.19.08.16.00
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 08:16:01 -0800 (PST)
Date: Thu, 19 Dec 2013 10:53:13 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219155313.GA25771@redhat.com>
References: <20131219040738.GA10316@redhat.com>
 <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>

On Wed, Dec 18, 2013 at 08:40:07PM -0800, Linus Torvalds wrote:
 > On Wed, Dec 18, 2013 at 8:07 PM, Dave Jones <davej@redhat.com> wrote:
 > > Just hit this while fuzzing with lots of child processes.
 > > (trinity -C128)
 > 
 > Ok, there's a BUG_ON() in the middle, the "bad page" part is just this:
 > 
 > > BUG: Bad page state in process trinity-c93  pfn:100499
 > > page:ffffea0004012640 count:0 mapcount:0 mapping:          (null) index:0x389
 > > page flags: 0x2000000000000c(referenced|uptodate)
 > > Call Trace:
 > >  [<ffffffff816db2f5>] dump_stack+0x4e/0x7a
 > >  [<ffffffff816d8b05>] bad_page.part.71+0xcf/0xe8
 > >  [<ffffffff8113a645>] free_pages_prepare+0x185/0x190
 > >  [<ffffffff8113b085>] free_hot_cold_page+0x35/0x180
 > >  [<ffffffff811403f3>] __put_single_page+0x23/0x30
 > >  [<ffffffff81140665>] put_page+0x35/0x50
 > >  [<ffffffff811e8705>] aio_free_ring+0x55/0xf0
 > >  [<ffffffff811e9c5a>] SyS_io_setup+0x59a/0xbe0
 > >  [<ffffffff816edb24>] tracesys+0xdd/0xe2
 > 
 > at free_pages() time, and I don't see anything bad in the printout wrt
 > the page counts of flags.

Overnight run hit another bad page state with a different trace.

WARNING: CPU: 2 PID: 14107 at mm/truncate.c:331 truncate_inode_pages_range+0x5e4/0x610()
Modules linked in: snd_seq_dummy fuse sctp tun 8021q garp stp hidp nfnetlink bnep rfcomm scsi_transport_iscsi nfc caif_socket caif af_802154 phonet af_rxrpc can_bcm can_raw bluetooth
 can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds ipt_ULOG af_key rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 rfkill xfs libcrc32c snd_hda_codec_realtek snd_hda_co
dec_hdmi coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm crct10dif_pclmul crc32c_intel ghash_clmulni_intel microcode serio_raw pcspkr usb_debug snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_s
eq_device e1000e ptp shpchp snd_pcm pps_core snd_page_alloc[31342.836846] BUG: Bad page state in process modprobe  pfn:10f05c
page:ffffea00043c1700 count:0 mapcount:0 mapping:          (null) index:0x0
page flags: 0x20000000000001(locked)
Modules linked in: snd_seq_dummy fuse sctp tun 8021q garp stp hidp nfnetlink bnep rfcomm scsi_transport_iscsi nfc caif_socket caif af_802154 phonet af_rxrpc can_bcm can_raw bluetooth
 can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds ipt_ULOG af_key rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 rfkill xfs libcrc32c snd_hda_codec_realtek snd_hda_co
dec_hdmi coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm crct10dif_pclmul crc32c_intel ghash_clmulni_intel microcode serio_raw pcspkr usb_debug snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_s
eq_device e1000e ptp shpchp snd_pcm pps_core snd_page_alloc snd_timer snd soundcore
CPU: 0 PID: 14132 Comm: modprobe Not tainted 3.13.0-rc4+ #5
 ffff88024e217108 ffff88000870fad0 ffffffff816db2f5 ffffea00043c1700
 ffff88000870fae8 ffffffff816d8b05 ffff88024e2170f8 ffff88000870fbd0
 ffffffff8113be1e 0000000000000000 0000000000000000 ffff88024e5d4d08
Call Trace:
 [<ffffffff816db2f5>] dump_stack+0x4e/0x7a
 [<ffffffff816d8b05>] bad_page.part.71+0xcf/0xe8
 [<ffffffff8113be1e>] get_page_from_freelist+0x80e/0x950
 [<ffffffff8117e1b1>] ? alloc_pages_vma+0xf1/0x1b0
 [<ffffffff8117c6e6>] ? alloc_pages_current+0x106/0x1f0
 [<ffffffff8113c178>] __alloc_pages_nodemask+0x218/0xab0
 [<ffffffff81132c55>] ? find_get_page+0x5/0x110
 [<ffffffff8103cf27>] ? pte_alloc_one+0x17/0x70
 [<ffffffff8117c6e6>] alloc_pages_current+0x106/0x1f0
 [<ffffffff8103cf27>] ? pte_alloc_one+0x17/0x70
 [<ffffffff8103cf27>] pte_alloc_one+0x17/0x70
 [<ffffffff8115a027>] __pte_alloc+0x27/0x130
 [<ffffffff8115df9c>] handle_mm_fault+0xafc/0xbb0
 [<ffffffff816e9321>] ? __do_page_fault+0x101/0x610
 [<ffffffff816e938f>] __do_page_fault+0x16f/0x610
 [<ffffffff810f7d7f>] ? __acct_update_integrals+0x7f/0x100
 [<ffffffff816e5591>] ? _raw_spin_unlock+0x31/0x50
 [<ffffffff8108c381>] ? vtime_account_user+0x91/0xa0
 [<ffffffff811318bb>] ? context_tracking_user_exit+0x9b/0x100
 [<ffffffff816e984a>] do_page_fault+0x1a/0x70
 [<ffffffff816e6492>] page_fault+0x22/0x30

CPU: 2 PID: 14107 Comm: trinity-c88 Tainted: G    B        3.13.0-rc4+ #5
 ffffffff81a28ae4 ffff8801577d7d30 ffffffff816db2f5 0000000000000000
 ffff8801577d7d68 ffffffff810529ad ffffffffffffffff ffff8801577d7da0
 0000000000000000 0000000000000001 ffffea00043c1700 ffff8801577d7d78
Call Trace:
 [<ffffffff816db2f5>] dump_stack+0x4e/0x7a
 [<ffffffff810529ad>] warn_slowpath_common+0x7d/0xa0
 [<ffffffff81052a8a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff81142834>] truncate_inode_pages_range+0x5e4/0x610
 [<ffffffff811428c7>] truncate_pagecache+0x47/0x60
 [<ffffffff811428f2>] truncate_setsize+0x12/0x20
 [<ffffffff811e8652>] put_aio_ring_file.isra.11+0x22/0x80
 [<ffffffff811e871f>] aio_free_ring+0x6f/0xf0
 [<ffffffff811e9c5a>] SyS_io_setup+0x59a/0xbe0
 [<ffffffff816edb24>] tracesys+0xdd/0xe2

Interesting that CPU2 was doing sys_io_setup again. Different trace though.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
