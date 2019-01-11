Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id C06AB8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 18:47:10 -0500 (EST)
Received: by mail-vk1-f199.google.com with SMTP id l202so3467628vke.1
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:47:10 -0800 (PST)
Received: from vern.gendns.com (vern.gendns.com. [98.142.107.122])
        by mx.google.com with ESMTPS id s80si18290707vse.347.2019.01.11.15.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 15:47:09 -0800 (PST)
Subject: Re: [PATCH v2] rbtree: fix the red root
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
From: David Lechner <david@lechnology.com>
Message-ID: <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
Date: Fri, 11 Jan 2019 17:47:05 -0600
MIME-Version: 1.0
In-Reply-To: <20190111205843.25761-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, joeypabalinas@gmail.com, walken@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/11/19 2:58 PM, Qian Cai wrote:
> A GPF was reported,
> 
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
>          kasan_die_handler.cold.22+0x11/0x31
>          notifier_call_chain+0x17b/0x390
>          atomic_notifier_call_chain+0xa7/0x1b0
>          notify_die+0x1be/0x2e0
>          do_general_protection+0x13e/0x330
>          general_protection+0x1e/0x30
>          rb_insert_color+0x189/0x1480
>          create_object+0x785/0xca0
>          kmemleak_alloc+0x2f/0x50
>          kmem_cache_alloc+0x1b9/0x3c0
>          getname_flags+0xdb/0x5d0
>          getname+0x1e/0x20
>          do_sys_open+0x3a1/0x7d0
>          __x64_sys_open+0x7e/0xc0
>          do_syscall_64+0x1b3/0x820
>          entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> It turned out,
> 
> gparent = rb_red_parent(parent);
> tmp = gparent->rb_right; <-- GPF was triggered here.
> 
> Apparently, "gparent" is NULL which indicates "parent" is rbtree's root
> which is red. Otherwise, it will be treated properly a few lines above.
> 
> /*
>   * If there is a black parent, we are done.
>   * Otherwise, take some corrective action as,
>   * per 4), we don't want a red root or two
>   * consecutive red nodes.
>   */
> if(rb_is_black(parent))
> 	break;
> 
> Hence, it violates the rule #1 (the root can't be red) and need a fix
> up, and also add a regression test for it. This looks like was
> introduced by 6d58452dc06 where it no longer always paint the root as
> black.
> 
> Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only
> when necessary)
> Reported-by: Esme <esploit@protonmail.ch>
> Tested-by: Joey Pabalinas <joeypabalinas@gmail.com>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---

Tested-by: David Lechner <david@lechnology.com>

FWIW, this fixed the following crash for me:

