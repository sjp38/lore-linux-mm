Received: from edge04.upc.biz ([192.168.13.239]) by viefep18-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080728103906.VRCA20560.viefep18-int.chello.at@edge04.upc.biz>
          for <linux-mm@kvack.org>; Mon, 28 Jul 2008 12:39:06 +0200
Subject: Re: [PATCH 12/30] mm: memory reserve management
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1217240994.7813.53.camel@penberg-laptop>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <1217239564.7813.36.camel@penberg-laptop>  <1217240224.6331.32.camel@twins>
	 <1217240994.7813.53.camel@penberg-laptop>
Content-Type: text/plain
Date: Mon, 28 Jul 2008 12:39:01 +0200
Message-Id: <1217241541.6331.42.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Neil Brown <neilb@suse.de>, mpm@selenic.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-28 at 13:29 +0300, Pekka Enberg wrote:

> > > > +	}
> > > > +
> > > > +	obj = __kmalloc_node_track_caller(size, flags, node, ip);
> > > > +	WARN_ON(!obj);
> > > 
> > > Why don't we discharge from the reserve here if !obj?
> > 
> > Well, this allocation should never fail:
> >   - we reserved memory
> >   - we accounted/throttle its usage
> > 
> > Thus this allocation should always succeed.
> 
> But if it *does* fail, it doesn't help that we mess up the reservation
> counts, no?

I guess you're right there. Will fix. Thanks!

> > > > +{
> > > > +	size_t size = ksize(obj);
> > > > +
> > > > +	kfree(obj);
> > > 
> > > We're trying to get rid of kfree() so I'd __kfree_reserve() could to
> > > mm/sl?b.c. Matt, thoughts?
> > 
> > My issue with moving these helpers into mm/sl?b.c is that it would
> > require replicating all this code 3 times. Even though the functionality
> > is (or should) be invariant to the actual slab implementation.
> 
> Right, I guess we could just rename ksize() to something else then and
> keep it internal to mm/.

That would be nice - we can stuff it into mm/internal.h or somesuch.

Also, you might have noticed, I still need to do everything SLOB. The
last time I rewrote all this code I was still hoping Linux would 'soon'
have a single slab allocator, but evidently we're still going with 3 for
now.. :-/

So I guess I can no longer hide behind that and will have to bite the
bullet and write the SLOB bits..

> > > > +	/*
> > > > +	 * ksize gives the full allocated size vs the requested size we used to
> > > > +	 * charge; however since we round up to the nearest power of two, this
> > > > +	 * should all work nicely.
> > > > +	 */
> > > > +	mem_reserve_kmalloc_charge(res, -size);
> > > > +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
