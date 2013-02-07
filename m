Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id ADF236B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 18:57:51 -0500 (EST)
Received: by mail-da0-f49.google.com with SMTP id t11so1492225daj.36
        for <linux-mm@kvack.org>; Thu, 07 Feb 2013 15:57:50 -0800 (PST)
Date: Thu, 7 Feb 2013 15:57:50 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/11] ksm: allow trees per NUMA node
In-Reply-To: <20130205164118.GI21389@suse.de>
Message-ID: <alpine.LNX.2.00.1302071353030.2133@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251753380.29196@eggly.anvils> <20130205164118.GI21389@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 5 Feb 2013, Mel Gorman wrote:
> On Fri, Jan 25, 2013 at 05:54:53PM -0800, Hugh Dickins wrote:
> > From: Petr Holasek <pholasek@redhat.com>
> > 
> > Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_across_nodes
> > which control merging pages across different numa nodes.
> > When it is set to zero only pages from the same node are merged,
> > otherwise pages from all nodes can be merged together (default behavior).
> > 
> > Typical use-case could be a lot of KVM guests on NUMA machine
> > and cpus from more distant nodes would have significant increase
> > of access latency to the merged ksm page. Sysfs knob was choosen
> > for higher variability when some users still prefers higher amount
> > of saved physical memory regardless of access latency.
> > 
> 
> This is understandable but it's going to be a fairly obscure option.
> I do not think it can be known in advance if the option should be set.
> The user must either run benchmarks before and after or use perf to
> record the "node-load-misses" event and see if setting the parameter
> reduces the number of remote misses.

Andrew made a similar point on the description of merge_across_nodes
in ksm.txt.  Petr's quiet at the moment, so I'll add a few more lines
to that description (in an incremental patch): but be assured what I say
will remain inadequate and unspecific - I don't have much idea of how to
decide the setting, but assume that the people who are interested in
using the knob will have a firmer idea of how to test for it.

> 
> I don't know the internals of ksm.c at all and this is my first time reading
> this series. Everything in this review is subject to being completely
> wrong or due to a major misunderstanding on my part. Delete all feedback
> if desired.

Thank you for spending your time on it.

[...snippings, but let's leave this paragraph in]

> > Hugh notes that this patch brings two problems, whose solution needs
> > further support in mm/ksm.c, which follows in subsequent patches:
> > 1) switching merge_across_nodes after running KSM is liable to oops
> >    on stale nodes still left over from the previous stable tree;
> > 2) memory hotremove may migrate KSM pages, but there is no provision
> >    here for !merge_across_nodes to migrate nodes to the proper tree.
...
> > --- mmotm.orig/mm/ksm.c	2013-01-25 14:36:31.724205455 -0800
> > +++ mmotm/mm/ksm.c	2013-01-25 14:36:38.608205618 -0800
...
> 
> With multiple stable node trees does the comment that begins with
> 
>  * A few notes about the KSM scanning process,
>  * to make it easier to understand the data structures below:
> 
> need an update?

Okay: I won't go through it pluralizing everything, but a couple of lines
on the !merge_across_nodes multiplicity of trees would be helpful.

> 
> It's uninitialised so kernel data size in vmlinux should be unaffected but
> it's an additional runtime cost of around 4K for a standardish enterprise
> distro kernel config.  Small beans on a NUMA machine and maybe not worth
> the hassle of kmalloc for nr_online_nodes and dealing with node memory
> hotplug but it's a pity.

It's a pity, I agree; as is the addition of int nid into rmap_item
on 32-bit (on 64-bit it just occupies a hole) - there can be a lot of
those.  We were kind of hoping that the #ifdef CONFIG_NUMA would cover
it, but some distros now enable NUMA by default even on 32-bit.  And
it's a pity because 99% of users will leave merge_across_nodes at its
default of 1 and only ever need a single tree of each kind.

I'll look into starting off with just root_stable_tree[1] and
root_unstable_tree[1], then kmalloc'ing nr_node_ids of them when and if
merge_across_nodes is switched off.  Then I don't think we need bother
about hotplug.  If it ends up looking clean enough, I'll add that patch.

