Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52AF56B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 03:15:46 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so12532379wme.5
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 00:15:46 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id fq2si35633141wjb.119.2016.11.24.00.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 00:15:44 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAO8E2Lj068163
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 03:15:43 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26wt6u93es-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 03:15:43 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 24 Nov 2016 18:15:40 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 020923578057
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 19:15:37 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAO8Fa5849676412
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 19:15:36 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAO8FaHs001458
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 19:15:36 +1100
Subject: Re: [PATCH 2/5] mm: migrate: Change migrate_mode to support
 combination migration modes.
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-3-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 24 Nov 2016 13:45:33 +0530
MIME-Version: 1.0
In-Reply-To: <20161122162530.2370-3-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5836A1A5.8050102@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

On 11/22/2016 09:55 PM, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> From: Zi Yan <ziy@nvidia.com>
> 
> No functionality is changed.

The commit message need to contains more details like it changes
the enum declaration from numbers to bit positions, where all it
changes existing code like compaction and migration.

> 
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>

Like last patch please fix the author details and signed offs.

> ---
>  include/linux/migrate_mode.h |  6 +++---
>  mm/compaction.c              | 20 ++++++++++----------
>  mm/migrate.c                 | 14 +++++++-------
>  3 files changed, 20 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> index ebf3d89..0e2deb8 100644
> --- a/include/linux/migrate_mode.h
> +++ b/include/linux/migrate_mode.h
> @@ -8,9 +8,9 @@
>   * MIGRATE_SYNC will block when migrating pages
>   */
>  enum migrate_mode {
> -	MIGRATE_ASYNC,
> -	MIGRATE_SYNC_LIGHT,
> -	MIGRATE_SYNC,
> +	MIGRATE_ASYNC		= 1<<0,
> +	MIGRATE_SYNC_LIGHT	= 1<<1,
> +	MIGRATE_SYNC		= 1<<2,

Right, so that they can be ORed with each other.

>  };
> 
>  #endif		/* MIGRATE_MODE_H_INCLUDED */
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0409a4a..6606ded 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -296,7 +296,7 @@ static void update_pageblock_skip(struct compact_control *cc,
>  	if (migrate_scanner) {
>  		if (pfn > zone->compact_cached_migrate_pfn[0])
>  			zone->compact_cached_migrate_pfn[0] = pfn;
> -		if (cc->mode != MIGRATE_ASYNC &&
> +		if (!(cc->mode & MIGRATE_ASYNC) &&
>  		    pfn > zone->compact_cached_migrate_pfn[1])
>  			zone->compact_cached_migrate_pfn[1] = pfn;
>  	} else {
> @@ -329,7 +329,7 @@ static void update_pageblock_skip(struct compact_control *cc,
>  static bool compact_trylock_irqsave(spinlock_t *lock, unsigned long *flags,
>  						struct compact_control *cc)
>  {
> -	if (cc->mode == MIGRATE_ASYNC) {
> +	if (cc->mode & MIGRATE_ASYNC) {
>  		if (!spin_trylock_irqsave(lock, *flags)) {
>  			cc->contended = true;
>  			return false;
> @@ -370,7 +370,7 @@ static bool compact_unlock_should_abort(spinlock_t *lock,
>  	}
> 
>  	if (need_resched()) {
> -		if (cc->mode == MIGRATE_ASYNC) {
> +		if (cc->mode & MIGRATE_ASYNC) {
>  			cc->contended = true;
>  			return true;
>  		}
> @@ -393,7 +393,7 @@ static inline bool compact_should_abort(struct compact_control *cc)
>  {
>  	/* async compaction aborts if contended */
>  	if (need_resched()) {
> -		if (cc->mode == MIGRATE_ASYNC) {
> +		if (cc->mode & MIGRATE_ASYNC) {
>  			cc->contended = true;
>  			return true;
>  		}
> @@ -704,7 +704,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  	 */
>  	while (unlikely(too_many_isolated(zone))) {
>  		/* async migration should just abort */
> -		if (cc->mode == MIGRATE_ASYNC)
> +		if (cc->mode & MIGRATE_ASYNC)
>  			return 0;
> 
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -716,7 +716,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  	if (compact_should_abort(cc))
>  		return 0;
> 
> -	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC)) {
> +	if (cc->direct_compaction && (cc->mode & MIGRATE_ASYNC)) {
>  		skip_on_failure = true;
>  		next_skip_pfn = block_end_pfn(low_pfn, cc->order);
>  	}
> @@ -1204,7 +1204,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	struct page *page;
>  	const isolate_mode_t isolate_mode =
>  		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
> -		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
> +		(!(cc->mode & MIGRATE_SYNC) ? ISOLATE_ASYNC_MIGRATE : 0);
> 
>  	/*
>  	 * Start at where we last stopped, or beginning of the zone as
> @@ -1250,7 +1250,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  		 * Async compaction is optimistic to see if the minimum amount
>  		 * of work satisfies the allocation.
>  		 */
> -		if (cc->mode == MIGRATE_ASYNC &&
> +		if ((cc->mode & MIGRATE_ASYNC) &&
>  		    !migrate_async_suitable(get_pageblock_migratetype(page)))
>  			continue;
> 
> @@ -1493,7 +1493,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  	unsigned long start_pfn = zone->zone_start_pfn;
>  	unsigned long end_pfn = zone_end_pfn(zone);
>  	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
> -	const bool sync = cc->mode != MIGRATE_ASYNC;
> +	const bool sync = !(cc->mode & MIGRATE_ASYNC);
> 
>  	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
>  							cc->classzone_idx);
> @@ -1589,7 +1589,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  			 * order-aligned block, so skip the rest of it.
>  			 */
>  			if (cc->direct_compaction &&
> -						(cc->mode == MIGRATE_ASYNC)) {
> +						(cc->mode & MIGRATE_ASYNC)) {
>  				cc->migrate_pfn = block_end_pfn(
>  						cc->migrate_pfn - 1, cc->order);
>  				/* Draining pcplists is useless in this case */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index bc6c1c4..4a4cf48 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -394,7 +394,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
>  	struct buffer_head *bh = head;
> 
>  	/* Simple case, sync compaction */
> -	if (mode != MIGRATE_ASYNC) {
> +	if (!(mode & MIGRATE_ASYNC)) {
>  		do {
>  			get_bh(bh);
>  			lock_buffer(bh);
> @@ -495,7 +495,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	 * the mapping back due to an elevated page count, we would have to
>  	 * block waiting on other references to be dropped.
>  	 */
> -	if (mode == MIGRATE_ASYNC && head &&
> +	if ((mode & MIGRATE_ASYNC) && head &&
>  			!buffer_migrate_lock_buffers(head, mode)) {
>  		page_ref_unfreeze(page, expected_count);
>  		spin_unlock_irq(&mapping->tree_lock);
> @@ -779,7 +779,7 @@ int buffer_migrate_page(struct address_space *mapping,
>  	 * with an IRQ-safe spinlock held. In the sync case, the buffers
>  	 * need to be locked now
>  	 */
> -	if (mode != MIGRATE_ASYNC)
> +	if (!(mode & MIGRATE_ASYNC))
>  		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
> 
>  	ClearPagePrivate(page);
> @@ -861,7 +861,7 @@ static int fallback_migrate_page(struct address_space *mapping,
>  {
>  	if (PageDirty(page)) {
>  		/* Only writeback pages in full synchronous migration */
> -		if (mode != MIGRATE_SYNC)
> +		if (!(mode & MIGRATE_SYNC))
>  			return -EBUSY;
>  		return writeout(mapping, page);
>  	}
> @@ -970,7 +970,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  	bool is_lru = !__PageMovable(page);
> 
>  	if (!trylock_page(page)) {
> -		if (!force || mode == MIGRATE_ASYNC)
> +		if (!force || (mode & MIGRATE_ASYNC))
>  			goto out;
> 
>  		/*
> @@ -999,7 +999,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		 * the retry loop is too short and in the sync-light case,
>  		 * the overhead of stalling is too much
>  		 */
> -		if (mode != MIGRATE_SYNC) {
> +		if (!(mode & MIGRATE_SYNC)) {
>  			rc = -EBUSY;
>  			goto out_unlock;
>  		}
> @@ -1262,7 +1262,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  		return -ENOMEM;
> 
>  	if (!trylock_page(hpage)) {
> -		if (!force || mode != MIGRATE_SYNC)
> +		if (!force || !(mode & MIGRATE_SYNC))
>  			goto out;
>  		lock_page(hpage);
>  	}

So here are the conversions

(mode == MIGRATE_SYNC) ---> (mode & MIGRATE_SYNC)
(mode != MIGRATE_SYNC) ---> !(mode & MIGRATE_SYNC)

It should be okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
