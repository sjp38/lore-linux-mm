Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 519CD6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 19:22:23 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so2028952eaj.3
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 16:22:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 46si12783719eem.46.2014.03.06.16.22.20
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 16:22:21 -0800 (PST)
Date: Thu, 6 Mar 2014 19:22:10 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140307002210.GA26603@redhat.com>
References: <20140305174503.GA16335@redhat.com>
 <20140305175725.GB16335@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140305175725.GB16335@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Mar 05, 2014 at 12:57:25PM -0500, Dave Jones wrote:
 > On Wed, Mar 05, 2014 at 12:45:03PM -0500, Dave Jones wrote:
 >  > I just saw this on my box that's been running trinity..
 >  > 
 >  > [48825.517189] BUG: Bad rss-counter state mm:ffff880177921d40 idx:0 val:1 (Not tainted)
 >  > 
 >  > There's nothing else, no trace, nothing.  Any ideas where to begin with this?
 > 
 > ah, on the serial console there was also this truncated warning..
 > 
 > [48825.517189] BUG: Bad rss-counter state mm:ffff880177921d40 idx:0 val:1 (Not tainted)
 > [48924.133273] ------------[ cut here ]------------
 > [48924.133391] kernel BUG at include/linux/swapops.h:131!
 > 
 > 	Dave
 > 
 > 124 static inline struct page *migration_entry_to_page(swp_entry_t entry)
 > 125 {
 > 126         struct page *p = pfn_to_page(swp_offset(entry));
 > 127         /*
 > 128          * Any use of migration entries may only occur while the
 > 129          * corresponding page is locked
 > 130          */
 > 131         BUG_ON(!PageLocked(p));
 > 132         return p;
 > 133 }

I hit this again, this time a full trace made it over the serial console.
This time there was no bad rss-counter message though.

kernel BUG at include/linux/swapops.h:131!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in: snd_seq_dummy fuse hidp tun bnep rfcomm llc2 af_key ipt_ULOG can_raw nfnetlink scsi_transport_iscsi nfc caif_socket caif af_802154 phonet af_rxrpc can_bcm can pppoe pppox ppp_generic slhc irda crc_ccitt rds rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 xfs libcrc32c coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm crct10dif_pclmul crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic microcode pcspkr serio_raw btusb bluetooth 6lowpan_iphc rfkill usb_debug shpchp snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm e1000e ptp snd_timer snd pps_core soundcore
CPU: 2 PID: 10002 Comm: trinity-c36 Not tainted 3.14.0-rc5+ #131 
task: ffff880108966750 ti: ffff88018911a000 task.ti: ffff88018911a000
RIP: 0010:[<ffffffff9d72d129>]  [<ffffffff9d72d129>] migration_entry_to_page.part.47+0x4/0x6
RSP: 0000:ffff88018911bae8  EFLAGS: 00010246
RAX: ffffea00048a8980 RBX: ffff8801a08ae020 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 3c00000000122a26
RBP: ffff88018911bae8 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: fffffffffffffffe R12: 0000000024544c3c
R13: ffff88018911bc18 R14: 0000000040c00000 R15: 0000000040a04000
FS:  0000000000000000(0000) GS:ffff88024d080000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000001 CR3: 00000001e3c27000 CR4: 00000000001407e0
DR0: 0000000000ab5000 DR1: 0000000001008000 DR2: 0000000002230000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff88018911bbc8 ffffffff9d17ec1e 0000000040d65fff 0000000040d65fff
 ffff8801e3c27000 0000000040d66000 ffff88011c72e008 0000000040d66000
 0000000040d65fff 0000000000000001 0000000040d66000 ffff88018911bb98
Call Trace:
 [<ffffffff9d17ec1e>] unmap_single_vma+0x89e/0x8a0
 [<ffffffff9d17fd49>] unmap_vmas+0x49/0x90
 [<ffffffff9d1890f5>] exit_mmap+0xe5/0x1a0
 [<ffffffff9d068d13>] mmput+0x73/0x110
 [<ffffffff9d06d022>] do_exit+0x2a2/0xb50
 [<ffffffff9d07bb63>] ? __sigqueue_free.part.11+0x33/0x40
 [<ffffffff9d07c39c>] ? __dequeue_signal+0x13c/0x220
 [<ffffffff9d06e8cc>] do_group_exit+0x4c/0xc0
 [<ffffffff9d07fd41>] get_signal_to_deliver+0x2d1/0x6d0
 [<ffffffff9d0024c7>] do_signal+0x57/0x9d0
 [<ffffffff9d11003e>] ? __acct_update_integrals+0x8e/0x120
 [<ffffffff9d73d66b>] ? preempt_count_sub+0x6b/0xf0
 [<ffffffff9d738ec1>] ? _raw_spin_unlock+0x31/0x50
 [<ffffffff9d0aa0b1>] ? vtime_account_user+0x91/0xa0
 [<ffffffff9d15215b>] ? context_tracking_user_exit+0x9b/0x100
 [<ffffffff9d002eb1>] do_notify_resume+0x71/0xc0
 [<ffffffff9d739c06>] retint_signal+0x46/0x90
Code: df 48 c1 ff 06 49 01 fc 4c 89 e7 e8 79 ff ff ff 85 c0 74 0c 4c 89 e0 48 c1 e0 06 48 29 d8 eb 02 31 c0 5b 41 5c 5d c3 55 48 89 e5 <0f> 0b 55 48 89 e5 0f 0b 55 48 89 e5 0f 0b 55 31 f6 48 89 e5 e8


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
