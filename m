Date: Sat, 22 Oct 2005 10:08:52 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
In-Reply-To: <20051021233111.58706a2e.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0510221002020.27511@schroedinger.engr.sgi.com>
References: <20050930193754.GB16812@xeon.cnet>
 <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com>
 <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com>
 <43419686.60600@colorfullife.com> <20051003221743.GB29091@logos.cnet>
 <4342B623.3060007@colorfullife.com> <20051006160115.GA30677@logos.cnet>
 <20051022013001.GE27317@logos.cnet> <20051021233111.58706a2e.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, manfred@colorfullife.com, linux-mm@kvack.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, arjanv@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 21 Oct 2005, Andrew Morton wrote:

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

The current worst case is 16k pagesize (IA64) and one cacheline sized 
objects (128 bytes) (hmm.. could even be smaller if the arch does 
overrride SLAB_HWCACHE_ALIGN) yielding a maximum of 128 entries per page. 

There are been versions of Linux for IA64 out there with 64k pagesize on 
IA64 and there is the possibility that we need to switch to 64k as a 
standard next year when we may have single OS images running with more 
than 16TB Ram.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
