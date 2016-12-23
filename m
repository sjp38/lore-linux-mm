Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFCEC6B035D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 13:30:06 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id o11so56802946ioo.0
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 10:30:06 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id 201si22175301ity.115.2016.12.23.10.30.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Dec 2016 10:30:06 -0800 (PST)
Date: Fri, 23 Dec 2016 12:30:02 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: do not merge cache if slub_debug contains a
 never-merge flag
In-Reply-To: <20161222235959.GC6871@lp-laptop-d>
Message-ID: <alpine.DEB.2.20.1612231228340.21172@east.gentwo.org>
References: <20161222235959.GC6871@lp-laptop-d>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Maistrenko <grygoriimkd@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>


On Fri, 23 Dec 2016, Grygorii Maistrenko wrote:

> In case CONFIG_SLUB_DEBUG_ON=n find_mergeable() gets debug features
> from commandline but never checks if there are features from the
> SLAB_NEVER_MERGE set.
> As a result selected by slub_debug caches are always mergeable if they
> have been created without a custom constructor set or without one of the
> SLAB_* debug features on.

WTF is this nonsense? That check is done a few lines earlier!

struct kmem_cache *ind_mergeable(size_t size, size_t align,
                unsigned long flags, const char *name, void (*ctor)(void *))
{
        struct kmem_cache *s;

        if (slab_nomerge || (flags & SLAB_NEVER_MERGE))    <----- !!!!!!
                return NULL;

        if (ctor)
                return NULL;

        size = ALIGN(size, sizeof(void *));
        align = calculate_alignment(flags,


>
> This adds the necessary check and makes selected slab caches unmergeable
> if one of the SLAB_NEVER_MERGE features is set from commandline.
>
> Signed-off-by: Grygorii Maistrenko <grygoriimkd@gmail.com>
> ---
>  mm/slab_common.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 329b03843863..7341cba8c58b 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -266,6 +266,9 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
>  	size = ALIGN(size, align);
>  	flags = kmem_cache_flags(size, flags, name, NULL);
>
> +	if (flags & SLAB_NEVER_MERGE)
> +		return NULL;
> +
>  	list_for_each_entry_reverse(s, &slab_caches, list) {
>  		if (slab_unmergeable(s))
>  			continue;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
