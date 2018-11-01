Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0706B0006
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 11:10:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f22-v6so14650191pgv.21
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 08:10:50 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a29-v6si22707981pfh.223.2018.11.01.08.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 08:10:49 -0700 (PDT)
Message-ID: <5eb92a4b34a934459e8558d0f7695a89ee178f89.camel@linux.intel.com>
Subject: Re: [mm PATCH v4 3/6] mm: Use memblock/zone specific iterator for
 handling deferred page init
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Thu, 01 Nov 2018 08:10:48 -0700
In-Reply-To: <20181101061733.GA8866@rapoport-lnx>
References: <20181017235043.17213.92459.stgit@localhost.localdomain>
	 <20181017235419.17213.68425.stgit@localhost.localdomain>
	 <5b937f29-a6e1-6622-b035-246229021d3e@microsoft.com>
	 <20181101061733.GA8866@rapoport-lnx>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "davem@davemloft.net" <davem@davemloft.net>, "yi.z.zhang@linux.intel.com" <yi.z.zhang@linux.intel.com>, "khalid.aziz@oracle.com" <khalid.aziz@oracle.com>, "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "ldufour@linux.vnet.ibm.com" <ldufour@linux.vnet.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mingo@kernel.org" <mingo@kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Thu, 2018-11-01 at 08:17 +0200, Mike Rapoport wrote:
> On Wed, Oct 31, 2018 at 03:40:02PM +0000, Pasha Tatashin wrote:
> > 
> > 
> > On 10/17/18 7:54 PM, Alexander Duyck wrote:
> > > This patch introduces a new iterator for_each_free_mem_pfn_range_in_zone.
> > > 
> > > This iterator will take care of making sure a given memory range provided
> > > is in fact contained within a zone. It takes are of all the bounds checking
> > > we were doing in deferred_grow_zone, and deferred_init_memmap. In addition
> > > it should help to speed up the search a bit by iterating until the end of a
> > > range is greater than the start of the zone pfn range, and will exit
> > > completely if the start is beyond the end of the zone.
> > > 
> > > This patch adds yet another iterator called
> > > for_each_free_mem_range_in_zone_from and then uses it to support
> > > initializing and freeing pages in groups no larger than MAX_ORDER_NR_PAGES.
> > > By doing this we can greatly improve the cache locality of the pages while
> > > we do several loops over them in the init and freeing process.
> > > 
> > > We are able to tighten the loops as a result since we only really need the
> > > checks for first_init_pfn in our first iteration and after that we can
> > > assume that all future values will be greater than this. So I have added a
> > > function called deferred_init_mem_pfn_range_in_zone that primes the
> > > iterators and if it fails we can just exit.
> > > 
> > > On my x86_64 test system with 384GB of memory per node I saw a reduction in
> > > initialization time from 1.85s to 1.38s as a result of this patch.
> > > 
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
>  
> [ ... ] 
> 
> > > ---
> > >  include/linux/memblock.h |   58 +++++++++++++++
> > >  mm/memblock.c            |   63 ++++++++++++++++
> > >  mm/page_alloc.c          |  176 ++++++++++++++++++++++++++++++++--------------
> > >  3 files changed, 242 insertions(+), 55 deletions(-)
> > > 
> > > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > > index aee299a6aa76..2ddd1bafdd03 100644
> > > --- a/include/linux/memblock.h
> > > +++ b/include/linux/memblock.h
> > > @@ -178,6 +178,25 @@ void __next_reserved_mem_region(u64 *idx, phys_addr_t *out_start,
> > >  			      p_start, p_end, p_nid))
> > >  
> > >  /**
> > > + * for_each_mem_range_from - iterate through memblock areas from type_a and not
> > > + * included in type_b. Or just type_a if type_b is NULL.
> > > + * @i: u64 used as loop variable
> > > + * @type_a: ptr to memblock_type to iterate
> > > + * @type_b: ptr to memblock_type which excludes from the iteration
> > > + * @nid: node selector, %NUMA_NO_NODE for all nodes
> > > + * @flags: pick from blocks based on memory attributes
> > > + * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
> > > + * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
> > > + * @p_nid: ptr to int for nid of the range, can be %NULL
> > > + */
> > > +#define for_each_mem_range_from(i, type_a, type_b, nid, flags,		\
> > > +			   p_start, p_end, p_nid)			\
> > > +	for (i = 0, __next_mem_range(&i, nid, flags, type_a, type_b,	\
> > > +				     p_start, p_end, p_nid);		\
> > > +	     i != (u64)ULLONG_MAX;					\
> > > +	     __next_mem_range(&i, nid, flags, type_a, type_b,		\
> > > +			      p_start, p_end, p_nid))
> > > +/**
> > >   * for_each_mem_range_rev - reverse iterate through memblock areas from
> > >   * type_a and not included in type_b. Or just type_a if type_b is NULL.
> > >   * @i: u64 used as loop variable
> > > @@ -248,6 +267,45 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
> > >  	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
> > >  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> > >  
> > > +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> 
> Sorry for jumping late, but I've noticed this only now.
> Do the new iterators have to be restricted by
> CONFIG_DEFERRED_STRUCT_PAGE_INIT?

They don't have to be. I just wrapped them since I figured it is better
to just strip the code if it isn't going to be used rather then leave
it floating around taking up space.

Thanks.

- Alex
