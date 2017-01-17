Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 16F736B0253
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 20:27:05 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id n189so106644489pga.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 17:27:05 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f1si23202820plm.190.2017.01.16.17.27.03
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 17:27:04 -0800 (PST)
Date: Tue, 17 Jan 2017 10:33:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slab: add a check for the first kmem_cache not to be
 destroyed
Message-ID: <20170117013300.GA25940@js1304-P5Q-DELUXE>
References: <20170116070459.43540-1-kwon@toanyone.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170116070459.43540-1-kwon@toanyone.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyunghwan Kwon <kwon@toanyone.net>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 16, 2017 at 04:04:59PM +0900, Kyunghwan Kwon wrote:
> The first kmem_cache created at booting up is supposed neither mergeable
> nor destroyable but was possible to destroy. So prevent it.
> 
> Signed-off-by: Kyunghwan Kwon <kwon@toanyone.net>
> ---
>  mm/slab_common.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 1dfc209..2d30ace 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -744,7 +744,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
>  	bool need_rcu_barrier = false;
>  	int err;
>  
> -	if (unlikely(!s))
> +	if (unlikely(!s) || s->refcount == -1)
>  		return;

Hello, Kyunghwan.

Few lines below, s->refcount is checked.

if (s->refcount)
        goto unlock;

Am I missing something?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
