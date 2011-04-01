Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 33B198D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 17:28:06 -0400 (EDT)
Date: Fri, 1 Apr 2011 16:28:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: kernel BUG at mm/slub.c:1193!
In-Reply-To: <201104012053.30458.johannes.hirte@fem.tu-ilmenau.de>
Message-ID: <alpine.DEB.2.00.1104011625550.27326@router.home>
References: <201104012053.30458.johannes.hirte@fem.tu-ilmenau.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Which kernel version is this? Line 1193 in upstream is not in the function
new_slab(). If this is the BUG_ON in new_slab() then we have an issue with
illegal flags being passed to kmem_cache_alloc().

On Fri, 1 Apr 2011, Johannes Hirte wrote:

> When I tried to create squashfs image my system suprised me with a
>
> ------------[ cut here ]------------
> kernel BUG at mm/slub.c:1193!
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/devices/virtual/block/loop0/uevent
> CPU 1
> Modules linked in: ext4 mbcache jbd2 crc16 snd_seq_midi snd_emu10k1_synth
> snd_emux_synth snd_seq_virmidi snd_seq_midi_emul snd_seq_oss
> snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_emu10k1 snd_rawmidi
> snd_ac97_codec ac97_bus snd_pcm snd_seq_device snd_timer snd_page_alloc
> snd_util_mem snd_hwdep snd sg ohci_hcd sr_mod 3w_xxxx uhci_hcd sata_sil
> i2c_amd756 i2c_amd8111 amd64_edac_mod edac_core k8temp hwmon edac_mce_amd
>
> Pid: 7298, comm: mksquashfs Tainted: G        W   2.6.38.1 #1 To Be Filled By
> O.E.M. To Be Filled By O.E.M./TYAN Tiger K8W Dual AMD Opteron, S2875
> RIP: 0010:[<ffffffff81098ebb>]  [<ffffffff81098ebb>] new_slab+0x16/0x20e
> RSP: 0000:ffff8800068bd688  EFLAGS: 00010202
> RAX: 0000000000000000 RBX: ffff8800bb30c6c0 RCX: ffff8800068bd6d0
> RDX: 00000000ffffffff RSI: 000000000002011a RDI: ffff8800bb30c6c0
> RBP: ffff8800bb30c6c0 R08: ffff8800bfc97fe8 R09: 0000000000000000
> R10: dead000000200200 R11: dead000000100100 R12: 00000000ffffffff
> R13: 0000000000000010 R14: 00000000ffffffff R15: ffff8800068bd6d0
> FS:  00007f3b6bf06700(0000) GS:ffff8800bfc80000(0000) knlGS:00000000f760fb40
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000002d8b84f CR3: 000000000689a000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process mksquashfs (pid: 7298, threadinfo ffff8800068bc000, task ffff8800bc25a6f0)
> Stack:
>  ffff8800bb30c6c0 000000000002011a 00000000ffffffff 0000000000000010
>  0000000000000003 ffffffff81099287 0000000000000000 ffffffff811cac77
>  ffff8800b992c038 0000000000000000 ffff8800bb30c6c0 ffff8800bb30c6c0
> Call Trace:
>  [<ffffffff81099287>] ? __slab_alloc+0x1d4/0x2ba
>  [<ffffffff811cac77>] ? alloc_extent_state+0x12/0x55
>  [<ffffffff811cac77>] ? alloc_extent_state+0x12/0x55
>  [<ffffffff810995e6>] ? kmem_cache_alloc+0x5a/0x86
>  [<ffffffff811cac77>] ? alloc_extent_state+0x12/0x55
>  [<ffffffff811cb6cf>] ? clear_extent_bit+0x92/0x31d
>  [<ffffffff811ce572>] ? try_release_extent_state+0x74/0x84
>  [<ffffffff811ac624>] ? btree_releasepage+0x3e/0x76
>  [<ffffffff81073939>] ? shrink_page_list+0x32d/0x4d6
>  [<ffffffff81073ec4>] ? shrink_inactive_list+0x1d4/0x2ab
>  [<ffffffff8102ae1e>] ? enqueue_task_fair+0x14a/0x167
>  [<ffffffff8107450a>] ? shrink_zone+0x2ec/0x3da
>  [<ffffffff81074924>] ? try_to_free_pages+0xf6/0x2f2
>  [<ffffffff8106f0ec>] ? __alloc_pages_nodemask+0x4b2/0x71a
>  [<ffffffff810706aa>] ? __do_page_cache_readahead+0x96/0x1b5
>  [<ffffffff81070a8e>] ? ra_submit+0x1c/0x23
>  [<ffffffff81070cba>] ? page_cache_async_readahead+0x7b/0xaa
>  [<ffffffff81068d8f>] ? find_get_page+0x18/0x69
>  [<ffffffff81069fc3>] ? generic_file_aio_read+0x2a0/0x5b0
>  [<ffffffff8118d791>] ? xfs_file_aio_read+0x1b3/0x209
>  [<ffffffff8107faf1>] ? handle_pte_fault+0x23f/0x665
>  [<ffffffff810a08ab>] ? do_sync_read+0xb1/0xea
>  [<ffffffff810801d6>] ? handle_mm_fault+0x1dd/0x24c
>  [<ffffffff81225846>] ? __percpu_counter_add+0x30/0x4f
>  [<ffffffff81084ba4>] ? do_brk+0x278/0x2cb
>  [<ffffffff810a0eb4>] ? vfs_read+0xac/0x126
>  [<ffffffff810a0f73>] ? sys_read+0x45/0x6e
>  [<ffffffff81001f3b>] ? system_call_fastpath+0x16/0x1b
> Code: c0 74 0b 48 83 c4 08 48 89 ef 5b 5d ff e0 48 83 c4 08 5b 5d c3 41 56 f7
> c6 06 00 80 ff 41 89 d6 41 55 41 54 55 48 89 fd 53 74 02 <0f> 0b 41 89 f4 4c 8b
> 6f 20 41 81 e4 f0 1e 07 00 44 0b 67 38 4c
> RIP  [<ffffffff81098ebb>] new_slab+0x16/0x20e
>  RSP <ffff8800068bd688>
> ---[ end trace 56d1588e41a62ee3 ]---
>
> The system was idle except for the mksquashfs process. If more infos are
> needed please tell me.
>
> regards,
>   Johannes
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
