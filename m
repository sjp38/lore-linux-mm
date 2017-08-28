Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4AB26B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 09:08:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n37so611301wrf.8
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 06:08:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f66si256055wmd.163.2017.08.28.06.08.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 06:08:32 -0700 (PDT)
Date: Mon, 28 Aug 2017 15:08:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm/slub: don't use reserved highatomic pageblock for
 optimistic try
Message-ID: <20170828130829.GL17097@dhcp22.suse.cz>
References: <1503882675-17910-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1503882675-17910-2-git-send-email-iamjoonsoo.kim@lge.com>
 <b50bd39f-931f-7016-f380-62d65babb03f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b50bd39f-931f-7016-f380-62d65babb03f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On Mon 28-08-17 13:29:29, Vlastimil Babka wrote:
> On 08/28/2017 03:11 AM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > High-order atomic allocation is difficult to succeed since we cannot
> > reclaim anything in this context. So, we reserves the pageblock for
> > this kind of request.
> > 
> > In slub, we try to allocate higher-order page more than it actually
> > needs in order to get the best performance. If this optimistic try is
> > used with GFP_ATOMIC, alloc_flags will be set as ALLOC_HARDER and
> > the pageblock reserved for high-order atomic allocation would be used.
> > Moreover, this request would reserve the MIGRATE_HIGHATOMIC pageblock
> > ,if succeed, to prepare further request. It would not be good to use
> > MIGRATE_HIGHATOMIC pageblock in terms of fragmentation management
> > since it unconditionally set a migratetype to request's migratetype
> > when unreserving the pageblock without considering the migratetype of
> > used pages in the pageblock.
> > 
> > This is not what we don't intend so fix it by unconditionally setting
> > __GFP_NOMEMALLOC in order to not set ALLOC_HARDER.
> 
> I wonder if it would be more robust to strip GFP_ATOMIC from alloc_gfp.
> E.g. __GFP_NOMEMALLOC does seem to prevent ALLOC_HARDER, but not
> ALLOC_HIGH. Or maybe we should adjust __GFP_NOMEMALLOC implementation
> and document it more thoroughly? CC Michal Hocko

Yeah, __GFP_NOMEMALLOC is rather inconsistent. It has been added to
override __GFP_MEMALLOC resp. PF_MEMALLOC AFAIK. In this particular
case I would agree that dropping __GFP_HIGH and __GFP_ATOMIC would
be more precise. I am not sure we want to touch the existing semantic of
__GFP_NOMEMALLOC though. This would require auditing all the existing
users (something tells me that quite some of those will be incorrect...)

> Also, were these 2 patches done via code inspection or you noticed
> suboptimal behavior which got fixed? Thanks.

The patch description is not very clear to me either but I guess that
Joonsoo sees to many larger order pages to back slab objects when the
system is not under heavy memory pressure and that increases internal
fragmentation?

> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/slub.c | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index e1e442c..fd8dd89 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1579,10 +1579,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> >  	 */
> >  	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
> >  	if (oo_order(oo) > oo_order(s->min)) {
> > -		if (alloc_gfp & __GFP_DIRECT_RECLAIM) {
> > -			alloc_gfp |= __GFP_NOMEMALLOC;
> > -			alloc_gfp &= ~__GFP_DIRECT_RECLAIM;
> > -		}
> > +		alloc_gfp |= __GFP_NOMEMALLOC;
> > +		alloc_gfp &= ~__GFP_DIRECT_RECLAIM;
> >  	}
> >  
> >  	page = alloc_slab_page(s, alloc_gfp, node, oo);
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
