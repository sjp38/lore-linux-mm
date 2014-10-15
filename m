Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D03CC6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 16:17:13 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id ey11so1921911pad.41
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 13:17:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ov3si12250779pbc.228.2014.10.15.13.17.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Oct 2014 13:17:12 -0700 (PDT)
Date: Wed, 15 Oct 2014 13:17:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/zbud: init user ops only when it is needed
Message-Id: <20141015131710.ffd6c40996cd1ce6c16dbae8@linux-foundation.org>
In-Reply-To: <1413367243-23524-1-git-send-email-heesub.shin@samsung.com>
References: <1413367243-23524-1-git-send-email-heesub.shin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>

On Wed, 15 Oct 2014 19:00:43 +0900 Heesub Shin <heesub.shin@samsung.com> wrote:

> When zbud is initialized through the zpool wrapper, pool->ops which
> points to user-defined operations is always set regardless of whether it
> is specified from the upper layer. This causes zbud_reclaim_page() to
> iterate its loop for evicting pool pages out without any gain.
> 
> This patch sets the user-defined ops only when it is needed, so that
> zbud_reclaim_page() can bail out the reclamation loop earlier if there
> is no user-defined operations specified.

Which callsite is calling zbud_zpool_create(..., NULL)?

> ...
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -132,7 +132,7 @@ static struct zbud_ops zbud_zpool_ops = {
>  
>  static void *zbud_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
>  {
> -	return zbud_create_pool(gfp, &zbud_zpool_ops);
> +	return zbud_create_pool(gfp, zpool_ops ? &zbud_zpool_ops : NULL);
>  }
>  
>  static void zbud_zpool_destroy(void *pool)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
