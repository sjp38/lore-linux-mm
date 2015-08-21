Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 48D6E6B0038
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 09:42:26 -0400 (EDT)
Received: by wijp15 with SMTP id p15so20272856wij.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 06:42:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si14988764wju.16.2015.08.21.06.42.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Aug 2015 06:42:24 -0700 (PDT)
Subject: Re: [PATCH 06/10] mm: page_alloc: Distinguish between being unable to
 sleep, unwilling to unwilling and avoiding waking kswapd
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-7-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D72ABD.8020205@suse.cz>
Date: Fri, 21 Aug 2015 15:42:21 +0200
MIME-Version: 1.0
In-Reply-To: <1439376335-17895-7-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 08/12/2015 12:45 PM, Mel Gorman wrote:
> __GFP_WAIT has been used to identify atomic context in callers that hold
> spinlocks or are in interrupts. They are expected to be high priority and
> have access one of two watermarks lower than "min". __GFP_HIGH users get
> access to the first lower watermark and can be called the "high priority
> reserve". Atomic users and interrupts access yet another lower watermark
> that can be called the "atomic reserve".
>
> Over time, callers had a requirement to not block when fallback options
> were available. Some have abused __GFP_WAIT leading to a situation where
> an optimisitic allocation with a fallback option can access atomic reserves.
>
> This patch uses __GFP_ATOMIC to identify callers that are truely atomic,
> cannot sleep and have no alternative. High priority users continue to use
> __GFP_HIGH. __GFP_DIRECT_RECLAIM identifies callers that can sleep and are
> willing to enter direct reclaim. __GFP_KSWAPD_RECLAIM to identify callers
> that want to wake kswapd for background reclaim. __GFP_WAIT is redefined
> as a caller that is willing to enter direct reclaim and wake kswapd for
> background reclaim.
>
> This patch then converts a number of sites
>
> o __GFP_ATOMIC is used by callers that are high priority and have memory
>    pools for those requests. GFP_ATOMIC uses this flag. Callers with
>    interrupts disabled still automatically use the atomic reserves.

Hm I can't see where the latter happens? In gfp_to_alloc_flags(), 
ALLOC_HARDER is set for __GFP_ATOMIC, or rt-tasks *not* in interrupt? 
What am I missing?

> o Callers that have a limited mempool to guarantee forward progress use
>    __GFP_DIRECT_RECLAIM. bio allocations fall into this category where
>    kswapd will still be woken but atomic reserves are not used as there
>    is a one-entry mempool to guarantee progress.
>
> o Callers that are checking if they are non-blocking should use the
>    helper gfpflags_allows_blocking() where possible. This is because

A bit subjective but gfpflags_allow_blocking() sounds better to me.
Or shorter gfp_allows_blocking()?

>    checking for __GFP_WAIT as was done historically now can trigger false
>    positives. Some exceptions like dm-crypt.c exist where the code intent
>    is clearer if __GFP_DIRECT_RECLAIM is used instead of the helper due to
>    flag manipulations.
>
> The key hazard to watch out for is callers that removed __GFP_WAIT and
> was depending on access to atomic reserves for inconspicuous reasons.
> In some cases it may be appropriate for them to use __GFP_HIGH.

Hm we might also have a (non-fatal) hazard of callers that directly 
combined __GFP_* flags that didn't include __GFP_WAIT, but did wake up 
kswapd, and now might be missing __GFP_KSWAPD_RECLAIM. Did you try 
checking for those? I imagine it's not a simple task...

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

>
> diff --git a/Documentation/vm/balance b/Documentation/vm/balance
> index c46e68cf9344..6f1f6fae30f5 100644
> --- a/Documentation/vm/balance
> +++ b/Documentation/vm/balance
> @@ -1,12 +1,14 @@
>   Started Jan 2000 by Kanoj Sarcar <kanoj@sgi.com>
>
> -Memory balancing is needed for non __GFP_WAIT as well as for non
> -__GFP_IO allocations.
> +Memory balancing is needed for !__GFP_ATOMIC and !__GFP_KSWAPD_RECLAIM as
> +well as for non __GFP_IO allocations.
>
> -There are two reasons to be requesting non __GFP_WAIT allocations:
> -the caller can not sleep (typically intr context), or does not want
> -to incur cost overheads of page stealing and possible swap io for
> -whatever reasons.
> +The first reason why a caller may avoid reclaim is that the caller can not
> +sleep due to holding a spinlock or is in interrupt context. The second may
> +be that the caller is willing to fail the allocation without incurring the
> +overhead of page stealing. This may happen for opportunistic high-order

I think "page stealing" has nowadays a different meaning in the 
anti-fragmentation context? Should it just say "reclaim"?

