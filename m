Date: Thu, 28 Jun 2007 18:12:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
Message-Id: <20070628181238.372828fa.akpm@linux-foundation.org>
In-Reply-To: <46845620.6020906@redhat.com>
References: <8e38f7656968417dfee0.1181332979@v2.random>
	<466C36AE.3000101@redhat.com>
	<20070610181700.GC7443@v2.random>
	<46814829.8090808@redhat.com>
	<20070626105541.cd82c940.akpm@linux-foundation.org>
	<468439E8.4040606@redhat.com>
	<20070628155715.49d051c9.akpm@linux-foundation.org>
	<46843E65.3020008@redhat.com>
	<20070628161350.5ce20202.akpm@linux-foundation.org>
	<4684415D.1060700@redhat.com>
	<20070628162936.9e78168d.akpm@linux-foundation.org>
	<46844B83.20901@redhat.com>
	<20070628171922.2c1bd91f.akpm@linux-foundation.org>
	<46845620.6020906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007 20:45:20 -0400
Rik van Riel <riel@redhat.com> wrote:

> >> The only problem with this is that anonymous
> >> pages could be easily pushed out of memory by
> >> the page cache, because the page cache has
> >> totally different locality of reference.
> > 
> > I don't immediately see why we need to change the fundamental aging design
> > at all.   The problems afacit are
> > 
> > a) that huge burst of activity when we hit pages_high and
> > 
> > b) the fact that this huge burst happens on lots of CPUs at the same time.
> > 
> > And balancing the LRUs _prior_ to hitting pages_high can address both
> > problems?
> 
> That may work on systems with up to a few GB of memory,
> but customers are already rolling out systems with 256GB
> of RAM for general purpose use, that's 64 million pages!
> 
> Even doing a background scan on that many pages will take
> insane amounts of CPU time.
> 
> In a few years, they will be deploying systems with 1TB
> of memory and throwing random workloads at them.

I don't see how the amount of memory changes anything here: if there are
more pages, more work needs to be done regardless of when we do it.

Still confused.

> >>>> No matter how efficient we make the scanning of one
> >>>> individual page, we simply cannot scan through 1TB
> >>>> worth of anonymous pages (which are all referenced
> >>>> because they've been there for a week) in order to
> >>>> deactivate something.
> >>> Sure.  And we could avoid that sudden transition by balancing the LRU prior
> >>> to hitting the great pages_high wall.
> >> Yes, we will need to do some preactive balancing.
> > 
> > OK..
> > 
> > And that huge anon-vma walk might need attention.  At the least we could do
> > something to prevent lots of CPUs from piling up in there.
> 
> Speaking of which, I have also seen a thousand processes waiting
> to grab the iprune_mutex in prune_icache.
> 

It would make sense to only permit one cpu at a time to go in and do
reclaimation against a particular zone (or even node).

But the problem with the vfs caches is that they aren't node/zone-specific.
We wouldn't want to get into the situation where 1023 CPUs are twiddling
thumbs waiting for one CPU to free stuff up (or less extreme variants of
this).

> Maybe direct reclaim processes should not dive into this cache
> at all, but simply increase some variable indicating that kswapd
> might want to prune some extra pages from this cache on its next
> run?

Tell the node's kswapd to go off and do VFS reclaim while the CPUs on that
node wait for it?  That would help I guess, but those thousand processes
would still need to block _somewhere_ waiting for the memory to come back.

Of course, iprune_mutex is a particularly dumb place in which to do that,
because the memory may get freed up from somewhere else.

The general design here could/should be to back off to the top-level when
there's contention (that's presently congestion_wait()) and to poll for
memory-became-allocatable.

So what we could do here is to back off when iprune_mutex is busy and, if
nothing else works out, block in congestion_wait() (which is becoming
increasingly misnamed).  Then, add some more smarts to congestion_wait():
deliver a wakeup when "enough" memory got freed from the VFS caches.

One suspects that at some stage, congestion_wait() will need to be told
what the calling task is actually waiting for (perhaps a zonelist) so that
the wakup delivery can become smarter.  


But for now, the question is: is this a reasonable overall design?  Back
off from contention points, block at the top-level, polling for allocatable
memory to turn up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