> 
> >  #define MM_SLOTS_HASH_BITS 10
> >  static DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
> > @@ -188,6 +192,9 @@ static unsigned int ksm_thread_pages_to_
> >  /* Milliseconds ksmd should sleep between batches */
> >  static unsigned int ksm_thread_sleep_millisecs = 20;
> >  
> > +/* Zeroed when merging across nodes is not allowed */
> > +static unsigned int ksm_merge_across_nodes = 1;
> > +
> 
> Nit but initialised data does increase the size of vmlinux so maybe this
> should be the "opposite". i.e. rename it to ksm_merge_within_nodes and
> default it to 0?

I don't find that particular increase in size very compelling!  Though
I would have preferred the tunable to be the opposite way around: it
annoys me that the new code comes into play when !ksm_merge_across_nodes.

However, I do find "merge across nodes" (thanks to Andrew for "across")
a much more vivid description than the opposite "merge within nodes",
and can't think of a better alternative for that; and wouldn't want to
change it anyway at this late (v7) stage, not without Petr's consent.

> 
> __read_mostly?

I feel the same way as I did when Andrew suggested it:
> 
> I spose this should be __read_mostly.  If __read_mostly is not really a
> synonym for __make_write_often_storage_slower.  I continue to harbor
> fear, uncertainty and doubt about this...

Could do.  No strong feeling, but I think I'd rather it share its
cacheline with other KSM-related stuff, than be off mixed up with
unrelateds.  I think there's a much stronger case for __read_mostly
when it's a library thing accessed by different subsystems.

You're right that this variable is accessed significantly more often
that the other KSM tunables, so deserves a __read_mostly more than
they do.  But where to stop?  Similar reluctance led me to avoid
using "unlikely" throughout ksm.c, unlikely as some conditions are
(I'm aghast to see that Andrea sneaked in a "likely" :).

> 
> >  #define KSM_RUN_STOP	0
> >  #define KSM_RUN_MERGE	1
> >  #define KSM_RUN_UNMERGE	2
> > @@ -441,10 +448,25 @@ out:		page = NULL;
> >  	return page;
> >  }
> >  
> > +/*
> > + * This helper is used for getting right index into array of tree roots.
> > + * When merge_across_nodes knob is set to 1, there are only two rb-trees for
> > + * stable and unstable pages from all nodes with roots in index 0. Otherwise,
> > + * every node has its own stable and unstable tree.
> > + */
> > +static inline int get_kpfn_nid(unsigned long kpfn)
> > +{
> > +	if (ksm_merge_across_nodes)
> > +		return 0;
> > +	else
> > +		return pfn_to_nid(kpfn);
> > +}
> > +
> 
> If we start with ksm_merge_across_nodes, KSM runs for a while and populates
> the stable node tree for node 0 and then ksm_merge_across_nodes gets set
> then badness happens because this can go anywhere
> 
>      nid = get_kpfn_nid(stable_node->kpfn);
>      rb_erase(&stable_node->node, &root_stable_tree[nid]);
> 
> Very late in the review I noticed that you comment on this already in the
> changelog and that it is addressed later in the series. I haven't seen

Yes.  Nobody's git bisection will be thwarted by this defect, so I'm
happy for Petr's patch to go in as is first, then fix applied after.
And even in this patch, there's already a pages_shared 0 test: which
is inadequate, but covers the common case.

> this patch yet so the following suggestion is very stale but might still
> be relevant.
> 
> 	We could increase size of root_stable_node[] by 1, have
> 	get_kpfn_nid return MAX_NR_NODES if ksm_merge_across_nodes and
> 	if ksm_merge_across_nodes gets set to 0 then we walk the stable
> 	tree at root_stable_tree[MAX_NR_NODES] and delete the entire
> 	tree? It's be disruptive as hell unfortunately and might break
> 	entirely if there is not enough memory to unshare the pages.
> 
> 	Ideally we could take our time walking root_stable_tree[MAX_NR_NODES]
> 	without worrying about collisions and fix it up somehow. Dunno

Petr's intention was that we just be disruptive, and insist on the old
tree being torn down first: it was merely a defect that this patch does
not quite ensure that.

