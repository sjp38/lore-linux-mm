Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id CB3166B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 04:06:50 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so11285410wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 01:06:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 200si2945549wms.27.2016.03.04.01.06.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Mar 2016 01:06:49 -0800 (PST)
Subject: Re: [PATCH] crypto/async_pq: use __free_page() instead of put_page()
References: <1456738445-876239-1-git-send-email-arnd@arndb.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D95025.1060500@suse.cz>
Date: Fri, 4 Mar 2016 10:06:45 +0100
MIME-Version: 1.0
In-Reply-To: <1456738445-876239-1-git-send-email-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-arm-kernel@lists.infradead.org, Michal Nazarewicz <mina86@mina86.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, "David S. Miller" <davem@davemloft.net>, NeilBrown <neilb@suse.com>, Markus Stockhausen <stockhausen@collogia.de>, Vinod Koul <vinod.koul@intel.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org

On 02/29/2016 10:33 AM, Arnd Bergmann wrote:
> The addition of tracepoints to the page reference tracking had an
> unfortunate side-effect in at least one driver that calls put_page
> from its exit function, resulting in a link error:
> 
> `.exit.text' referenced in section `__jump_table' of crypto/built-in.o: defined in discarded section `.exit.text' of crypto/built-in.o
> 
> From a cursory look at that this driver, it seems that it may be
> doing the wrong thing here anyway, as the page gets allocated
> using 'alloc_page()', and should be freed using '__free_page()'
> rather than 'put_page()'.
> 
> With this patch, I no longer get any other build errors from the
> page_ref patch, so hopefully we can assume that it's always wrong
> to call any of those functions from __exit code, and that no other
> driver does it.

Hopefully that's true. If any such driver was leaking references to
those pages, so the put_page() didn't actually result in freeing, the
explicit __free_page should catch this via built-in checks.

> Fixes: 0f80830dd044 ("mm/page_ref: add tracepoint to track down page reference manipulation")

Since it's in mmotm which is quilt-based, the commit hash from -next is
not stable.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  crypto/async_tx/async_pq.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/crypto/async_tx/async_pq.c b/crypto/async_tx/async_pq.c
> index c0748bbd4c08..08b3ac68952b 100644
> --- a/crypto/async_tx/async_pq.c
> +++ b/crypto/async_tx/async_pq.c
> @@ -444,7 +444,7 @@ static int __init async_pq_init(void)
>  
>  static void __exit async_pq_exit(void)
>  {
> -	put_page(pq_scribble_page);
> +	__free_page(pq_scribble_page);
>  }
>  
>  module_init(async_pq_init);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
