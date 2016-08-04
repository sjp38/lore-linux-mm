Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39B8E6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 07:58:38 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so401668990pab.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:58:38 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id af3si14434416pad.39.2016.08.04.04.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 04:58:37 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id i6so17845190pfe.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:58:37 -0700 (PDT)
Date: Thu, 4 Aug 2016 20:58:40 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID:
 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
Message-ID: <20160804115809.GA447@swordfish>
References: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, Vitaly Wool <vitalywool@gmail.com>, Marcin =?utf-8?B?TWlyb3PFgmF3?= <marcin@mejor.pl>, Andrew Morton <akpm@linux-foundation.org>

Hello,

Cc Seth, Dan

On (08/01/16 11:03), Marcin MirosA?aw wrote:
> [  429.722411] ------------[ cut here ]------------
> [  429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
> [  429.740048] Call Trace:
> [  429.740048]  [<ffffffffad255d43>] dump_stack+0x63/0x90
> [  429.740048]  [<ffffffffad04c997>] __warn+0xc7/0xf0
> [  429.740048]  [<ffffffffad04cac8>] warn_slowpath_null+0x18/0x20
> [  429.740048]  [<ffffffffad1250c6>] __zswap_pool_current+0x56/0x60
> [  429.740048]  [<ffffffffad1250e3>] zswap_pool_current+0x13/0x20
> [  429.740048]  [<ffffffffad125efb>] __zswap_param_set+0x1db/0x2f0
> [  429.740048]  [<ffffffffad126042>] zswap_zpool_param_set+0x12/0x20
> [  429.740048]  [<ffffffffad06645f>] param_attr_store+0x5f/0xc0
> [  429.740048]  [<ffffffffad065b69>] module_attr_store+0x19/0x30
> [  429.740048]  [<ffffffffad1b0b02>] sysfs_kf_write+0x32/0x40
> [  429.740048]  [<ffffffffad1b0663>] kernfs_fop_write+0x113/0x190
> [  429.740048]  [<ffffffffad13fc52>] __vfs_write+0x32/0x150
> [  429.740048]  [<ffffffffad15f0ae>] ? __fd_install+0x2e/0xe0
> [  429.740048]  [<ffffffffad15ef11>] ? __alloc_fd+0x41/0x180
> [  429.740048]  [<ffffffffad0838dd>] ? percpu_down_read+0xd/0x50
> [  429.740048]  [<ffffffffad140d33>] vfs_write+0xb3/0x1a0
> [  429.740048]  [<ffffffffad13db81>] ? filp_close+0x51/0x70
> [  429.740048]  [<ffffffffad142140>] SyS_write+0x50/0xc0
> [  429.740048]  [<ffffffffad413836>] entry_SYSCALL_64_fastpath+0x1e/0xa8
> [  429.764069] ---[ end trace ff7835fbf4d983b9 ]---

I think it's something like this.

suppose there are no pools available - the list is empty (see later).
__zswap_param_set():

	pool = zswap_pool_find_get(type, compressor);

gives NULL. so it creates a new one

	pool = zswap_pool_create(type, compressor);

then it does

	ret = param_set_charp(s, kp);

which gives 0 -- all ok. so it goes to

	if (!ret) {
		put_pool = zswap_pool_current();
	}

which gives WARN_ON(), as the list is still empty.



now, how is this possible. for example, we init a zswap with the default
configuration; but zbud is not available (can it be?). so the pool creation
fails, but init_zswap() does not set zswap_init_started back to false. it
either must clear it at the error path, or set it to true right before
'return 0'.

one more problem here is that param_set_charp() does GFP_KERNEL
under zswap_pools_lock.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
