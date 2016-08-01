Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D4C0A6B025E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:45:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p129so83762740wmp.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:45:43 -0700 (PDT)
Received: from mail-lf0-x233.google.com (mail-lf0-x233.google.com. [2a00:1450:4010:c07::233])
        by mx.google.com with ESMTPS id r72si14582275lfd.312.2016.08.01.07.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 07:45:42 -0700 (PDT)
Received: by mail-lf0-x233.google.com with SMTP id f93so117320405lfi.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:45:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 1 Aug 2016 16:45:41 +0200
Message-ID: <CAG_fn=W66woqqpn3=dTJ8_48wccNhhKq2HCQrdKSfQj__scX-Q@mail.gmail.com>
Subject: Re: [PATCH 1/6] mm/kasan: fix corruptions and false positive reports
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Aug 1, 2016 at 4:45 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
> Once object put in quarantine, we no longer own it, i.e. object could lea=
ve
> the quarantine and be reallocated. So having set_track() call after the
> quarantine_put() may corrupt slab objects.
>
>  BUG kmalloc-4096 (Not tainted): Poison overwritten
>  ------------------------------------------------------------------------=
-----
>  Disabling lock debugging due to kernel taint
>  INFO: 0xffff8804540de850-0xffff8804540de857. First byte 0xb5 instead of =
0x6b
> ...
>  INFO: Freed in qlist_free_all+0x42/0x100 age=3D75 cpu=3D3 pid=3D24492
>   __slab_free+0x1d6/0x2e0
>   ___cache_free+0xb6/0xd0
>   qlist_free_all+0x83/0x100
>   quarantine_reduce+0x177/0x1b0
>   kasan_kmalloc+0xf3/0x100
>   kasan_slab_alloc+0x12/0x20
>   kmem_cache_alloc+0x109/0x3e0
>   mmap_region+0x53e/0xe40
>   do_mmap+0x70f/0xa50
>   vm_mmap_pgoff+0x147/0x1b0
>   SyS_mmap_pgoff+0x2c7/0x5b0
>   SyS_mmap+0x1b/0x30
>   do_syscall_64+0x1a0/0x4e0
>   return_from_SYSCALL_64+0x0/0x7a
>  INFO: Slab 0xffffea0011503600 objects=3D7 used=3D7 fp=3D0x          (nul=
l) flags=3D0x8000000000004080
>  INFO: Object 0xffff8804540de848 @offset=3D26696 fp=3D0xffff8804540dc588
>  Redzone ffff8804540de840: bb bb bb bb bb bb bb bb                       =
   ........
>  Object ffff8804540de848: 6b 6b 6b 6b 6b 6b 6b 6b b5 52 00 00 f2 01 60 cc=
  kkkkkkkk.R....`.
>
> Similarly, poisoning after the quarantine_put() leads to false positive
> use-after-free reports:
>
>  BUG: KASAN: use-after-free in anon_vma_interval_tree_insert+0x304/0x430 =
at addr ffff880405c540a0
>  Read of size 8 by task trinity-c0/3036
>  CPU: 0 PID: 3036 Comm: trinity-c0 Not tainted 4.7.0-think+ #9
>   ffff880405c54200 00000000c5c4423e ffff88044a5ef9f0 ffffffffaea48532
>   ffff88044a5efa88 ffff880461497a00 ffff88044a5efa78 ffffffffae57cfe2
>   ffff88046501c958 ffff880436aa5440 0000000000000282 0000000000000007
>  Call Trace:
>   [<ffffffffaea48532>] dump_stack+0x68/0x96
>   [<ffffffffae57cfe2>] kasan_report_error+0x222/0x600
>   [<ffffffffae57d571>] __asan_report_load8_noabort+0x61/0x70
>   [<ffffffffae4f8924>] anon_vma_interval_tree_insert+0x304/0x430
>   [<ffffffffae52f811>] anon_vma_chain_link+0x91/0xd0
>   [<ffffffffae536e46>] anon_vma_clone+0x136/0x3f0
>   [<ffffffffae537181>] anon_vma_fork+0x81/0x4c0
>   [<ffffffffae125663>] copy_process.part.47+0x2c43/0x5b20
>   [<ffffffffae12895d>] _do_fork+0x16d/0xbd0
>   [<ffffffffae129469>] SyS_clone+0x19/0x20
>   [<ffffffffae0064b0>] do_syscall_64+0x1a0/0x4e0
>   [<ffffffffafa09b1a>] entry_SYSCALL64_slow_path+0x25/0x25
>
> Fix this by putting an object in the quarantine after all other operation=
s.
>
> Fixes: 80a9201a5965 ("mm, kasan: switch SLUB to stackdepot, enable memory=
 quarantine for SLUB")
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Reported-by: Vegard Nossum <vegard.nossum@oracle.com>
> Reported-by: Sasha Levin <alexander.levin@verizon.com>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Alexander Potapenko <glider@google.com>
> ---
>  mm/kasan/kasan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index b6f99e8..3019cec 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -543,9 +543,9 @@ bool kasan_slab_free(struct kmem_cache *cache, void *=
object)
>                 switch (alloc_info->state) {
>                 case KASAN_STATE_ALLOC:
>                         alloc_info->state =3D KASAN_STATE_QUARANTINE;
> -                       quarantine_put(free_info, cache);
>                         set_track(&free_info->track, GFP_NOWAIT);
>                         kasan_poison_slab_free(cache, object);
> +                       quarantine_put(free_info, cache);
This is exactly the patch I was going to send in a couple of minutes :)
>                         return true;
>                 case KASAN_STATE_QUARANTINE:
>                 case KASAN_STATE_FREE:
> --
> 2.7.3
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
