Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 574846B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 06:49:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s63so73624667wme.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 03:49:27 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id i192si16754221lfb.230.2016.05.02.03.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 03:49:25 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id j8so51107720lfd.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 03:49:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1462167348-6280-1-git-send-email-chengang@emindsoft.com.cn>
References: <1462167348-6280-1-git-send-email-chengang@emindsoft.com.cn>
Date: Mon, 2 May 2016 12:49:25 +0200
Message-ID: <CAG_fn=W5Ai_cqhzyi=EBEyhhQtvoQtOsuyfBfRihf=fuKh2Xqw@mail.gmail.com>
Subject: Re: [PATCH] include/linux/kasan.h: Notice about 0 for kasan_[dis/en]able_current()
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chengang@emindsoft.com.cn
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Mon, May 2, 2016 at 7:35 AM,  <chengang@emindsoft.com.cn> wrote:
> From: Chen Gang <chengang@emindsoft.com.cn>
>
> According to their comments and the kasan_depth's initialization, if
> kasan_depth is zero, it means disable. So kasan_depth need consider
> about the 0 overflow.
>
> Also remove useless comments for dummy kasan_slab_free().
>
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  include/linux/kasan.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 645c280..37fab04 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -32,13 +32,15 @@ static inline void *kasan_mem_to_shadow(const void *a=
ddr)
>  /* Enable reporting bugs after kasan_disable_current() */
>  static inline void kasan_enable_current(void)
>  {
> -       current->kasan_depth++;
> +       if (current->kasan_depth + 1)
> +               current->kasan_depth++;
>  }
>
>  /* Disable reporting bugs for current task */
>  static inline void kasan_disable_current(void)
>  {
> -       current->kasan_depth--;
> +       if (current->kasan_depth)
> +               current->kasan_depth--;
>  }
>
>  void kasan_unpoison_shadow(const void *address, size_t size);
> @@ -113,8 +115,6 @@ static inline void kasan_krealloc(const void *object,=
 size_t new_size,
>
>  static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
>                                    gfp_t flags) {}
> -/* kasan_slab_free() returns true if the object has been put into quaran=
tine.
> - */
>  static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
>  {
>         return false;
> --
> 1.9.3
>

Acked-by: Alexander Potapenko <glider@google.com>

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
