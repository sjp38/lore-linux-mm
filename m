Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id BDE9F6B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 10:40:46 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so2952152eek.35
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 07:40:46 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id l44si19571712eem.229.2013.12.11.07.40.45
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 07:40:45 -0800 (PST)
Message-ID: <52A8877A.10209@suse.cz>
Date: Wed, 11 Dec 2013 16:40:42 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: oops in pgtable_trans_huge_withdraw
References: <20131206210254.GA7962@redhat.com>
In-Reply-To: <20131206210254.GA7962@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Sasha Levin <sasha.levin@oracle.com>

On 12/06/2013 10:02 PM, Dave Jones wrote:
> I've spent a few days enhancing trinity's use of mmap's, trying to make it
> reproduce https://lkml.org/lkml/2013/12/4/499

FYI, I managed to reproduce that using trinity today,
trinity was from git at commit e8912cc which is from Dec 09 so I guess 
your enhancements were already there?
kernel was linux-next-20131209
I was running trinity -c mmap -c munmap -c mremap -c remap_file_pages -c 
mlock -c munlock

Now I'm running with Kirill's patch, will post results later.

My goal was to reproduce Sasha Levin's BUG in munlock_vma_pages_range
https://lkml.org/lkml/2013/12/7/130

Perhaps it could be related as well.
Sasha, do you know at which commit your trinity clone was at?

Thanks,
Vlastimil

> Instead, I hit this.. related ?
>
> Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> Modules linked in: tun snd_seq_dummy rfcomm fuse hidp bnep can_raw caif_socket caif phonet af_rxrpc llc2 af_key rose netrom pppoe pppox ppp_generic slhc scsi_transport_iscsi bluetooth nfnetlink can_bcm can af_802154 ipt_ULOG nfc irda crc_ccitt rds x25 atm appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 rfkill xfs snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_page_alloc libcrc32c snd_timer e1000e snd coretemp hwmon ptp x86_pkg_temp_thermal shpchp serio_raw pps_core kvm_intel pcspkr kvm crct10dif_pclmul crc32c_intel usb_debug ghash_clmulni_intel soundcore microcode
> CPU: 3 PID: 11758 Comm: trinity-child3 Not tainted 3.13.0-rc2+ #23
> task: ffff8800719415d0 ti: ffff8801cfa74000 task.ti: ffff8801cfa74000
> RIP: 0010:[<ffffffff8118e415>]  [<ffffffff8118e415>] pgtable_trans_huge_withdraw+0x55/0xc0
> RSP: 0000:ffff8801cfa75ac8  EFLAGS: 00010206
> RAX: 00000000060e4800 RBX: 0000000000000000 RCX: 0000000000000027
> RDX: 0000000000000000 RSI: ffff880183920000 RDI: ffff880183920000
> RBP: ffff8801cfa75ae8 R08: ffff880071941cd8 R09: 0000000000000001
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880183920000
> R13: ffffea0000000000 R14: 0000000000000020 R15: 0000000040000000
> FS:  00007f6dd67aa740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000020 CR3: 00000001ce03a000 CR4: 00000000001407e0
> DR0: 0000000000000000 DR1: 00000000018efae0 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000f5060a
> Stack:
>   ffffea0000000000 ffff8801cfa75c40 80000001a82008e7 ffff8801cfa75c40
>   ffff8801cfa75b20 ffffffff811b13e2 ffff8801e0a8e9f0 ffff8801aa3ab000
>   ffffffffffffffff 0000000040200000 ffff8801cfa75c40 ffff8801cfa75bf0
> Call Trace:
>   [<ffffffff811b13e2>] zap_huge_pmd+0x62/0x140
>   [<ffffffff8117ac58>] unmap_single_vma+0x678/0x830
>   [<ffffffff8117bea9>] unmap_vmas+0x49/0x90
>   [<ffffffff81184da5>] exit_mmap+0xc5/0x170
>   [<ffffffff8105104b>] mmput+0x6b/0x100
>   [<ffffffff81055a18>] do_exit+0x298/0xce0
>   [<ffffffff8105782c>] do_group_exit+0x4c/0xc0
>   [<ffffffff8106a671>] get_signal_to_deliver+0x2d1/0x930
>   [<ffffffff810024a8>] do_signal+0x48/0x610
>   [<ffffffff810a9af9>] ? get_lock_stats+0x19/0x60
>   [<ffffffff810aa27e>] ? put_lock_stats.isra.28+0xe/0x30
>   [<ffffffff810aa7de>] ? lock_release_holdtime.part.29+0xee/0x170
>   [<ffffffff8114f18e>] ? context_tracking_user_exit+0x4e/0x190
>   [<ffffffff810ad1f5>] ? trace_hardirqs_on_caller+0x115/0x1e0
>   [<ffffffff81002acc>] do_notify_resume+0x5c/0xa0
>   [<ffffffff817587c6>] retint_signal+0x46/0x90
> Code: c1 e0 06 4a 8b 44 28 30 0f b7 00 38 c4 74 79 4c 89 e7 e8 af 03 eb ff 4c 89 e7 48 c1 e8 0c 48 c1 e0 06 49 8b 5c 05 20 4c 8d 73 20 <4c> 3b 73 20 74 35 e8 90 03 eb ff 4c 89 f7 48 89 c2 48 8b 43 20
> RIP  [<ffffffff8118e415>] pgtable_trans_huge_withdraw+0x55/0xc0
>   RSP <ffff8801cfa75ac8>
>
>
>          pgtable = pmd_huge_pte(mm, pmdp);
>          if (list_empty(&pgtable->lru))
>   231:   4c 8d 73 20             lea    0x20(%rbx),%r14
>   235:   4c 3b 73 20             cmp    0x20(%rbx),%r14		<--- faulting instruction.
>   239:   74 35                   je     270 <pgtable_trans_huge_withdraw+0x90>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
