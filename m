Date: Fri, 31 Mar 2006 15:46:08 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
Message-Id: <20060331154608.00a36954.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
	<20060331150120.21fad488.akpm@osdl.org>
	<Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Fri, 31 Mar 2006, Andrew Morton wrote:
> 
> > Christoph Lameter <clameter@sgi.com> wrote:
> > >
> > > We experienced that concurrent slab shrinking on 2.6.16 can slow down a
> > >  system excessively due to lock contention.
> > 
> > How much?
> 
> System sluggish in general. cscope takes 20 minutes to start etc. Dropping 
> the caches restored performance.

OK.  What sort of system was it, and what was the workload?  FIlesystem types?

What sort of overhead was it?  sleeping-in-D-state? 
pingponging-cachelines-around?

It's been like that for an awful long time.  Can you think why this has
only just now been noticed?

> > Which lock(s)?
> 
> Seems to be mainly iprune_sem. So its inode reclaim.

But why on earth would iprune_mutex make such a difference?  The kernel can
throw away inodes at a great old rate, and it takes quite some time to
restore them.

I fear that something new is happening, and that prune_icache() is now
doing lots of work without achieving anything.  

We have fiddled with various things in fs/inode.c which could affect this
over the past year.  I wonder if one of those changes has caused the inode
scan to now scan lots of unreclaimable inodes.

> > > Slab shrinking is a global
> > >  operation so it does not make sense for multiple slab shrink operations
> > >  to be ongoing at the same time.
> > 
> > That's how it used to be - it was a semaphore and we baled out if
> > down_trylock() failed.  If we're going to revert that change then I'd
> > prefer to just go back to doing it that way (only with a mutex).
> 
> No problem with that. Seems that the behavior <2.6.9 was okay. This showed 
> up during beta testing of a new major distribution release.

OK.

> > The reason we made that change in 2.6.9:
> > 
> >   Use an rwsem to protect the shrinker list instead of a regular
> >   semaphore.  Modifications to the list are now done under the write lock,
> >   shrink_slab takes the read lock, and access to shrinker->nr becomes racy
> >   (which is no concurrent.
> > 
> >   Previously, having the slab scanner get preempted or scheduling while
> >   holding the semaphore would cause other tasks to skip putting pressure on
> >   the slab.
> > 
> >   Also, make shrink_icache_memory return -1 if it can't do anything in
> >   order to hold pressure on this cache and prevent useless looping in
> >   shrink_slab.
> 
> Shrink_icache_memory() never returns -1.

                if (!(gfp_mask & __GFP_FS))
                        return -1;

> > Note the lack of performance numbers?  How are we to judge which the
> > regression which your proposal introduces is outweighed by the (unmeasured)
> > gain it provides?
> 
> We just noticed general sluggishness and took some stackdumps to see what 
> the system was up to.

OK.  But was it D-state sleep (semaphore lock contention) or what?

> Do we have a benchmark for slab shrinking?

Nope.  In general reclaim shouldn't be a performance problem because the
things which we reclaim take so much work to reestablish.  It only causes
problems when we're repeatedly scanning lots of things which aren't
actually reclaimable.   Hence my suspicions are aroused...

> > We need a *lot* of testing results with varied workloads and varying
> > machine types before we can say that changes like this are of aggregate
> > benefit and do not introduce bad corner-case regressions.
> 
> The slowdown of the system running concurrent slab reclaim is pretty 
> severe. Machine is basically unusable until you manually trigger the 
> dropping of the caches.

bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
