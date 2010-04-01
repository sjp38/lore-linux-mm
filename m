Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFE96B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 02:29:48 -0400 (EDT)
Message-ID: <4BB43D58.5030801@cs.helsinki.fi>
Date: Thu, 01 Apr 2010 09:29:44 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] Fix missing of last user info while getting DEBUG_SLAB
 config 	enabled
References: <l2g4810ea571003312024jb883f2eet5b48a7fbb9ec340f@mail.gmail.com>
In-Reply-To: <l2g4810ea571003312024jb883f2eet5b48a7fbb9ec340f@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ShiYong LI <a22381@motorola.com>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ShiYong LI kirjoitti:
> Hi all,
>  
> For OMAP3430 chip, while getting DEBUG_SLAB config enabled, found a bug 
> that last user information is missed in slab corruption log dumped by 
> kernel. Actually, It's caused by ignorance of redzone and last user tag 
> while calling kmem_cache_create() function if cache alignment > 16 bytes 
> (unsigned long long). 
>  
> Here is a patch to fix this problem. Already verified it on kernel 2.6.29.

The patch is badly whitespace damaged.

>  From 26a5a8ad2a1d7612929a91f6866cea9d1bea6077 Mon Sep 17 00:00:00 2001
> From: Shiyong Li <shi-yong.li@motorola.com 
> <mailto:shi-yong.li@motorola.com>>
> Date: Wed, 31 Mar 2010 10:09:35 +0800
> Subject: [PATCH] Fix missing of last user info while getting DEBUG_SLAB 
> config enabled.
> As OMAP3 cache line is 64 byte long, while calling kmem_cache_create()
> funtion, some cases need 64 byte alignment of requested memory space.
> But, if cache line > 16 bytes, current kernel ignore redzone
> and last user debug head/trail tag to make sure this alignment is not
> broken.
> This fix removes codes that ignorance of redzone and last user tag.
> Instead, use "align" argument value as object offset to guarantee the
> alignment.
> Signed-off-by: Shiyong Li <shi-yong.li@motorola.com 
> <mailto:shi-yong.li@motorola.com>>
> ---
>  mm/slab.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
> diff --git a/mm/slab.c b/mm/slab.c
> index a8a38ca..84af997 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2267,9 +2267,6 @@ kmem_cache_create (const char *name, size_t size, 
> size_t align,
>   if (ralign < align) {
>    ralign = align;
>   }
> - /* disable debug if necessary */
> - if (ralign > __alignof__(unsigned long long))
> -  flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);
>   /*
>    * 4) Store it.
>    */
> @@ -2289,8 +2286,8 @@ kmem_cache_create (const char *name, size_t size, 
> size_t align,
>    */
>   if (flags & SLAB_RED_ZONE) {
>    /* add space for red zone words */
> -  cachep->obj_offset += sizeof(unsigned long long);
> -  size += 2 * sizeof(unsigned long long);
> +  cachep->obj_offset += align;
> +  size += align + sizeof(unsigned long long);
>   }

I don't understand what you're trying to do here. What if align is less 
han sizeof(unsigned long long)? What if SLAB_RED_ZONE is not enabled but 
  SLAB_STORE_USER is?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
