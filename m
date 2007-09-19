Message-ID: <46F072A5.8060008@google.com>
Date: Tue, 18 Sep 2007 17:51:49 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] cpuset write dirty map
References: <469D3342.3080405@google.com>	<46E741B1.4030100@google.com>	<46E742A2.9040006@google.com> <20070914161536.3ec5c533.akpm@linux-foundation.org>
In-Reply-To: <20070914161536.3ec5c533.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 11 Sep 2007 18:36:34 -0700
> Ethan Solomita <solo@google.com> wrote:
> 
>> Add a dirty map to struct address_space
> 
> I get a tremendous number of rejects trying to wedge this stuff on top of
> Peter's mm-dirty-balancing-for-tasks changes.  More rejects than I am
> prepared to partially-fix so that I can usefully look at these changes in
> tkdiff, so this is all based on a quick peek at the diff itself..

	This isn't surprising. We're both changing the calculation of dirty
limits. If his code is already into your workspace, then I'll have to do
the merging after you release it.

>> +#if MAX_NUMNODES <= BITS_PER_LONG
> 
> The patch is sprinkled full of this conditional.
> 
>   I don't understand why this is being done.  afaict it isn't described
>   in a code comment (it should be) nor even in the changelogs?

	I can add comments.

>   Given its overall complexity and its likelihood to change in the
>   future, I'd suggest that this conditional be centralised in a single
>   place.  Something like
> 
>   /*
>    * nice comment goes here
>    */
>   #if MAX_NUMNODES <= BITS_PER_LONG
>   #define CPUSET_DIRTY_LIMITS 1
>   #else
>   #define CPUSET_DIRTY_LIMITS 0
>   #endif
> 
>   Then use #if CPUSET_DIRTY_LIMITS everywhere else.
> 
>   (This is better than #ifdef CPUSET_DIRTY_LIMITS because we'll et a
>   warning if someone typos '#if CPUSET_DITRY_LIMITS')

	I can add something like this. Probably something like:

CPUSET_DIRTY_LIMITS_USEPTR

>> --- 0/include/linux/fs.h	2007-09-11 14:35:58.000000000 -0700
>> +++ 1/include/linux/fs.h	2007-09-11 14:36:24.000000000 -0700
>> @@ -516,6 +516,13 @@ struct address_space {
>>  	spinlock_t		private_lock;	/* for use by the address_space */
>>  	struct list_head	private_list;	/* ditto */
>>  	struct address_space	*assoc_mapping;	/* ditto */
>> +#ifdef CONFIG_CPUSETS
>> +#if MAX_NUMNODES <= BITS_PER_LONG
>> +	nodemask_t		dirty_nodes;	/* nodes with dirty pages */
>> +#else
>> +	nodemask_t		*dirty_nodes;	/* pointer to map if dirty */
>> +#endif
>> +#endif
> 
> afacit there is no code comment and no changelog text which explains the
> above design decision?  There should be, please.

	OK.
> 
> There is talk of making cpusets available with CONFIG_SMP=n.  Will this new
> feature be available in that case?  (it should be).

	I'm not sure how useful it would be in that scenario, but for
consistency we should still be able to specify varying dirty ratios
(from patch 6/6). The above code wouldn't mean anything SMP=n since
there's only the one node. We'd just be indicating whether the inode has
any dirty pages, which we already know.

> 
>>  } __attribute__((aligned(sizeof(long))));
>>  	/*
>>  	 * On most architectures that alignment is already the case; but
>> diff -uprN -X 0/Documentation/dontdiff 0/include/linux/writeback.h 1/include/linux/writeback.h
>> --- 0/include/linux/writeback.h	2007-09-11 14:35:58.000000000 -0700
>> +++ 1/include/linux/writeback.h	2007-09-11 14:37:46.000000000 -0700
>> @@ -62,6 +62,7 @@ struct writeback_control {
>>  	unsigned for_writepages:1;	/* This is a writepages() call */
>>  	unsigned range_cyclic:1;	/* range_start is cyclic */
>>  	void *fs_private;               /* For use by ->writepages() */
>> +	nodemask_t *nodes;		/* Set of nodes of interest */
>>  };
> 
> That comment is a bit terse.  It's always good to be lavish when commenting
> data structures, for understanding those is key to understanding a design.
> 
	OK

>>  /*
>> diff -uprN -X 0/Documentation/dontdiff 0/kernel/cpuset.c 1/kernel/cpuset.c
>> --- 0/kernel/cpuset.c	2007-09-11 14:35:58.000000000 -0700
>> +++ 1/kernel/cpuset.c	2007-09-11 14:36:24.000000000 -0700
>> @@ -4,7 +4,7 @@
>>   *  Processor and Memory placement constraints for sets of tasks.
>>   *
>>   *  Copyright (C) 2003 BULL SA.
>> - *  Copyright (C) 2004-2006 Silicon Graphics, Inc.
>> + *  Copyright (C) 2004-2007 Silicon Graphics, Inc.
>>   *  Copyright (C) 2006 Google, Inc
>>   *
>>   *  Portions derived from Patrick Mochel's sysfs code.
>> @@ -14,6 +14,7 @@
>>   *  2003-10-22 Updates by Stephen Hemminger.
>>   *  2004 May-July Rework by Paul Jackson.
>>   *  2006 Rework by Paul Menage to use generic containers
>> + *  2007 Cpuset writeback by Christoph Lameter.
>>   *
>>   *  This file is subject to the terms and conditions of the GNU General Public
>>   *  License.  See the file COPYING in the main directory of the Linux
>> @@ -1754,6 +1755,63 @@ int cpuset_mem_spread_node(void)
>>  }
>>  EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
>>  
>> +#if MAX_NUMNODES > BITS_PER_LONG
> 
> waah.  In other places we do "MAX_NUMNODES <= BITS_PER_LONG"

	Your sanity is important to me. Will fix.
> 
>> +
>> +/*
>> + * Special functions for NUMA systems with a large number of nodes.
>> + * The nodemask is pointed to from the address space structures.
>> + * The attachment of the dirty_node mask is protected by the
>> + * tree_lock. The nodemask is freed only when the inode is cleared
>> + * (and therefore unused, thus no locking necessary).
>> + */
> 
> hmm, OK, there's a hint as to wghat's going on.
> 
> It's unobvious why the break point is at MAX_NUMNODES = BITS_PER_LONG and
> we might want to tweak that in the future.  Yet another argument for
> centralising this comparison.

	I'll add a comment to make it more obvious. The point is to only add
