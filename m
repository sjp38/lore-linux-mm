Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id DCABA6B0069
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 09:57:59 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id n3so3187411wiv.9
        for <linux-mm@kvack.org>; Sat, 18 Oct 2014 06:57:59 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id ji3si2512846wid.102.2014.10.18.06.57.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 18 Oct 2014 06:57:58 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so4016163wiv.5
        for <linux-mm@kvack.org>; Sat, 18 Oct 2014 06:57:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1413367243-23524-1-git-send-email-heesub.shin@samsung.com>
References: <1413367243-23524-1-git-send-email-heesub.shin@samsung.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Sat, 18 Oct 2014 09:57:37 -0400
Message-ID: <CALZtONDkBakFoBz6Pi_xN0A+uiAmWqKxPyzP-ynqF4f77ZNTog@mail.gmail.com>
Subject: Re: [PATCH] mm/zbud: init user ops only when it is needed
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sunae Seo <sunae.seo@samsung.com>

On Wed, Oct 15, 2014 at 6:00 AM, Heesub Shin <heesub.shin@samsung.com> wrote:
> When zbud is initialized through the zpool wrapper, pool->ops which
> points to user-defined operations is always set regardless of whether it
> is specified from the upper layer. This causes zbud_reclaim_page() to
> iterate its loop for evicting pool pages out without any gain.
>
> This patch sets the user-defined ops only when it is needed, so that
> zbud_reclaim_page() can bail out the reclamation loop earlier if there
> is no user-defined operations specified.

Though the only current user (zswap) always passes an ops param, other
future users may not and this is the right way to handle it.  thanks!

>
> Signed-off-by: Heesub Shin <heesub.shin@samsung.com>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zbud.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/zbud.c b/mm/zbud.c
> index ecf1dbe..db8de74 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -132,7 +132,7 @@ static struct zbud_ops zbud_zpool_ops = {
>
>  static void *zbud_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
>  {
> -       return zbud_create_pool(gfp, &zbud_zpool_ops);
> +       return zbud_create_pool(gfp, zpool_ops ? &zbud_zpool_ops : NULL);
>  }
>
>  static void zbud_zpool_destroy(void *pool)
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
