Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id CCCFF6B006C
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 07:26:49 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id vb8so325751obc.7
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:26:49 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id gp3si767615obb.47.2014.11.25.04.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 04:26:48 -0800 (PST)
Received: by mail-ob0-f179.google.com with SMTP id va2so330385obc.10
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:26:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1416852146-9781-7-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com> <1416852146-9781-7-git-send-email-a.ryabinin@samsung.com>
From: Dmitry Chernenkov <dmitryc@google.com>
Date: Tue, 25 Nov 2014 16:26:28 +0400
Message-ID: <CAA6XgkGWdR7r1VmKKE0-Rs9jozdXcv88khB1goFrOyDx1wTkhg@mail.gmail.com>
Subject: Re: [PATCH v7 06/12] mm: slub: share slab_err and object_err functions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

LGTM

On Mon, Nov 24, 2014 at 9:02 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> Remove static and add function declarations to mm/slab.h so they
> could be used by kernel address sanitizer.
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  include/linux/slub_def.h | 5 +++++
>  mm/slub.c                | 4 ++--
>  2 files changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index c75bc1d..144b5cb 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -115,4 +115,9 @@ static inline void *virt_to_obj(struct kmem_cache *s, void *slab_page, void *x)
>         return x - ((x - slab_page) % s->size);
>  }
>
> +__printf(3, 4)
> +void slab_err(struct kmem_cache *s, struct page *page, const char *fmt, ...);
> +void object_err(struct kmem_cache *s, struct page *page,
> +               u8 *object, char *reason);
> +
>  #endif /* _LINUX_SLUB_DEF_H */
> diff --git a/mm/slub.c b/mm/slub.c
> index 95d2142..0c01584 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -629,14 +629,14 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
>         dump_stack();
>  }
>
> -static void object_err(struct kmem_cache *s, struct page *page,
> +void object_err(struct kmem_cache *s, struct page *page,
>                         u8 *object, char *reason)
>  {
>         slab_bug(s, "%s", reason);
>         print_trailer(s, page, object);
>  }
>
> -static void slab_err(struct kmem_cache *s, struct page *page,
> +void slab_err(struct kmem_cache *s, struct page *page,
>                         const char *fmt, ...)
>  {
>         va_list args;
> --
> 2.1.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
