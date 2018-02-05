Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECC26B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 07:39:54 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 202so3785591pgb.13
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 04:39:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l12-v6sor1450848plc.127.2018.02.05.04.39.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Feb 2018 04:39:53 -0800 (PST)
Date: Mon, 5 Feb 2018 21:39:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: bisected bd4c82c22c367e is the first bad commit (was [Bug
 198617] New: zswap causing random applications to crash)
Message-ID: <20180205123947.GA426@jagdpanzerIV>
References: <20180130114841.aa2d3bd99526c03c6a5b5810@linux-foundation.org>
 <20180203013455.GA739@jagdpanzerIV>
 <CAC=cRTPyh-JTY=uOQf2dgmyPDyY-4+ryxkedp-iZMcFQZtnaqw@mail.gmail.com>
 <20180205013758.GA648@jagdpanzerIV>
 <87d11j4pdy.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d11j4pdy.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, huang ying <huang.ying.caritas@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On (02/05/18 20:00), Huang, Ying wrote:
[..]
> I have successfully reproduced the issue and find the problem.  The
> following patch fix the issue for me, can you try it?

That was quick ;)

> ---------------------------------8<-------------------------------
> From 4c52d531680f91572ebc6f4525a018e32a934ef0 Mon Sep 17 00:00:00 2001
> From: Huang Ying <huang.ying.caritas@gmail.com>
> Date: Mon, 5 Feb 2018 19:27:43 +0800
> Subject: [PATCH] fontswap thp fix

Seems to be fixing the problem on my x86 box. Executed several tests, no
crashes were observed. Can run more tests tomorrow.


============================================================================

Probably unrelated, but may be it is related: my X server used to hang
sometimes (rarely) which I suspect was/is caused by nouveau driver. It,
surprisingly, didn't hang this time around. Nouveau spitted a number
of backtraces, but X server managed to survive it. Any chance that
nouveau-X server thing was caused by THP?


