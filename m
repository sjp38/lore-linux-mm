Date: Sun, 23 Oct 2005 14:30:11 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
Message-ID: <20051023163011.GA7088@logos.cnet>
References: <20050930193754.GB16812@xeon.cnet> <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com> <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com> <43419686.60600@colorfullife.com> <20051003221743.GB29091@logos.cnet> <4342B623.3060007@colorfullife.com> <20051006160115.GA30677@logos.cnet> <20051022013001.GE27317@logos.cnet> <20051021233111.58706a2e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051021233111.58706a2e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: manfred@colorfullife.com, clameter@engr.sgi.com, linux-mm@kvack.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, arjanv@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Andrew!

On Fri, Oct 21, 2005 at 11:31:11PM -0700, Andrew Morton wrote:
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> >
> > ...
> > +unsigned long long slab_free_status(kmem_cache_t *cachep, struct slab *slabp)
> > +{
> > +	unsigned long long bitmap = 0;
> > +	int i;
> > +
> > +	if (cachep->num > sizeof(unsigned long long)*8)
> > +		BUG();
> > +
> > +	spin_lock_irq(&cachep->spinlock);
> > +	for(i=0; i < cachep->num ; i++) {
> > +		if (slab_bufctl(slabp)[i] == BUFCTL_INUSE)
> > +			set_bit(i, (unsigned long *)&bitmap);
> > +	}
> > +	spin_unlock_irq(&cachep->spinlock);
> > +
> > +	return bitmap;
> > +}
> 
> What if there are more than 64 objects per page?

I don't think there are reclaimable caches with more than 64 objects per page
at the moment, but if that happens to be the case we just need to use an 
appropriately larger bitmap as Arjan mentioned.

> > +        if (!ops)
> > +                BUG();
> > +	if (!PageSlab(page))
> > +		BUG();
> > +	if (slabp->s_mem != (page_address(page) + slabp->colouroff))
> > +		BUG();
> > +
> > +        if (PageLocked(page))
> > +                return 0;
> 
> There's quite a lot of whitespace breakage btw.

Sorry about that! Silly.

> It all seems rather complex.

Hiding the locking behind an API does not sound very pleasant to me, but
other than that it seems quite straightforward...

What worries you?

> What about simply compacting the cache by copying freeable dentries? 
> Something like, in prune_one_dentry():
> 
> 	if (dcache occupancy < 90%) {
> 		new_dentry = alloc_dentry()
> 		*new_dentry = *dentry;
> 		<fix stuff up>
> 		free(dentry);
> 	} else {
> 		free(dentry)
> 	}
> 
> ?

Compacting the dcache sounds like a good thing to be done to help
reducing fragmentation (and simpler), but it is complementary to the
aggregate freeing of pages proposed.

The major issue I believe this patch tries to attack is that of unused
list ordering. Sequential objects in the unused list are not necessarily
ordered by their page container (actually, it is easy to come up with
several reasons for them _not_ to be optimally ordered for reclaim, eg.
multi-user/multi-task workloads).

Under such scenarios in which the unused list ordering is not close to
"page container order", the VM might have to reclaim larger amounts of
dentries "dumbfully" in the hope to make progress by freeing full pages.
It completly lacks the knowledge that to make progress full pages
are required.

Recently David Chinner reported a case on a very large mem box in which
demonstrates the issue very clearly:

http://marc.theaimsgroup.com/?l=linux-mm&m=112674700612691&w=2

While compacting the cache as you suggest would certainly help his
specific, the most effective measure seems to be free full pages
immediately.

I will proceed with some testing this week, suggestions are welcome.    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
