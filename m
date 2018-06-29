Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 090FC6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 04:29:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u16-v6so4171517pfm.15
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 01:29:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p25-v6si8972539pfi.345.2018.06.29.01.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 01:29:21 -0700 (PDT)
Date: Fri, 29 Jun 2018 10:29:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
Message-ID: <20180629082912.GC13860@dhcp22.suse.cz>
References: <20180622090935.GT10465@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806220845190.8072@file01.intranet.prod.int.rdu2.redhat.com>
 <20180622130524.GZ10465@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806221447050.2717@file01.intranet.prod.int.rdu2.redhat.com>
 <20180625090957.GF28965@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806250941380.11092@file01.intranet.prod.int.rdu2.redhat.com>
 <20180625141434.GO28965@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806251037250.17405@file01.intranet.prod.int.rdu2.redhat.com>
 <20180625145733.GP28965@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806282150310.7845@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1806282150310.7845@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 28-06-18 22:43:29, Mikulas Patocka wrote:
> 
> 
> On Mon, 25 Jun 2018, Michal Hocko wrote:
> 
> > On Mon 25-06-18 10:42:30, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Mon, 25 Jun 2018, Michal Hocko wrote:
> > > 
> > > > > And the throttling in dm-bufio prevents kswapd from making forward 
> > > > > progress, causing this situation...
> > > > 
> > > > Which is what we have PF_THROTTLE_LESS for. Geez, do we have to go in
> > > > circles like that? Are you even listening?
> > > > 
> > > > [...]
> > > > 
> > > > > And so what do you want to do to prevent block drivers from sleeping?
> > > > 
> > > > use the existing means we have.
> > > > -- 
> > > > Michal Hocko
> > > > SUSE Labs
> > > 
> > > So - do you want this patch?
> > > 
> > > There is no behavior difference between changing the allocator (so that it 
> > > implies PF_THROTTLE_LESS for block drivers) and chaning all the block 
> > > drivers to explicitly set PF_THROTTLE_LESS.
> > 
> > As long as you can reliably detect those users. And using gfp_mask is
> 
> You can detect them if __GFP_IO is not set and __GFP_NORETRY is set. You 
> can grep the kernel for __GFP_NORETRY to find all the users.

It seems that arguing doesn't make much sense here. I will not repeat
myself...

> > about the worst way to achieve that because users tend to be creative
> > when it comes to using gfp mask. PF_THROTTLE_LESS in general is a
> > way to tell the allocator that _you_ are the one to help the reclaim by
> > cleaning data.
> 
> But using PF_LESS_THROTTLE explicitly adds more lines of code than 
> implying PF_LESS_THROTTLE in the allocator.

Yes and it will also make the code more explicit about the intention and
so it will be easier to maintain longterm.

> From: Mikulas Patocka <mpatocka@redhat.com>
> Subject: [PATCH] mm: set PF_LESS_THROTTLE when allocating memory for i/o
> 
> When doing __GFP_NORETRY allocation, the system may sleep in
> wait_iff_congested if there are too many dirty pages. Unfortunatelly this
> sleeping may slow down kswapd, preventing it from doing writeback and
> resolving the congestion.