[  308.986648] nouveau 0000:01:00.0: swiotlb buffer is full (sz: 2097152 bytes)
[  308.986653] nouveau 0000:01:00.0: swiotlb: coherent allocation failed, size=2097152
[  308.986657] CPU: 5 PID: 343 Comm: Xorg Not tainted 4.15.0-next-20180205-dbg-00021-ga1282bf979c4-dirty #2480
[  308.986659] Call Trace:
[  308.986667]  dump_stack+0x46/0x59
[  308.986671]  swiotlb_alloc_coherent+0x164/0x174
[  308.986675]  ttm_dma_pool_get_pages+0x16e/0x3ce
[  308.986679]  ttm_dma_populate+0x108/0x2af
[  308.986681]  ttm_tt_bind+0x32/0x57
[  308.986684]  ttm_bo_handle_move_mem+0x120/0x328
[  308.986687]  ? ttm_bo_mem_space+0x170/0x3a0
[  308.986690]  ttm_bo_validate+0x7b/0xd9
[  308.986694]  ? __mutex_trylock_or_owner+0x43/0x54
[  308.986697]  ttm_bo_init_reserved+0x31f/0x38a
[  308.986700]  ttm_bo_init+0x52/0x76
[  308.986703]  ? nouveau_bo_invalidate_caches+0x8/0x8
[  308.986706]  nouveau_bo_new+0x4a8/0x4c7
[  308.986709]  ? nouveau_bo_invalidate_caches+0x8/0x8
[  308.986712]  nouveau_gem_new+0x49/0xcc
[  308.986715]  nouveau_gem_ioctl_new+0x3e/0x9f
[  308.986717]  ? nouveau_gem_new+0xcc/0xcc
[  308.986720]  drm_ioctl_kernel+0x64/0xa0
[  308.986723]  drm_ioctl+0x1d6/0x2a8
[  308.986725]  ? nouveau_gem_new+0xcc/0xcc
[  308.986729]  ? _raw_spin_unlock_irq+0x13/0x24
[  308.986732]  ? free_swap_slot+0xad/0xc2
[  308.986735]  nouveau_drm_ioctl+0x71/0xa4
[  308.986738]  vfs_ioctl+0x1e/0x2b
[  308.986741]  do_vfs_ioctl+0x505/0x518
[  308.986745]  ? __fget+0x5d/0x67
[  308.986747]  SyS_ioctl+0x3e/0x5a
[  308.986751]  do_syscall_64+0x17f/0x196
[  308.986754]  entry_SYSCALL_64_after_hwframe+0x21/0x86
[  308.986757] RIP: 0033:0x7f0395218d87
[  308.986759] RSP: 002b:00007ffc210c4c48 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[  308.986761] RAX: ffffffffffffffda RBX: 000056213e828350 RCX: 00007f0395218d87
[  308.986764] RDX: 00007ffc210c4ca0 RSI: 00000000c0306480 RDI: 000000000000000b
[  308.986765] RBP: 00007ffc210c4ca0 R08: 0000000000000004 R09: 0000000000000006
[  308.986767] R10: 000056213e320010 R11: 0000000000000246 R12: 00000000c0306480
[  308.986769] R13: 000000000000000b R14: 00007ffc210c4d60 R15: 000056213e35e770
[  309.264408] nouveau 0000:01:00.0: swiotlb buffer is full (sz: 2097152 bytes)
[  309.264412] nouveau 0000:01:00.0: swiotlb: coherent allocation failed, size=2097152
[  309.264416] CPU: 4 PID: 343 Comm: Xorg Not tainted 4.15.0-next-20180205-dbg-00021-ga1282bf979c4-dirty #2480
[  309.264418] Call Trace:
[  309.264425]  dump_stack+0x46/0x59
[  309.264429]  swiotlb_alloc_coherent+0x164/0x174
[  309.264434]  ttm_dma_pool_get_pages+0x16e/0x3ce
[  309.264437]  ttm_dma_populate+0x108/0x2af
[  309.264440]  ttm_tt_bind+0x32/0x57
[  309.264442]  ttm_bo_handle_move_mem+0x120/0x328
[  309.264445]  ? ttm_bo_mem_space+0x170/0x3a0
[  309.264448]  ttm_bo_validate+0x7b/0xd9
[  309.264452]  ? __mutex_trylock_or_owner+0x43/0x54
[  309.264454]  ttm_bo_init_reserved+0x31f/0x38a
[  309.264457]  ttm_bo_init+0x52/0x76
[  309.264461]  ? nouveau_bo_invalidate_caches+0x8/0x8
[  309.264463]  nouveau_bo_new+0x4a8/0x4c7
[  309.264466]  ? nouveau_bo_invalidate_caches+0x8/0x8
[  309.264469]  nouveau_gem_new+0x49/0xcc
[  309.264471]  nouveau_gem_ioctl_new+0x3e/0x9f
[  309.264474]  ? nouveau_gem_new+0xcc/0xcc
[  309.264477]  drm_ioctl_kernel+0x64/0xa0
[  309.264479]  drm_ioctl+0x1d6/0x2a8
[  309.264482]  ? nouveau_gem_new+0xcc/0xcc
[  309.264485]  nouveau_drm_ioctl+0x71/0xa4
[  309.264489]  vfs_ioctl+0x1e/0x2b
[  309.264491]  do_vfs_ioctl+0x505/0x518
[  309.264495]  ? __fget+0x5d/0x67
[  309.264497]  SyS_ioctl+0x3e/0x5a
[  309.264500]  do_syscall_64+0x17f/0x196
[  309.264504]  entry_SYSCALL_64_after_hwframe+0x21/0x86
[  309.264506] RIP: 0033:0x7f0395218d87
[  309.264508] RSP: 002b:00007ffc210c4c48 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[  309.264511] RAX: ffffffffffffffda RBX: 000056213e828350 RCX: 00007f0395218d87
[  309.264513] RDX: 00007ffc210c4ca0 RSI: 00000000c0306480 RDI: 000000000000000b
[  309.264515] RBP: 00007ffc210c4ca0 R08: 0000000000000004 R09: 00007f03954ddad0
[  309.264517] R10: 00007f03913786a1 R11: 0000000000000246 R12: 00000000c0306480
[  309.264518] R13: 000000000000000b R14: 00007ffc210c4d60 R15: 000056213e35e770

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
