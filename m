Date: Fri, 21 Oct 2005 23:31:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
Message-Id: <20051021233111.58706a2e.akpm@osdl.org>
In-Reply-To: <20051022013001.GE27317@logos.cnet>
References: <20050930193754.GB16812@xeon.cnet>
	<Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com>
	<20051001215254.GA19736@xeon.cnet>
	<Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com>
	<43419686.60600@colorfullife.com>
	<20051003221743.GB29091@logos.cnet>
	<4342B623.3060007@colorfullife.com>
	<20051006160115.GA30677@logos.cnet>
	<20051022013001.GE27317@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: manfred@colorfullife.com, clameter@engr.sgi.com, linux-mm@kvack.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, arjanv@redhat.com
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> ...
> +unsigned long long slab_free_status(kmem_cache_t *cachep, struct slab *slabp)
> +{
> +	unsigned long long bitmap = 0;
> +	int i;
> +
> +	if (cachep->num > sizeof(unsigned long long)*8)
> +		BUG();
> +
> +	spin_lock_irq(&cachep->spinlock);
> +	for(i=0; i < cachep->num ; i++) {
> +		if (slab_bufctl(slabp)[i] == BUFCTL_INUSE)
> +			set_bit(i, (unsigned long *)&bitmap);
> +	}
> +	spin_unlock_irq(&cachep->spinlock);
> +
> +	return bitmap;
> +}

What if there are more than 64 objects per page?

> +        if (!ops)
> +                BUG();
> +	if (!PageSlab(page))
> +		BUG();
> +	if (slabp->s_mem != (page_address(page) + slabp->colouroff))
> +		BUG();
> +
> +        if (PageLocked(page))
> +                return 0;

There's quite a lot of whitespace breakage btw.


It all seems rather complex.

What about simply compacting the cache by copying freeable dentries? 
Something like, in prune_one_dentry():

	if (dcache occupancy < 90%) {
		new_dentry = alloc_dentry()
		*new_dentry = *dentry;
		<fix stuff up>
		free(dentry);
	} else {
		free(dentry)
	}

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
