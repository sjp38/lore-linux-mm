Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.39 kmem_cache bug
Date: Sun, 29 Sep 2002 20:20:40 -0400
References: <20020928201308.GA59189@compsoc.man.ac.uk> <200209291137.48483.tomlins@cam.org> <3D972828.6010807@colorfullife.com>
In-Reply-To: <3D972828.6010807@colorfullife.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209292020.40824.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 29, 2002 12:19 pm, Manfred Spraul wrote:
> Ed Tomlinson wrote:
> > On September 29, 2002 09:52 am, Manfred Spraul wrote:
> >>Ed Tomlinson wrote:
> >>>-	if (__kmem_cache_shrink(cachep)) {
> >>>+	/* remove any empty partial pages */
> >>>+	spin_lock_irq(&cachep->spinlock);
> >>>+	while (!cachep->growing) {
> >>>+		struct list_head *p;
> >>>+		slab_t *slabp;
> >>>+
> >>
> >>growing is guaranteed to be false - loop is not necessary.
> >
> > Sort of.  Guess since the lock is not dropped if we see !growing
> > it will stay that way as long as we stay locked.  So we do need
> > to test growing but only once.  Have I understood this correctly?
>
> No. Much simpler:
> There is no synchonization between kmem_cache_destroy and
> kmem_cache_{alloc,free}. The caller must do that.
>
> Both
> 	x = kmem_cache_create();
> 	kmem_cache_destroy(x);
> 	kmem_cache_alloc(x);
>
> and all variante where kmem_cache_alloc runs at the same time as
> kmem_cache_destroy [smp, or just sleeping in gfp] are illegal.

So if growing is set something is seriously wrong...

> > We do seem to agree on most issues.  Lets work with this and hopefully we
> > can end up with a firsst class slab implementation that works hand in
> > hand with the vm and helps the whole system perform effectivily.
>
> Yes, lets work together. Implementing & debugging slab is simple [if it
> boots, then it's correct], the design is difficult.
>
> The first problem is the per-cpu array draining. It's needed, too many
> objects can sit in the per-cpu arrays.
> < 2.5.39, the per-cpu arrays can cause more list operations than no
> batching, this is something that must be avoided.
>
> Do you see an alternative to a timer/callback/hook? What's the simplest
> approach to ensure that the callback runs on all cpus? I know Redhat has
> a scalable timer patch, that one would fix the timer to the cpu that
> called add_timer.

Maybe.  If we treat the per cpu data as special form of cache we could
use the shrinker callbacks to track how much we have to trim.  When the value
exceeds a threshold (set when we setup the callback) we trim.  We could
do the test in freeing path in slab.   

> My proposal would be a 1 (or 2, or 5) seconds callback, that frees
> 0.2*cc->limit, if there were no allocations from the slab during the
> last interval.

Using the above logic would tie the trimming to vm scanning pressure,
which is probably a good idea.  

The patch add shrinker callbacks was posted to linux-mm Sunday and
to lkml on Thursday.

My schedule lets me read and answer a little mail in the mornings (7-8am 
EDT).  When I get home from work (5pm EDT) I usually have a few hours to 
code etc.

Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