This description is misleading at best if not outright wrong.
		if (!sc->hibernation_mode && !current_is_kswapd() &&
		   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
			wait_iff_congested(BLK_RW_ASYNC, HZ/10);

so this is an explict throttling of the direct reclaim.

So I would use the following wording instead:
"
It has been noticed that congestion throttling can slow down allocations
path that participate in the IO and thus help the memory reclaim.
Stalling those allocation is therefore not productive. Moreover mempool
allocator and md variants of the same already implement their own
throttling which has a better way to be feedback driven. Stalling at the
page allocator is therefore even counterproductive.

PF_LESS_THROTTLE is a task flag denoting allocation context that is
participating in the memory reclaim which fits into these IO paths
model, so use the flag and make the page allocator aware they are
special and they do not really want any dirty data throttling.

<HERE GOES YOUR STORAGE CONFIGURATION AND DATA ABOUT STALLS>
"

with a more clear patch description and some data to back them up, you
can add

Acked-by: Michal Hocko <mhocko@suse.com> # mempool_alloc and bvec_alloc

I cannot really comment on other md allocators though because I am not
familiar with those. 

> This patch fixes it by setting PF_LESS_THROTTLE when allocating memory for
> block device drivers.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Cc: stable@vger.kernel.org
> 
> ---
>  block/bio.c                   |    4 ++++
>  drivers/md/dm-bufio.c         |   14 +++++++++++---
>  drivers/md/dm-crypt.c         |    8 ++++++++
>  drivers/md/dm-integrity.c     |    4 ++++
>  drivers/md/dm-kcopyd.c        |    3 +++
>  drivers/md/dm-verity-target.c |    4 ++++
>  drivers/md/dm-writecache.c    |    4 ++++
>  mm/mempool.c                  |    4 ++++
>  8 files changed, 42 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/mm/mempool.c
> ===================================================================
> --- linux-2.6.orig/mm/mempool.c	2018-06-29 03:47:16.290000000 +0200
> +++ linux-2.6/mm/mempool.c	2018-06-29 03:47:16.270000000 +0200
> @@ -369,6 +369,7 @@ void *mempool_alloc(mempool_t *pool, gfp
>  	unsigned long flags;
>  	wait_queue_entry_t wait;
>  	gfp_t gfp_temp;
> +	unsigned old_flags;
>  
>  	VM_WARN_ON_ONCE(gfp_mask & __GFP_ZERO);
>  	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
> @@ -381,7 +382,10 @@ void *mempool_alloc(mempool_t *pool, gfp
>  
>  repeat_alloc:
>  
> +	old_flags = current->flags & PF_LESS_THROTTLE;
> +	current->flags |= PF_LESS_THROTTLE;
>  	element = pool->alloc(gfp_temp, pool->pool_data);
> +	current_restore_flags(old_flags, PF_LESS_THROTTLE);
>  	if (likely(element != NULL))
>  		return element;
>  
> Index: linux-2.6/block/bio.c
> ===================================================================
> --- linux-2.6.orig/block/bio.c	2018-06-29 03:47:16.290000000 +0200
> +++ linux-2.6/block/bio.c	2018-06-29 03:47:16.270000000 +0200
> @@ -217,6 +217,7 @@ fallback:
>  	} else {
>  		struct biovec_slab *bvs = bvec_slabs + *idx;
>  		gfp_t __gfp_mask = gfp_mask & ~(__GFP_DIRECT_RECLAIM | __GFP_IO);
> +		unsigned old_flags;
>  
>  		/*
>  		 * Make this allocation restricted and don't dump info on
> @@ -229,7 +230,10 @@ fallback:
>  		 * Try a slab allocation. If this fails and __GFP_DIRECT_RECLAIM
>  		 * is set, retry with the 1-entry mempool
>  		 */
> +		old_flags = current->flags & PF_LESS_THROTTLE;
> +		current->flags |= PF_LESS_THROTTLE;
>  		bvl = kmem_cache_alloc(bvs->slab, __gfp_mask);
> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
>  		if (unlikely(!bvl && (gfp_mask & __GFP_DIRECT_RECLAIM))) {
>  			*idx = BVEC_POOL_MAX;
>  			goto fallback;
> Index: linux-2.6/drivers/md/dm-bufio.c
> ===================================================================
> --- linux-2.6.orig/drivers/md/dm-bufio.c	2018-06-29 03:47:16.290000000 +0200
> +++ linux-2.6/drivers/md/dm-bufio.c	2018-06-29 03:47:16.270000000 +0200
> @@ -356,6 +356,7 @@ static void __cache_size_refresh(void)
>  static void *alloc_buffer_data(struct dm_bufio_client *c, gfp_t gfp_mask,
>  			       unsigned char *data_mode)
>  {
> +	void *ptr;
>  	if (unlikely(c->slab_cache != NULL)) {
>  		*data_mode = DATA_MODE_SLAB;
>  		return kmem_cache_alloc(c->slab_cache, gfp_mask);
> @@ -363,9 +364,14 @@ static void *alloc_buffer_data(struct dm
>  
>  	if (c->block_size <= KMALLOC_MAX_SIZE &&
>  	    gfp_mask & __GFP_NORETRY) {
> +		unsigned old_flags;
>  		*data_mode = DATA_MODE_GET_FREE_PAGES;
> -		return (void *)__get_free_pages(gfp_mask,
> +		old_flags = current->flags & PF_LESS_THROTTLE;
> +		current->flags |= PF_LESS_THROTTLE;
> +		ptr = (void *)__get_free_pages(gfp_mask,
>  						c->sectors_per_block_bits - (PAGE_SHIFT - SECTOR_SHIFT));
> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
> +		return ptr;
>  	}
>  
>  	*data_mode = DATA_MODE_VMALLOC;
> @@ -381,8 +387,10 @@ static void *alloc_buffer_data(struct dm
>  	 */
>  	if (gfp_mask & __GFP_NORETRY) {
>  		unsigned noio_flag = memalloc_noio_save();
> -		void *ptr = __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
> -
> +		unsigned old_flags = current->flags & PF_LESS_THROTTLE;
> +		current->flags |= PF_LESS_THROTTLE;
> +		ptr = __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
>  		memalloc_noio_restore(noio_flag);
>  		return ptr;
>  	}
> Index: linux-2.6/drivers/md/dm-integrity.c
> ===================================================================
> --- linux-2.6.orig/drivers/md/dm-integrity.c	2018-06-29 03:47:16.290000000 +0200
> +++ linux-2.6/drivers/md/dm-integrity.c	2018-06-29 03:47:16.270000000 +0200
> @@ -1318,6 +1318,7 @@ static void integrity_metadata(struct wo
>  	int r;
>  
>  	if (ic->internal_hash) {
> +		unsigned old_flags;
>  		struct bvec_iter iter;
>  		struct bio_vec bv;
>  		unsigned digest_size = crypto_shash_digestsize(ic->internal_hash);
> @@ -1331,8 +1332,11 @@ static void integrity_metadata(struct wo
>  		if (unlikely(ic->mode == 'R'))
>  			goto skip_io;
>  
> +		old_flags = current->flags & PF_LESS_THROTTLE;
> +		current->flags |= PF_LESS_THROTTLE;
>  		checksums = kmalloc((PAGE_SIZE >> SECTOR_SHIFT >> ic->sb->log2_sectors_per_block) * ic->tag_size + extra_space,
>  				    GFP_NOIO | __GFP_NORETRY | __GFP_NOWARN);
> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
>  		if (!checksums)
>  			checksums = checksums_onstack;
>  
> Index: linux-2.6/drivers/md/dm-kcopyd.c
> ===================================================================
> --- linux-2.6.orig/drivers/md/dm-kcopyd.c	2018-06-29 03:47:16.290000000 +0200
> +++ linux-2.6/drivers/md/dm-kcopyd.c	2018-06-29 03:47:16.270000000 +0200
> @@ -245,7 +245,10 @@ static int kcopyd_get_pages(struct dm_kc
>  	*pages = NULL;
>  
>  	do {
> +		unsigned old_flags = current->flags & PF_LESS_THROTTLE;
> +		current->flags |= PF_LESS_THROTTLE;
>  		pl = alloc_pl(__GFP_NOWARN | __GFP_NORETRY | __GFP_KSWAPD_RECLAIM);
> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
>  		if (unlikely(!pl)) {
>  			/* Use reserved pages */
>  			pl = kc->pages;
> Index: linux-2.6/drivers/md/dm-verity-target.c
> ===================================================================
> --- linux-2.6.orig/drivers/md/dm-verity-target.c	2018-06-29 03:47:16.290000000 +0200
> +++ linux-2.6/drivers/md/dm-verity-target.c	2018-06-29 03:47:16.280000000 +0200
> @@ -596,9 +596,13 @@ no_prefetch_cluster:
>  static void verity_submit_prefetch(struct dm_verity *v, struct dm_verity_io *io)
>  {
>  	struct dm_verity_prefetch_work *pw;
> +	unsigned old_flags;
>  
> +	old_flags = current->flags & PF_LESS_THROTTLE;
> +	current->flags |= PF_LESS_THROTTLE;
>  	pw = kmalloc(sizeof(struct dm_verity_prefetch_work),
>  		GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN);
> +	current_restore_flags(old_flags, PF_LESS_THROTTLE);
>  
>  	if (!pw)
>  		return;
> Index: linux-2.6/drivers/md/dm-writecache.c
> ===================================================================
> --- linux-2.6.orig/drivers/md/dm-writecache.c	2018-06-29 03:47:16.290000000 +0200
> +++ linux-2.6/drivers/md/dm-writecache.c	2018-06-29 03:47:16.280000000 +0200
> @@ -1473,6 +1473,7 @@ static void __writecache_writeback_pmem(
>  	unsigned max_pages;
>  
>  	while (wbl->size) {
> +		unsigned old_flags;
>  		wbl->size--;
>  		e = container_of(wbl->list.prev, struct wc_entry, lru);
>  		list_del(&e->lru);
> @@ -1486,6 +1487,8 @@ static void __writecache_writeback_pmem(
>  		bio_set_dev(&wb->bio, wc->dev->bdev);
>  		wb->bio.bi_iter.bi_sector = read_original_sector(wc, e);
>  		wb->page_offset = PAGE_SIZE;
> +		old_flags = current->flags & PF_LESS_THROTTLE;
> +		current->flags |= PF_LESS_THROTTLE;
>  		if (max_pages <= WB_LIST_INLINE ||
>  		    unlikely(!(wb->wc_list = kmalloc(max_pages * sizeof(struct wc_entry *),
>  						     GFP_NOIO | __GFP_NORETRY |
> @@ -1493,6 +1496,7 @@ static void __writecache_writeback_pmem(
>  			wb->wc_list = wb->wc_list_inline;
>  			max_pages = WB_LIST_INLINE;
>  		}
> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
>  
>  		BUG_ON(!wc_add_block(wb, e, GFP_NOIO));
>  
> Index: linux-2.6/drivers/md/dm-crypt.c
> ===================================================================
> --- linux-2.6.orig/drivers/md/dm-crypt.c	2018-06-29 03:47:16.290000000 +0200
> +++ linux-2.6/drivers/md/dm-crypt.c	2018-06-29 03:47:16.280000000 +0200
> @@ -2181,12 +2181,16 @@ static void *crypt_page_alloc(gfp_t gfp_
>  {
>  	struct crypt_config *cc = pool_data;
>  	struct page *page;
> +	unsigned old_flags;
>  
>  	if (unlikely(percpu_counter_compare(&cc->n_allocated_pages, dm_crypt_pages_per_client) >= 0) &&
>  	    likely(gfp_mask & __GFP_NORETRY))
>  		return NULL;
>  
> +	old_flags = current->flags & PF_LESS_THROTTLE;
> +	current->flags |= PF_LESS_THROTTLE;
>  	page = alloc_page(gfp_mask);
> +	current_restore_flags(old_flags, PF_LESS_THROTTLE);
>  	if (likely(page != NULL))
>  		percpu_counter_add(&cc->n_allocated_pages, 1);
>  
> @@ -2893,7 +2897,10 @@ static int crypt_map(struct dm_target *t
>  
>  	if (cc->on_disk_tag_size) {
>  		unsigned tag_len = cc->on_disk_tag_size * (bio_sectors(bio) >> cc->sector_shift);
> +		unsigned old_flags;
>  
> +		old_flags = current->flags & PF_LESS_THROTTLE;
> +		current->flags |= PF_LESS_THROTTLE;
>  		if (unlikely(tag_len > KMALLOC_MAX_SIZE) ||
>  		    unlikely(!(io->integrity_metadata = kmalloc(tag_len,
>  				GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN)))) {
> @@ -2902,6 +2909,7 @@ static int crypt_map(struct dm_target *t
>  			io->integrity_metadata = mempool_alloc(&cc->tag_pool, GFP_NOIO);
>  			io->integrity_metadata_from_pool = true;
>  		}
> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
>  	}
>  
>  	if (crypt_integrity_aead(cc))

-- 
Michal Hocko
SUSE Labs
