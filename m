Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EB43B6B01EF
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 13:56:31 -0400 (EDT)
Message-ID: <4BC601C5.5050404@cs.helsinki.fi>
Date: Wed, 14 Apr 2010 20:56:21 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH - V2] Fix missing of last user while dumping slab corruption
 	log
References: <w2z4810ea571004112250x855fadd5uecbc813726ae3412@mail.gmail.com>
In-Reply-To: <w2z4810ea571004112250x855fadd5uecbc813726ae3412@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ShiYong LI <a22381@motorola.com>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, dwmw2@infradead.org, TAO HU <taohu@motorola.com>
List-ID: <linux-mm.kvack.org>

ShiYong LI wrote:
> Hi,
> 
> Compared to previous version, add alignment checking to make sure
> memory space storing redzone2 and last user tags is 8 byte alignment.
> 
> From 949e8c29e8681a2359e23a8fbd8b9d4833f42344 Mon Sep 17 00:00:00 2001
> From: Shiyong Li <shi-yong.li@motorola.com>
> Date: Mon, 12 Apr 2010 13:48:21 +0800
> Subject: [PATCH] Fix missing of last user info while getting
> DEBUG_SLAB config enabled.
> 
> Even with SLAB_RED_ZONE and SLAB_STORE_USER enabled, kernel would NOT
> store redzone and last user data around allocated memory space if arch
> cache line > sizeof(unsigned long long). As a result, last user information
> is unexpectedly MISSED while dumping slab corruption log.
> 
> This fix makes sure that redzone and last user tags get stored unless
> the required alignment breaks redzone's.
> 
> Signed-off-by: Shiyong Li <shi-yong.li@motorola.com>

OK, I added this to linux-next for testing. Thanks!

> ---
>  mm/slab.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index a8a38ca..b97c57e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2267,8 +2267,8 @@ kmem_cache_create (const char *name, size_t
> size, size_t align,
>  	if (ralign < align) {
>  		ralign = align;
>  	}
> -	/* disable debug if necessary */
> -	if (ralign > __alignof__(unsigned long long))
> +	/* disable debug if not aligning with REDZONE_ALIGN */
> +	if (ralign & (__alignof__(unsigned long long) - 1))
>  		flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);
>  	/*
>  	 * 4) Store it.
> @@ -2289,8 +2289,8 @@ kmem_cache_create (const char *name, size_t
> size, size_t align,
>  	 */
>  	if (flags & SLAB_RED_ZONE) {
>  		/* add space for red zone words */
> -		cachep->obj_offset += sizeof(unsigned long long);
> -		size += 2 * sizeof(unsigned long long);
> +		cachep->obj_offset += align;
> +		size += align + sizeof(unsigned long long);
>  	}
>  	if (flags & SLAB_STORE_USER) {
>  		/* user store requires one word storage behind the end of

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
