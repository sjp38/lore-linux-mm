Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id BE19B6B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 13:46:01 -0500 (EST)
Received: by qgea14 with SMTP id a14so94420871qge.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 10:46:01 -0800 (PST)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id a64si10126376qha.61.2015.12.09.10.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 10:46:01 -0800 (PST)
Received: by qgcc31 with SMTP id c31so94288771qgc.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 10:46:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1449300220-30108-1-git-send-email-kuleshovmail@gmail.com>
References: <1449300220-30108-1-git-send-email-kuleshovmail@gmail.com>
Date: Wed, 9 Dec 2015 10:46:00 -0800
Message-ID: <CAA9_cmeeOXKzohqg+vF4eUcdRP8eiX-Ydq+-G2pUYybXkyN6fA@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: use memblock_insert_region() for the empty array
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Dec 4, 2015 at 11:23 PM, Alexander Kuleshov
<kuleshovmail@gmail.com> wrote:
> We have the special case for an empty array in the memblock_add_range()
> function. In the same time we have almost the same functional in the
> memblock_insert_region() function. Let's use the memblock_insert_region()
> instead of direct initialization.
>
> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
> ---
>  mm/memblock.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index d300f13..e8a897d 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -496,12 +496,16 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
>         struct memblock_region *rgn = &type->regions[idx];
>
>         BUG_ON(type->cnt >= type->max);
> -       memmove(rgn + 1, rgn, (type->cnt - idx) * sizeof(*rgn));
> +       /* special case for empty array */
> +       if (idx)
> +       {
> +               memmove(rgn + 1, rgn, (type->cnt - idx) * sizeof(*rgn));
> +               type->cnt++;
> +       }
>         rgn->base = base;
>         rgn->size = size;
>         rgn->flags = flags;
>         memblock_set_region_node(rgn, nid);
> -       type->cnt++;
>         type->total_size += size;
>  }
>
> @@ -536,11 +540,7 @@ int __init_memblock memblock_add_range(struct memblock_type *type,
>         /* special case for empty array */
>         if (type->regions[0].size == 0) {
>                 WARN_ON(type->cnt != 1 || type->total_size);
> -               type->regions[0].base = base;
> -               type->regions[0].size = size;
> -               type->regions[0].flags = flags;
> -               memblock_set_region_node(&type->regions[0], nid);
> -               type->total_size = size;
> +               memblock_insert_region(type, 0, base, size, nid, flags);
>                 return 0;
>         }
>  repeat:
> --

Latest -next (20151209) fails to boot due to this patch.  Here's the
backlog.  Also reported here with a different failing signature:
https://lkml.org/lkml/2015/12/9/340


[    0.860371] BUG: unable to handle kernel paging request at ffff880000099000
[    0.862642] IP: [<ffffffff814686f4>] __memset+0x24/0x30
[    0.864010] PGD 2f6a067 PUD 2f6b067 PMD 2f6c067 PTE 8000000000099161
[    0.865787] Oops: 0003 [#1] SMP
[    0.866856] Dumping ftrace buffer:
[    0.867823]    (ftrace buffer empty)
[    0.868850] Modules linked in:
[    0.869870] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.4.0-rc4+ #2187
[    0.871322] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.872761] task: ffff88030e490000 ti: ffff88030e498000 task.ti:
ffff88030e498000
[    0.874818] RIP: 0010:[<ffffffff814686f4>]  [<ffffffff814686f4>]
__memset+0x24/0x30
[    0.876979] RSP: 0000:ffff88030e49b878  EFLAGS: 00010206
[    0.878331] RAX: 5a5a5a5a5a5a5a5a RBX: ffff88031314e300 RCX: 0000000000000600
[    0.879945] RDX: 0000000000000000 RSI: 000000000000005a RDI: ffff880000099000
[    0.881559] RBP: ffff88030e49b8c8 R08: ffffffff81cbf9b4 R09: ffff880000098000
[    0.883185] R10: 0000000000000000 R11: ffffffff81cbf992 R12: 0000000000000002
[    0.884797] R13: 0000000000020022 R14: 0000000000098000 R15: ffffea0000002600
[    0.886344] FS:  0000000000000000(0000) GS:ffff88031fc00000(0000)
knlGS:0000000000000000
[    0.888462] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.889870] CR2: ffff880000099000 CR3: 0000000001e09000 CR4: 00000000000006f0
[    0.892214] Stack:
[    0.892964]  ffffffff8122a2a7 ffff88030e49b8b0 000000028121e4f4
00400000ffffffff
[    0.895271]  ffff880000098000 00000000024080c0 ffff8803131988c0
0000000000000001
[    0.897563]  ffff88031314e300 ffff88031ffeb120 ffff88030e49b9a8
ffffffff8122bf83
[    0.899872] Call Trace:
[    0.900686]  [<ffffffff8122a2a7>] ? new_slab+0x4a7/0x530
[    0.901970]  [<ffffffff8122bf83>] ___slab_alloc+0x353/0x550
[    0.903291]  [<ffffffff812d89b1>] ? __kernfs_new_node+0x41/0xc0
[    0.904765]  [<ffffffff810f5de1>] ? mark_held_locks+0x71/0x90
[    0.906076]  [<ffffffff812d89b1>] ? __kernfs_new_node+0x41/0xc0
[    0.907548]  [<ffffffff8122c1d1>] __slab_alloc+0x51/0x90
[    0.908835]  [<ffffffff812d89b1>] ? __kernfs_new_node+0x41/0xc0
[    0.910193]  [<ffffffff8122c3b6>] kmem_cache_alloc+0x1a6/0x1f0
[    0.911658]  [<ffffffff812d89b1>] __kernfs_new_node+0x41/0xc0
[    0.912987]  [<ffffffff812d9be6>] kernfs_new_node+0x26/0x50
[    0.914336]  [<ffffffff812db605>] __kernfs_create_file+0x35/0xd0
[    0.915800]  [<ffffffff812dbee0>] sysfs_add_file_mode_ns+0x90/0x1b0
[    0.917243]  [<ffffffff812dc188>] sysfs_add_file+0x18/0x20
[    0.918584]  [<ffffffff812dc946>] sysfs_merge_group+0x56/0xc0
[    0.919937]  [<ffffffff8159b406>] dpm_sysfs_add+0x76/0xd0
[    0.921983]  [<ffffffff8159027c>] device_add+0x45c/0x6a0
[    0.923295]  [<ffffffff810f5fbd>] ? trace_hardirqs_on+0xd/0x10
[    0.924639]  [<ffffffff814e25a5>] acpi_device_add+0x1fd/0x297
[    0.926004]  [<ffffffff814e27c7>] ? acpi_free_pnp_ids+0x50/0x50
[    0.927331]  [<ffffffff814e3233>] acpi_add_single_object+0x4ef/0x55c
[    0.928812]  [<ffffffff814dc9ea>] ? acpi_os_signal_semaphore+0x29/0x35
[    0.930282]  [<ffffffff814e3372>] acpi_bus_check_add+0xd2/0x195
[    0.931712]  [<ffffffff8150190b>] acpi_ns_walk_namespace+0xdf/0x18f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
