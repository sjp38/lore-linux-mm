Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 302BD6B0035
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 01:27:12 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so1706436pdj.34
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 22:27:11 -0700 (PDT)
Date: Thu, 17 Oct 2013 14:27:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 01/15] slab: correct pfmemalloc check
Message-ID: <20131017052730.GA26617@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1381913052-23875-2-git-send-email-iamjoonsoo.kim@lge.com>
 <00000141c1e16001-26ccfd98-51ee-4ca6-8ddf-61abd491dea8-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000141c1e16001-26ccfd98-51ee-4ca6-8ddf-61abd491dea8-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>

On Wed, Oct 16, 2013 at 03:27:54PM +0000, Christoph Lameter wrote:
> On Wed, 16 Oct 2013, Joonsoo Kim wrote:
> 
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -930,7 +930,8 @@ static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
> >  {
> >  	if (unlikely(pfmemalloc_active)) {
> >  		/* Some pfmemalloc slabs exist, check if this is one */
> > -		struct page *page = virt_to_head_page(objp);
> > +		struct slab *slabp = virt_to_slab(objp);
> > +		struct page *page = virt_to_head_page(slabp->s_mem);
> >  		if (PageSlabPfmemalloc(page))
> 
> I hope the compiler optimizes this code correctly because virt_to_slab
> already does one virt_to_head_page()?

It should not.
objp could be in a different page with slabp->s_mem's,
so virt_to_head_page() should be called twice.

Anyway, after implementing struct slab overloading, one call site is
removed by [14/15] in this patchset, so there is no issue.

Thanks.

> 
> Otherwise this looks fine.
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
