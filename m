Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCA2D6B0253
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 14:22:55 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id q16so7187067ioh.4
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 11:22:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x4sor7018009iti.119.2018.01.08.11.22.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 11:22:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180102100320.24801-2-joeypabalinas@gmail.com>
References: <20180102100320.24801-1-joeypabalinas@gmail.com> <20180102100320.24801-2-joeypabalinas@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 8 Jan 2018 14:22:13 -0500
Message-ID: <CALZtOND9r9gz8cUPYfRN7Wjaowcx1uHnqQbNw8Qxo8pRSgJwcw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/zswap: make type and compressor const
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joey Pabalinas <joeypabalinas@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jan 2, 2018 at 5:03 AM, Joey Pabalinas <joeypabalinas@gmail.com> wrote:
> The characters pointed to by `zswap_compressor`, `type`, and `compressor`
> aren't ever modified. Add const to the static variable and both parameters in
> `zswap_pool_find_get()`, `zswap_pool_create()`, and `__zswap_param_set()`
>
> Signed-off-by: Joey Pabalinas <joeypabalinas@gmail.com>

Nak.

Those variables are not const; they are updated in
__zswap_param_set().  They aren't modified in pool_find_get() or
pool_create(), but they certainly aren't globally const.

>
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index d39581a076c3aed1e9..a4f2dfaf9131694265 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -90,7 +90,7 @@ module_param_cb(enabled, &zswap_enabled_param_ops, &zswap_enabled, 0644);
>
>  /* Crypto compressor to use */
>  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> -static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> +static const char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
>  static int zswap_compressor_param_set(const char *,
>                                       const struct kernel_param *);
>  static struct kernel_param_ops zswap_compressor_param_ops = {
> @@ -475,7 +475,8 @@ static struct zswap_pool *zswap_pool_last_get(void)
>  }
>
>  /* type and compressor must be null-terminated */
> -static struct zswap_pool *zswap_pool_find_get(char *type, char *compressor)
> +static struct zswap_pool *zswap_pool_find_get(const char *type,
> +                                             const char *compressor)
>  {
>         struct zswap_pool *pool;
>
> @@ -495,7 +496,8 @@ static struct zswap_pool *zswap_pool_find_get(char *type, char *compressor)
>         return NULL;
>  }
>
> -static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
> +static struct zswap_pool *zswap_pool_create(const char *type,
> +                                           const char *compressor)
>  {
>         struct zswap_pool *pool;
>         char name[38]; /* 'zswap' + 32 char (max) num + \0 */
> @@ -658,7 +660,7 @@ static void zswap_pool_put(struct zswap_pool *pool)
>
>  /* val must be a null-terminated string */
>  static int __zswap_param_set(const char *val, const struct kernel_param *kp,
> -                            char *type, char *compressor)
> +                            const char *type, const char *compressor)
>  {
>         struct zswap_pool *pool, *put_pool = NULL;
>         char *s = strstrip((char *)val);
> --
> 2.15.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
