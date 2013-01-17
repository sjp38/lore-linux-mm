Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2C6396B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:43:19 -0500 (EST)
Message-ID: <1358458996.23211.46.camel@gandalf.local.home>
Subject: Re: [RFC][PATCH] slub: Check for page NULL before doing the
 node_match check
From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 17 Jan 2013 16:43:16 -0500
In-Reply-To: <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
References: <1358446258.23211.32.camel@gandalf.local.home>
	 <1358447864.23211.34.camel@gandalf.local.home>
	 <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R.
 Goncalves" <lgoncalv@redhat.com>

On Thu, 2013-01-17 at 21:28 +0000, Christoph Lameter wrote:
> On Thu, 17 Jan 2013, Steven Rostedt wrote:
> 
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -2399,7 +2399,7 @@ redo:
> > >
> > >  	object = c->freelist;
> > >  	page = c->page;

We should add a BUG_ON(!page) if it's a problem. I wasted a bit of time
finding this bug just because it triggered in a static inline function,
and I didn't have the vmlinuz file to play with. I had to ask someone
else to do the work for me.


> > > -	if (unlikely(!object || !node_match(page, node)))
> > > +	if (unlikely(!object || !page || !node_match(page, node)))
> >
> > I'm still trying to see if c->freelist != NULL and c->page == NULL isn't
> > a bug. The cmpxchg_doubles are a little confusing. If it's not expected
> > that page is NULL but freelist isn't than we need to figure out why it
> > happened.
> 
> hmmm.. We may want to change the sequence of updates to c->page and
> c->freelist. Update c->freelist to be NULL first so that we always enter
> the slow path for these cases where we can do more expensive
> synchronization.
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2013-01-15 10:42:08.490183607 -0600
> +++ linux/mm/slub.c	2013-01-17 15:27:48.973051155 -0600
> @@ -1993,8 +1993,8 @@ static inline void flush_slab(struct kme
>  	deactivate_slab(s, c->page, c->freelist);
> 
>  	c->tid = next_tid(c->tid);
> -	c->page = NULL;
>  	c->freelist = NULL;
> +	c->page = NULL;

I'm assuming that this is to deal with the same CPU being able to touch
the code?

If so, it requires "barrier()". If this can affect other CPUs, then we
need a smp_wmb() here, and smp_rmb() where it matters.

-- Steve

>  }
> 
>  /*
> @@ -2227,8 +2227,8 @@ redo:
>  	if (unlikely(!node_match(page, node))) {
>  		stat(s, ALLOC_NODE_MISMATCH);
>  		deactivate_slab(s, page, c->freelist);
> -		c->page = NULL;
>  		c->freelist = NULL;
> +		c->page = NULL;
>  		goto new_slab;
>  	}
> 
> @@ -2239,8 +2239,8 @@ redo:
>  	 */
>  	if (unlikely(!pfmemalloc_match(page, gfpflags))) {
>  		deactivate_slab(s, page, c->freelist);
> -		c->page = NULL;
>  		c->freelist = NULL;
> +		c->page = NULL;
>  		goto new_slab;
>  	}
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
