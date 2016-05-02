Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D14E76B025E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 07:34:53 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m64so35693540lfd.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:34:53 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id i131si16856487lfd.115.2016.05.02.04.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 04:34:52 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id m64so30838145lfd.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:34:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
Date: Mon, 2 May 2016 13:34:52 +0200
Message-ID: <CAG_fn=UdYpYQCyQ0JGD6VxNvNmZBChX-cTdaR5xm1S6BgP-Gnw@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Mon, May 2, 2016 at 7:36 AM,  <chengang@emindsoft.com.cn> wrote:
> From: Chen Gang <chengang@emindsoft.com.cn>
>
> According to kasan_[dis|en]able_current() comments and the kasan_depth'
> s initialization, if kasan_depth is zero, it means disable.
The comments for those functions are really poor, but there's nothing
there that says kasan_depth=3D=3D0 disables KASAN.
Actually, kasan_report_enabled() is currently the only place that
denotes the semantics of kasan_depth, so it couldn't be wrong.

init_task.kasan_depth is 1 during bootstrap and is then set to zero by
kasan_init()
For every other thread, current->kasan_depth is zero-initialized.

> So need use "!!kasan_depth" instead of "!kasan_depth" for checking
> enable.
>
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  mm/kasan/kasan.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 7da78a6..6464b8f 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -102,7 +102,7 @@ static inline const void *kasan_shadow_to_mem(const v=
oid *shadow_addr)
>
>  static inline bool kasan_report_enabled(void)
>  {
> -       return !current->kasan_depth;
> +       return !!current->kasan_depth;
>  }
>
>  void kasan_report(unsigned long addr, size_t size,
> --
> 1.9.3
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
