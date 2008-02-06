Date: Wed, 6 Feb 2008 11:01:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Support for statistics to help analyze allocator behavior
In-Reply-To: <20080206001948.6f749aa8.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802061059110.25173@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
 <20080206001948.6f749aa8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2008, Andrew Morton wrote:

> > @@ -1357,17 +1366,22 @@ static struct page *get_partial(struct k
> >  static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
> >  {
> >  	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
> > +	struct kmem_cache_cpu *c = get_cpu_slab(s, smp_processor_id());
> 
> So we're never running preemptibly here.

Correct.

> > +			if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
> >  			add_full(n, page);
> 
> missing a tab

Ack.

> 
> > +#ifdef CONFIG_SLUB_STATS
> > +
> > +#define STAT_ATTR(si, text) 					\
> > +static ssize_t text##_show(struct kmem_cache *s, char *buf)	\
> > +{								\
> > +	unsigned long sum  = 0;					\
> > +	int cpu;						\
> > +								\
> > +	for_each_online_cpu(cpu)				\
> > +		sum += get_cpu_slab(s, cpu)->stat[si];		\
> 
> maybe cache the get_cpu_slab() result in a local?

Every iteration must perform a different lookup. The cpu variable is 
passed to get_cpu_slab().

> 
> > +	return sprintf(buf, "%lu\n", sum);			\
> > +}								\
> > +SLAB_ATTR_RO(text);						\
> 
> this is pretty broken after cpu hot-unplug, isn't it?

No it still gives all the events on the processors that are up which is 
consistent in some way (and its only stats). There is really no clean 
solution. Same situation as with the event counters in the VM. We could 
fold them into some other processor when it goes down. Yuck.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
