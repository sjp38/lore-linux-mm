Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51DF96B025E
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 04:50:47 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id 41so245031010qtn.7
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 01:50:47 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 5si27494802qtn.280.2016.12.27.01.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 01:50:46 -0800 (PST)
Subject: Re: [PATCH v2] slub: do not merge cache if slub_debug contains a
 never-merge flag
References: <20161222235959.GC6871@lp-laptop-d>
 <alpine.DEB.2.20.1612231228340.21172@east.gentwo.org>
 <20161223190023.GA9644@lp-laptop-d>
 <alpine.DEB.2.20.1612241708280.9536@east.gentwo.org>
 <20161226190855.GB2600@lp-laptop-d>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <2fbcdb6a-f3b6-fc33-653a-6e7162b8513f@iki.fi>
Date: Tue, 27 Dec 2016 11:50:43 +0200
MIME-Version: 1.0
In-Reply-To: <20161226190855.GB2600@lp-laptop-d>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Maistrenko <grygoriimkd@gmail.com>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On 12/26/2016 09:08 PM, Grygorii Maistrenko wrote:
> In case CONFIG_SLUB_DEBUG_ON=n, find_mergeable() gets debug features
> from commandline but never checks if there are features from the
> SLAB_NEVER_MERGE set.
> As a result selected by slub_debug caches are always mergeable if they
> have been created without a custom constructor set or without one of the
> SLAB_* debug features on.
>
> This moves the SLAB_NEVER_MERGE check below the flags update from
> commandline to make sure it won't merge the slab cache if one of the
> debug features is on.
>
> Signed-off-by: Grygorii Maistrenko <grygoriimkd@gmail.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

> ---
>   mm/slab_common.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> New in v2:
> 	- (flags & SLAB_NEVER_MERGE) check is moved down below the flags update
> 	  as suggested by Christoph Lameter
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 329b03843863..a85a01439490 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -255,7 +255,7 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
>   {
>   	struct kmem_cache *s;
>   
> -	if (slab_nomerge || (flags & SLAB_NEVER_MERGE))
> +	if (slab_nomerge)
>   		return NULL;
>   
>   	if (ctor)
> @@ -266,6 +266,9 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
>   	size = ALIGN(size, align);
>   	flags = kmem_cache_flags(size, flags, name, NULL);
>   
> +	if (flags & SLAB_NEVER_MERGE)
> +		return NULL;
> +
>   	list_for_each_entry_reverse(s, &slab_caches, list) {
>   		if (slab_unmergeable(s))
>   			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
