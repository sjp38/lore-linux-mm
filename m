Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id E6A5C6B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 17:41:19 -0400 (EDT)
Received: by iecuq6 with SMTP id uq6so143623798iec.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 14:41:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b5si17964953igl.12.2015.07.07.14.41.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 14:41:19 -0700 (PDT)
Date: Tue, 7 Jul 2015 14:41:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
Message-Id: <20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
In-Reply-To: <alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <msnitzer@redhat.com>, "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, David Rientjes <rientjes@google.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 7 Jul 2015 11:10:09 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:

> Introduce the functions kvmalloc and kvmalloc_node. These functions
> provide reliable allocation of object of arbitrary size. They attempt to
> do allocation with kmalloc and if it fails, use vmalloc. Memory allocated
> with these functions should be freed with kvfree.

Sigh.  We've resisted doing this because vmalloc() is somewhat of a bad
thing, and we don't want to make it easy for people to do bad things.

And vmalloc is bad because a) it's slow and b) it does GFP_KERNEL
allocations for page tables and c) it is susceptible to arena
fragmentation.

We'd prefer that people fix their junk so it doesn't depend upon large
contiguous allocations.  This isn't userspace - kernel space is hostile
and kernel code should be robust.

So I dunno.  Should we continue to make it a bit more awkward to use
vmalloc()?  Probably that tactic isn't being very successful - people
will just go ahead and open-code it.  And given the surprising amount
of stuff you've placed in kvmalloc_node(), they'll implement it
incorrectly...

How about we compromise: add kvmalloc_node(), but include a BUG_ON("you
suck") to it?

>
> ...
>
> +void *kvmalloc_node(size_t size, gfp_t gfp, int node)
> +{
> +	void *p;
> +	unsigned uninitialized_var(noio_flag);
> +
> +	/* vmalloc doesn't support no-wait allocations */
> +	WARN_ON(!(gfp & __GFP_WAIT));

It could be a WARN_ON_ONCE, but that doesn't seem very important.

> +	if (likely(size <= KMALLOC_MAX_SIZE)) {
> +		p = kmalloc_node(size, gfp | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN, node);

There is no way in which a reader will be able to work out the reason
for this selection of flags.  Heck, this reviewer can't work it out
either.

Can we please have a code comment in there which reveals all this?

Also, it would be nice to find a tasteful way of squeezing this into 80
cols.

> +		if (likely(p != NULL))
> +			return p;
> +	}
> +	if ((gfp & (__GFP_IO | __GFP_FS)) != (__GFP_IO | __GFP_FS)) {
> +		/*
> +		 * vmalloc allocates page tables with GFP_KERNEL, regardless
> +		 * of GFP flags passed to it. If we are no GFP_NOIO context,
> +		 * we call memalloc_noio_save, so that all allocations are
> +		 * implicitly done with GFP_NOIO.

OK.  But why do we turn on __GFP_HIGH?

> +		 */
> +		noio_flag = memalloc_noio_save();
> +		gfp |= __GFP_HIGH;
> +	}
> +	p = __vmalloc_node_flags(size, node, gfp | __GFP_REPEAT | __GFP_HIGHMEM);

Again, please document the __GFP_REPEAT reasoning.

__vmalloc_node_flags() handles __GFP_ZERO, I believe?  So we presently
don't have a kvzalloc() - callers are to open-code the __GFP_ZERO.

I suppose we may as well go ahead and add the 4-line wrapper for
kvzalloc().

> +	if ((gfp & (__GFP_IO | __GFP_FS)) != (__GFP_IO | __GFP_FS)) {
> +		memalloc_noio_restore(noio_flag);
> +	}

scripts/checkpatch.pl is your friend!

> +	return p;
> +}
> +EXPORT_SYMBOL(kvmalloc_node);
> +
> +void *kvmalloc(size_t size, gfp_t gfp)
> +{
> +	return kvmalloc_node(size, gfp, NUMA_NO_NODE);
> +}
> +EXPORT_SYMBOL(kvmalloc);

It's probably better to switch this to a static inline.  That's a bit
faster and will save a bit of stack on a stack-heavy code path.  Unless
gcc manages to do a tailcall, but it doesn't seem to do that much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
