Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4EF6B0261
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 20:20:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e6so57906017pfk.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:20:12 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id wf9si9700766pab.40.2016.10.12.17.20.10
        for <linux-mm@kvack.org>;
        Wed, 12 Oct 2016 17:20:11 -0700 (PDT)
Date: Thu, 13 Oct 2016 11:20:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2] z3fold: add shrinker
Message-ID: <20161013002006.GN23194@dastard>
References: <20161012001827.53ae55723e67d1dee2a2f839@gmail.com>
 <20161011225206.GJ23194@dastard>
 <20161012102634.f32cb17648eff6b2fd452aea@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161012102634.f32cb17648eff6b2fd452aea@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 12, 2016 at 10:26:34AM +0200, Vitaly Wool wrote:
> On Wed, 12 Oct 2016 09:52:06 +1100
> Dave Chinner <david@fromorbit.com> wrote:
> 
> <snip>
> > 
> > > +static unsigned long z3fold_shrink_scan(struct shrinker *shrink,
> > > +				struct shrink_control *sc)
> > > +{
> > > +	struct z3fold_pool *pool = container_of(shrink, struct z3fold_pool,
> > > +						shrinker);
> > > +	struct z3fold_header *zhdr;
> > > +	int i, nr_to_scan = sc->nr_to_scan;
> > > +
> > > +	spin_lock(&pool->lock);
> > 
> > Do not do this. Shrinkers should not run entirely under a spin lock
> > like this - it causes scheduling latency problems and when the
> > shrinker is run concurrently on different CPUs it will simply burn
> > CPU doing no useful work. Especially, in this case, as each call to
> > z3fold_compact_page() may be copying a significant amount of data
> > around and so there is potentially a /lot/ of work being done on
> > each call to the shrinker.
> > 
> > If you need compaction exclusion for the shrinker invocation, then
> > please use a sleeping lock to protect the compaction work.
> 
> Well, as far as I recall, spin_lock() will resolve to a sleeping lock
> for PREEMPT_RT,

Irrelevant for mainline kernels....

> so it is not that much of a problem for configurations
> which do care much about latencies.

That's an incorrect assumption. Long spinlock holds prevent
scheduling on that CPU, and so we still get latency problems.

> Please also note that the time
> spent in the loop is deterministic since we take not more than one entry
> from every unbuddied list.

So the loop is:

	for_each_unbuddied_list_down(i, NCHUNKS - 3) {

NCHUNKS = (PAGE_SIZE - (1 << (PAGE_SHIFT - 6)) >> (PAGE_SHIFT - 6)

So for 4k page, NCHUNKS = (4096 - (1<<6)) >> 6, which is 63. So,
potentially 60 memmoves under a single spinlock on a 4k page
machine. That's a lot of work, especially as some of those memmoves
are going to move a large amount of data in the page.

And if we consider 64k pages, we've now got NCHUNKS = 1023, which
means your shrinker is not, by default, going to scan all your
unbuddied lists because it will expire nr_to_scan (usually
SHRINK_BATCH = 128) before it's got through all of them. So not only
will the shrinker do too much under a spinlock, it won't even do
what you want it to do correctly on such setups.

Further, the way nr_to_scan is decremented and the shrinker return
value are incorrect. nr_to_scan is not the /number of objects to
free/, but the number of objects to /check for reclaim/. The
shrinker is then supposed to return the number it frees (or
compacts) to give feedback to the shrinker infrastructure about how
much reclaim work is being done (i.e. scanned vs freed ratio). This
code always returns 0, which tells the shrinker infrastructure that
it's not making progress...

> What I could do though is add the following piece of code at the end of
> the loop, right after the /break/:
> 		spin_unlock(&pool->lock);
> 		cond_resched();
> 		spin_lock(&pool->lock);
> 
> Would that make sense for you?

Not really, because it ignores the fact that shrinkers can (and
often do) run concurrently on multiple CPUs, and so serialising them
all on a spinlock just causes contention, even if you do this.

Memory reclaim is only as good as the worst shrinker it runs. I
don't care what your subsystem does, but if you're implementing a
shrinker then it needs to play by memory reclaim and shrinker
context rules.....

> > >  *****************/
> > > @@ -234,6 +335,13 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
> > >  		INIT_LIST_HEAD(&pool->unbuddied[i]);
> > >  	INIT_LIST_HEAD(&pool->buddied);
> > >  	INIT_LIST_HEAD(&pool->lru);
> > > +	pool->shrinker.count_objects = z3fold_shrink_count;
> > > +	pool->shrinker.scan_objects = z3fold_shrink_scan;
> > > +	pool->shrinker.seeks = DEFAULT_SEEKS;
> > > +	if (register_shrinker(&pool->shrinker)) {
> > > +		pr_warn("z3fold: could not register shrinker\n");
> > > +		pool->no_shrinker = true;
> > > +	} 
> > 
> > Just fail creation of the pool. If you can't register a shrinker,
> > then much bigger problems are about to happen to your system, and
> > running a new memory consumer that /can't be shrunk/ is not going to
> > help anyone.
> 
> I don't have a strong opinion on this but it doesn't look fatal to me
> in _this_ particular case (z3fold) since even without the shrinker, the
> compression ratio will never be lower than the one of zbud, which
> doesn't have a shrinker at all.

Either your subsystem needs a shrinker or it doesn't. If it needs
one, then it should follow the accepted norm of failing
initialisation because a shrinker register failure is indicative of
a serious memory allocation problem already occurring in the
machine. We can only make it worse by continuing without a
shrinker....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
