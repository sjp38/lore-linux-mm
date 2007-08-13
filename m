Date: Mon, 13 Aug 2007 15:28:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality,
 performance and maintenance
In-Reply-To: <20070813221847.GA20314@Krystal>
Message-ID: <Pine.LNX.4.64.0708131523020.28626@schroedinger.engr.sgi.com>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de>
 <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com>
 <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com>
 <4692A1D0.50308@mbligh.org> <20070709214426.GC1026@Krystal>
 <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com>
 <20070709225817.GA5111@Krystal> <Pine.LNX.4.64.0707091715450.2062@schroedinger.engr.sgi.com>
 <20070813221847.GA20314@Krystal>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Aug 2007, Mathieu Desnoyers wrote:

> > @@ -1554,23 +1564,20 @@ static void __always_inline *slab_alloc(
> >  		gfp_t gfpflags, int node, void *addr)
> >  {
> >  	void **object;
> > -	unsigned long flags;
> >  	struct kmem_cache_cpu *c;
> >  
> 
> What if we prefetch c->freelist here ? I see in this diff that the other
> code just reads it sooner as a condition for the if().

Not sure as to what this may bring. If you read it earlier then you may 
get the wrong value and then may have to refetch the cacheline.

We cannot fetch c->freelist without determining c. I can remove the 
check for c->page == page so that the fetch of c->freelist comes 
immeidately after detemination of c. But that does not change performance.

> > -		c->freelist = object;
> > -	} else
> > -		__slab_free(s, page, x, addr, c->offset);
> > +redo:
> > +	freelist = c->freelist;
> 
> I suspect this smp_rmb() may be the cause of a major slowdown.
> Therefore, I think we should try taking a copy of c->page and simply
> check if it has changed right after the cmpxchg_local:

Thought so too and I removed that smp_rmb and tested this modification 
on UP again without any performance gains. I think the cacheline fetches 
dominates the execution thread here and cmpxchg does not bring us 
anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
