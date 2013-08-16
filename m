Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 6247F6B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 15:01:08 -0400 (EDT)
Date: Fri, 16 Aug 2013 14:01:06 -0500
From: Russ Anderson <rja@sgi.com>
Subject: Re: [PATCH] memblock, numa: Binary search node id
Message-ID: <20130816190106.GD22182@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
References: <1376545589-32129-1-git-send-email-yinghai@kernel.org> <20130815134348.bb119a7987af0bb64ed77b7b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130815134348.bb119a7987af0bb64ed77b7b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 15, 2013 at 01:43:48PM -0700, Andrew Morton wrote:
> On Wed, 14 Aug 2013 22:46:29 -0700 Yinghai Lu <yinghai@kernel.org> wrote:
> 
> > Current early_pfn_to_nid() on arch that support memblock go
> > over memblock.memory one by one, so will take too many try
> > near the end.
> > 
> > We can use existing memblock_search to find the node id for
> > given pfn, that could save some time on bigger system that
> > have many entries memblock.memory array.
> 
> Looks nice.  I wonder how much difference it makes.

Here are the timing differences for several machines.
In each case with the patch less time was spent in __early_pfn_to_nid().


                        3.11-rc5        with patch      difference (%)
                        --------        ----------      --------------
UV1: 256 nodes  9TB:     411.66          402.47         -9.19 (2.23%)
UV2: 255 nodes 16TB:    1141.02         1138.12         -2.90 (0.25%)
UV2:  64 nodes  2TB:     128.15          126.53         -1.62 (1.26%)
UV2:  32 nodes  2TB:     121.87          121.07         -0.80 (0.66%)
                        Time in seconds.

Acked-by: Russ Anderson <rja@sgi.com>
 
> > ...
> >
> > --- linux-2.6.orig/include/linux/memblock.h
> > +++ linux-2.6/include/linux/memblock.h
> > @@ -60,6 +60,8 @@ int memblock_reserve(phys_addr_t base, p
> >  void memblock_trim_memory(phys_addr_t align);
> >  
> >  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> > +int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
> > +			    unsigned long  *end_pfn);
> >  void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
> >  			  unsigned long *out_end_pfn, int *out_nid);
> >  
> > Index: linux-2.6/mm/memblock.c
> > ===================================================================
> > --- linux-2.6.orig/mm/memblock.c
> > +++ linux-2.6/mm/memblock.c
> > @@ -914,6 +914,24 @@ int __init_memblock memblock_is_memory(p
> >  	return memblock_search(&memblock.memory, addr) != -1;
> >  }
> >  
> > +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> > +int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
> > +			 unsigned long *start_pfn, unsigned long *end_pfn)
> > +{
> > +	struct memblock_type *type = &memblock.memory;
> > +	int mid = memblock_search(type, (phys_addr_t)pfn << PAGE_SHIFT);
> > +
> > +	if (mid == -1)
> > +		return -1;
> > +
> > +	*start_pfn = type->regions[mid].base >> PAGE_SHIFT;
> > +	*end_pfn = (type->regions[mid].base + type->regions[mid].size)
> > +			>> PAGE_SHIFT;
> > +
> > +	return type->regions[mid].nid;
> > +}
> > +#endif
> 
> This function will have no callers if
> CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y.  That's not too bad as the
> function is __init_memblock.  But this depends on
> CONFIG_ARCH_DISCARD_MEMBLOCK.  Messy :(
> 

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
