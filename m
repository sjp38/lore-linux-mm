Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D93186B0253
	for <linux-mm@kvack.org>; Sun,  7 Aug 2016 18:40:41 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so182704395lfg.3
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 15:40:41 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id ag8si20674920wjc.126.2016.08.07.15.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Aug 2016 15:40:40 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id f65so91205664wmi.0
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 15:40:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160804115809.GA447@swordfish>
References: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl> <20160804115809.GA447@swordfish>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 8 Aug 2016 00:40:39 +0200
Message-ID: <CAMJBoFMdEmojdgX7tzAK9a9DE49e4776qDjZfrgQa9NB1vXZaQ@mail.gmail.com>
Subject: Re: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID:
 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>, =?UTF-8?Q?Marcin_Miros=C5=82aw?= <marcin@mejor.pl>, Andrew Morton <akpm@linux-foundation.org>

Hi Sergey,

On Thu, Aug 4, 2016 at 1:58 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hello,
>
> Cc Seth, Dan
>
> On (08/01/16 11:03), Marcin Miros=C5=82aw wrote:
>> [  429.722411] ------------[ cut here ]------------
>> [  429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503 __zswap_pool_=
current+0x56/0x60
>> [  429.740048] Call Trace:
>> [  429.740048]  [<ffffffffad255d43>] dump_stack+0x63/0x90
>> [  429.740048]  [<ffffffffad04c997>] __warn+0xc7/0xf0
>> [  429.740048]  [<ffffffffad04cac8>] warn_slowpath_null+0x18/0x20
>> [  429.740048]  [<ffffffffad1250c6>] __zswap_pool_current+0x56/0x60
>> [  429.740048]  [<ffffffffad1250e3>] zswap_pool_current+0x13/0x20
>> [  429.740048]  [<ffffffffad125efb>] __zswap_param_set+0x1db/0x2f0
>> [  429.740048]  [<ffffffffad126042>] zswap_zpool_param_set+0x12/0x20
>> [  429.740048]  [<ffffffffad06645f>] param_attr_store+0x5f/0xc0
>> [  429.740048]  [<ffffffffad065b69>] module_attr_store+0x19/0x30
>> [  429.740048]  [<ffffffffad1b0b02>] sysfs_kf_write+0x32/0x40
>> [  429.740048]  [<ffffffffad1b0663>] kernfs_fop_write+0x113/0x190
>> [  429.740048]  [<ffffffffad13fc52>] __vfs_write+0x32/0x150
>> [  429.740048]  [<ffffffffad15f0ae>] ? __fd_install+0x2e/0xe0
>> [  429.740048]  [<ffffffffad15ef11>] ? __alloc_fd+0x41/0x180
>> [  429.740048]  [<ffffffffad0838dd>] ? percpu_down_read+0xd/0x50
>> [  429.740048]  [<ffffffffad140d33>] vfs_write+0xb3/0x1a0
>> [  429.740048]  [<ffffffffad13db81>] ? filp_close+0x51/0x70
>> [  429.740048]  [<ffffffffad142140>] SyS_write+0x50/0xc0
>> [  429.740048]  [<ffffffffad413836>] entry_SYSCALL_64_fastpath+0x1e/0xa8
>> [  429.764069] ---[ end trace ff7835fbf4d983b9 ]---
>
> I think it's something like this.
>
> suppose there are no pools available - the list is empty (see later).
> __zswap_param_set():
>
>         pool =3D zswap_pool_find_get(type, compressor);
>
> gives NULL. so it creates a new one
>
>         pool =3D zswap_pool_create(type, compressor);
>
> then it does
>
>         ret =3D param_set_charp(s, kp);
>
> which gives 0 -- all ok. so it goes to
>
>         if (!ret) {
>                 put_pool =3D zswap_pool_current();
>         }
>
> which gives WARN_ON(), as the list is still empty.
>
>
>
> now, how is this possible. for example, we init a zswap with the default
> configuration; but zbud is not available (can it be?). so the pool creati=
on
> fails, but init_zswap() does not set zswap_init_started back to false. it
> either must clear it at the error path, or set it to true right before
> 'return 0'.
>
> one more problem here is that param_set_charp() does GFP_KERNEL
> under zswap_pools_lock.
>

Thanks a lot for looking into this, I have very limited ability to
debug stuff while on vacation :)

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
