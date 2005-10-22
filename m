Date: Sat, 22 Oct 2005 11:21:13 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
Message-ID: <20051022092113.GA25265@devserv.devel.redhat.com>
References: <20050930193754.GB16812@xeon.cnet> <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com> <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com> <43419686.60600@colorfullife.com> <20051003221743.GB29091@logos.cnet> <4342B623.3060007@colorfullife.com> <20051006160115.GA30677@logos.cnet> <20051022013001.GE27317@logos.cnet> <20051021233111.58706a2e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051021233111.58706a2e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, manfred@colorfullife.com, clameter@engr.sgi.com, linux-mm@kvack.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

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

the bitops usually work on bigger than wordsize things though..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
