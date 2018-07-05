Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD1076B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 15:45:02 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q3-v6so5000814qki.4
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 12:45:02 -0700 (PDT)
Received: from mail.stoffel.org (mail.stoffel.org. [104.236.43.127])
        by mx.google.com with ESMTPS id n128-v6si3688848qkd.20.2018.07.05.12.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Jul 2018 12:45:00 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <23358.29981.262730.50194@quad.stoffel.home>
Date: Thu, 5 Jul 2018 15:44:29 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [dm-devel] [PATCH] mm: set PF_LESS_THROTTLE when allocating memory
	for i/o
In-Reply-To: <alpine.LRH.2.02.1807031837110.16609@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1807031837110.16609@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, linux-block@vger.kernel.org, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, mhocko@kernel.org, dm-devel@redhat.com, xia <jing.xia.mail@gmail.com>, "Alasdair G. Kergon" <agk@redhat.com>

>>>>> "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:

Mikulas> It has been noticed that congestion throttling can slow down
Mikulas> allocations path that participate in the IO and thus help the
Mikulas> memory reclaim.  Stalling those allocation is therefore not
Mikulas> productive. Moreover mempool allocator and md variants of the
Mikulas> same already implement their own throttling which has a
Mikulas> better way to be feedback driven. Stalling at the page
Mikulas> allocator is therefore even counterproductive.

Can you show numbers for this claim?  I would think that throttling
needs to be done as close to the disk as possible, and propogate back
up the layers to have this all work well, so that faster devices (and
the layers stacked on them) will work better without stalling on a
slow device.


Mikulas> PF_LESS_THROTTLE is a task flag denoting allocation context that is
Mikulas> participating in the memory reclaim which fits into these IO paths
Mikulas> model, so use the flag and make the page allocator aware they are
Mikulas> special and they do not really want any dirty data throttling.

Mikulas> The throttling causes stalls on Android - it uses the dm-verity driver 
Mikulas> that uses dm-bufio. Allocations in dm-bufio were observed to sleep in 
Mikulas> wait_iff_congested repeatedly.

Mikulas> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Mikulas> Acked-by: Michal Hocko <mhocko@suse.com> # mempool_alloc and bvec_alloc
Mikulas> Cc: stable@vger.kernel.org

Mikulas> ---
Mikulas>  block/bio.c                   |    4 ++++
Mikulas>  drivers/md/dm-bufio.c         |   14 +++++++++++---
Mikulas>  drivers/md/dm-crypt.c         |    8 ++++++++
Mikulas>  drivers/md/dm-integrity.c     |    4 ++++
Mikulas>  drivers/md/dm-kcopyd.c        |    3 +++
Mikulas>  drivers/md/dm-verity-target.c |    4 ++++
Mikulas>  drivers/md/dm-writecache.c    |    4 ++++
Mikulas>  mm/mempool.c                  |    4 ++++
Mikulas>  8 files changed, 42 insertions(+), 3 deletions(-)

