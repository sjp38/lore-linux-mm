Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 33A856B0038
	for <linux-mm@kvack.org>; Mon, 19 May 2014 12:03:22 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id j107so9004364qga.6
        for <linux-mm@kvack.org>; Mon, 19 May 2014 09:03:22 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id s10si8890718qak.221.2014.05.19.09.03.21
        for <linux-mm@kvack.org>;
        Mon, 19 May 2014 09:03:21 -0700 (PDT)
Date: Mon, 19 May 2014 11:03:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <20140519152437.GB25889@esperanza>
Message-ID: <alpine.DEB.2.10.1405191056580.22956@gentwo.org>
References: <cover.1399982635.git.vdavydov@parallels.com> <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405141119320.16512@gentwo.org> <20140515071650.GB32113@esperanza> <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza> <alpine.DEB.2.10.1405160957100.32249@gentwo.org> <20140519152437.GB25889@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 19 May 2014, Vladimir Davydov wrote:

> > I doubt that. The accounting occurs when a new cpu slab page is allocated.
> > But the individual allocations in the fastpath are not accounted to a
> > specific group. Thus allocation in a slab page can belong to various
> > cgroups.
>
> On each kmalloc, we pick the cache that belongs to the current memcg,
> and allocate objects from that cache (see memcg_kmem_get_cache()). And
> all slab pages allocated for a per memcg cache are accounted to the
> memcg the cache belongs to (see memcg_charge_slab). So currently, each
> kmem cache, i.e. each slab of it, can only have objects of one cgroup,
> namely its owner.

Ok that works for kmalloc. What about dentry/inodes and so on?

> OK, it seems we have no choice but keeping dead caches left after memcg
> offline until they have active slabs. How can we get rid of them then?

Then they are moved to a list and therefore you can move them to yours I
think.

> Simply counting slabs on cache and destroying cache when the count goes
> to 0 isn't enough, because slub may keep some free slabs by default (if
> they are frozen e.g.) Reaping them periodically doesn't look nice.

But those are only limited to one slab per cpu ( plus eventual cpu partial
ones but you can switch that feature off).

> What if we modify __slab_free so that it won't keep empty slabs for dead
> caches? That way we would only have to count slabs allocated to a cache,
> and destroy caches as soon as the counter drops to 0. No

Well that should already be in there. Se s->min_partial to zero?

> periodic/vmpressure reaping would be necessary. I attached the patch
> that does the trick below. The changes it introduces to __slab_free do
> not look very intrusive to me. Could you please take a look at it (to
> diff slub.c primarily) when you have time, and say if, in your opinion,
> the changes to __slab_free are acceptable or not?

Looking now.

> @@ -2620,14 +2651,16 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>                  return;
>          }
>
> -	if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
> +	if (unlikely(!new.inuse &&
> +		     (n->nr_partial > s->min_partial || cache_dead)))
>  		goto slab_empty;

Could you set s->min_partial = 0 to avoid this?

>
>  	/*
>  	 * Objects left in the slab. If it was not on the partial list before
>  	 * then add it.
>  	 */
> -	if (!kmem_cache_has_cpu_partial(s) && unlikely(!prior)) {
> +	if ((!kmem_cache_has_cpu_partial(s) || cache_dead) &&
> +	    unlikely(!prior)) {
>  		if (kmem_cache_debug(s))
>  			remove_full(s, n, page);
>  		add_partial(n, page, DEACTIVATE_TO_TAIL);

Not sure why we need this and the other stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
