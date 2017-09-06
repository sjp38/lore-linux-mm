Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E86712802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 13:21:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i198so3228711wmf.5
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 10:21:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j194si1599057wmd.114.2017.09.06.10.21.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 10:21:13 -0700 (PDT)
Date: Wed, 6 Sep 2017 19:21:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm/slub: wake up kswapd for initial high order
 allocation
Message-ID: <20170906172110.m7ag4ox34fcscg4x@dhcp22.suse.cz>
References: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1709061056270.13344@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1709061056270.13344@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed 06-09-17 10:59:09, Cristopher Lameter wrote:
> On Wed, 6 Sep 2017, js1304@gmail.com wrote:
> 
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1578,8 +1578,12 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> >  	 * so we fall-back to the minimum order allocation.
> >  	 */
> >  	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
> > -	if ((alloc_gfp & __GFP_DIRECT_RECLAIM) && oo_order(oo) > oo_order(s->min))
> > -		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~(__GFP_RECLAIM|__GFP_NOFAIL);
> > +	if (oo_order(oo) > oo_order(s->min)) {
> > +		if (alloc_gfp & __GFP_DIRECT_RECLAIM) {
> > +			alloc_gfp |= __GFP_NOMEMALLOC;
> > +			alloc_gfp &= ~__GFP_DIRECT_RECLAIM;
> > +		}
> > +	}
> >
> 
> Can we come up with another inline function in gfp.h for this as well?

What do you mean? The oo_order thing?

> Well and needing these functions to manipulate flags actually indicates
> that we may need a cleanup of the GFP flags at some point. There is a buch
> of flags that disable things and some that enable things.

Good luck with that
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
