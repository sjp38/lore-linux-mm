Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 99DD7828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 07:09:29 -0500 (EST)
Received: by mail-qk0-f180.google.com with SMTP id q19so238357297qke.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 04:09:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 205si7141318qhr.99.2016.01.14.04.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 04:09:28 -0800 (PST)
Date: Thu, 14 Jan 2016 13:09:19 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 04/16] mm/slab: activate debug_pagealloc in SLAB when it
 is actually enabled
Message-ID: <20160114130919.48254935@redhat.com>
In-Reply-To: <1452749069-15334-5-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1452749069-15334-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, brouer@redhat.com

On Thu, 14 Jan 2016 14:24:17 +0900
Joonsoo Kim <js1304@gmail.com> wrote:

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/slab.c | 15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index bbe4df2..4b55516 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1838,7 +1838,8 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
>  
>  		if (cachep->flags & SLAB_POISON) {
>  #ifdef CONFIG_DEBUG_PAGEALLOC
> -			if (cachep->size % PAGE_SIZE == 0 &&
> +			if (debug_pagealloc_enabled() &&
> +				cachep->size % PAGE_SIZE == 0 &&
>  					OFF_SLAB(cachep))
>  				kernel_map_pages(virt_to_page(objp),
>  					cachep->size / PAGE_SIZE, 1);
> @@ -2176,7 +2177,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>  	 * to check size >= 256. It guarantees that all necessary small
>  	 * sized slab is initialized in current slab initialization sequence.
>  	 */
> -	if (!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
> +	if (debug_pagealloc_enabled() &&
> +		!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
>  		size >= 256 && cachep->object_size > cache_line_size() &&
>  		ALIGN(size, cachep->align) < PAGE_SIZE) {
>  		cachep->obj_offset += PAGE_SIZE - ALIGN(size, cachep->align);
> @@ -2232,7 +2234,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>  		 * poisoning, then it's going to smash the contents of
>  		 * the redzone and userword anyhow, so switch them off.
>  		 */
> -		if (size % PAGE_SIZE == 0 && flags & SLAB_POISON)
> +		if (debug_pagealloc_enabled() &&
> +			size % PAGE_SIZE == 0 && flags & SLAB_POISON)
>  			flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);

Sorry, but I dislike the indention style here (when the if covers
several lines). Same goes for other changes in this patch.  Looking,
there are several example of this indention style in the existing
mm/slab.c. Thus, I don't know if this is accepted in the MM area (it is
definitely not accepted in the NET-area).


>  #endif
>  	}
> @@ -2716,7 +2719,8 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
>  	set_obj_status(page, objnr, OBJECT_FREE);
>  	if (cachep->flags & SLAB_POISON) {
>  #ifdef CONFIG_DEBUG_PAGEALLOC
> -		if ((cachep->size % PAGE_SIZE)==0 && OFF_SLAB(cachep)) {
> +		if (debug_pagealloc_enabled() &&
> +			(cachep->size % PAGE_SIZE) == 0 && OFF_SLAB(cachep)) {
>  			store_stackinfo(cachep, objp, caller);
>  			kernel_map_pages(virt_to_page(objp),
>  					 cachep->size / PAGE_SIZE, 0);
> @@ -2861,7 +2865,8 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
>  		return objp;
>  	if (cachep->flags & SLAB_POISON) {
>  #ifdef CONFIG_DEBUG_PAGEALLOC
> -		if ((cachep->size % PAGE_SIZE) == 0 && OFF_SLAB(cachep))
> +		if (debug_pagealloc_enabled() &&
> +			(cachep->size % PAGE_SIZE) == 0 && OFF_SLAB(cachep))
>  			kernel_map_pages(virt_to_page(objp),
>  					 cachep->size / PAGE_SIZE, 1);
>  		else



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
