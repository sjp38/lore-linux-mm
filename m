Date: Mon, 16 Apr 2007 19:28:33 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] rename page_count for lockless pagecache
In-Reply-To: <20070414022407.GC14544@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0704161913230.10887@blonde.wat.veritas.com>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
 <20070412103340.5564.23286.sendpatchset@linux.site>
 <Pine.LNX.4.64.0704131229510.19073@blonde.wat.veritas.com>
 <20070413121347.GC966@wotan.suse.de> <20070414022407.GC14544@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Apr 2007, Nick Piggin wrote:
> On Fri, Apr 13, 2007 at 02:13:47PM +0200, Nick Piggin wrote:
> > On Fri, Apr 13, 2007 at 12:53:05PM +0100, Hugh Dickins wrote:
> > > Might it be more profitable for a DEBUG mode to inject random
> > > variations into page_count?
> > 
> > I think that's a very fine idea, and much more suitable for an
> > everyday kernel than my test threads. Doesn't help if they use the
> > field somehow without the accessors, but we must discourage that.
> > Thanks, I'll add such a debug mode.
> 
> Something like this boots and survives some stress testing here.
> 
> I guess it should be under something other than CONFIG_DEBUG_VM,
> because it could harm performance and scalability significantly on
> bigger boxes... or maybe it should use per-cpu counters? ;)
> 
> --
> Add some debugging for lockless pagecache as suggested by Hugh.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Hmm, maybe.  Would be rather cleaner if in this case page_count()
were not inlined but EXPORTed, with the ll_count static within it.

But I'm not terribly proud of the idea, and wonder whether we just
forget it?  How are we going to recognize it if this (or your
lpctest) ever does cause a problem?  Seems like a good thing for
you or I to try when developing, but whether it should go on into
the tree I'm less sure.

Hugh

> 
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -267,10 +267,29 @@ static inline int get_page_unless_zero(s
>  	return atomic_inc_not_zero(&page->_count);
>  }
>  
> +#ifdef CONFIG_DEBUG_VM
> +extern int ll_counter;
> +#endif
>  static inline int page_count(struct page *page)
>  {
>  	if (unlikely(PageCompound(page)))
>  		page = (struct page *)page_private(page);
> +#ifdef CONFIG_DEBUG_VM
> +	/*
> +	 * debug testing for lockless pagecache. add a random value to
> +	 * page_count every now and then, to simulate speculative references
> +	 * to it.
> +	 */
> +	{
> +		int count = atomic_read(&page->_count);
> +		if (count) {
> +			ll_counter++;
> +			if (ll_counter % 5 == 0 || ll_counter % 7 == 0)
> +				count += ll_counter % 11;
> +		}
> +		return count;
> +	}
> +#endif
>  	return atomic_read(&page->_count);
>  }
>  
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -137,6 +137,8 @@ static unsigned long __initdata dma_rese
>  #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
>  
>  #ifdef CONFIG_DEBUG_VM
> +int ll_counter; /* used in include/linux/mm.h, for lockless pagecache */
> +EXPORT_SYMBOL(ll_counter);
>  static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
>  {
>  	int ret = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
