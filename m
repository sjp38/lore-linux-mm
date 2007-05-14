Date: Mon, 14 May 2007 09:35:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/5] mm: slub allocation fairness
In-Reply-To: <1179159285.2942.20.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705140929200.10801@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>  <20070514133212.581041171@chello.nl>
  <Pine.LNX.4.64.0705140847330.10442@schroedinger.engr.sgi.com>
 <1179159285.2942.20.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Peter Zijlstra wrote:

> On Mon, 2007-05-14 at 08:49 -0700, Christoph Lameter wrote:
> > On Mon, 14 May 2007, Peter Zijlstra wrote:
> > 
> > > Index: linux-2.6-git/include/linux/slub_def.h
> > > ===================================================================
> > > --- linux-2.6-git.orig/include/linux/slub_def.h
> > > +++ linux-2.6-git/include/linux/slub_def.h
> > > @@ -52,6 +52,7 @@ struct kmem_cache {
> > >  	struct kmem_cache_node *node[MAX_NUMNODES];
> > >  #endif
> > >  	struct page *cpu_slab[NR_CPUS];
> > > +	int rank;
> > >  };
> > 
> > Ranks as part of the kmem_cache structure? I thought this is a temporary 
> > thing?
> 
> No it needs to store the current state to verity subsequent allocations
> their gfp flags against.

What state? This is a global state? The kmem_cache struct is rarely
written to after setting up the slab. Any writes could create a serious 
performance problem on large scale systems.

 
> > >   * Lock order:
> > > @@ -961,6 +962,8 @@ static struct page *allocate_slab(struct
> > >  	if (!page)
> > >  		return NULL;
> > >  
> > > +	s->rank = page->index;
> > > +
> > 
> > Argh.... Setting a cache structure field from a page struct field? What 
> > about concurrency?
> 
> Oh, right; allocate_slab is not serialized itself.

Nor should you ever write to the kmem_cache structure concurrently at all.

> > >  
> > > -	else {
> > > +	} else {
> > >  		object = page->lockless_freelist;
> > >  		page->lockless_freelist = object[page->offset];
> > >  	}
> > 
> > This is the hot path. No modifications please.
> 
> Yes it is, but sorry, I have to. I really need to validate each slab
> alloc its GFP flags. Thats what the whole thing is about, I thought you
> understood that.

You are accessing a kmem_cache structure field in the hot path. That 
cacheline is never used in the hot path. Sorry this is way to intrusive 
for the problem you are trying to solve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
