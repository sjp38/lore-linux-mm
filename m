Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27E856B027E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 05:04:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w42-v6so16176500edd.0
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:04:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b12-v6si8456346edk.370.2018.10.17.02.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 02:04:10 -0700 (PDT)
Date: Wed, 17 Oct 2018 11:04:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm PATCH v3 2/6] mm: Drop meminit_pfn_in_nid as it is redundant
Message-ID: <20181017090407.GI18839@dhcp22.suse.cz>
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202703.2171.40829.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015202703.2171.40829.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Mon 15-10-18 13:27:03, Alexander Duyck wrote:
> As best as I can tell the meminit_pfn_in_nid call is completely redundant.
> The deferred memory initialization is already making use of
> for_each_free_mem_range which in turn will call into __next_mem_range which
> will only return a memory range if it matches the node ID provided assuming
> it is not NUMA_NO_NODE.
> 
> I am operating on the assumption that there are no zones or pgdata_t
> structures that have a NUMA node of NUMA_NO_NODE associated with them. If
> that is the case then __next_mem_range will never return a memory range
> that doesn't match the zone's node ID and as such the check is redundant.
> 
> So one piece I would like to verfy on this is if this works for ia64.
> Technically it was using a different approach to get the node ID, but it
> seems to have the node ID also encoded into the memblock. So I am
> assuming this is okay, but would like to get confirmation on that.

Good catch. Both for_each_free_mem_range and __early_pfn_to_nid rely on
the memblock layer to properly map ranges to nids. I haven't checked too
closely whether this was really necessary in the original deferred
implementatiob by Mel but it is much more clear that it is not needed
now with the clear iterator.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c |   50 ++++++++++++++------------------------------------
>  1 file changed, 14 insertions(+), 36 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4bd858d1c3ba..a766a15fad81 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1301,36 +1301,22 @@ int __meminit early_pfn_to_nid(unsigned long pfn)
>  #endif
>  
>  #ifdef CONFIG_NODES_SPAN_OTHER_NODES
> -static inline bool __meminit __maybe_unused
> -meminit_pfn_in_nid(unsigned long pfn, int node,
> -		   struct mminit_pfnnid_cache *state)
> +/* Only safe to use early in boot when initialisation is single-threaded */
> +static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
>  {
>  	int nid;
>  
> -	nid = __early_pfn_to_nid(pfn, state);
> +	nid = __early_pfn_to_nid(pfn, &early_pfnnid_cache);
>  	if (nid >= 0 && nid != node)
>  		return false;
>  	return true;
>  }
>  
> -/* Only safe to use early in boot when initialisation is single-threaded */
> -static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
> -{
> -	return meminit_pfn_in_nid(pfn, node, &early_pfnnid_cache);
> -}
> -
>  #else
> -
>  static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
>  {
>  	return true;
>  }
> -static inline bool __meminit  __maybe_unused
> -meminit_pfn_in_nid(unsigned long pfn, int node,
> -		   struct mminit_pfnnid_cache *state)
> -{
> -	return true;
> -}
>  #endif
>  
>  
> @@ -1459,21 +1445,13 @@ static inline void __init pgdat_init_report_one_done(void)
>   *
>   * Then, we check if a current large page is valid by only checking the validity
>   * of the head pfn.
> - *
> - * Finally, meminit_pfn_in_nid is checked on systems where pfns can interleave
> - * within a node: a pfn is between start and end of a node, but does not belong
> - * to this memory node.
>   */
> -static inline bool __init
> -deferred_pfn_valid(int nid, unsigned long pfn,
> -		   struct mminit_pfnnid_cache *nid_init_state)
> +static inline bool __init deferred_pfn_valid(unsigned long pfn)
>  {
>  	if (!pfn_valid_within(pfn))
>  		return false;
>  	if (!(pfn & (pageblock_nr_pages - 1)) && !pfn_valid(pfn))
>  		return false;
> -	if (!meminit_pfn_in_nid(pfn, nid, nid_init_state))
> -		return false;
>  	return true;
>  }
>  
> @@ -1481,15 +1459,14 @@ static inline void __init pgdat_init_report_one_done(void)
>   * Free pages to buddy allocator. Try to free aligned pages in
>   * pageblock_nr_pages sizes.
>   */
> -static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
> +static void __init deferred_free_pages(unsigned long pfn,
>  				       unsigned long end_pfn)
>  {
> -	struct mminit_pfnnid_cache nid_init_state = { };
>  	unsigned long nr_pgmask = pageblock_nr_pages - 1;
>  	unsigned long nr_free = 0;
>  
>  	for (; pfn < end_pfn; pfn++) {
> -		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
> +		if (!deferred_pfn_valid(pfn)) {
>  			deferred_free_range(pfn - nr_free, nr_free);
>  			nr_free = 0;
>  		} else if (!(pfn & nr_pgmask)) {
> @@ -1509,17 +1486,18 @@ static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
>   * by performing it only once every pageblock_nr_pages.
>   * Return number of pages initialized.
>   */
> -static unsigned long  __init deferred_init_pages(int nid, int zid,
> +static unsigned long  __init deferred_init_pages(struct zone *zone,
>  						 unsigned long pfn,
>  						 unsigned long end_pfn)
>  {
> -	struct mminit_pfnnid_cache nid_init_state = { };
>  	unsigned long nr_pgmask = pageblock_nr_pages - 1;
> +	int nid = zone_to_nid(zone);
>  	unsigned long nr_pages = 0;
> +	int zid = zone_idx(zone);
>  	struct page *page = NULL;
>  
>  	for (; pfn < end_pfn; pfn++) {
> -		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
> +		if (!deferred_pfn_valid(pfn)) {
>  			page = NULL;
>  			continue;
>  		} else if (!page || !(pfn & nr_pgmask)) {
> @@ -1582,12 +1560,12 @@ static int __init deferred_init_memmap(void *data)
>  	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
>  		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
>  		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> -		nr_pages += deferred_init_pages(nid, zid, spfn, epfn);
> +		nr_pages += deferred_init_pages(zone, spfn, epfn);
>  	}
>  	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
>  		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
>  		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> -		deferred_free_pages(nid, zid, spfn, epfn);
> +		deferred_free_pages(spfn, epfn);
>  	}
>  	pgdat_resize_unlock(pgdat, &flags);
>  
> @@ -1676,7 +1654,7 @@ static int __init deferred_init_memmap(void *data)
>  		while (spfn < epfn && nr_pages < nr_pages_needed) {
>  			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
>  			first_deferred_pfn = min(t, epfn);
> -			nr_pages += deferred_init_pages(nid, zid, spfn,
> +			nr_pages += deferred_init_pages(zone, spfn,
>  							first_deferred_pfn);
>  			spfn = first_deferred_pfn;
>  		}
> @@ -1688,7 +1666,7 @@ static int __init deferred_init_memmap(void *data)
>  	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
>  		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
>  		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
> -		deferred_free_pages(nid, zid, spfn, epfn);
> +		deferred_free_pages(spfn, epfn);
>  
>  		if (first_deferred_pfn == epfn)
>  			break;
> 

-- 
Michal Hocko
SUSE Labs
