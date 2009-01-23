Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2876B004F
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 06:42:13 -0500 (EST)
Date: Fri, 23 Jan 2009 12:57:31 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123115731.GO15750@one.firstfloor.org>
References: <20090121143008.GV24891@wotan.suse.de> <87hc3qcpo1.fsf@basil.nowhere.org> <20090123112555.GF19986@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090123112555.GF19986@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2009 at 12:25:55PM +0100, Nick Piggin wrote:
> > > +#ifdef CONFIG_SLQB_SYSFS
> > > +	struct kobject kobj;	/* For sysfs */
> > > +#endif
> > > +#ifdef CONFIG_NUMA
> > > +	struct kmem_cache_node *node[MAX_NUMNODES];
> > > +#endif
> > > +#ifdef CONFIG_SMP
> > > +	struct kmem_cache_cpu *cpu_slab[NR_CPUS];
> > 
> > Those both really need to be dynamically allocated, otherwise
> > it wastes a lot of memory in the common case
> > (e.g. NR_CPUS==128 kernel on dual core system). And of course
> > on the proposed NR_CPUS==4096 kernels it becomes prohibitive.
> > 
> > You could use alloc_percpu? There's no alloc_pernode 
> > unfortunately, perhaps there should be one. 
> 
> cpu_slab is dynamically allocated, by just changing the size of
> the kmem_cache cache at boot time. 

You'll always have at least the MAX_NUMNODES waste because
you cannot tell the compiler that the cpu_slab field has 
moved.

> Probably the best way would
> be to have dynamic cpu and node allocs for them, I agree.

It's really needed.

> Any plans for an alloc_pernode?

It shouldn't be very hard to implement. Or do you ask if I'm volunteering? @)

> > > + * - investiage performance with memoryless nodes. Perhaps CPUs can be given
> > > + *   a default closest home node via which it can use fastpath functions.
> > 
> > FWIW that is what x86-64 always did. Perhaps you can just fix ia64 to do 
> > that too and be happy.
> 
> What if the node is possible but not currently online?

Nobody should allocate on it then.

> > > +/* Not all arches define cache_line_size */
> > > +#ifndef cache_line_size
> > > +#define cache_line_size()	L1_CACHE_BYTES
> > > +#endif
> > > +
> > 
> > They should. better fix them?
> 
> git grep -l -e cache_line_size arch/ | egrep '\.h$'
> 
> Only ia64, mips, powerpc, sparc, x86...

It's straight forward to that define everywhere.

> 
> > > +	if (unlikely(slab_poison(s)))
> > > +		memset(start, POISON_INUSE, PAGE_SIZE << s->order);
> > > +
> > > +	start += colour;
> > 
> > One thing i was wondering. Did you try to disable the colouring and see
> > if it makes much difference on modern systems? They tend to have either
> > larger caches or higher associativity caches.
> 
> I have tried, but I don't think I found a test where it made a
> statistically significant difference. It is not very costly to
> implement, though.

how about the memory usage?

also this is all so complicated already that every simplification helps.

> > > +#endif
> > > +
> > > +#ifdef CONFIG_NUMA
> > > +static struct kmem_cache kmem_node_cache;
> > > +static struct kmem_cache_cpu kmem_node_cpus[NR_CPUS];
> > > +static struct kmem_cache_node kmem_node_nodes[MAX_NUMNODES];
> > > +#endif
> > 
> > That all needs fixing too of course.
> 
> Hmm. I was hoping it could stay simple as it is just a static constant
> (for a given NR_CPUS) overhead. 

The issue is that distro kernels typically run with NR_CPUS >>> num_possible_cpus()
And we'll see likely higher NR_CPUS (and MAX_NUMNODES) in the future,
but also still want to run the same kernels on really small systems (e.g.
Atom based) without wasting their memory.  

So for anything NR_CPUS you should use per_cpu data -- that is correctly
sized automatically.

For MAX_NUMNODES we don't have anything equivalent currently, so 
you would also need alloc_pernode() I guess.

Ok you can just use per cpu for them too and only use the first
entry in each node. That's cheating, but not too bad.


> I wonder if bootmem is still up here?

bootmem is finished when slab comes up.
> 
> Could bite the bullet and do a multi-stage bootstap like SLUB, but I
> want to try avoiding that (but init code is also of course much less
> important than core code and total overheads). 

For DEFINE_PER_CPU you don't need special allocation.

Probably want a DEFINE_PER_NODE() for this or see above.

> 
> > > +static ssize_t align_show(struct kmem_cache *s, char *buf)
> > > +{
> > > +	return sprintf(buf, "%d\n", s->align);
> > > +}
> > > +SLAB_ATTR_RO(align);
> > > +
> > 
> > When you map back to the attribute you can use a index into a table
> > for the field, saving that many functions?
> > 
> > > +STAT_ATTR(CLAIM_REMOTE_LIST, claim_remote_list);
> > > +STAT_ATTR(CLAIM_REMOTE_LIST_OBJECTS, claim_remote_list_objects);
> > 
> > This really should be table driven, shouldn't it? That would give much
> > smaller code.
> 
> Tables probably would help. I will keep it close to SLUB for now,
> though.

Hmm, then fix slub? 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
