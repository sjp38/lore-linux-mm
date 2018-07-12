Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6861C6B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 04:00:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t11-v6so10985972edq.1
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 01:00:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2-v6si1338069edi.372.2018.07.12.01.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 01:00:07 -0700 (PDT)
Date: Thu, 12 Jul 2018 10:00:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 06/11] mm/memblock: add a name for memblock flags
 enumeration
Message-ID: <20180712080006.GA328@dhcp22.suse.cz>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530370506-21751-7-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530370506-21751-7-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Sat 30-06-18 17:55:01, Mike Rapoport wrote:
> Since kernel-doc does not like anonymous enums the name is required for
> adding documentation. While on it, I've also updated all the function
> declarations to use 'enum memblock_flags' instead of unsigned long.

memblock_flags doesn't tell me much about the purpose of these flags. We
could bikeshed about the name but let's keep it this way. I do not have
good tip for nice name either.

I haven't checked whether all places have been updated (the memblock api
is quite large) but this changes makes perfect sense to me. Unsigned
long is just improper type for something like this.

> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  include/linux/memblock.h | 22 +++++++++++-----------
>  mm/memblock.c            | 37 +++++++++++++++++++++----------------
>  mm/nobootmem.c           |  2 +-
>  3 files changed, 33 insertions(+), 28 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index ca59883..8b8fbce 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -21,7 +21,7 @@
>  #define INIT_PHYSMEM_REGIONS	4
>  
>  /* Definition of memblock flags. */
> -enum {
> +enum memblock_flags {
>  	MEMBLOCK_NONE		= 0x0,	/* No special request */
>  	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
>  	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
> @@ -31,7 +31,7 @@ enum {
>  struct memblock_region {
>  	phys_addr_t base;
>  	phys_addr_t size;
> -	unsigned long flags;
> +	enum memblock_flags flags;
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  	int nid;
>  #endif
> @@ -72,7 +72,7 @@ void memblock_discard(void);
>  
>  phys_addr_t memblock_find_in_range_node(phys_addr_t size, phys_addr_t align,
>  					phys_addr_t start, phys_addr_t end,
> -					int nid, ulong flags);
> +					int nid, enum memblock_flags flags);
>  phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
>  				   phys_addr_t size, phys_addr_t align);
>  void memblock_allow_resize(void);
> @@ -89,19 +89,19 @@ int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
>  int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
> -ulong choose_memblock_flags(void);
> +enum memblock_flags choose_memblock_flags(void);
>  
>  /* Low level functions */
>  int memblock_add_range(struct memblock_type *type,
>  		       phys_addr_t base, phys_addr_t size,
> -		       int nid, unsigned long flags);
> +		       int nid, enum memblock_flags flags);
>  
> -void __next_mem_range(u64 *idx, int nid, ulong flags,
> +void __next_mem_range(u64 *idx, int nid, enum memblock_flags flags,
>  		      struct memblock_type *type_a,
>  		      struct memblock_type *type_b, phys_addr_t *out_start,
>  		      phys_addr_t *out_end, int *out_nid);
>  
> -void __next_mem_range_rev(u64 *idx, int nid, ulong flags,
> +void __next_mem_range_rev(u64 *idx, int nid, enum memblock_flags flags,
>  			  struct memblock_type *type_a,
>  			  struct memblock_type *type_b, phys_addr_t *out_start,
>  			  phys_addr_t *out_end, int *out_nid);
> @@ -253,13 +253,13 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
>  			   NUMA_NO_NODE, MEMBLOCK_NONE, p_start, p_end, NULL)
>  
>  static inline void memblock_set_region_flags(struct memblock_region *r,
> -					     unsigned long flags)
> +					     enum memblock_flags flags)
>  {
>  	r->flags |= flags;
>  }
>  
>  static inline void memblock_clear_region_flags(struct memblock_region *r,
> -					       unsigned long flags)
> +					       enum memblock_flags flags)
>  {
>  	r->flags &= ~flags;
>  }
> @@ -317,10 +317,10 @@ static inline bool memblock_bottom_up(void)
>  
>  phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
>  					phys_addr_t start, phys_addr_t end,
> -					ulong flags);
> +					enum memblock_flags flags);
>  phys_addr_t memblock_alloc_base_nid(phys_addr_t size,
>  					phys_addr_t align, phys_addr_t max_addr,
> -					int nid, ulong flags);
> +					int nid, enum memblock_flags flags);
>  phys_addr_t memblock_alloc_base(phys_addr_t size, phys_addr_t align,
>  				phys_addr_t max_addr);
>  phys_addr_t __memblock_alloc_base(phys_addr_t size, phys_addr_t align,
> diff --git a/mm/memblock.c b/mm/memblock.c
> index cc16d70..4f5aecb 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -61,7 +61,7 @@ static int memblock_can_resize __initdata_memblock;
>  static int memblock_memory_in_slab __initdata_memblock = 0;
>  static int memblock_reserved_in_slab __initdata_memblock = 0;
>  
> -ulong __init_memblock choose_memblock_flags(void)
> +enum memblock_flags __init_memblock choose_memblock_flags(void)
>  {
>  	return system_has_some_mirror ? MEMBLOCK_MIRROR : MEMBLOCK_NONE;
>  }
> @@ -110,7 +110,7 @@ bool __init_memblock memblock_overlaps_region(struct memblock_type *type,
>  static phys_addr_t __init_memblock
>  __memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
>  				phys_addr_t size, phys_addr_t align, int nid,
> -				ulong flags)
> +				enum memblock_flags flags)
>  {
>  	phys_addr_t this_start, this_end, cand;
>  	u64 i;
> @@ -144,7 +144,7 @@ __memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
>  static phys_addr_t __init_memblock
>  __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
>  			       phys_addr_t size, phys_addr_t align, int nid,
> -			       ulong flags)
> +			       enum memblock_flags flags)
>  {
>  	phys_addr_t this_start, this_end, cand;
>  	u64 i;
> @@ -189,7 +189,8 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
>   */
>  phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
>  					phys_addr_t align, phys_addr_t start,
> -					phys_addr_t end, int nid, ulong flags)
> +					phys_addr_t end, int nid,
> +					enum memblock_flags flags)
>  {
>  	phys_addr_t kernel_end, ret;
>  
> @@ -252,7 +253,7 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
>  					phys_addr_t align)
>  {
>  	phys_addr_t ret;
> -	ulong flags = choose_memblock_flags();
> +	enum memblock_flags flags = choose_memblock_flags();
>  
>  again:
>  	ret = memblock_find_in_range_node(size, align, start, end,
> @@ -473,7 +474,8 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
>  static void __init_memblock memblock_insert_region(struct memblock_type *type,
>  						   int idx, phys_addr_t base,
>  						   phys_addr_t size,
> -						   int nid, unsigned long flags)
> +						   int nid,
> +						   enum memblock_flags flags)
>  {
>  	struct memblock_region *rgn = &type->regions[idx];
>  
> @@ -505,7 +507,7 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
>   */
>  int __init_memblock memblock_add_range(struct memblock_type *type,
>  				phys_addr_t base, phys_addr_t size,
> -				int nid, unsigned long flags)
> +				int nid, enum memblock_flags flags)
>  {
>  	bool insert = false;
>  	phys_addr_t obase = base;
> @@ -874,7 +876,8 @@ void __init_memblock __next_reserved_mem_region(u64 *idx,
>   * As both region arrays are sorted, the function advances the two indices
>   * in lockstep and returns each intersection.
>   */
> -void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
> +void __init_memblock __next_mem_range(u64 *idx, int nid,
> +				      enum memblock_flags flags,
>  				      struct memblock_type *type_a,
>  				      struct memblock_type *type_b,
>  				      phys_addr_t *out_start,
> @@ -983,7 +986,8 @@ void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
>   *
>   * Reverse of __next_mem_range().
>   */
> -void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
> +void __init_memblock __next_mem_range_rev(u64 *idx, int nid,
> +					  enum memblock_flags flags,
>  					  struct memblock_type *type_a,
>  					  struct memblock_type *type_b,
>  					  phys_addr_t *out_start,
> @@ -1141,7 +1145,8 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>  
>  static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
>  					phys_addr_t align, phys_addr_t start,
> -					phys_addr_t end, int nid, ulong flags)
> +					phys_addr_t end, int nid,
> +					enum memblock_flags flags)
>  {
>  	phys_addr_t found;
>  
> @@ -1163,7 +1168,7 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
>  
>  phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
>  					phys_addr_t start, phys_addr_t end,
> -					ulong flags)
> +					enum memblock_flags flags)
>  {
>  	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE,
>  					flags);
> @@ -1171,14 +1176,14 @@ phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
>  
>  phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
>  					phys_addr_t align, phys_addr_t max_addr,
> -					int nid, ulong flags)
> +					int nid, enum memblock_flags flags)
>  {
>  	return memblock_alloc_range_nid(size, align, 0, max_addr, nid, flags);
>  }
>  
>  phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
>  {
> -	ulong flags = choose_memblock_flags();
> +	enum memblock_flags flags = choose_memblock_flags();
>  	phys_addr_t ret;
>  
>  again:
> @@ -1259,7 +1264,7 @@ static void * __init memblock_virt_alloc_internal(
>  {
>  	phys_addr_t alloc;
>  	void *ptr;
> -	ulong flags = choose_memblock_flags();
> +	enum memblock_flags flags = choose_memblock_flags();
>  
>  	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
>  		nid = NUMA_NO_NODE;
> @@ -1734,7 +1739,7 @@ phys_addr_t __init_memblock memblock_get_current_limit(void)
>  static void __init_memblock memblock_dump(struct memblock_type *type)
>  {
>  	phys_addr_t base, end, size;
> -	unsigned long flags;
> +	enum memblock_flags flags;
>  	int idx;
>  	struct memblock_region *rgn;
>  
> @@ -1752,7 +1757,7 @@ static void __init_memblock memblock_dump(struct memblock_type *type)
>  			snprintf(nid_buf, sizeof(nid_buf), " on node %d",
>  				 memblock_get_region_node(rgn));
>  #endif
> -		pr_info(" %s[%#x]\t[%pa-%pa], %pa bytes%s flags: %#lx\n",
> +		pr_info(" %s[%#x]\t[%pa-%pa], %pa bytes%s flags: %#x\n",
>  			type->name, idx, &base, &end, &size, nid_buf, flags);
>  	}
>  }
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index c2cfa04..439af3b 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -42,7 +42,7 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
>  {
>  	void *ptr;
>  	u64 addr;
> -	ulong flags = choose_memblock_flags();
> +	enum memblock_flags flags = choose_memblock_flags();
>  
>  	if (limit > memblock.current_limit)
>  		limit = memblock.current_limit;
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
