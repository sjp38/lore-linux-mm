Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E768E6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 16:55:34 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so104779489pab.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 13:55:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ke5si5714447pab.238.2015.06.08.13.55.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 13:55:34 -0700 (PDT)
Date: Mon, 8 Jun 2015 13:55:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zsmalloc: fix a null pointer dereference in
 destroy_handle_cache()
Message-Id: <20150608135532.ac913746b6394217e92a229a@linux-foundation.org>
In-Reply-To: <1433502690-2524-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433502690-2524-1-git-send-email-sergey.senozhatsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On Fri,  5 Jun 2015 20:11:30 +0900 Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:

> zs_destroy_pool()->destroy_handle_cache() invoked from
> zs_create_pool() can pass a NULL ->handle_cachep pointer
> to kmem_cache_destroy(), which will dereference it.
>

That's slightly lacking in details (under what circumstances will it
crash) so I changed it to

: If zs_create_pool()->create_handle_cache()->kmem_cache_create() fails,
: zs_create_pool()->destroy_handle_cache() will dereference the NULL
: pool->handle_cachep.
:
: Modify destroy_handle_cache() to avoid this.


> ...
>
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -285,7 +285,8 @@ static int create_handle_cache(struct zs_pool *pool)
>  
>  static void destroy_handle_cache(struct zs_pool *pool)
>  {
> -	kmem_cache_destroy(pool->handle_cachep);
> +	if (pool->handle_cachep)
> +		kmem_cache_destroy(pool->handle_cachep);
>  }
>  
>  static unsigned long alloc_handle(struct zs_pool *pool)

I'll apply this, but...  from a bit of grepping I'm estimating that we
have approximately 200 instances of

	if (foo)
		kmem_cache_destroy(foo);

so obviously kmem_cache_destroy() should be doing the check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
