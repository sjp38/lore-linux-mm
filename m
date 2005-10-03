Date: Mon, 3 Oct 2005 19:17:43 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
Message-ID: <20051003221743.GB29091@logos.cnet>
References: <20050930193754.GB16812@xeon.cnet> <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com> <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com> <43419686.60600@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43419686.60600@colorfullife.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, akpm@osdl.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

Hi Manfred,

On Mon, Oct 03, 2005 at 10:37:26PM +0200, Manfred Spraul wrote:
> Christoph Lameter wrote:
> 
> >On Sat, 1 Oct 2005, Marcelo wrote:
> >
> > 
> >
> >>I thought about having a mini-API for this such as "struct 
> >>slab_reclaim_ops" implemented by each reclaimable cache, invoked by a 
> >>generic SLAB function.
> >>
> >>   
> >>
> Which functions would be needed?
> - lock_cache(): No more alive/dead changes
> - objp_is_alive()
> - objp_is_killable()
> - objp_kill() 

Yep something along that line. I'll come up with something more precise
tomorrow.

> I think it would be simpler if the caller must mark the objects as 
> alive/dead before/after calling kmem_cache_alloc/free: I don't think 
> it's a good idea to add special case code and branches to the normal 
> kmem_cache_alloc codepath. And especially: It would mean that 
> kmem_cache_alloc must perform a slab lookup  in each alloc call, this 
> could be slow.
> The slab users could store the alive status somewhere in the object. And 
> they could set the flag early, e.g. disable alive as soon as an object 
> is put on the rcu aging list.

The "i_am_alive" flag purpose at the moment is to avoid interpreting
uninitialized data (in the dentry cache, the reference counter is bogus
in such case). It was just a quick hack to watch it work, it seemed to
me it could be done within SLAB code.

This information ("liveness" of objects) is managed inside the SLAB
generic code, and it seems to be available already through the
kmembufctl array which is part of the management data, right?

Suppose there's no need for the cache specific functions to be aware of
liveness, ie. its SLAB specific information.

Another issue is synchronization between multiple threads in this 
level of the reclaim path. Can be dealt with PageLock: if the bit is set,
don't bother checking the page, someone else is already doing
so.

You mention

> - lock_cache(): No more alive/dead changes

With the PageLock bit, you can instruct kmem_cache_alloc() to skip partial
but Locked pages (thus avoiding any object allocations within that page).
Hum, what about higher order SLABs?

Well, kmem_cache_alloc() can be a little bit smarter at this point, since 
its already a slow path, no? Its refill time, per-CPU cache is exhausted...

As for dead changes (object deletion), they should only happen with the
object specific lock held (dentry->d_lock in dcache's case). Looks
safe.

> The tricky part is lock_cache: is it actually possible to really lock 
> the dentry cache, or could RCU cause changes at any time.

dentry->d_lock is a per-object lock guaranteeing synch. between lookups and
deletion. Lookup of dentries is lockfree, but not acquision of reference: 

struct dentry * __d_lookup(struct dentry * parent, struct qstr * name)
{
	...
        rcu_read_lock();

        hlist_for_each_rcu(node, head) {
                struct dentry *dentry;
                struct qstr *qstr;

                dentry = hlist_entry(node, struct dentry, d_hash);

                if (dentry->d_name.hash != hash)
                        continue;
                if (dentry->d_parent != parent)
                        continue;

                spin_lock(&dentry->d_lock);

                /*
                 * Recheck the dentry after taking the lock - d_move may have
                 * changed things.  Don't bother checking the hash because we're
                 * about to compare the whole name anyway.
                 */
                if (dentry->d_parent != parent)
                        goto next;


Finding dependencies of "pinned" objects, walking the tree downwards in children's
direction in dcache's case, is protected by dcache_lock at the moment. The inode 
cache might want to delete the dentry which pins the inode in memory. 

Finally, I fail to see the requirement for a global lock as Andrew mentions, even
though locking is tricky and must be carefully checked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
