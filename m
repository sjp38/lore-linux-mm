Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id ABED66B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:05:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p129so41372057wmp.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 08:05:18 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id 69si3915852wme.0.2016.07.29.08.05.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 08:05:16 -0700 (PDT)
Date: Fri, 29 Jul 2016 11:05:14 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: [4.7+] various memory corruption reports.
Message-ID: <20160729150513.GB29545@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

I've just gotten back into running trinity on daily pulls of master, and it seems pretty horrific
right now.  I can reproduce some kind of memory corruption within a couple minutes runtime.

Report 1:

[ 2007.777923] =============================================================================
[ 2007.778137] BUG kmalloc-4096 (Not tainted): Poison overwritten
[ 2007.778271] -----------------------------------------------------------------------------
[ 2007.778489] Disabling lock debugging due to kernel taint
[ 2007.778609] INFO: 0xffff8804540de850-0xffff8804540de857. First byte 0xb5 instead of 0x6b
[ 2007.778794] INFO: Allocated in rw_copy_check_uvector+0x5e/0x290 age=110 cpu=0 pid=21173
[ 2007.778976] 	___slab_alloc.constprop.69+0x53d/0x5c0
[ 2007.779086] 	__slab_alloc.isra.63.constprop.68+0x48/0x80
[ 2007.779204] 	__kmalloc+0x319/0x440
[ 2007.779280] 	rw_copy_check_uvector+0x5e/0x290
[ 2007.790613] 	import_iovec+0x9f/0x430
[ 2007.801876] 	process_vm_rw+0xf3/0x1d0
[ 2007.813138] 	SyS_process_vm_readv+0x19/0x20
[ 2007.824278] 	do_syscall_64+0x1a0/0x4e0
[ 2007.835330] 	return_from_SYSCALL_64+0x0/0x7a
[ 2007.846428] INFO: Freed in qlist_free_all+0x42/0x100 age=75 cpu=3 pid=24492
[ 2007.857637] 	__slab_free+0x1d6/0x2e0
[ 2007.868813] 	___cache_free+0xb6/0xd0
[ 2007.880008] 	qlist_free_all+0x83/0x100
[ 2007.891270] 	quarantine_reduce+0x177/0x1b0
[ 2007.902494] 	kasan_kmalloc+0xf3/0x100
[ 2007.913718] 	kasan_slab_alloc+0x12/0x20
[ 2007.924938] 	kmem_cache_alloc+0x109/0x3e0
[ 2007.936005] 	mmap_region+0x53e/0xe40
[ 2007.946987] 	do_mmap+0x70f/0xa50
[ 2007.957951] 	vm_mmap_pgoff+0x147/0x1b0
[ 2007.968983] 	SyS_mmap_pgoff+0x2c7/0x5b0
[ 2007.979890] 	SyS_mmap+0x1b/0x30
[ 2007.990685] 	do_syscall_64+0x1a0/0x4e0
[ 2008.001483] 	return_from_SYSCALL_64+0x0/0x7a
[ 2008.012202] INFO: Slab 0xffffea0011503600 objects=7 used=7 fp=0x          (null) flags=0x8000000000004080
[ 2008.023213] INFO: Object 0xffff8804540de848 @offset=26696 fp=0xffff8804540dc588
[ 2008.044813] Redzone ffff8804540de840: bb bb bb bb bb bb bb bb                          ........
[ 2008.055705] Object ffff8804540de848: 6b 6b 6b 6b 6b 6b 6b 6b b5 52 00 00 f2 01 60 cc  kkkkkkkk.R....`.
[ 2008.066589] Object ffff8804540de858: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.077442] Object ffff8804540de868: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.088253] Object ffff8804540de878: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.098864] Object ffff8804540de888: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.109371] Object ffff8804540de898: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.119828] Object ffff8804540de8a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.130203] Object ffff8804540de8b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.140518] Object ffff8804540de8c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.150674] Object ffff8804540de8d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.160754] Object ffff8804540de8e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.170835] Object ffff8804540de8f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.180796] Object ffff8804540de908: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.190777] Object ffff8804540de918: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.200649] Object ffff8804540de928: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.210385] Object ffff8804540de938: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.220130] Object ffff8804540de948: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.229692] Object ffff8804540de958: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.239158] Object ffff8804540de968: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.248562] Object ffff8804540de978: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.257842] Object ffff8804540de988: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.267006] Object ffff8804540de998: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.276113] Object ffff8804540de9a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.285158] Object ffff8804540de9b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.294086] Object ffff8804540de9c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.302920] Object ffff8804540de9d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.311688] Object ffff8804540de9e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.320302] Object ffff8804540de9f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.328855] Object ffff8804540dea08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.337276] Object ffff8804540dea18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.345613] Object ffff8804540dea28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.353917] Object ffff8804540dea38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.362072] Object ffff8804540dea48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.370241] Object ffff8804540dea58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.378186] Object ffff8804540dea68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.386086] Object ffff8804540dea78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.393913] Object ffff8804540dea88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.401696] Object ffff8804540dea98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.409315] Object ffff8804540deaa8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.416885] Object ffff8804540deab8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.424259] Object ffff8804540deac8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.431659] Object ffff8804540dead8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.438909] Object ffff8804540deae8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.446022] Object ffff8804540deaf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.453064] Object ffff8804540deb08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.459973] Object ffff8804540deb18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.466811] Object ffff8804540deb28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.473602] Object ffff8804540deb38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.480202] Object ffff8804540deb48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.486770] Object ffff8804540deb58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.493177] Object ffff8804540deb68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.499522] Object ffff8804540deb78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.505771] Object ffff8804540deb88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.511885] Object ffff8804540deb98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.517910] Object ffff8804540deba8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.523782] Object ffff8804540debb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.529601] Object ffff8804540debc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.535343] Object ffff8804540debd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.540951] Object ffff8804540debe8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.546507] Object ffff8804540debf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.551912] Object ffff8804540dec08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.557165] Object ffff8804540dec18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.562247] Object ffff8804540dec28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.567361] Object ffff8804540dec38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.572327] Object ffff8804540dec48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.577152] Object ffff8804540dec58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.581875] Object ffff8804540dec68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.586353] Object ffff8804540dec78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.590642] Object ffff8804540dec88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.594825] Object ffff8804540dec98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.598888] Object ffff8804540deca8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.602770] Object ffff8804540decb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.606533] Object ffff8804540decc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.610087] Object ffff8804540decd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.613589] Object ffff8804540dece8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.616987] Object ffff8804540decf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.620264] Object ffff8804540ded08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.623367] Object ffff8804540ded18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.626339] Object ffff8804540ded28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.629264] Object ffff8804540ded38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.632104] Object ffff8804540ded48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.634944] Object ffff8804540ded58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.637680] Object ffff8804540ded68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.640380] Object ffff8804540ded78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.642982] Object ffff8804540ded88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.645573] Object ffff8804540ded98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.648020] Object ffff8804540deda8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.650386] Object ffff8804540dedb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.652614] Object ffff8804540dedc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.654823] Object ffff8804540dedd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.656997] Object ffff8804540dede8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.659116] Object ffff8804540dedf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.661120] Object ffff8804540dee08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.663054] Object ffff8804540dee18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.665054] Object ffff8804540dee28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.666989] Object ffff8804540dee38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.668868] Object ffff8804540dee48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.670711] Object ffff8804540dee58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.672508] Object ffff8804540dee68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.674206] Object ffff8804540dee78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.675818] Object ffff8804540dee88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.677328] Object ffff8804540dee98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.678650] Object ffff8804540deea8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.679867] Object ffff8804540deeb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.681005] Object ffff8804540deec8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.681993] Object ffff8804540deed8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.682909] Object ffff8804540deee8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.683776] Object ffff8804540deef8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.684670] Object ffff8804540def08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.685553] Object ffff8804540def18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.686425] Object ffff8804540def28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.687312] Object ffff8804540def38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.688226] Object ffff8804540def48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.689071] Object ffff8804540def58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.689986] Object ffff8804540def68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.690893] Object ffff8804540def78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.691785] Object ffff8804540def88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.692664] Object ffff8804540def98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.693529] Object ffff8804540defa8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.694378] Object ffff8804540defb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.695271] Object ffff8804540defc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.696181] Object ffff8804540defd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.697073] Object ffff8804540defe8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.697989] Object ffff8804540deff8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.698899] Object ffff8804540df008: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.699794] Object ffff8804540df018: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.700688] Object ffff8804540df028: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.701569] Object ffff8804540df038: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.702425] Object ffff8804540df048: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.703315] Object ffff8804540df058: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.704211] Object ffff8804540df068: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.705053] Object ffff8804540df078: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.705986] Object ffff8804540df088: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.706892] Object ffff8804540df098: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.707740] Object ffff8804540df0a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.708597] Object ffff8804540df0b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.709457] Object ffff8804540df0c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.710299] Object ffff8804540df0d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.711172] Object ffff8804540df0e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.712061] Object ffff8804540df0f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.712952] Object ffff8804540df108: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.713858] Object ffff8804540df118: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.714751] Object ffff8804540df128: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.715612] Object ffff8804540df138: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.716446] Object ffff8804540df148: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.717318] Object ffff8804540df158: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.718224] Object ffff8804540df168: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.719076] Object ffff8804540df178: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.719949] Object ffff8804540df188: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.720772] Object ffff8804540df198: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.721599] Object ffff8804540df1a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.722426] Object ffff8804540df1b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.723290] Object ffff8804540df1c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.724190] Object ffff8804540df1d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.725075] Object ffff8804540df1e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.725995] Object ffff8804540df1f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.726889] Object ffff8804540df208: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.727776] Object ffff8804540df218: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.728650] Object ffff8804540df228: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.729527] Object ffff8804540df238: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.730387] Object ffff8804540df248: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.731253] Object ffff8804540df258: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.732130] Object ffff8804540df268: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.733024] Object ffff8804540df278: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.733903] Object ffff8804540df288: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.734792] Object ffff8804540df298: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.735650] Object ffff8804540df2a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.736514] Object ffff8804540df2b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.737375] Object ffff8804540df2c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.738209] Object ffff8804540df2d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.739025] Object ffff8804540df2e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.739861] Object ffff8804540df2f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.740733] Object ffff8804540df308: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.741559] Object ffff8804540df318: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.742402] Object ffff8804540df328: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.743284] Object ffff8804540df338: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.744170] Object ffff8804540df348: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.745032] Object ffff8804540df358: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.745920] Object ffff8804540df368: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.746786] Object ffff8804540df378: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.747644] Object ffff8804540df388: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.748486] Object ffff8804540df398: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.749327] Object ffff8804540df3a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.750196] Object ffff8804540df3b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.751102] Object ffff8804540df3c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.751993] Object ffff8804540df3d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.752874] Object ffff8804540df3e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.753742] Object ffff8804540df3f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.754590] Object ffff8804540df408: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.755417] Object ffff8804540df418: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.756271] Object ffff8804540df428: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.757160] Object ffff8804540df438: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.758014] Object ffff8804540df448: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.758893] Object ffff8804540df458: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.759763] Object ffff8804540df468: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.760594] Object ffff8804540df478: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.761425] Object ffff8804540df488: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.762278] Object ffff8804540df498: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.763137] Object ffff8804540df4a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.764004] Object ffff8804540df4b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.764849] Object ffff8804540df4c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.765725] Object ffff8804540df4d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.766582] Object ffff8804540df4e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.767421] Object ffff8804540df4f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.768286] Object ffff8804540df508: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.769159] Object ffff8804540df518: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.770005] Object ffff8804540df528: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.770889] Object ffff8804540df538: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.771727] Object ffff8804540df548: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.772595] Object ffff8804540df558: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.773429] Object ffff8804540df568: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.774269] Object ffff8804540df578: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.775145] Object ffff8804540df588: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.776025] Object ffff8804540df598: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.776908] Object ffff8804540df5a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.777789] Object ffff8804540df5b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.778645] Object ffff8804540df5c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.779476] Object ffff8804540df5d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.780321] Object ffff8804540df5e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.781189] Object ffff8804540df5f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.782091] Object ffff8804540df608: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.782904] Object ffff8804540df618: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.783770] Object ffff8804540df628: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.784624] Object ffff8804540df638: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.785490] Object ffff8804540df648: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.786330] Object ffff8804540df658: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.787194] Object ffff8804540df668: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.788079] Object ffff8804540df678: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.788964] Object ffff8804540df688: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.789842] Object ffff8804540df698: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.790699] Object ffff8804540df6a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.791528] Object ffff8804540df6b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.792357] Object ffff8804540df6c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.793215] Object ffff8804540df6d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.794090] Object ffff8804540df6e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.794892] Object ffff8804540df6f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.795757] Object ffff8804540df708: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.796606] Object ffff8804540df718: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.797446] Object ffff8804540df728: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.798268] Object ffff8804540df738: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.799125] Object ffff8804540df748: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.799963] Object ffff8804540df758: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.800818] Object ffff8804540df768: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.801643] Object ffff8804540df778: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.802493] Object ffff8804540df788: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.803318] Object ffff8804540df798: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.804122] Object ffff8804540df7a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.805004] Object ffff8804540df7b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.805881] Object ffff8804540df7c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.806718] Object ffff8804540df7d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.807559] Object ffff8804540df7e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.808364] Object ffff8804540df7f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.809213] Object ffff8804540df808: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.810093] Object ffff8804540df818: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.810947] Object ffff8804540df828: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 2008.811825] Object ffff8804540df838: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[ 2008.812695] Redzone ffff8804540df848: bb bb bb bb bb bb bb bb                          ........
[ 2008.813667] Padding ffff8804540df994: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[ 2008.814768] CPU: 2 PID: 24511 Comm: trinity-c1 Tainted: G    B           4.7.0-think+ #9
[ 2008.816159]  ffffea0011503600 000000004e98d727 ffff880435dc78a0 ffffffffada48532
[ 2008.817616]  ffff88046500ec40 000000000000114c ffff880435dc78d0 ffffffffad5737ef
[ 2008.819167]  ffff8804540de858 ffff88046500ec40 000000000000006b ffff8803ecde0040
[ 2008.820854] Call Trace:
[ 2008.822502]  [<ffffffffada48532>] dump_stack+0x68/0x96
[ 2008.824346]  [<ffffffffad5737ef>] print_trailer+0x11f/0x1a0
[ 2008.826252]  [<ffffffffad573d3c>] check_bytes_and_report+0xdc/0x120
[ 2008.828194]  [<ffffffffad574c25>] check_object+0x255/0x2a0
[ 2008.830231]  [<ffffffffad5cf4fe>] ? rw_copy_check_uvector+0x5e/0x290
[ 2008.832343]  [<ffffffffad575043>] alloc_debug_processing+0x113/0x1b0
[ 2008.834537]  [<ffffffffad57733d>] ___slab_alloc.constprop.69+0x53d/0x5c0
[ 2008.836805]  [<ffffffffad5cf4fe>] ? rw_copy_check_uvector+0x5e/0x290
[ 2008.839156]  [<ffffffffad5cf4fe>] ? rw_copy_check_uvector+0x5e/0x290
[ 2008.841531]  [<ffffffffad577408>] __slab_alloc.isra.63.constprop.68+0x48/0x80
[ 2008.843987]  [<ffffffffad577fc9>] __kmalloc+0x319/0x440
[ 2008.846519]  [<ffffffffad5cf4fe>] ? rw_copy_check_uvector+0x5e/0x290
[ 2008.849121]  [<ffffffffad5cf4fe>] rw_copy_check_uvector+0x5e/0x290
[ 2008.851835]  [<ffffffffad50e542>] ? alloc_set_pte+0xbe2/0x1650
[ 2008.854589]  [<ffffffffada8642f>] import_iovec+0x9f/0x430
[ 2008.857396]  [<ffffffffada86390>] ? iov_iter_get_pages_alloc+0x820/0x820
[ 2008.860326]  [<ffffffffad1c766f>] ? sched_clock_cpu+0x14f/0x1e0
[ 2008.863336]  [<ffffffffad542953>] process_vm_rw+0xf3/0x1d0
[ 2008.866397]  [<ffffffffad542860>] ? process_vm_rw_core.isra.3+0x940/0x940
[ 2008.869545]  [<ffffffffad231cd0>] ? debug_check_no_locks_freed+0x280/0x280
[ 2008.872803]  [<ffffffffad231cd0>] ? debug_check_no_locks_freed+0x280/0x280
[ 2008.876048]  [<ffffffffadaab907>] ? debug_smp_processor_id+0x17/0x20
[ 2008.879380]  [<ffffffffad226d2d>] ? get_lock_stats+0x1d/0x90
[ 2008.882773]  [<ffffffffad0054e0>] ? enter_from_user_mode+0x50/0x50
[ 2008.886245]  [<ffffffffad542c20>] ? SyS_process_vm_readv+0x20/0x20
[ 2008.889780]  [<ffffffffad542c39>] SyS_process_vm_writev+0x19/0x20
[ 2008.893348]  [<ffffffffad0064b0>] do_syscall_64+0x1a0/0x4e0
[ 2008.897037]  [<ffffffffad00301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[ 2008.900794]  [<ffffffffaea09b1a>] entry_SYSCALL64_slow_path+0x25/0x25
[ 2008.904625] FIX kmalloc-4096: Restoring 0xffff8804540de850-0xffff8804540de857=0x6b
[ 2008.912490] FIX kmalloc-4096: Marking all objects used



Report 2:

[ 1682.901684] =============================================================================
[ 1682.901902] BUG buffer_head (Not tainted): Poison overwritten
[ 1682.902034] -----------------------------------------------------------------------------
[ 1682.902251] Disabling lock debugging due to kernel taint
[ 1682.902369] INFO: 0xffff88042dff8c8c-0xffff88042dff8c8f. First byte 0xf4 instead of 0x6b
[ 1682.902551] INFO: Allocated in alloc_buffer_head+0x20/0xc0 age=26418 cpu=3 pid=3322
[ 1682.902727] 	___slab_alloc.constprop.69+0x53d/0x5c0
[ 1682.902840] 	__slab_alloc.isra.63.constprop.68+0x48/0x80
[ 1682.902960] 	kmem_cache_alloc+0x2d0/0x3e0
[ 1682.903053] 	alloc_buffer_head+0x20/0xc0
[ 1682.903142] 	alloc_page_buffers+0xa9/0x1f0
[ 1682.903234] 	create_empty_buffers+0x30/0x480
[ 1682.903331] 	create_page_buffers+0x120/0x1b0
[ 1682.903427] 	__block_write_begin_int+0x17a/0x17e0
[ 1682.903533] 	__block_write_begin+0x11/0x20
[ 1682.903627] 	ext4_da_write_begin+0x368/0xaa0
[ 1682.914645] 	generic_perform_write+0x290/0x520
[ 1682.925625] 	__generic_file_write_iter+0x314/0x530
[ 1682.936589] 	ext4_file_write_iter+0x1b4/0xf10
[ 1682.947574] 	do_iter_readv_writev+0x23f/0x510
[ 1682.958502] 	do_readv_writev+0x394/0x6a0
[ 1682.969403] 	vfs_writev+0x75/0xb0
[ 1682.980364] INFO: Freed in qlist_free_all+0x42/0x100 age=6008 cpu=3 pid=3322
[ 1682.991389] 	__slab_free+0x1d6/0x2e0
[ 1683.002417] 	___cache_free+0xb6/0xd0
[ 1683.013417] 	qlist_free_all+0x83/0x100
[ 1683.024416] 	quarantine_reduce+0x177/0x1b0
[ 1683.035344] 	kasan_kmalloc+0xf3/0x100
[ 1683.046278] 	kasan_slab_alloc+0x12/0x20
[ 1683.057090] 	kmem_cache_alloc+0x109/0x3e0
[ 1683.067953] 	__sigqueue_alloc+0x1ad/0x410
[ 1683.078668] 	__send_signal+0x1a7/0x1030
[ 1683.089360] 	send_signal+0x5f/0xb0
[ 1683.100033] 	do_send_sig_info+0x9d/0x130
[ 1683.110634] 	group_send_sig_info+0xb2/0x120
[ 1683.121246] 	kill_pid_info+0x89/0x150
[ 1683.131877] 	SYSC_kill+0x228/0x580
[ 1683.142383] 	SyS_kill+0xe/0x10
[ 1683.152836] 	do_syscall_64+0x1a0/0x4e0
[ 1683.163230] INFO: Slab 0xffffea0010b7fe00 objects=17 used=0 fp=0xffff88042dff8e48 flags=0x8000000000004080
[ 1683.173850] INFO: Object 0xffff88042dff8c80 @offset=3200 fp=0xffff88042dff91d8
[ 1683.194918] Redzone ffff88042dff8c78: bb bb bb bb bb bb bb bb                          ........
[ 1683.205606] Object ffff88042dff8c80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b f4 01 c0 ee  kkkkkkkkkkkk....
[ 1683.216306] Object ffff88042dff8c90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1683.226974] Object ffff88042dff8ca0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1683.237521] Object ffff88042dff8cb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1683.248014] Object ffff88042dff8cc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1683.258322] Object ffff88042dff8cd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1683.268599] Object ffff88042dff8ce0: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
[ 1683.278753] Redzone ffff88042dff8ce8: bb bb bb bb bb bb bb bb                          ........
[ 1683.288925] Padding ffff88042dff8e34: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[ 1683.299161] CPU: 2 PID: 3321 Comm: trinity-c10 Tainted: G    B           4.7.0-think+ #9
[ 1683.309540]  ffffea0010b7fe00 00000000fc8e1f9e ffff88043f0778e0 ffffffffb0a48532
[ 1683.319946]  ffff880461497740 00000000000001b4 ffff88043f077910 ffffffffb05737ef
[ 1683.330318]  ffff88042dff8c90 ffff880461497740 000000000000006b ffff880449ba5440
[ 1683.340671] Call Trace:
[ 1683.350925]  [<ffffffffb0a48532>] dump_stack+0x68/0x96
[ 1683.361189]  [<ffffffffb05737ef>] print_trailer+0x11f/0x1a0
[ 1683.371502]  [<ffffffffb0573d3c>] check_bytes_and_report+0xdc/0x120
[ 1683.381760]  [<ffffffffb0574c25>] check_object+0x255/0x2a0
[ 1683.392039]  [<ffffffffb0574d2c>] __free_slab+0xbc/0x250
[ 1683.402233]  [<ffffffffb0574ef0>] discard_slab+0x30/0x50
[ 1683.412387]  [<ffffffffb0578567>] __slab_free+0x237/0x2e0
[ 1683.422507]  [<ffffffffb023115f>] ? mark_held_locks+0xcf/0x130
[ 1683.432568]  [<ffffffffb057db12>] ? qlist_free_all+0x42/0x100
[ 1683.442741]  [<ffffffffb057a9b6>] ___cache_free+0xb6/0xd0
[ 1683.452835]  [<ffffffffb057db53>] qlist_free_all+0x83/0x100
[ 1683.462877]  [<ffffffffb057df07>] quarantine_reduce+0x177/0x1b0
[ 1683.472815]  [<ffffffffb057c423>] kasan_kmalloc+0xf3/0x100
[ 1683.482638]  [<ffffffffb012552a>] ? copy_process.part.47+0x2b0a/0x5b20
[ 1683.492561]  [<ffffffffb057c922>] kasan_slab_alloc+0x12/0x20
[ 1683.502354]  [<ffffffffb0577549>] kmem_cache_alloc+0x109/0x3e0
[ 1683.512261]  [<ffffffffb012552a>] copy_process.part.47+0x2b0a/0x5b20
[ 1683.522018]  [<ffffffffb0122a20>] ? __cleanup_sighand+0x30/0x30
[ 1683.531807]  [<ffffffffb012895d>] _do_fork+0x16d/0xbd0
[ 1683.541520]  [<ffffffffb01287f0>] ? fork_idle+0x250/0x250
[ 1683.551186]  [<ffffffffb00054e0>] ? enter_from_user_mode+0x50/0x50
[ 1683.560885]  [<ffffffffb1a09c00>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[ 1683.570662]  [<ffffffffb0129469>] SyS_clone+0x19/0x20
[ 1683.580298]  [<ffffffffb00064b0>] do_syscall_64+0x1a0/0x4e0
[ 1683.589849]  [<ffffffffb000301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[ 1683.599486]  [<ffffffffb1a09b1a>] entry_SYSCALL64_slow_path+0x25/0x25
[ 1683.609173] FIX buffer_head: Restoring 0xffff88042dff8c8c-0xffff88042dff8c8f=0x6b

Report 3:

[  301.092929] =============================================================================
[  301.093155] BUG vm_area_struct (Not tainted): Poison overwritten
[  301.093292] -----------------------------------------------------------------------------
[  301.093508] Disabling lock debugging due to kernel taint
[  301.093630] INFO: 0xffff8803ef5c25c0-0xffff8803ef5c25c7. First byte 0xb6 instead of 0x6b
[  301.093820] INFO: Allocated in copy_process.part.47+0x2b0a/0x5b20 age=126 cpu=3 pid=3110
[  301.094008] 	___slab_alloc.constprop.69+0x53d/0x5c0
[  301.094119] 	__slab_alloc.isra.63.constprop.68+0x48/0x80
[  301.094238] 	kmem_cache_alloc+0x2d0/0x3e0
[  301.105724] 	copy_process.part.47+0x2b0a/0x5b20
[  301.117205] 	_do_fork+0x16d/0xbd0
[  301.128627] 	SyS_clone+0x19/0x20
[  301.139993] 	do_syscall_64+0x1a0/0x4e0
[  301.151551] 	return_from_SYSCALL_64+0x0/0x7a
[  301.162911] INFO: Freed in qlist_free_all+0x42/0x100 age=55 cpu=2 pid=3106
[  301.174380] 	__slab_free+0x1d6/0x2e0
[  301.185935] 	___cache_free+0xb6/0xd0
[  301.197299] 	qlist_free_all+0x83/0x100
[  301.208653] 	quarantine_reduce+0x177/0x1b0
[  301.220018] 	kasan_kmalloc+0xf3/0x100
[  301.231275] 	kasan_slab_alloc+0x12/0x20
[  301.242476] 	kmem_cache_alloc+0x109/0x3e0
[  301.253682] 	__sigqueue_alloc+0x1ad/0x410
[  301.264997] 	__send_signal+0x1a7/0x1030
[  301.276143] 	send_signal+0x5f/0xb0
[  301.287345] 	do_send_sig_info+0x9d/0x130
[  301.298559] 	group_send_sig_info+0xb2/0x120
[  301.309811] 	kill_pid_info+0x89/0x150
[  301.321101] 	SYSC_kill+0x228/0x580
[  301.332231] 	SyS_kill+0xe/0x10
[  301.343327] 	do_syscall_64+0x1a0/0x4e0
[  301.354368] INFO: Slab 0xffffea000fbd7000 objects=30 used=30 fp=0x          (null) flags=0x8000000000004080
[  301.365622] INFO: Object 0xffff8803ef5c25b8 @offset=9656 fp=0xffff8803ef5c1710
[  301.387910] Redzone ffff8803ef5c25b0: bb bb bb bb bb bb bb bb                          ........
[  301.399148] Object ffff8803ef5c25b8: 6b 6b 6b 6b 6b 6b 6b 6b b6 2c 00 00 46 01 60 8d  kkkkkkkk.,..F.`.
[  301.410442] Object ffff8803ef5c25c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.421761] Object ffff8803ef5c25d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.432970] Object ffff8803ef5c25e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.444049] Object ffff8803ef5c25f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.455063] Object ffff8803ef5c2608: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.465953] Object ffff8803ef5c2618: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.476838] Object ffff8803ef5c2628: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.487572] Object ffff8803ef5c2638: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.498167] Object ffff8803ef5c2648: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.508729] Object ffff8803ef5c2658: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  301.519148] Object ffff8803ef5c2668: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
[  301.529525] Redzone ffff8803ef5c2670: bb bb bb bb bb bb bb bb                          ........
[  301.539878] Padding ffff8803ef5c27bc: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  301.550270] CPU: 3 PID: 3110 Comm: trinity-c4 Tainted: G    B           4.7.0-think+ #9
[  301.560896]  ffffea000fbd7000 00000000b0c1eccd ffff8804402879c0 ffffffffb7a48532
[  301.571617]  ffff88045d097a00 0000000000000204 ffff8804402879f0 ffffffffb75737ef
[  301.582239]  ffff8803ef5c25c8 ffff88045d097a00 000000000000006b ffff88043aa8b840
[  301.592843] Call Trace:
[  301.603396]  [<ffffffffb7a48532>] dump_stack+0x68/0x96
[  301.614024]  [<ffffffffb75737ef>] print_trailer+0x11f/0x1a0
[  301.624636]  [<ffffffffb7573d3c>] check_bytes_and_report+0xdc/0x120
[  301.635261]  [<ffffffffb7574c25>] check_object+0x255/0x2a0
[  301.645821]  [<ffffffffb712552a>] ? copy_process.part.47+0x2b0a/0x5b20
[  301.656344]  [<ffffffffb7575043>] alloc_debug_processing+0x113/0x1b0
[  301.666851]  [<ffffffffb757733d>] ___slab_alloc.constprop.69+0x53d/0x5c0
[  301.677356]  [<ffffffffb712552a>] ? copy_process.part.47+0x2b0a/0x5b20
[  301.687896]  [<ffffffffb712552a>] ? copy_process.part.47+0x2b0a/0x5b20
[  301.698319]  [<ffffffffb7577408>] __slab_alloc.isra.63.constprop.68+0x48/0x80
[  301.708722]  [<ffffffffb712552a>] ? copy_process.part.47+0x2b0a/0x5b20
[  301.719165]  [<ffffffffb7577710>] kmem_cache_alloc+0x2d0/0x3e0
[  301.729551]  [<ffffffffb74d35d6>] ? __vm_enough_memory+0xb6/0x430
[  301.739944]  [<ffffffffb712552a>] copy_process.part.47+0x2b0a/0x5b20
[  301.750310]  [<ffffffffb7122a20>] ? __cleanup_sighand+0x30/0x30
[  301.760621]  [<ffffffffb7231cd0>] ? debug_check_no_locks_freed+0x280/0x280
[  301.770971]  [<ffffffffb712895d>] _do_fork+0x16d/0xbd0
[  301.781229]  [<ffffffffb71287f0>] ? fork_idle+0x250/0x250
[  301.791500]  [<ffffffffb70054e0>] ? enter_from_user_mode+0x50/0x50
[  301.801814]  [<ffffffffb8a09c00>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  301.812021]  [<ffffffffb7129469>] SyS_clone+0x19/0x20
[  301.822237]  [<ffffffffb70064b0>] do_syscall_64+0x1a0/0x4e0
[  301.832363]  [<ffffffffb700301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[  301.842543]  [<ffffffffb8a09b1a>] entry_SYSCALL64_slow_path+0x25/0x25
[  301.852690] FIX vm_area_struct: Restoring 0xffff8803ef5c25c0-0xffff8803ef5c25c7=0x6b
[  301.872930] FIX vm_area_struct: Marking all objects used



Maybe related ? KASAN triggers sometimes too..

[   94.565717] BUG: KASAN: use-after-free in anon_vma_interval_tree_insert+0x304/0x430 at addr ffff880405c540a0
[   94.565943] Read of size 8 by task trinity-c0/3036
[   94.566053] CPU: 0 PID: 3036 Comm: trinity-c0 Not tainted 4.7.0-think+ #9
[   94.566285]  ffff880405c54200 00000000c5c4423e ffff88044a5ef9f0 ffffffffaea48532
[   94.566462]  ffff88044a5efa88 ffff880461497a00 ffff88044a5efa78 ffffffffae57cfe2
[   94.566639]  ffff88046501c958 ffff880436aa5440 0000000000000282 0000000000000007
[   94.566814] Call Trace:
[   94.566871]  [<ffffffffaea48532>] dump_stack+0x68/0x96
[   94.566989]  [<ffffffffae57cfe2>] kasan_report_error+0x222/0x600
[   94.567127]  [<ffffffffae57d571>] __asan_report_load8_noabort+0x61/0x70
[   94.567278]  [<ffffffffae4f8924>] ? anon_vma_interval_tree_insert+0x304/0x430
[   94.567439]  [<ffffffffae4f8924>] anon_vma_interval_tree_insert+0x304/0x430
[   94.567598]  [<ffffffffae52f811>] anon_vma_chain_link+0x91/0xd0
[   94.578849]  [<ffffffffafa03e80>] ? down_write+0xa0/0xe0
[   94.590209]  [<ffffffffae536e46>] anon_vma_clone+0x136/0x3f0
[   94.601652]  [<ffffffffae537181>] anon_vma_fork+0x81/0x4c0
[   94.613087]  [<ffffffffae4d35d6>] ? __vm_enough_memory+0xb6/0x430
[   94.624548]  [<ffffffffae125663>] copy_process.part.47+0x2c43/0x5b20
[   94.635959]  [<ffffffffae122a20>] ? __cleanup_sighand+0x30/0x30
[   94.647363]  [<ffffffffae231cd0>] ? debug_check_no_locks_freed+0x280/0x280
[   94.658751]  [<ffffffffae12895d>] _do_fork+0x16d/0xbd0
[   94.670093]  [<ffffffffae1287f0>] ? fork_idle+0x250/0x250
[   94.681406]  [<ffffffffae0054e0>] ? enter_from_user_mode+0x50/0x50
[   94.692755]  [<ffffffffafa09c00>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[   94.704041]  [<ffffffffae129469>] SyS_clone+0x19/0x20
[   94.715330]  [<ffffffffae0064b0>] do_syscall_64+0x1a0/0x4e0
[   94.726570]  [<ffffffffae00301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[   94.737866]  [<ffffffffafa09b1a>] entry_SYSCALL64_slow_path+0x25/0x25
[   94.748900] Object at ffff880405c54008, in cache vm_area_struct
[   94.760064] Object allocated with size 184 bytes.
[   94.771273] Allocation:
[   94.782379] PID = 3413
[   94.793439]  [<ffffffffae076ceb>] save_stack_trace+0x2b/0x50
[   94.804570]  [<ffffffffae57c166>] save_stack+0x46/0xd0
[   94.815598]  [<ffffffffae57c40a>] kasan_kmalloc+0xda/0x100
[   94.826645]  [<ffffffffae57c922>] kasan_slab_alloc+0x12/0x20
[   94.837643]  [<ffffffffae577549>] kmem_cache_alloc+0x109/0x3e0
[   94.848611]  [<ffffffffae12552a>] copy_process.part.47+0x2b0a/0x5b20
[   94.859507]  [<ffffffffae12895d>] _do_fork+0x16d/0xbd0
[   94.870397]  [<ffffffffae129469>] SyS_clone+0x19/0x20
[   94.881222]  [<ffffffffae0064b0>] do_syscall_64+0x1a0/0x4e0
[   94.892027]  [<ffffffffafa09b1a>] return_from_SYSCALL_64+0x0/0x7a
[   94.902792] Memory state around the buggy address:
[   94.913471]  ffff880405c53f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[   94.924291]  ffff880405c54000: fc fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[   94.935063] >ffff880405c54080: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
[   94.945802]                                ^   
[   94.956452]  ffff880405c54100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[   94.967223]  ffff880405c54180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[   94.977900] ==================================================================
[   94.988650] Disabling lock debugging due to kernel taint
[   94.999295] ==================================================================



I'll work on narrowing down the exact syscalls needed to trigger this.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