Mikulas> Index: linux-2.6/mm/mempool.c
Mikulas> ===================================================================
Mikulas> --- linux-2.6.orig/mm/mempool.c	2018-06-29 03:47:16.290000000 +0200
Mikulas> +++ linux-2.6/mm/mempool.c	2018-06-29 03:47:16.270000000 +0200
Mikulas> @@ -369,6 +369,7 @@ void *mempool_alloc(mempool_t *pool, gfp
Mikulas>  	unsigned long flags;
Mikulas>  	wait_queue_entry_t wait;
Mikulas>  	gfp_t gfp_temp;
Mikulas> +	unsigned old_flags;
 
Mikulas>  	VM_WARN_ON_ONCE(gfp_mask & __GFP_ZERO);
Mikulas>  	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
Mikulas> @@ -381,7 +382,10 @@ void *mempool_alloc(mempool_t *pool, gfp
 
Mikulas>  repeat_alloc:
 
Mikulas> +	old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +	current->flags |= PF_LESS_THROTTLE;
Mikulas>  	element = pool->alloc(gfp_temp, pool->pool_data);
Mikulas> +	current_restore_flags(old_flags, PF_LESS_THROTTLE);
Mikulas>  	if (likely(element != NULL))
Mikulas>  		return element;
 
Mikulas> Index: linux-2.6/block/bio.c
Mikulas> ===================================================================
Mikulas> --- linux-2.6.orig/block/bio.c	2018-06-29 03:47:16.290000000 +0200
Mikulas> +++ linux-2.6/block/bio.c	2018-06-29 03:47:16.270000000 +0200
Mikulas> @@ -217,6 +217,7 @@ fallback:
Mikulas>  	} else {
Mikulas>  		struct biovec_slab *bvs = bvec_slabs + *idx;
Mikulas>  		gfp_t __gfp_mask = gfp_mask & ~(__GFP_DIRECT_RECLAIM | __GFP_IO);
Mikulas> +		unsigned old_flags;
 
Mikulas>  		/*
Mikulas>  		 * Make this allocation restricted and don't dump info on
Mikulas> @@ -229,7 +230,10 @@ fallback:
Mikulas>  		 * Try a slab allocation. If this fails and __GFP_DIRECT_RECLAIM
Mikulas>  		 * is set, retry with the 1-entry mempool
Mikulas>  		 */
Mikulas> +		old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +		current->flags |= PF_LESS_THROTTLE;
Mikulas>  		bvl = kmem_cache_alloc(bvs->slab, __gfp_mask);
Mikulas> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
Mikulas>  		if (unlikely(!bvl && (gfp_mask & __GFP_DIRECT_RECLAIM))) {
Mikulas>  			*idx = BVEC_POOL_MAX;
Mikulas>  			goto fallback;
Mikulas> Index: linux-2.6/drivers/md/dm-bufio.c
Mikulas> ===================================================================
Mikulas> --- linux-2.6.orig/drivers/md/dm-bufio.c	2018-06-29 03:47:16.290000000 +0200
Mikulas> +++ linux-2.6/drivers/md/dm-bufio.c	2018-06-29 03:47:16.270000000 +0200
Mikulas> @@ -356,6 +356,7 @@ static void __cache_size_refresh(void)
Mikulas>  static void *alloc_buffer_data(struct dm_bufio_client *c, gfp_t gfp_mask,
Mikulas>  			       unsigned char *data_mode)
Mikulas>  {
Mikulas> +	void *ptr;
Mikulas>  	if (unlikely(c->slab_cache != NULL)) {
Mikulas>  		*data_mode = DATA_MODE_SLAB;
Mikulas>  		return kmem_cache_alloc(c->slab_cache, gfp_mask);
Mikulas> @@ -363,9 +364,14 @@ static void *alloc_buffer_data(struct dm
 
Mikulas>  	if (c->block_size <= KMALLOC_MAX_SIZE &&
Mikulas>  	    gfp_mask & __GFP_NORETRY) {
Mikulas> +		unsigned old_flags;
Mikulas>  		*data_mode = DATA_MODE_GET_FREE_PAGES;
Mikulas> -		return (void *)__get_free_pages(gfp_mask,
Mikulas> +		old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +		current->flags |= PF_LESS_THROTTLE;
Mikulas> +		ptr = (void *)__get_free_pages(gfp_mask,
c-> sectors_per_block_bits - (PAGE_SHIFT - SECTOR_SHIFT));
Mikulas> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
Mikulas> +		return ptr;
Mikulas>  	}
 
Mikulas>  	*data_mode = DATA_MODE_VMALLOC;
Mikulas> @@ -381,8 +387,10 @@ static void *alloc_buffer_data(struct dm
Mikulas>  	 */
Mikulas>  	if (gfp_mask & __GFP_NORETRY) {
Mikulas>  		unsigned noio_flag = memalloc_noio_save();
Mikulas> -		void *ptr = __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
Mikulas> -
Mikulas> +		unsigned old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +		current->flags |= PF_LESS_THROTTLE;
Mikulas> +		ptr = __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
Mikulas> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
Mikulas>  		memalloc_noio_restore(noio_flag);
Mikulas>  		return ptr;
Mikulas>  	}
Mikulas> Index: linux-2.6/drivers/md/dm-integrity.c
Mikulas> ===================================================================
Mikulas> --- linux-2.6.orig/drivers/md/dm-integrity.c	2018-06-29 03:47:16.290000000 +0200
Mikulas> +++ linux-2.6/drivers/md/dm-integrity.c	2018-06-29 03:47:16.270000000 +0200
Mikulas> @@ -1318,6 +1318,7 @@ static void integrity_metadata(struct wo
Mikulas>  	int r;
 
Mikulas>  	if (ic->internal_hash) {
Mikulas> +		unsigned old_flags;
Mikulas>  		struct bvec_iter iter;
Mikulas>  		struct bio_vec bv;
Mikulas>  		unsigned digest_size = crypto_shash_digestsize(ic->internal_hash);
Mikulas> @@ -1331,8 +1332,11 @@ static void integrity_metadata(struct wo
Mikulas>  		if (unlikely(ic->mode == 'R'))
Mikulas>  			goto skip_io;
 
Mikulas> +		old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +		current->flags |= PF_LESS_THROTTLE;
Mikulas>  		checksums = kmalloc((PAGE_SIZE >> SECTOR_SHIFT >> ic->sb->log2_sectors_per_block) * ic->tag_size + extra_space,
Mikulas>  				    GFP_NOIO | __GFP_NORETRY | __GFP_NOWARN);
Mikulas> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
Mikulas>  		if (!checksums)
Mikulas>  			checksums = checksums_onstack;
 
Mikulas> Index: linux-2.6/drivers/md/dm-kcopyd.c
Mikulas> ===================================================================
Mikulas> --- linux-2.6.orig/drivers/md/dm-kcopyd.c	2018-06-29 03:47:16.290000000 +0200
Mikulas> +++ linux-2.6/drivers/md/dm-kcopyd.c	2018-06-29 03:47:16.270000000 +0200
Mikulas> @@ -245,7 +245,10 @@ static int kcopyd_get_pages(struct dm_kc
Mikulas>  	*pages = NULL;
 
Mikulas>  	do {
Mikulas> +		unsigned old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +		current->flags |= PF_LESS_THROTTLE;
Mikulas>  		pl = alloc_pl(__GFP_NOWARN | __GFP_NORETRY | __GFP_KSWAPD_RECLAIM);
Mikulas> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
Mikulas>  		if (unlikely(!pl)) {
Mikulas>  			/* Use reserved pages */
Mikulas>  			pl = kc->pages;
Mikulas> Index: linux-2.6/drivers/md/dm-verity-target.c
Mikulas> ===================================================================
Mikulas> --- linux-2.6.orig/drivers/md/dm-verity-target.c	2018-06-29 03:47:16.290000000 +0200
Mikulas> +++ linux-2.6/drivers/md/dm-verity-target.c	2018-06-29 03:47:16.280000000 +0200
Mikulas> @@ -596,9 +596,13 @@ no_prefetch_cluster:
Mikulas>  static void verity_submit_prefetch(struct dm_verity *v, struct dm_verity_io *io)
Mikulas>  {
Mikulas>  	struct dm_verity_prefetch_work *pw;
Mikulas> +	unsigned old_flags;
 
Mikulas> +	old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +	current->flags |= PF_LESS_THROTTLE;
Mikulas>  	pw = kmalloc(sizeof(struct dm_verity_prefetch_work),
Mikulas>  		GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN);
Mikulas> +	current_restore_flags(old_flags, PF_LESS_THROTTLE);
 
Mikulas>  	if (!pw)
Mikulas>  		return;
Mikulas> Index: linux-2.6/drivers/md/dm-writecache.c
Mikulas> ===================================================================
Mikulas> --- linux-2.6.orig/drivers/md/dm-writecache.c	2018-06-29 03:47:16.290000000 +0200
Mikulas> +++ linux-2.6/drivers/md/dm-writecache.c	2018-06-29 03:47:16.280000000 +0200
Mikulas> @@ -1473,6 +1473,7 @@ static void __writecache_writeback_pmem(
Mikulas>  	unsigned max_pages;
 
Mikulas>  	while (wbl->size) {
Mikulas> +		unsigned old_flags;
wbl-> size--;
Mikulas>  		e = container_of(wbl->list.prev, struct wc_entry, lru);
Mikulas>  		list_del(&e->lru);
Mikulas> @@ -1486,6 +1487,8 @@ static void __writecache_writeback_pmem(
Mikulas>  		bio_set_dev(&wb->bio, wc->dev->bdev);
wb-> bio.bi_iter.bi_sector = read_original_sector(wc, e);
wb-> page_offset = PAGE_SIZE;
Mikulas> +		old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +		current->flags |= PF_LESS_THROTTLE;
Mikulas>  		if (max_pages <= WB_LIST_INLINE ||
Mikulas>  		    unlikely(!(wb->wc_list = kmalloc(max_pages * sizeof(struct wc_entry *),
Mikulas>  						     GFP_NOIO | __GFP_NORETRY |
Mikulas> @@ -1493,6 +1496,7 @@ static void __writecache_writeback_pmem(
wb-> wc_list = wb->wc_list_inline;
Mikulas>  			max_pages = WB_LIST_INLINE;
Mikulas>  		}
Mikulas> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
 
Mikulas>  		BUG_ON(!wc_add_block(wb, e, GFP_NOIO));
 
Mikulas> Index: linux-2.6/drivers/md/dm-crypt.c
Mikulas> ===================================================================
Mikulas> --- linux-2.6.orig/drivers/md/dm-crypt.c	2018-06-29 03:47:16.290000000 +0200
Mikulas> +++ linux-2.6/drivers/md/dm-crypt.c	2018-06-29 03:47:16.280000000 +0200
Mikulas> @@ -2181,12 +2181,16 @@ static void *crypt_page_alloc(gfp_t gfp_
Mikulas>  {
Mikulas>  	struct crypt_config *cc = pool_data;
Mikulas>  	struct page *page;
Mikulas> +	unsigned old_flags;
 
Mikulas>  	if (unlikely(percpu_counter_compare(&cc->n_allocated_pages, dm_crypt_pages_per_client) >= 0) &&
Mikulas>  	    likely(gfp_mask & __GFP_NORETRY))
Mikulas>  		return NULL;
 
Mikulas> +	old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +	current->flags |= PF_LESS_THROTTLE;
Mikulas>  	page = alloc_page(gfp_mask);
Mikulas> +	current_restore_flags(old_flags, PF_LESS_THROTTLE);
Mikulas>  	if (likely(page != NULL))
Mikulas>  		percpu_counter_add(&cc->n_allocated_pages, 1);
 
Mikulas> @@ -2893,7 +2897,10 @@ static int crypt_map(struct dm_target *t
 
Mikulas>  	if (cc->on_disk_tag_size) {
Mikulas>  		unsigned tag_len = cc->on_disk_tag_size * (bio_sectors(bio) >> cc->sector_shift);
Mikulas> +		unsigned old_flags;
 
Mikulas> +		old_flags = current->flags & PF_LESS_THROTTLE;
Mikulas> +		current->flags |= PF_LESS_THROTTLE;
Mikulas>  		if (unlikely(tag_len > KMALLOC_MAX_SIZE) ||
Mikulas>  		    unlikely(!(io->integrity_metadata = kmalloc(tag_len,
Mikulas>  				GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN)))) {
Mikulas> @@ -2902,6 +2909,7 @@ static int crypt_map(struct dm_target *t
io-> integrity_metadata = mempool_alloc(&cc->tag_pool, GFP_NOIO);
io-> integrity_metadata_from_pool = true;
Mikulas>  		}
Mikulas> +		current_restore_flags(old_flags, PF_LESS_THROTTLE);
Mikulas>  	}
 
Mikulas>  	if (crypt_integrity_aead(cc))

Mikulas> --
Mikulas> dm-devel mailing list
Mikulas> dm-devel@redhat.com
Mikulas> https://www.redhat.com/mailman/listinfo/dm-devel