You're right that we could be cleverer: in the light of the changes I
ended up making for collisions in migration, maybe that approach could
be extended to switching merge_across_nodes.

But I think you'll agree that switching merge_across_nodes is a path
that needs to be handled correctly, but no way does it need optimization:
people will do it when they're trying to work out the right tuning for
their loads, and thereafter probably never again.

> > @@ -554,7 +578,12 @@ static void remove_rmap_item_from_tree(s
> >  		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
> >  		BUG_ON(age > 1);
> >  		if (!age)
> > -			rb_erase(&rmap_item->node, &root_unstable_tree);
> > +#ifdef CONFIG_NUMA
> > +			rb_erase(&rmap_item->node,
> > +					&root_unstable_tree[rmap_item->nid]);
> > +#else
> > +			rb_erase(&rmap_item->node, &root_unstable_tree[0]);
> > +#endif
> >  
> 
> nit, does rmap_item->nid deserve a getter and setter helper instead?

I found that part ugly too: it gets macro helpers in trivial tidyups 3/11,
though not quite the getter/setter helpers you had in mind.

> > @@ -1122,6 +1166,18 @@ struct rmap_item *unstable_tree_search_i
> >  			return NULL;
> >  		}
> >  
> > +		/*
> > +		 * If tree_page has been migrated to another NUMA node, it
> > +		 * will be flushed out and put into the right unstable tree
> > +		 * next time: only merge with it if merge_across_nodes.
> > +		 * Just notice, we don't have similar problem for PageKsm
> > +		 * because their migration is disabled now. (62b61f611e)
> > +		 */
> > +		if (!ksm_merge_across_nodes && page_to_nid(tree_page) != nid) {
> > +			put_page(tree_page);
> > +			return NULL;
> > +		}
> > +
> 
> What about this case?
> 
> 1. ksm_merge_across_nodes==0
> 2. pages gets placed on different unstable trees
> 3. ksm_merge_across_nodes==1
> 
> At that point we should be removing pages from the different unstable
> tree and moving them to root_unstable_tree[0] but this put_page() doesn't
> happen. Does it matter?

It doesn't matter.  The general philosophy in ksm.c is to be very lazy
about the unstable tree: all kinds of things can go "wrong" with it
temporarily, that's okay so long as we don't fall for errors that would
persist round after round.  The check above is required (somewhere) to
make sure that we don't merge pages from different nodes into the same
stable tree when the switch says not to do that.  But the case that
you're thinking of, it'll just sort itself out in a later round
(I think you later realized how the unstable tree is rebuilt
from scratch each round).

Or have I misunderstood: are you worrying that a put_page()
is missing?  I don't see that.

But now you point me to this block, I do wonder if we could place it
better.  When I came to worry about such an issue in the stable tree,
I decided that it's perfectly okay to use a page from the wrong node
for an intermediate test, and suboptimal to give up at that point,
just wrong to return it as a final match.  But here we give up even
when it's an intermediate: seems inconsistent, I'll give it some more
thought later, and probably want to move it: it's not wrong as is,
but I think it could be more efficient and more consistent.

> > @@ -1301,7 +1368,8 @@ static struct rmap_item *scan_get_next_r
> >  		 */
> >  		lru_add_drain_all();
> >  
> > -		root_unstable_tree = RB_ROOT;
> > +		for (nid = 0; nid < nr_node_ids; nid++)
> > +			root_unstable_tree[nid] = RB_ROOT;
> >  
> 
> Minor but you shouldn't need to reset tham all if
> ksm_merge_across_nodes==1

True; and I'll need to attend to this if we do move away from
the static allocation of root_unstable_tree[MAX_NUMNODES].

> 
> Initially this triggered an alarm because it's not immediately obvious
> why you can just discard an rbtree like this. It looks like because the
> unstable tree is also part of a linked list so the rb representation can
> be reset quickly without leaking memory.

Right, it takes a while to get your head around the way we just forget
the old tree and start again each time.  There's a funny place in
remove_rmap_item_from_tree() (visible in an earlier extract) where it
has to consider the "age" of the rmap_item, to decide whether it's
linked into the current tree or not.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
