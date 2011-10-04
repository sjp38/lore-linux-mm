Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD49900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:29:00 -0400 (EDT)
Date: Tue, 4 Oct 2011 09:28:54 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: lockdep recursive locking detected (rcu_kthread /
 __cache_free)
In-Reply-To: <20111003214739.GK2403@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1110040916330.8522@router.home>
References: <20111003175322.GA26122@sucs.org> <20111003203139.GH2403@linux.vnet.ibm.com> <alpine.DEB.2.00.1110031540560.11713@router.home> <20111003214739.GK2403@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Sitsofe Wheeler <sitsofe@yahoo.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org

On Mon, 3 Oct 2011, Paul E. McKenney wrote:

> On Mon, Oct 03, 2011 at 03:46:11PM -0500, Christoph Lameter wrote:
> > On Mon, 3 Oct 2011, Paul E. McKenney wrote:
> >
> > > The first lock was acquired here in an RCU callback.  The later lock that
> > > lockdep complained about appears to have been acquired from a recursive
> > > call to __cache_free(), with no help from RCU.  This looks to me like
> > > one of the issues that arise from the slab allocator using itself to
> > > allocate slab metadata.
> >
> > Right. However, this is a false positive since the slab cache with
> > the metadata is different from the slab caches with the slab data. The slab
> > cache with the metadata does not use itself any metadata slab caches.
>
> Wouldn't it be possible to pass a new flag to the metadata slab caches
> upon creation so that their locks could be placed in a separate lock
> class?  Just allocate a separate lock_class_key structure for each such
> lock in that case, and then use lockdep_set_class_and_name to associate
> that structure with the corresponding lock.  I do this in kernel/rcutree.c
> in order to allow the rcu_node tree's locks to nest properly.

We could give the kmalloc array a different class from created slab
caches. That should have the desired effect.

But that seems to be already the case (looking at init_node_lock_keys).
Non OFF_SLAB caches seem to be getting a different lock class? Why is this
not working?

static void init_node_lock_keys(int q)
{
        struct cache_sizes *s = malloc_sizes;

        if (g_cpucache_up != FULL)
                return;

        for (s = malloc_sizes; s->cs_size != ULONG_MAX; s++) {
                struct kmem_list3 *l3;

                l3 = s->cs_cachep->nodelists[q];
                if (!l3 || OFF_SLAB(s->cs_cachep))
                        continue;

                slab_set_lock_classes(s->cs_cachep, &on_slab_l3_key,
                                &on_slab_alc_key, q);
        }
}




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
