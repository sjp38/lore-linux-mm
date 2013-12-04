Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1605F6B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 10:17:10 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x13so2265614qcv.15
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 07:17:09 -0800 (PST)
Received: from b232-35.smtp-out.amazonses.com (b232-35.smtp-out.amazonses.com. [199.127.232.35])
        by mx.google.com with ESMTP id j1si52061480qer.1.2013.12.04.07.17.08
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 07:17:09 -0800 (PST)
Date: Wed, 4 Dec 2013 15:17:08 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the
 allocator
In-Reply-To: <20131203180717.94c013d1.akpm@linux-foundation.org>
Message-ID: <00000142be2f1de0-764bb035-adbc-4367-b2b4-bf05498510a6-000000@email.amazonses.com>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org> <1381265890-11333-2-git-send-email-hannes@cmpxchg.org> <20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org> <20131204015218.GA19709@lge.com>
 <20131203180717.94c013d1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Christian Casteyde <casteyde.christian@free.fr>, Pekka Enberg <penberg@kernel.org>

On Tue, 3 Dec 2013, Andrew Morton wrote:

> >  	page = alloc_slab_page(alloc_gfp, node, oo);
> >  	if (unlikely(!page)) {
> >  		oo = s->min;
>
> What is the value of s->min?  Please tell me it's zero.

It usually is.

> > @@ -1349,7 +1350,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> >  		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
> >  		int pages = 1 << oo_order(oo);
> >
> > -		kmemcheck_alloc_shadow(page, oo_order(oo), flags, node);
> > +		kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);
>
> That seems reasonable, assuming kmemcheck can handle the allocation
> failure.
>
>
> Still I dislike this practice of using unnecessarily large allocations.
> What does it gain us?  Slightly improved object packing density.
> Anything else?

The fastpath for slub works only within the bounds of a single slab page.
Therefore a larger frame increases the number of allocation possible from
the fastpath without having to use the slowpath and also reduces the
management overhead in the partial lists.

There is a kernel parameter that can be used to control the maximum order

	slub_max_order

The default is PAGE_ALLOC_COSTLY_ORDER. See also
Documentation/vm/slub.txt.

Booting with slub_max_order=1 will force order 0/1 pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