one long to the data structure, no matter sizeof(nodemask_t), adding
either a nodemask_t or a pointer to a nodemask_t if nodemask_t is too large.

> 
>> +void cpuset_update_dirty_nodes(struct address_space *mapping,
>> +			struct page *page)
>> +{
>> +	nodemask_t *nodes = mapping->dirty_nodes;
>> +	int node = page_to_nid(page);
>> +
>> +	if (!nodes) {
>> +		nodes = kmalloc(sizeof(nodemask_t), GFP_ATOMIC);
> 
> Does it have to be atomic?  atomic is weak and can fail.
> 
> If some callers can do GFP_KERNEL and some can only do GFP_ATOMIC then we
> should at least pass the gfp_t into this function so it can do the stronger
> allocation when possible.

	I was going to say that sanity would be improved by just allocing the
nodemask at inode alloc time. A failure here could be a problem because
below cpuset_intersects_dirty_nodes() assumes that a NULL nodemask
pointer means that there are no dirty nodes, thus preventing dirty pages
from getting written to disk. i.e. This must never fail.

	Given that we allocate it always at the beginning, I'm leaning towards
just allocating it within mapping no matter its size. It will make the
code much much simpler, and save me writing all the comments we've been
discussing. 8-)

	How disastrous would this be? Is the need to support a 1024 node system
with 1,000,000 open mostly-read-only files thus needing to spend 120MB
of extra memory on my nodemasks a real scenario and a showstopper?

> 
> 
>> +		if (!nodes)
>> +			return;
>> +
>> +		*nodes = NODE_MASK_NONE;
>> +		mapping->dirty_nodes = nodes;
>> +	}
>> +
>> +	if (!node_isset(node, *nodes))
>> +		node_set(node, *nodes);
>> +}
>> +
>> +void cpuset_clear_dirty_nodes(struct address_space *mapping)
>> +{
>> +	nodemask_t *nodes = mapping->dirty_nodes;
>> +
>> +	if (nodes) {
>> +		mapping->dirty_nodes = NULL;
>> +		kfree(nodes);
>> +	}
>> +}
> 
> Can this race with cpuset_update_dirty_nodes()?  And with itself?  If not,
> a comment which describes the locking requirements would be good.

	I'll add a comment. Such a race should not be possible. It is called
only from clear_inode() which is used when the inode is being freed
"with extreme prejudice" (from its comments). I can add a check that
i_state I_FREEING is set. Would that do?

> 
>> +/*
>> + * Called without the tree_lock. The nodemask is only freed when the inode
>> + * is cleared and therefore this is safe.
>> + */
>> +int cpuset_intersects_dirty_nodes(struct address_space *mapping,
>> +			nodemask_t *mask)
>> +{
>> +	nodemask_t *dirty_nodes = mapping->dirty_nodes;
>> +
>> +	if (!mask)
>> +		return 1;
>> +
>> +	if (!dirty_nodes)
>> +		return 0;
>> +
>> +	return nodes_intersects(*dirty_nodes, *mask);
>> +}
>> +#endif
>> +
>>  /**
>>   * cpuset_excl_nodes_overlap - Do we overlap @p's mem_exclusive ancestors?
>>   * @p: pointer to task_struct of some other task.
>> diff -uprN -X 0/Documentation/dontdiff 0/mm/page-writeback.c 1/mm/page-writeback.c
>> --- 0/mm/page-writeback.c	2007-09-11 14:35:58.000000000 -0700
>> +++ 1/mm/page-writeback.c	2007-09-11 14:36:24.000000000 -0700
>> @@ -33,6 +33,7 @@
>>  #include <linux/syscalls.h>
>>  #include <linux/buffer_head.h>
>>  #include <linux/pagevec.h>
>> +#include <linux/cpuset.h>
>>  
>>  /*
>>   * The maximum number of pages to writeout in a single bdflush/kupdate
>> @@ -832,6 +833,7 @@ int __set_page_dirty_nobuffers(struct pa
>>  			radix_tree_tag_set(&mapping->page_tree,
>>  				page_index(page), PAGECACHE_TAG_DIRTY);
>>  		}
>> +		cpuset_update_dirty_nodes(mapping, page);
>>  		write_unlock_irq(&mapping->tree_lock);
>>  		if (mapping->host) {
>>  			/* !PageAnon && !swapper_space */
>>
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
