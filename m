Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 65E766B0037
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:51:13 -0400 (EDT)
Date: Thu, 22 Aug 2013 11:48:53 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: workingset: keep shadow entries in check
Message-ID: <20130822094853.GC26749@cmpxchg.org>
References: <1376767883-4411-1-git-send-email-hannes@cmpxchg.org>
 <1376767883-4411-10-git-send-email-hannes@cmpxchg.org>
 <20130820135924.937d93a3fd0368b48ba01189@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130820135924.937d93a3fd0368b48ba01189@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 20, 2013 at 01:59:24PM -0700, Andrew Morton wrote:
> On Sat, 17 Aug 2013 15:31:23 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Previously, page cache radix tree nodes were freed after reclaim
> > emptied out their page pointers.  But now reclaim stores shadow
> > entries in their place, which are only reclaimed when the inodes
> > themselves are reclaimed.  This is problematic for bigger files that
> > are still in use after they have a significant amount of their cache
> > reclaimed, without any of those pages actually refaulting.  The shadow
> > entries will just sit there and waste memory.  In the worst case, the
> > shadow entries will accumulate until the machine runs out of memory.
> 
> erk.  This whole patch is overhead :(
> 
> > To get this under control, a list of inodes that contain shadow
> > entries is maintained.  If the global number of shadows exceeds a
> > certain threshold, a shrinker is activated that reclaims old entries
> > from the mappings.  This is heavy-handed but it should not be a hot
> > path and is mainly there to protect from accidentally/maliciously
> > induced OOM kills.  The global list is also not a problem because the
> > modifications are very rare: inodes are added once in their lifetime
> > when the first shadow entry is stored (i.e. the first page reclaimed)
> > and lazily removed when the inode exits.  Or if the shrinker removes
> > all shadow entries.
> > 
> > ...
> >
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -417,6 +417,7 @@ struct address_space {
> >  	/* Protected by tree_lock together with the radix tree */
> >  	unsigned long		nrpages;	/* number of total pages */
> >  	unsigned long		nrshadows;	/* number of shadow entries */
> > +	struct list_head	shadow_list;	/* list of mappings with shadows */
> >  	pgoff_t			writeback_index;/* writeback starts here */
> >  	const struct address_space_operations *a_ops;	/* methods */
> >  	unsigned long		flags;		/* error bits/gfp mask */
> 
> There's another 16 bytes into the inode.  Bad.

Yeah :(

An obvious alternative to storing page eviction information in the
page cache radix tree would be to have a separate data structure that
scales with the number of physical pages available.

It really depends on the workload which one's cheaper in terms of both
memory and cpu.

Workloads where the ratio between number of inodes and inode size is
high suffer from the increased inode size, but when they have decent
access locality within the inodes, the inodes should be evicted along
with their pages.  So in this case there is little to no memory
overhead from the eviction information compared to the fixed size
separate data structure.

And refault information lookup is cheaper of course when storing
eviction information inside the cache slots.

Workloads for which this model sucks are those with inode locality but
no data locality.  The inodes stay alive and the lack of data locality
produces many shadow entries that only the costly shrinker can get rid
of.  Numbers aside, it was a judgement call to improve workloads with
high data locality at the cost of those without.

But I'll include a more concrete cost analysis in the submission that
also includes more concrete details on the benefits of the series ;)

> > +void workingset_shadows_inc(struct address_space *mapping)
> > +{
> > +	might_lock(&shadow_lock);
> > +
> > +	if (mapping->nrshadows == 0 && list_empty(&mapping->shadow_list)) {
> > +		spin_lock(&shadow_lock);
> 
> I can't work out whether or not shadow_lock is supposed to be irq-save.
> Some places it is, others are unobvious.

It is.  The caller holds the irq-safe tree_lock, though, so no need to
disable IRQs a second time.  I'll add documentation.

> > +static unsigned long get_nr_old_shadows(void)
> > +{
> > +	unsigned long nr_max;
> > +	unsigned long nr;
> > +	long sum = 0;
> > +	int cpu;
> > +
> > +	for_each_possible_cpu(cpu)
> > +		sum += per_cpu(nr_shadows, cpu);
> 
> Ouch, slow.  shrink_slab() will call this repeatedly and scan_shadows()
> calls it from a loop.  Can we use something non-deathly-slow here? 
> Like percpu_counter_read_positive()?

Finally, a usecase for percpu_counter!!  Sounds reasonable, I'll
convert this stuff over.

> > +	nr = max(sum, 0L);
> > +
> > +	/*
> > +	 * Every shadow entry with a refault distance bigger than the
> > +	 * active list is ignored and so NR_ACTIVE_FILE would be a
> > +	 * reasonable ceiling.  But scanning and shrinking shadow
> > +	 * entries is quite expensive, so be generous.
> > +	 */
> > +	nr_max = global_dirtyable_memory() * 4;
> > +
> > +	if (nr <= nr_max)
> > +		return 0;
> > +	return nr - nr_max;
> > +}
> > +
> > +static unsigned long scan_mapping(struct address_space *mapping,
> > +				  unsigned long nr_to_scan)
> 
> Some methodological description would be useful.

Fair enough, I'll write something.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