> +allocation requests that have order-0 fallback options. In such cases,
> +the caller may also wish to avoid waking kswapd.
>
>   __GFP_IO allocation requests are made to prevent file system deadlocks.
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index cba12f34ff77..100d3fbaebae 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -650,7 +650,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>
>   	if (is_coherent || nommu())
>   		addr = __alloc_simple_buffer(dev, size, gfp, &page);
> -	else if (!(gfp & __GFP_WAIT))
> +	else if (gfp & __GFP_ATOMIC)
>   		addr = __alloc_from_pool(size, &page);
>   	else if (!dev_get_cma_area(dev))
>   		addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller, want_vaddr);
> @@ -1369,7 +1369,7 @@ static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
>   	*handle = DMA_ERROR_CODE;
>   	size = PAGE_ALIGN(size);
>
> -	if (!(gfp & __GFP_WAIT))
> +	if (gfp & __GFP_ATOMIC)
>   		return __iommu_alloc_atomic(dev, size, handle);
>
>   	/*
> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> index d16a1cead23f..713d963fb96b 100644
> --- a/arch/arm64/mm/dma-mapping.c
> +++ b/arch/arm64/mm/dma-mapping.c
> @@ -100,7 +100,7 @@ static void *__dma_alloc_coherent(struct device *dev, size_t size,
>   	if (IS_ENABLED(CONFIG_ZONE_DMA) &&
>   	    dev->coherent_dma_mask <= DMA_BIT_MASK(32))
>   		flags |= GFP_DMA;
> -	if (IS_ENABLED(CONFIG_DMA_CMA) && (flags & __GFP_WAIT)) {
> +	if (IS_ENABLED(CONFIG_DMA_CMA) && (flags & __GFP_DIRECT_RECLAIM)) {
>   		struct page *page;
>   		void *addr;
>
> @@ -147,7 +147,7 @@ static void *__dma_alloc(struct device *dev, size_t size,
>
>   	size = PAGE_ALIGN(size);
>
> -	if (!coherent && !(flags & __GFP_WAIT)) {
> +	if (!coherent && (flags & __GFP_ATOMIC)) {
>   		struct page *page = NULL;
>   		void *addr = __alloc_from_pool(size, &page, flags);
>

Hmm these change the lack of __GFP_WAIT to expect __GFP_ATOMIC, so it's 
potentially one of those "key hazards" mentioned in the changelog, 
right? But here it's not just about using atomic reserves, but using a 
completely different allocation function.
E.g. in case of arch/arm/mm/dma-mapping.c:__dma_alloc() I see it can go 
to __alloc_remap_buffer -> __dma_alloc_remap -> dma_common_contiguous_remap
which does kmalloc(..., GFP_KERNEL) and has comment "Cannot be used in 
non-sleeping contexts".

So I think callers that cannot sleep and did clear __GFP_WAIT before, 
are now dangerous unless they set __GFP_ATOMIC?

> diff --git a/drivers/firewire/core-cdev.c b/drivers/firewire/core-cdev.c
> index 2a3973a7c441..dc611c8cad10 100644
> --- a/drivers/firewire/core-cdev.c
> +++ b/drivers/firewire/core-cdev.c
> @@ -486,7 +486,7 @@ static int ioctl_get_info(struct client *client, union ioctl_arg *arg)
>   static int add_client_resource(struct client *client,
>   			       struct client_resource *resource, gfp_t gfp_mask)
>   {
> -	bool preload = !!(gfp_mask & __GFP_WAIT);
> +	bool preload = !!(gfp_mask & __GFP_DIRECT_RECLAIM);

Use the helper here to avoid !! as a bonus?

> --- a/drivers/infiniband/core/sa_query.c
> +++ b/drivers/infiniband/core/sa_query.c
> @@ -619,7 +619,7 @@ static void init_mad(struct ib_sa_mad *mad, struct ib_mad_agent *agent)
>
>   static int send_mad(struct ib_sa_query *query, int timeout_ms, gfp_t gfp_mask)
>   {
> -	bool preload = !!(gfp_mask & __GFP_WAIT);
> +	bool preload = !!(gfp_mask & __GFP_DIRECT_RECLAIM);
>   	unsigned long flags;
>   	int ret, id;
>

Same here.

> diff --git a/drivers/usb/host/u132-hcd.c b/drivers/usb/host/u132-hcd.c
> index d51687780b61..06badad3ab75 100644
> --- a/drivers/usb/host/u132-hcd.c
> +++ b/drivers/usb/host/u132-hcd.c
> @@ -2247,7 +2247,7 @@ static int u132_urb_enqueue(struct usb_hcd *hcd, struct urb *urb,
>   {
>   	struct u132 *u132 = hcd_to_u132(hcd);
>   	if (irqs_disabled()) {
> -		if (__GFP_WAIT & mem_flags) {
> +		if (__GFP_DIRECT_RECLAIM & mem_flags) {
>   			printk(KERN_ERR "invalid context for function that migh"
>   				"t sleep\n");
>   			return -EINVAL;

And here - no other flag manipulations and it would match the printk.
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -594,7 +594,7 @@ int clear_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>   	if (bits & (EXTENT_IOBITS | EXTENT_BOUNDARY))
>   		clear = 1;
>   again:
> -	if (!prealloc && (mask & __GFP_WAIT)) {
> +	if (!prealloc && (mask & __GFP_DIRECT_RECLAIM)) {
>   		/*
>   		 * Don't care for allocation failure here because we might end
>   		 * up not needing the pre-allocated extent state at all, which
> @@ -850,7 +850,7 @@ __set_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>
>   	bits |= EXTENT_FIRST_DELALLOC;
>   again:
> -	if (!prealloc && (mask & __GFP_WAIT)) {
> +	if (!prealloc && (mask & __GFP_DIRECT_RECLAIM)) {
>   		prealloc = alloc_extent_state(mask);
>   		BUG_ON(!prealloc);
>   	}
> @@ -1076,7 +1076,7 @@ int convert_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>   	btrfs_debug_check_extent_io_range(tree, start, end);
>
>   again:
> -	if (!prealloc && (mask & __GFP_WAIT)) {
> +	if (!prealloc && (mask & __GFP_DIRECT_RECLAIM)) {
>   		/*
>   		 * Best effort, don't worry if extent state allocation fails
>   		 * here for the first iteration. We might have a cached state
> @@ -4265,7 +4265,7 @@ int try_release_extent_mapping(struct extent_map_tree *map,
>   	u64 start = page_offset(page);
>   	u64 end = start + PAGE_CACHE_SIZE - 1;
>
> -	if ((mask & __GFP_WAIT) &&
> +	if ((mask & __GFP_DIRECT_RECLAIM) &&
>   	    page->mapping->host->i_size > 16 * 1024 * 1024) {
>   		u64 len;
>   		while (start <= end) {

Why not here as well.

> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -669,7 +669,7 @@ void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
>   	cpumask_var_t cpus;
>   	int cpu, ret;
>
> -	might_sleep_if(gfp_flags & __GFP_WAIT);
> +	might_sleep_if(gfp_flags & __GFP_DIRECT_RECLAIM);
>
>   	if (likely(zalloc_cpumask_var(&cpus, (gfp_flags|__GFP_NOWARN)))) {
>   		preempt_disable();
> diff --git a/lib/idr.c b/lib/idr.c
> index 5335c43adf46..e5118fc82961 100644
> --- a/lib/idr.c
> +++ b/lib/idr.c
> @@ -399,7 +399,7 @@ void idr_preload(gfp_t gfp_mask)
>   	 * allocation guarantee.  Disallow usage from those contexts.
>   	 */
>   	WARN_ON_ONCE(in_interrupt());
> -	might_sleep_if(gfp_mask & __GFP_WAIT);
> +	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
>
>   	preempt_disable();
>
> @@ -453,7 +453,7 @@ int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp_mask)
>   	struct idr_layer *pa[MAX_IDR_LEVEL + 1];
>   	int id;
>
> -	might_sleep_if(gfp_mask & __GFP_WAIT);
> +	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
>
>   	/* sanity checks */
>   	if (WARN_ON_ONCE(start < 0))
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index f9ebe1c82060..cc5fdc3fb734 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -188,7 +188,7 @@ radix_tree_node_alloc(struct radix_tree_root *root)
>   	 * preloading in the interrupt anyway as all the allocations have to
>   	 * be atomic. So just do normal allocation when in interrupt.
>   	 */
> -	if (!(gfp_mask & __GFP_WAIT) && !in_interrupt()) {
> +	if (!(gfp_mask & __GFP_DIRECT_RECLAIM) && !in_interrupt()) {
>   		struct radix_tree_preload *rtp;
>
>   		/*

These too?

> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index dac5bf59309d..2056d16807de 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -632,7 +632,7 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
>   {
>   	struct bdi_writeback *wb;
>
> -	might_sleep_if(gfp & __GFP_WAIT);
> +	might_sleep_if(gfp & __GFP_DIRECT_RECLAIM);
>
>   	if (!memcg_css->parent)
>   		return &bdi->wb;

ditto

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2143,7 +2143,7 @@ static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>   		return false;
>   	if (fail_page_alloc.ignore_gfp_highmem && (gfp_mask & __GFP_HIGHMEM))
>   		return false;
> -	if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & __GFP_WAIT))
> +	if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & (__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))

Should __GFP_ATOMIC really be here?

> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 197c3f59ecbf..c5fcdd6f85b7 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1588,7 +1588,7 @@ int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
>   /* Set an association id for a given association */
>   int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
>   {
> -	bool preload = !!(gfp & __GFP_WAIT);
> +	bool preload = !!(gfp & __GFP_DIRECT_RECLAIM);
>   	int ret;
>
>   	/* If the id is already assigned, keep it. */

helper?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
