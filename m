Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC366B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 16:47:53 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so37670722lfw.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 13:47:53 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id b205si5555748wmd.1.2016.08.19.13.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 13:47:51 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id q128so48401220wma.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 13:47:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1471634122-31789-1-git-send-email-ebiggers@google.com>
References: <1471634122-31789-1-git-send-email-ebiggers@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 19 Aug 2016 13:47:50 -0700
Message-ID: <CAGXu5jKzGcHJj7oL_=ezPK46VfxbiuHdoRVbEfUNf_MSopoRMg@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid undefined behavior in hardened usercopy check
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 19, 2016 at 12:15 PM, Eric Biggers <ebiggers@google.com> wrote:
> check_bogus_address() checked for pointer overflow using this expression,
> where 'ptr' has type 'const void *':
>
>         ptr + n < ptr
>
> Since pointer wraparound is undefined behavior, gcc at -O2 by default
> treats it like the following, which would not behave as intended:
>
>         (long)n < 0
>
> Fortunately, this doesn't currently happen for kernel code because kernel
> code is compiled with -fno-strict-overflow.  But the expression should be
> fixed anyway to use well-defined integer arithmetic, since it could be
> treated differently by different compilers in the future or could be
> reported by tools checking for undefined behavior.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Cool, thanks. I'll get this into my tree.

-Kees

> ---
>  mm/usercopy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index 8ebae91..82f81df 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -124,7 +124,7 @@ static inline const char *check_kernel_text_object(const void *ptr,
>  static inline const char *check_bogus_address(const void *ptr, unsigned long n)
>  {
>         /* Reject if object wraps past end of memory. */
> -       if (ptr + n < ptr)
> +       if ((unsigned long)ptr + n < (unsigned long)ptr)
>                 return "<wrapped address>";
>
>         /* Reject if NULL or ZERO-allocation. */
> --
> 2.8.0.rc3.226.g39d4020
>



-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
