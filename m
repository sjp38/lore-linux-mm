Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8D4A8E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 13:31:00 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id o23so10416647pll.0
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 10:31:00 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f1si28315972pld.92.2018.12.24.10.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Dec 2018 10:30:59 -0800 (PST)
Subject: Re: Invalid opcode in khugepaged
References: <2aa66a9c-b8dc-b630-11e6-234dbce68b5b@gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <1644239b-560b-1c0b-2333-cfb65106949f@oracle.com>
Date: Mon, 24 Dec 2018 10:30:26 -0800
MIME-Version: 1.0
In-Reply-To: <2aa66a9c-b8dc-b630-11e6-234dbce68b5b@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiner Kallweit <hkallweit1@gmail.com>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Jerome Glisse <jglisse@redhat.com>

Adding people more familiar with this code and changes that went into 4.20.

On 12/24/18 3:02 AM, Heiner Kallweit wrote:
> I just got the following error. It's for the first time that I see it.
> It happened whilst machine was idle, nothing special running.
> 
> See also second error below. Not sure whether both errors may be related.
> 
> [17932.571487] invalid opcode: 0000 [#1] SMP
> [17932.571518] CPU: 2 PID: 203 Comm: khugepaged Not tainted 4.20.0-rc7-next-20181221+ #2
> [17932.571550] Hardware name: NA ZBOX-CI327NANO-GS-01/ZBOX-CI327NANO-GS-01, BIOS 5.12 04/26/2018
> [17932.571614] RIP: 0010:khugepaged+0x2a2/0x2280
> [17932.571640] Code: c0 48 8b 4d d0 65 48 33 0c 25 28 00 00 00 0f 85 22 1e 00 00 48 8d 65 d8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8 30 43 ec ff e9 1e <fe> ff ff 48 8d 45 a0 48 8b 15 88 cc cc 00 49 c7 c4 90 f5 aa 85 48
> [17932.571721] RSP: 0018:ffffab4b801f7dc0 EFLAGS: 00010286
> [17932.571751] RAX: 0000000000000000 RBX: 0000000000002710 RCX: 0000000000000000
> [17932.571786] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff94c23a8c2a80
> [17932.571820] RBP: ffffab4b801f7f9a R08: 0000000000000000 R09: 0000000000000000
> [17932.571855] R10: 0000000000000000 R11: 0000000000000000 R12: ffffab4b801f7e20
> [17932.571890] R13: ffffffff86862720 R14: 0000000000000000 R15: 00000000000000d0
> [17932.571928] FS:  0000000000000000(0000) GS:ffff94c23bb00000(0000) knlGS:0000000000000000
> [17932.571967] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [17932.571997] CR2: 00007f20c458f012 CR3: 0000000171213000 CR4: 00000000003406e0
> [17932.572034] Call Trace:
> [17932.572061]  ? wait_woken+0xa0/0xa0
> [17932.572088]  ? kthread+0x126/0x140
> [17932.572111]  ? __collapse_huge_page_swapin+0x540/0x540
> [17932.572141]  ? kthread_create_on_node+0x60/0x60
> [17932.572172]  ? ret_from_fork+0x3a/0x50
> [17932.572197] Modules linked in: snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic vfat fat x86_pkg_temp_thermal realtek snd_hda_intel i2c_i801 i915 snd_hda_codec r8169 snd_hda_core intel_gtt i2c_algo_bit snd_pcm libphy drm_kms_helper snd_timer syscopyarea sysfillrect sysimgblt fb_sys_fops snd mei_me drm mei usb_storage crypto_user efivarfs ipv6 serio_raw atkbd libps2 xhci_pci xhci_hcd usbcore usb_common i8042 serio ext4 crc32c_intel mbcache jbd2 ahci libahci libata
> [17932.572490] ---[ end trace 67319a943508795f ]---
> [17932.572523] RIP: 0010:khugepaged+0x2a2/0x2280
> [17932.572550] Code: c0 48 8b 4d d0 65 48 33 0c 25 28 00 00 00 0f 85 22 1e 00 00 48 8d 65 d8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8 30 43 ec ff e9 1e <fe> ff ff 48 8d 45 a0 48 8b 15 88 cc cc 00 49 c7 c4 90 f5 aa 85 48
> [17932.572632] RSP: 0018:ffffab4b801f7dc0 EFLAGS: 00010286
> [17932.572681] RAX: 0000000000000000 RBX: 0000000000002710 RCX: 0000000000000000
> [17932.572718] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff94c23a8c2a80
> [17932.572753] RBP: ffffab4b801f7f9a R08: 0000000000000000 R09: 0000000000000000
> [17932.572788] R10: 0000000000000000 R11: 0000000000000000 R12: ffffab4b801f7e20
> [17932.572823] R13: ffffffff86862720 R14: 0000000000000000 R15: 00000000000000d0
> [17932.572860] FS:  0000000000000000(0000) GS:ffff94c23bb00000(0000) knlGS:0000000000000000
> [17932.572900] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [17932.572931] CR2: 00007f20c458f012 CR3: 0000000171213000 CR4: 00000000003406e0
> 
> 
> 
> 
> 
> 
> 
> [47143.912026] BUG: Bad page state in process ls  pfn:16866d
> [47143.912056] page:ffffe8e305a19b40 count:0 mapcount:-107 mapping:000000000000007b index:0x1
> [47143.912083] anon
> [47143.912086] flags: 0x800000000000006b(locked|referenced|dirty|active|workingset)
> [47143.912123] raw: 800000000000006b dead000000000100 dead000000000200 000000000000007b
> [47143.912152] raw: 0000000000000001 0000000000000000 00000000ffffff94 000000000000006a
> [47143.912176] page dumped because: PAGE_FLAGS_CHECK_AT_PREP flag set
> [47143.912196] bad because of flags: 0x6b(locked|referenced|dirty|active|workingset)
> [47143.912222] Modules linked in: snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic vfat fat x86_pkg_temp_thermal realtek snd_hda_intel i2c_i801 i915 snd_hda_codec r8169 snd_hda_core intel_gtt i2c_algo_bit snd_pcm libphy drm_kms_helper snd_timer syscopyarea sysfillrect sysimgblt fb_sys_fops snd mei_me drm mei usb_storage crypto_user efivarfs ipv6 serio_raw atkbd libps2 xhci_pci xhci_hcd usbcore usb_common i8042 serio ext4 crc32c_intel mbcache jbd2 ahci libahci libata
> [47143.912388] CPU: 3 PID: 2535 Comm: ls Tainted: G      D           4.20.0-rc7-next-20181221+ #2
> [47143.912417] Hardware name: NA ZBOX-CI327NANO-GS-01/ZBOX-CI327NANO-GS-01, BIOS 5.12 04/26/2018
> [47143.912446] Call Trace:
> [47143.912465]  dump_stack+0x70/0x9a
> [47143.912482]  bad_page.cold.136+0x80/0xb3
> [47143.912499]  check_new_page_bad+0x5d/0x60
> [47143.912515]  get_page_from_freelist+0xe55/0x1280
> [47143.912535]  __alloc_pages_nodemask+0x11c/0x330
> [47143.912554]  pagecache_get_page+0xb0/0x240
> [47143.912572]  __getblk_gfp+0xf1/0x260
> [47143.912587]  __breadahead+0x21/0x70
> [47143.912635]  __ext4_get_inode_loc+0x3ae/0x490 [ext4]
> [47143.912681]  __ext4_iget+0xe9/0xca0 [ext4]
> [47143.912725]  ext4_lookup+0xfe/0x1f0 [ext4]
> [47143.912742]  __lookup_slow+0x101/0x1f0
> [47143.912759]  lookup_slow+0x35/0x50
> [47143.912774]  walk_component+0x1c1/0x5f0
> [47143.912791]  ? link_path_walk.part.66+0x71/0x560
> [47143.912810]  ? kfree+0x18d/0x240
> [47143.912825]  path_lookupat.isra.68+0x68/0x210
> [47143.912845]  ? get_acl+0x7b/0x110
> [47143.912859]  filename_lookup.part.85+0x9b/0x120
> [47143.912880]  ? __check_object_size+0xa5/0x185
> [47143.912898]  ? strncpy_from_user+0x4f/0x180
> [47143.912915]  user_path_at_empty+0x39/0x40
> [47143.912934]  vfs_statx+0x71/0xd0
> [47143.912949]  __do_sys_newlstat+0x3d/0x70
> [47143.912966]  ? mntput+0x1f/0x30
> [47143.912980]  ? path_put+0x19/0x20
> [47143.912997]  ? trace_hardirqs_off_caller+0x3f/0xf0
> [47143.913016]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> [47143.913034]  ? trace_hardirqs_on+0x22/0xf0
> [47143.913051]  __x64_sys_newlstat+0x11/0x20
> [47143.913067]  do_syscall_64+0x50/0x180
> [47143.913085]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [47143.913104] RIP: 0033:0x7fc9c224ce49
> [47143.913120] Code: 64 c7 00 16 00 00 00 b8 ff ff ff ff c3 0f 1f 40 00 f3 0f 1e fa 48 89 f0 83 ff 01 77 34 48 89 c7 48 89 d6 b8 06 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 07 c3 66 0f 1f 44 00 00 48 8b 15 e1 1f 0d 00
> [47143.913172] RSP: 002b:00007ffef7914218 EFLAGS: 00000246 ORIG_RAX: 0000000000000006
> [47143.913201] RAX: ffffffffffffffda RBX: 000055cb0704b220 RCX: 00007fc9c224ce49
> [47143.913223] RDX: 000055cb0704b238 RSI: 000055cb0704b238 RDI: 00007ffef7914220
> [47143.913246] RBP: 00007ffef79145e0 R08: 0000000000000000 R09: 000055cb0704f65b
> [47143.913269] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffef7914220
> [47143.913291] R13: 0000000000000000 R14: 0000000000000005 R15: 000055cb0704b238
> 
