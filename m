Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f181.google.com (mail-ve0-f181.google.com [209.85.128.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB446B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 23:07:51 -0500 (EST)
Received: by mail-ve0-f181.google.com with SMTP id oy12so341059veb.26
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:07:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id hs8si429848veb.136.2013.12.18.20.07.48
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 20:07:49 -0800 (PST)
Date: Wed, 18 Dec 2013 23:07:38 -0500
From: Dave Jones <davej@redhat.com>
Subject: bad page state in 3.13-rc4
Message-ID: <20131219040738.GA10316@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

Just hit this while fuzzing with lots of child processes. 
(trinity -C128)

BUG: Bad page state in process trinity-c93  pfn:100499
------------[ cut here ]------------
kernel BUG at include/linux/mm.h:439!
invalid opcode: 0000 [#1] PREEMPT SMP 
Modules linked in: dlci sctp snd_seq_dummy hidp fuse rfcomm bnep tun can_raw can_bcm bluetooth can rose phonet pppoe pppox ppp_generic slhc llc2 af_rxrpc af_key netrom caif_socket caif ipt_ULOG nfnetlink nfc af_802154 irda crc_ccitt rds scsi_transport_iscsi x25 atm appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 rfkill xfs snd_hda_codec_hdmi snd_hda_codec_realtek libcrc32c snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer snd shpchp soundcore coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm crct10dif_pclmul crc32c_intel ghash_clmulni_intel microcode serio_raw pcspkr usb_debug e1000e ptp pps_core
CPU: 0 PID: 4408 Comm: trinity-c39 Not tainted 3.13.0-rc4+ #5 
task: ffff88021b1d5be0 ti: ffff88011fd40000 task.ti: ffff88011fd40000
RIP: 0010:[<ffffffff816d8f89>]  [<ffffffff816d8f89>] get_page.part.20+0x4/0x6
RSP: 0018:ffff88011fd418c8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff88024e20f780 RCX: 0000000000017151
RDX: 0000000000000000 RSI: 0000000000000017 RDI: 0000000000000001
RBP: ffff88011fd418c8 R08: fffffffffffffffd R09: 00000000000170f8
R10: ffff88024e5d3e80 R11: 0000000000000017 R12: ffffea0004012640
R13: 0000000000000000 R14: ffffea0004184200 R15: 0000000000000000
FS:  00007f2203b5e740(0000) GS:ffff88024e200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000018ca000 CR3: 000000014dcf4000 CR4: 00000000001407f0
DR0: 0000000000f88000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff88011fd418e8 ffffffff81141385 ffffea0004012640 ffffea0004012642
 ffff88011fd418f8 ffffffff8114161c ffff88011fd41920 ffffffff81145572
 ffffea0004012640 ffffea0004012600 ffffea0004012660 ffff88011fd419a8
Call Trace:
 [<ffffffff81141385>] __lru_cache_add+0xa5/0xc0
 [<ffffffff8114161c>] lru_cache_add+0x1c/0x30
 [<ffffffff81145572>] putback_lru_page+0x72/0xb0
 [<ffffffff8118c3f9>] migrate_pages+0x479/0x780
 [<ffffffff81155480>] ? isolate_freepages_block+0x360/0x360
 [<ffffffff8115638a>] compact_zone+0x2aa/0x460
 [<ffffffff8109ff90>] ? debug_check_no_locks_freed+0xb0/0x150
 [<ffffffff811565d4>] compact_zone_order+0x94/0xe0
 [<ffffffff81156911>] try_to_compact_pages+0xe1/0x110
 [<ffffffff816d8c88>] __alloc_pages_direct_compact+0xac/0x1d0
 [<ffffffff8113c86a>] __alloc_pages_nodemask+0x90a/0xab0
 [<ffffffff8117e1b1>] alloc_pages_vma+0xf1/0x1b0
 [<ffffffff81190e0d>] ? do_huge_pmd_anonymous_page+0xfd/0x3a0
 [<ffffffff81190e0d>] do_huge_pmd_anonymous_page+0xfd/0x3a0
 [<ffffffff8115beec>] ? follow_page_mask+0x24c/0x510
 [<ffffffff8115d919>] handle_mm_fault+0x479/0xbb0
 [<ffffffff816e5591>] ? _raw_spin_unlock+0x31/0x50
 [<ffffffff8115e1fe>] __get_user_pages+0x1ae/0x5f0
 [<ffffffff8116028c>] __mlock_vma_pages_range+0x8c/0xa0
 [<ffffffff81160a00>] __mm_populate+0xc0/0x150
 [<ffffffff8114f486>] vm_mmap_pgoff+0xb6/0xc0
 [<ffffffff81162d16>] SyS_mmap_pgoff+0x116/0x270
 [<ffffffff81010495>] ? syscall_trace_enter+0x145/0x270
 [<ffffffff81007b52>] SyS_mmap+0x22/0x30
 [<ffffffff816edb24>] tracesys+0xdd/0xe2
Code: 48 c8 48 85 d2 48 0f 49 c2 48 01 c8 49 89 06 58 5b 41 5c 41 5d 41 5e 41 5f 5d c3 55 48 89 e5 0f 0b 55 48 89 e5 0f 0b 55 48 89 e5 <0f> 0b 80 3d 59 6a 60 00 00 75 1d 55 be 6c 00 00 00 48 c7 c7 e6 
RIP  [<ffffffff816d8f89>] get_page.part.20+0x4/0x6
 RSP <ffff88011fd418c8>
page:ffffea0004012640 count:0 mapcount:0 mapping:          (null) index:0x389
page flags: 0x2000000000000c(referenced|uptodate)
Modules linked in: dlci sctp snd_seq_dummy hidp fuse rfcomm bnep tun can_raw can_bcm bluetooth can rose phonet pppoe pppox ppp_generic slhc llc2 af_rxrpc af_key netrom caif_socket caif ipt_ULOG nfnetlink nfc af_802154 irda crc_ccitt rds scsi_transport_iscsi x25 atm appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 rfkill xfs snd_hda_codec_hdmi snd_hda_codec_realtek libcrc32c snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer snd shpchp soundcore coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm crct10dif_pclmul crc32c_intel ghash_clmulni_intel microcode serio_raw pcspkr usb_debug e1000e ptp pps_core
CPU: 2 PID: 4395 Comm: trinity-c93 Tainted: G      D      3.13.0-rc4+ #5 
 0000000000000000 ffff88004517fde8 ffffffff816db2f5 ffffea0004012640
 ffff88004517fe00 ffffffff816d8b05 ffffea0004012640 ffff88004517fe38
 ffffffff8113a645 ffffea0004012640 0000000000000000 002000000000001d
Call Trace:
 [<ffffffff816db2f5>] dump_stack+0x4e/0x7a
 [<ffffffff816d8b05>] bad_page.part.71+0xcf/0xe8
 [<ffffffff8113a645>] free_pages_prepare+0x185/0x190
 [<ffffffff8113b085>] free_hot_cold_page+0x35/0x180
 [<ffffffff811403f3>] __put_single_page+0x23/0x30
 [<ffffffff81140665>] put_page+0x35/0x50
 [<ffffffff811e8705>] aio_free_ring+0x55/0xf0
 [<ffffffff811e9c5a>] SyS_io_setup+0x59a/0xbe0
 [<ffffffff816edb24>] tracesys+0xdd/0xe2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
