Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A636F6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 07:42:23 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k135so92567922lfb.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 04:42:23 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id 42si936735lfs.66.2016.08.02.04.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 04:42:22 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id b199so136392788lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 04:42:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1470062715-14077-2-git-send-email-aryabinin@virtuozzo.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com> <1470062715-14077-2-git-send-email-aryabinin@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 2 Aug 2016 13:42:20 +0200
Message-ID: <CAG_fn=W6DAYeYgo5a-28zt=sCY8LAMP6Yi35a6Aq_C_=dX=yUg@mail.gmail.com>
Subject: Re: [PATCH 2/6] mm/kasan: don't reduce quarantine in atomic contexts
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Aug 1, 2016 at 4:45 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
> Currently we call quarantine_reduce() for ___GFP_KSWAPD_RECLAIM
> (implied by __GFP_RECLAIM) allocation. So, basically we call it on
> almost every allocation. quarantine_reduce() sometimes is heavy operation=
,
> and calling it with disabled interrupts may trigger hard LOCKUP:
>
>  NMI watchdog: Watchdog detected hard LOCKUP on cpu 2irq event stamp: 141=
1258
>  Call Trace:
>   <NMI>  [<ffffffff98a48532>] dump_stack+0x68/0x96
>   [<ffffffff98357fbb>] watchdog_overflow_callback+0x15b/0x190
>   [<ffffffff9842f7d1>] __perf_event_overflow+0x1b1/0x540
>   [<ffffffff98455b14>] perf_event_overflow+0x14/0x20
>   [<ffffffff9801976a>] intel_pmu_handle_irq+0x36a/0xad0
>   [<ffffffff9800ba4c>] perf_event_nmi_handler+0x2c/0x50
>   [<ffffffff98057058>] nmi_handle+0x128/0x480
>   [<ffffffff980576d2>] default_do_nmi+0xb2/0x210
>   [<ffffffff980579da>] do_nmi+0x1aa/0x220
>   [<ffffffff99a0bb07>] end_repeat_nmi+0x1a/0x1e
>   <<EOE>>  [<ffffffff981871e6>] __kernel_text_address+0x86/0xb0
>   [<ffffffff98055c4b>] print_context_stack+0x7b/0x100
>   [<ffffffff98054e9b>] dump_trace+0x12b/0x350
>   [<ffffffff98076ceb>] save_stack_trace+0x2b/0x50
>   [<ffffffff98573003>] set_track+0x83/0x140
>   [<ffffffff98575f4a>] free_debug_processing+0x1aa/0x420
>   [<ffffffff98578506>] __slab_free+0x1d6/0x2e0
>   [<ffffffff9857a9b6>] ___cache_free+0xb6/0xd0
>   [<ffffffff9857db53>] qlist_free_all+0x83/0x100
>   [<ffffffff9857df07>] quarantine_reduce+0x177/0x1b0
>   [<ffffffff9857c423>] kasan_kmalloc+0xf3/0x100
>
> Reduce the quarantine_reduce iff direct reclaim is allowed.
>
> Fixes: 55834c59098d("mm: kasan: initial memory quarantine implementation"=
)
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Alexander Potapenko <glider@google.com>
> ---
>  mm/kasan/kasan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 3019cec..c99ef40 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -565,7 +565,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const vo=
id *object, size_t size,
>         unsigned long redzone_start;
>         unsigned long redzone_end;
>
> -       if (flags & __GFP_RECLAIM)
> +       if (gfpflags_allow_blocking(flags))
>                 quarantine_reduce();
>
>         if (unlikely(object =3D=3D NULL))
> @@ -596,7 +596,7 @@ void kasan_kmalloc_large(const void *ptr, size_t size=
, gfp_t flags)
>         unsigned long redzone_start;
>         unsigned long redzone_end;
>
> -       if (flags & __GFP_RECLAIM)
> +       if (gfpflags_allow_blocking(flags))
>                 quarantine_reduce();
>
>         if (unlikely(ptr =3D=3D NULL))
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
