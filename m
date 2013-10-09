Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id BCA9C6B0039
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 11:30:33 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1088817pdj.8
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 08:30:33 -0700 (PDT)
Received: by mail-oa0-f53.google.com with SMTP id i7so424984oag.40
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 08:30:30 -0700 (PDT)
Date: Wed, 9 Oct 2013 10:30:22 -0500
From: Seth Jennings <spartacus06@gmail.com>
Subject: Re: [PATCH v3 5/6] zswap: replace tree in zswap with radix tree in
 zbud
Message-ID: <20131009153022.GB5406@variantweb.net>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
 <1381238980-2491-6-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381238980-2491-6-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Tue, Oct 08, 2013 at 03:29:39PM +0200, Krzysztof Kozlowski wrote:
> This allows migration of zbud pages.
> 
> Add radix tree to zbud replacing the red-black tree in zswap. Use
> offset as index to this tree so effectively the handle concept is not
> needed anymore. Zswap uses only offset to access data stored in zbud.
> 
> Functionality of red-black tree from zswap was merged into zbud's radix
> tree.
> 
> The patch changes the way of storing duplicated pages. Now zswap refused
> to store them.
> 
> This change also exposes and fixes race condition between:
>  - zbud_reclaim_page() (called from zswap_frontswap_store())
> and
>  - zbud_free() (called from zswap_frontswap_invalidate_page()).
> This race was present already but additional locking and in-direct use
> of handle makes it frequent during high memory pressure.
> 
> Race typically looks like:
>  - thread 1: zbud_reclaim_page()
>    - thread 1: zswap_writeback_entry()
>      - zbud_map()
>  - thread 0: zswap_frontswap_invalidate_page()
>    - zbud_free()
>  - thread 1: read zswap_entry from memory or call zbud_unmap(), now on
>    invalid memory address
> 
> The zbud_reclaim_page() calls evict handler (zswap_writeback_entry())
> without holding pool lock. The zswap_writeback_entry() reads
> memory under address obtained from zbud_map() without any lock held.
> If invalidate happens during this time the zbud_free() will remove handle
> from the tree and zbud_unmap() won't succeed.
> 
> The new map_count fields in zbud_header try to address this problem by
> protecting handles from freeing.
> 
> Still are some things to do in this patch:
> 1. Accept storing of duplicated pages (as it was in original zswap).
> 2. Use RCU for radix tree reads and updates.
> 3. Optimize locking in zbud_free_all().
> 4. Iterate over LRU list instead of radix tree in zbud_free_all().

I started working on this in parallel to see if we come up with the
same solutions.  In many places we did :)

A few places where we did things differently:

I see you changed the first|last size in zbud from a size in chunks to
a size in bytes and then proceed to do size_to_chunks() in many places.

I think we should keep the size in chunks and track the exact size of the
entry at the zswap level in the struct zswap_header before the compressed
page data inside the zbud allocation.  Doing that also does away with
the struct zbud_mapped_entry argument in the zbud_map() call used to
return both the address and the length.  Now we can just return the
address and the zswap layer can determine the length from it's own
zswap_header inside the mapped data.

In my approach, I was also looking at allowing the zbud pools to use
HIGHMEM pages, since the handle is no longer an address.  This requires
the pages that are being mapped to be kmapped (atomic) which will
disable preemption.  This isn't an additional overhead since the
map/unmap corresponds with a compress/decompress operation at the zswap
level which uses per-cpu variables that disable preemption already.

With preemption disabled during the map, a per-cpu variable can store
any current zbud mapping at the zbud layer.  This would eliminate the
lookup by offset in zbud_unmap() and possibly do away the race condition
you mention and remove the need for per-buddy mapcounts which is kinda
messy.

Once we get this sorted, the next step in my mind is to teach the MM
about zbud pages in the reclaim page so we can do away with the LRU
logic in zbud.

Thanks again for all your work!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
