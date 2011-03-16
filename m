Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CFF748D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 16:28:40 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p2GKSbTE012822
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:28:37 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz5.hot.corp.google.com with ESMTP id p2GKSZcB021262
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:28:36 -0700
Received: by pzk2 with SMTP id 2so420981pzk.23
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:28:35 -0700 (PDT)
Date: Wed, 16 Mar 2011 13:28:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/8] mm/slub: Factor out some common code.
In-Reply-To: <20110316022805.27713.qmail@science.horizon.com>
Message-ID: <alpine.DEB.2.00.1103161308410.11002@chino.kir.corp.google.com>
References: <20110316022805.27713.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, herbert@gondor.hengli.com.au, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Mar 2011, George Spelvin wrote:

> For sysfs files that map a boolean to a flags bit.

Where's your signed-off-by?

> ---
>  mm/slub.c |   93 ++++++++++++++++++++++++++++--------------------------------
>  1 files changed, 43 insertions(+), 50 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index e15aa7f..856246f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3982,38 +3982,61 @@ static ssize_t objects_partial_show(struct kmem_cache *s, char *buf)
>  }
>  SLAB_ATTR_RO(objects_partial);
>  
> +static ssize_t flag_show(struct kmem_cache *s, char *buf, unsigned flag)
> +{
> +	return sprintf(buf, "%d\n", !!(s->flags & flag));
> +}
> +
> +static ssize_t flag_store(struct kmem_cache *s,
> +				const char *buf, size_t length, unsigned flag)
> +{
> +	s->flags &= ~flag;
> +	if (buf[0] == '1')
> +		s->flags |= flag;
> +	return length;
> +}
> +
> +/* Like above, but changes allocation size; so only allowed on empty slab */
> +static ssize_t flag_store_sizechange(struct kmem_cache *s,
> +				const char *buf, size_t length, unsigned flag)
> +{
> +	if (any_slab_objects(s))
> +		return -EBUSY;
> +
> +	flag_store(s, buf, length, flag);
> +	calculate_sizes(s, -1);
> +	return length;
> +}
> +

Nice cleanup.

"flag" should be unsigned long in all of these functions: the constants 
are declared with UL suffixes in slab.h.

After that's fixed,

	Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
