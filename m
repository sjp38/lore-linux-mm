Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C1E516B0036
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 18:32:23 -0400 (EDT)
Date: Tue, 12 Mar 2013 15:32:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bounce:fix bug, avoid to flush dcache on slab page from
 jbd2.
Message-Id: <20130312153221.0d26fe5599d4885e51bb0c7c@linux-foundation.org>
In-Reply-To: <5139DB90.5090302@gmail.com>
References: <5139DB90.5090302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuge <shugelinux@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Kevin <kevin@allwinneretch.com>, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, "Darrick J. Wong" <darrick.wong@oracle.com>

On Fri, 08 Mar 2013 20:37:36 +0800 Shuge <shugelinux@gmail.com> wrote:

> The bounce accept slab pages from jbd2, and flush dcache on them.
> When enabling VM_DEBUG, it will tigger VM_BUG_ON in page_mapping().
> So, check PageSlab to avoid it in __blk_queue_bounce().
> 
> Bug URL: http://lkml.org/lkml/2013/3/7/56
> 
> ...
>
> --- a/mm/bounce.c
> +++ b/mm/bounce.c
> @@ -214,7 +214,8 @@ static void __blk_queue_bounce(struct request_queue 
> *q, struct bio **bio_orig,
>   		if (rw == WRITE) {
>   			char *vto, *vfrom;
>   -			flush_dcache_page(from->bv_page);
> +			if (unlikely(!PageSlab(from->bv_page)))
> +				flush_dcache_page(from->bv_page);
>   			vto = page_address(to->bv_page) + to->bv_offset;
>   			vfrom = kmap(from->bv_page) + from->bv_offset;
>   			memcpy(vto, vfrom, to->bv_len);

I guess this is triggered by Catalin's f1a0c4aa0937975b ("arm64: Cache
maintenance routines"), which added a page_mapping() call to arm64's
arch/arm64/mm/flush.c:flush_dcache_page().

What's happening is that jbd2 is using kmalloc() to allocate buffer_head
data.  That gets submitted down the BIO layer and __blk_queue_bounce()
calls flush_dcache_page() which in the arm64 case calls page_mapping()
and page_mapping() does VM_BUG_ON(PageSlab) and splat.

The unusual thing about all of this is that the payload for some disk
IO is coming from kmalloc, rather than being a user page.  It's oddball
but we've done this for ages and should continue to support it.


Now, the page from kmalloc() cannot be in highmem, so why did the
bounce code decide to bounce it?

__blk_queue_bounce() does

		/*
		 * is destination page below bounce pfn?
		 */
		if (page_to_pfn(page) <= queue_bounce_pfn(q) && !force)
			continue;

and `force' comes from must_snapshot_stable_pages().  But
must_snapshot_stable_pages() must have returned false, because if it
had returned true then it would have been must_snapshot_stable_pages()
which went BUG, because must_snapshot_stable_pages() calls page_mapping().

So my tentative diagosis is that arm64 is fishy.  A page which was
allocated via jbd2_alloc(GFP_NOFS)->kmem_cache_alloc() ended up being
above arm64's queue_bounce_pfn().  Can you please do a bit of
investigation to work out if this is what is happening?  Find out why
__blk_queue_bounce() decided to bounce a page which shouldn't have been
bounced?

This is all terribly fragile :( afaict if someone sets
bdi_cap_stable_pages_required() against that jbd2 queue, we're going to
hit that BUG_ON() again, via must_snapshot_stable_pages()'s
page_mapping() call.  (Darrick, this means you ;))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
