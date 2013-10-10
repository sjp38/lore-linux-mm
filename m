Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C12E56B0037
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 03:01:30 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so2274859pad.35
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 00:01:30 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUF00C4LY6ETT10@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 Oct 2013 08:01:26 +0100 (BST)
Message-id: <1381388484.21461.16.camel@AMDC1943>
Subject: Re: [PATCH v3 5/6] zswap: replace tree in zswap with radix tree in zbud
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Thu, 10 Oct 2013 09:01:24 +0200
In-reply-to: <20131009171617.GA21057@variantweb.net>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
 <1381238980-2491-6-git-send-email-k.kozlowski@samsung.com>
 <20131009153022.GB5406@variantweb.net> <20131009171617.GA21057@variantweb.net>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <spartacus06@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Wed, 2013-10-09 at 12:16 -0500, Seth Jennings wrote:
> On Wed, Oct 09, 2013 at 10:30:22AM -0500, Seth Jennings wrote:
> > In my approach, I was also looking at allowing the zbud pools to use
> > HIGHMEM pages, since the handle is no longer an address.  This requires
> > the pages that are being mapped to be kmapped (atomic) which will
> > disable preemption.  This isn't an additional overhead since the
> > map/unmap corresponds with a compress/decompress operation at the zswap
> > level which uses per-cpu variables that disable preemption already.
> 
> On second though, lets not mess with the HIGHMEM page support for now.
> Turns out it is tricker than I thought since the unbuddied lists are
> linked through the zbud header stored in the page.  But we can still
> disable preemption to allow per-cpu tracking of the current mapping and
> avoid a lookup (and races) in zbud_unmap().

This tracking of current mapping could solve another problem I
encountered with new one-radix-tree approach with storage of duplicated
entries.

The problem is in zbud_unmap() API using offset to unmap (if duplicated
entries are overwritten):
 - thread 1: zswap_fronstwap_load() of some offset
   - zbud_map() maps this offset -> zhdr1
 - thread 2: zswap_frontswap_store() stores new data for this offset 
   - zbud_alloc() allocated new zhdr2 and replaces zhdr1 in radix tree 
     under this offset
   - new compressed data is stored by zswap
 - thread 1: tries to zbud_unmap() of this offset, but now the old
   zhdr1 is not present in radix tree so unmap will either fail or use
   zhdr2 which is wrong

To solve this issue I experimented with unmapping by zbud_mapped_entry
instead of offset (so zbud_unmap() won't search zbud_header in radix
tree at all):
##########################
int zbud_unmap(struct zbud_pool *pool, pgoff_t offset,
		struct zbud_mapped_entry *entry)
{
	struct zbud_header *zhdr = handle_to_zbud_header((unsigned
long)entry->addr);

	VM_BUG_ON((offset != zhdr->first_offset) && (offset !=
zhdr->last_offset));
	spin_lock(&pool->lock);
	if (put_map_count(zhdr, offset)) {
		/* Racing zbud_free() could not free the offset because
		 * it was still mapped so it is our job to free. */
		zbud_header_free(pool, zhdr, offset);
		spin_unlock(&pool->lock);
		return -EFAULT;
	}
	put_zbud_page(zhdr);
	spin_unlock(&pool->lock);
	return 0;
}
##########################

However getting rid of first/last_map_count seems much more simpler! 

Best regards,
Krzysztof


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