Unable to handle kernel NULL pointer dereference at virtual address 00000004
pgd = (ptrval)
[00000004] *pgd=00000000
Internal error: Oops: 5 [#1] PREEMPT ARM
Modules linked in:
CPU: 0 PID: 1 Comm: swapper Not tainted 5.0.0-rc1-00126-g27b09b277853 #1360
Hardware name: Generic DA850/OMAP-L138/AM18x
PC is at rb_insert_color+0x1c/0x1a4
LR is at kernfs_link_sibling+0x94/0xcc
pc : [<c04b95ec>]    lr : [<c014bfdc>]    psr: 60000013
sp : c2831b38  ip : 00000000  fp : c06b762c
r10: 00000000  r9 : c06b835c  r8 : 00000000
r7 : c2963f00  r6 : c066b028  r5 : c2016cc0  r4 : 00000000
r3 : 00000000  r2 : c2983010  r1 : c2963f2c  r0 : c2016cd0
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 0005317f  Table: c0004000  DAC: 00000053
Process swapper (pid: 1, stack limit = 0x(ptrval))
Stack: (0xc2831b38 to 0xc2832000)
1b20:                                                       00000000 c2016cc0
1b40: c066b028 c014bfdc c2016cc0 c2963f00 c066b028 c014c768 c2963f00 c014c448
1b60: 00000000 c2016cc0 c2963f00 c066b028 c2963f00 c014c860 00000000 00000001
1b80: c0589938 c2b4b408 00000000 c014ec70 00000000 c2b4b408 00000000 c04c4cb0
1ba0: 0000070f 00000000 00000000 9fd04dd9 00000000 c2b4b408 c066b028 00000000
1bc0: c293ac98 c04b58f8 c059081c 00000000 c2b4b408 c066b028 00000000 00000000
1be0: 00000000 c04b5d64 c2831c08 9fd04dd9 c2b4b3c0 c293ac80 c2bd16c0 c2b4b408
1c00: c00d650c c059081c c2bd16c0 c28e3a80 c2b4b3c0 00000000 c2b4b3c0 00000000
1c20: c06b7634 00020000 c06b835c c00d72f8 00000000 c00b0c24 00000000 00000074
1c40: c0590728 00000000 c0590728 c2b4b3c0 00000074 c0590728 00020000 00000000
1c60: c06b762c c00b0958 00000000 00380bc6 00000000 c06bbf1c c2bd9c00 c2bfe000
1c80: c06bbf14 0000000c 00000000 00000000 c2831e0c c00b0a90 00000000 00000000
1ca0: 00000000 00000000 003b2580 c017d6e4 00000000 00000000 00000000 c2bfe000
1cc0: c2bd9c00 00000000 003b2580 00000000 00000000 c01971a0 00001103 00000000
1ce0: c2bd8400 00000400 00000400 9fd04dd9 00000000 0000000a 00000002 00000000
1d00: ffffffff 00000000 ffffffff 00000000 00000000 00000001 00000a04 00000032
1d20: 00000000 0000000c 00000004 c00af550 c2bd9ecc 9fd04dd9 c2404480 c2bd9eb4
1d40: c2bd8400 c2404480 00000002 00000001 00000000 00000000 00000001 00000000
1d60: 00000000 00000000 00000000 00000000 00000000 00000000 00000001 00000000
1d80: 00380bc6 00000000 003b257f 00000000 00000077 0000ffff 00000200 00000002
1da0: 00000001 0000ffff 00000000 00000401 c2bfe22c 00000000 00000000 00000000
1dc0: 00000000 00000000 c2012400 c24be100 00001000 00000000 c2404480 00000000
1de0: 00004003 9fd04dd9 00000000 c2bd9c00 c2404480 00000083 c24044fc 00008000
1e00: 00000000 00000020 00008000 c00e4d88 c2404480 00000000 00000000 c0190afc
1e20: c2bd0be0 c0692898 c0692898 00000000 00000020 c0190b10 c0194f48 c2bd0be0
1e40: c066b370 c00e568c c29f5000 c01002d4 c29f5000 c2bd0be0 00008000 c0100488
1e60: c0692898 00000000 c066b028 c2bd0be0 c2bd0bc0 c01033ec 00000000 ffffff00
1e80: ffff0a00 c0575ff4 c2bd0be0 c281a010 c2417098 c2bd0be0 0000000a 00000000
1ea0: 0000000a 9fd04dd9 0000000a c2bd0be0 c2bd0bc0 00000000 c0575ff8 00008000
1ec0: c066b028 00008000 c0575ff4 c0104178 00000000 00000000 c2014000 c2014005
1ee0: c0575ff8 c3fb1280 c0652868 c062b1ec 00000000 c01013d8 c24c3558 00000000
1f00: 00000000 00006180 c24c3558 c00f17c4 e10c76ac 0b300002 c2858015 c281a010
1f20: c2415da8 9fd04dd9 00000000 00000002 c06ad310 c066b028 c066da68 00000000
1f40: 00000000 00000000 00000000 c062b478 00000000 c0037200 00306b6c 9fd00000
1f60: c0576098 9fd04dd9 00000002 c06ad310 c0652878 00000000 00000000 00000000
1f80: 00000000 00000000 00000000 c062b5e4 00000000 00000000 00000000 00000000
1fa0: c04c7860 c04c7868 00000000 c00090e0 00000000 00000000 00000000 00000000
1fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
[<c04b95ec>] (rb_insert_color) from [<c014bfdc>] (kernfs_link_sibling+0x94/0xcc)
[<c014bfdc>] (kernfs_link_sibling) from [<c014c768>] (kernfs_add_one+0x90/0x140)
[<c014c768>] (kernfs_add_one) from [<c014c860>] (kernfs_create_dir_ns+0x48/0x74)
[<c014c860>] (kernfs_create_dir_ns) from [<c014ec70>] (sysfs_create_dir_ns+0x68/0xd0)
[<c014ec70>] (sysfs_create_dir_ns) from [<c04b58f8>] (kobject_add_internal+0x9c/0x2c4)
[<c04b58f8>] (kobject_add_internal) from [<c04b5d64>] (kobject_init_and_add+0x54/0x94)
[<c04b5d64>] (kobject_init_and_add) from [<c00d650c>] (sysfs_slab_add+0x10c/0x220)
[<c00d650c>] (sysfs_slab_add) from [<c00d72f8>] (__kmem_cache_create+0x1d8/0x338)
[<c00d72f8>] (__kmem_cache_create) from [<c00b0958>] (kmem_cache_create_usercopy+0x180/0x298)
[<c00b0958>] (kmem_cache_create_usercopy) from [<c00b0a90>] (kmem_cache_create+0x20/0x28)
[<c00b0a90>] (kmem_cache_create) from [<c017d6e4>] (ext4_mb_init+0x374/0x44c)
[<c017d6e4>] (ext4_mb_init) from [<c01971a0>] (ext4_fill_super+0x2258/0x2ef0)
[<c01971a0>] (ext4_fill_super) from [<c00e4d88>] (mount_bdev+0x154/0x18c)
[<c00e4d88>] (mount_bdev) from [<c0190b10>] (ext4_mount+0x14/0x20)
[<c0190b10>] (ext4_mount) from [<c00e568c>] (mount_fs+0x14/0xa8)
[<c00e568c>] (mount_fs) from [<c0100488>] (vfs_kern_mount+0x48/0xf0)
[<c0100488>] (vfs_kern_mount) from [<c01033ec>] (do_mount+0x180/0xb9c)
[<c01033ec>] (do_mount) from [<c0104178>] (ksys_mount+0x8c/0xb4)
[<c0104178>] (ksys_mount) from [<c062b1ec>] (mount_block_root+0x128/0x2a4)
[<c062b1ec>] (mount_block_root) from [<c062b478>] (mount_root+0x110/0x154)
[<c062b478>] (mount_root) from [<c062b5e4>] (prepare_namespace+0x128/0x188)
[<c062b5e4>] (prepare_namespace) from [<c04c7868>] (kernel_init+0x8/0xf4)
[<c04c7868>] (kernel_init) from [<c00090e0>] (ret_from_fork+0x14/0x34)
Exception stack(0xc2831fb0 to 0xc2831ff8)
1fa0:                                     00000000 00000000 00000000 00000000
1fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1fe0: 00000000 00000000 00000000 00000000 00000013 00000000
Code: e5923000 e3130001 1a000054 e92d4070 (e593c004)
---[ end trace 1c5a7737a0eab0f2 ]---
Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b ]---
