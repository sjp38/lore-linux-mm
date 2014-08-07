Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC5E6B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 07:52:07 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id ty20so3439867lab.32
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 04:52:06 -0700 (PDT)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id a3si5093631laa.33.2014.08.07.04.52.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 04:52:05 -0700 (PDT)
Received: by mail-lb0-f172.google.com with SMTP id z11so2617977lbi.17
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 04:52:04 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 7 Aug 2014 13:52:04 +0200
Message-ID: <CAMuHMdW2kb=EF-Nmem_gyUu=p7hFOTe+Q2ekHh41SaHHiWDGeg@mail.gmail.com>
Subject: BUG: enable_cpucache failed for radix_tree_node, error 12 (was: Re:
 [PATCH v3 9/9] slab: remove BAD_ALIEN_MAGIC)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>

Hi Joonsoo,

On Tue, Jul 1, 2014 at 10:27 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> BAD_ALIEN_MAGIC value isn't used anymore. So remove it.
>
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/slab.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 7820a45..60c9e11 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -470,8 +470,6 @@ static struct kmem_cache kmem_cache_boot = {
>         .name = "kmem_cache",
>  };
>
> -#define BAD_ALIEN_MAGIC 0x01020304ul
> -
>  static DEFINE_PER_CPU(struct delayed_work, slab_reap_work);
>
>  static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
> @@ -838,7 +836,7 @@ static int transfer_objects(struct array_cache *to,
>  static inline struct alien_cache **alloc_alien_cache(int node,
>                                                 int limit, gfp_t gfp)
>  {
> -       return (struct alien_cache **)BAD_ALIEN_MAGIC;
> +       return NULL;
>  }

With latest mainline, I'm getting a crash during bootup on m68k/ARAnyM:

enable_cpucache failed for radix_tree_node, error 12.
kernel BUG at /scratch/geert/linux/linux-m68k/mm/slab.c:1522!
*** TRAP #7 ***   FORMAT=0
Current process id is 0
BAD KERNEL TRAP: 00000000
Modules linked in:
PC: [<0039c92c>] kmem_cache_init_late+0x70/0x8c
SR: 2200  SP: 00345f90  a2: 0034c2e8
d0: 0000003d    d1: 00000000    d2: 00000000    d3: 003ac942
d4: 00000000    d5: 00000000    a0: 0034f686    a1: 0034f682
Process swapper (pid: 0, task=0034c2e8)
Frame format=0
Stack from 00345fc4:
        002f69ef 002ff7e5 000005f2 000360fa 0017d806 003921d4 00000000 00000000
        00000000 00000000 00000000 00000000 003ac942 00000000 003912d6
Call Trace: [<000360fa>] parse_args+0x0/0x2ca
 [<0017d806>] strlen+0x0/0x1a
 [<003921d4>] start_kernel+0x23c/0x428
 [<003912d6>] _sinittext+0x2d6/0x95e

Code: f7e5 4879 002f 69ef 61ff ffca 462a 4e47 <4879> 0035 4b1c 61ff
fff0 0cc4 7005 23c0 0037 fd20 588f 265f 285f 4e75 48e7 301c
Disabling lock debugging due to kernel taint
Kernel panic - not syncing: Attempted to kill the idle task!
---[ end Kernel panic - not syncing: Attempted to kill the idle task!

I bisected it to commit a640616822b2c3a8009b0600f20c4a76ea8a0025
Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Date:   Wed Aug 6 16:04:38 2014 -0700

    slab: remove BAD_ALIEN_MAGIC

    BAD_ALIEN_MAGIC value isn't used anymore. So remove it.

    Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Acked-by: Christoph Lameter <cl@linux.com>
    Cc: Pekka Enberg <penberg@kernel.org>
    Cc: David Rientjes <rientjes@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Error 12 is ENOMEM, so I first thought it went out-of-memory, but just reverting
the above commit on mainline makes it work again.

I don't see the failure on ARM.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
