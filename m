Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 3B5C76B0062
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 10:30:08 -0400 (EDT)
Message-ID: <5044BE2F.8020902@parallels.com>
Date: Mon, 3 Sep 2012 18:26:55 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [01/14] slub: Add debugging to verify correct cache use on
 kmem_cache_free()
References: <20120824160903.168122683@linux.com> <00000139596ca1bb-cd01519b-4a4a-4673-9567-2f2b6d7d3616-000000@email.amazonses.com>
In-Reply-To: <00000139596ca1bb-cd01519b-4a4a-4673-9567-2f2b6d7d3616-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:17 PM, Christoph Lameter wrote:
> Add additional debugging to check that the objects is actually from the cache
> the caller claims. Doing so currently trips up some other debugging code. It
> takes a lot to infer from that what was happening.
> 
> V2: Only warn once.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

I am fine with it.

Reviewed-by: Glauber Costa <glommer@parallels.com>
> ---
>  mm/slub.c |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index c67bd0a..00f8557 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2614,6 +2614,13 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
>  
>  	page = virt_to_head_page(x);
>  
> +	if (kmem_cache_debug(s) && page->slab != s) {
> +		printk("kmem_cache_free: Wrong slab cache. %s but object"
> +			" is from  %s\n", page->slab->name, s->name);
> +		WARN_ON_ONCE(1);
> +		return;
> +	}
> +
>  	slab_free(s, page, x, _RET_IP_);
>  
>  	trace_kmem_cache_free(_RET_IP_, x);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
