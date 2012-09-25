Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 645A36B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 03:15:25 -0400 (EDT)
Received: by wibhq7 with SMTP id hq7so125997wib.8
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 00:15:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1347137279-17568-5-git-send-email-elezegarcia@gmail.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
	<1347137279-17568-5-git-send-email-elezegarcia@gmail.com>
Date: Tue, 25 Sep 2012 10:15:23 +0300
Message-ID: <CAOJsxLGf3Aburoqw5xxycbM8yOLQPoGVR+Hv9qcaaAo2k7EV_A@mail.gmail.com>
Subject: Re: [PATCH 05/10] mm, util: Use dup_user to duplicate user memory
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Sat, Sep 8, 2012 at 11:47 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> Previously the strndup_user allocation was being done through memdup_user,
> and the caller was wrongly traced as being strndup_user
> (the correct trace must report the caller of strndup_user).
>
> This is a common problem: in order to get accurate callsite tracing,
> a utils function can't allocate through another utils function,
> but instead do the allocation himself (or inlined).
>
> Here we fix this by creating an always inlined dup_user() function to
> performed the real allocation and to be used by memdup_user and strndup_user.
>
> Cc: Pekka Enberg <penberg@kernel.org>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
> ---
>  mm/util.c |   11 ++++++++---
>  1 files changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/mm/util.c b/mm/util.c
> index dc3036c..48d3ff8b 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -76,14 +76,14 @@ void *kmemdup(const void *src, size_t len, gfp_t gfp)
>  EXPORT_SYMBOL(kmemdup);
>
>  /**
> - * memdup_user - duplicate memory region from user space
> + * dup_user - duplicate memory region from user space
>   *
>   * @src: source address in user space
>   * @len: number of bytes to copy
>   *
>   * Returns an ERR_PTR() on failure.
>   */
> -void *memdup_user(const void __user *src, size_t len)
> +static __always_inline void *dup_user(const void __user *src, size_t len)
>  {
>         void *p;
>
> @@ -103,6 +103,11 @@ void *memdup_user(const void __user *src, size_t len)
>
>         return p;
>  }
> +
> +void *memdup_user(const void __user *src, size_t len)
> +{
> +       return dup_user(src, len);
> +}
>  EXPORT_SYMBOL(memdup_user);
>
>  static __always_inline void *__do_krealloc(const void *p, size_t new_size,
> @@ -214,7 +219,7 @@ char *strndup_user(const char __user *s, long n)
>         if (length > n)
>                 return ERR_PTR(-EINVAL);
>
> -       p = memdup_user(s, length);
> +       p = dup_user(s, length);
>
>         if (IS_ERR(p))
>                 return p;

Looks good to me. Andrew, do you want to pick this up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
