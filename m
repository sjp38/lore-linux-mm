Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 845D86B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 12:04:52 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so1463032bkb.40
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 09:04:51 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id tn6si591404bkb.156.2013.12.13.09.04.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 09:04:51 -0800 (PST)
Date: Fri, 13 Dec 2013 12:04:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 7/7] mm: page_alloc: Default allow file pages to use
 remote nodes for fair allocation policy
Message-ID: <20131213170443.GO22729@cmpxchg.org>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-8-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386943807-29601-8-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 13, 2013 at 02:10:07PM +0000, Mel Gorman wrote:
> Indications from Johannes that he wanted this. Needs some data and/or justification why
> thrash protection needs it plus docs describing how MPOL_LOCAL is now different before
> it should be considered finished. I do not necessarily agree this patch is necessary
> but it's worth punting it out there for discussion and testing.

I demonstrated enormous gains in the original submission of the fair
allocation patch and your tests haven't really shown downsides to the
cache-over-nodes portion of it.  So I don't see why we should revert
the cache-over-nodes fairness without any supporting data.

Reverting cross-node fairness for anon and slab is a good idea.  It
was always about cache and the original patch was too broad stroked,
but it doesn't invalidate everything it was about.

I can see, however, that we might want to make this configurable, but
I'm not eager on exporting user interfaces unless we have to.  As the
node-local fairness was never questioned by anybody, is it necessary
to make it configurable?  Shouldn't we be okay with just a single
vm.pagecache_interleave (name by Rik) sysctl that defaults to 1 but
allows users to go back to pagecache obeying mempolicy?

> Not signed off
> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bf49918..bce40c0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1885,7 +1885,8 @@ unsigned __bitwise__ zone_distribute_mode __read_mostly;
>  #define DISTRIBUTE_STUPID_ANON	(DISTRIBUTE_LOCAL_ANON|DISTRIBUTE_REMOTE_ANON)
>  #define DISTRIBUTE_STUPID_FILE	(DISTRIBUTE_LOCAL_FILE|DISTRIBUTE_REMOTE_FILE)
>  #define DISTRIBUTE_STUPID_SLAB	(DISTRIBUTE_LOCAL_SLAB|DISTRIBUTE_REMOTE_SLAB)
> -#define DISTRIBUTE_DEFAULT	(DISTRIBUTE_LOCAL_ANON|DISTRIBUTE_LOCAL_FILE|DISTRIBUTE_LOCAL_SLAB)
> +#define DISTRIBUTE_DEFAULT	(DISTRIBUTE_LOCAL_ANON|DISTRIBUTE_LOCAL_FILE|DISTRIBUTE_LOCAL_SLAB| \
> +				 DISTRIBUTE_REMOTE_FILE)
>  
>  /* Only these GFP flags are affected by the fair zone allocation policy */
>  #define DISTRIBUTE_GFP_MASK	((GFP_MOVABLE_MASK|__GFP_PAGECACHE))
> -- 
> 1.8.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
