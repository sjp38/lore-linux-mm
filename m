Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 34ACB6B0007
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 00:11:43 -0500 (EST)
Date: Thu, 31 Jan 2013 14:11:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Questin about swap_slot free and invalidate page
Message-ID: <20130131051140.GB23548@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

When I reviewed zswap, I was curious about frontswap_store.
It said following as.

 * If frontswap already contains a page with matching swaptype and
 * offset, the frontswap implementation may either overwrite the data and
 * return success or invalidate the page from frontswap and return failure.

It didn't say why it happens. we already have __frontswap_invalidate_page
and call it whenever swap_slot frees. If we don't free swap slot,
scan_swap_map can't find the slot for swap out so I thought overwriting of
data shouldn't happen in frontswap.

As I looked the code, the curplit is reuse_swap_page. It couldn't free swap
slot if the page founded is PG_writeback but miss calling frontswap_invalidate_page
so data overwriting on frontswap can happen. I'm not sure frontswap guys
already discussed it long time ago.

If we can fix it, we can remove duplication entry handling logic
in all of backend of frontswap. All of backend should handle it although
it's pretty rare. Of course, zram could be fixed. It might be trivial now
but more there are many backend of frontswap, more it would be a headache.

If we are trying to fix it in swap layer,  we might fix it following as

int reuse_swap_page(struct page *page)
{
        ..
        ..
        if (count == 1) {
                if (!PageWriteback(page)) {
                        delete_from_swap_cache(page);
                        SetPageDirty(page);
                } else {
                        frontswap_invalidate_page();
                        swap_slot_free_notify();
                }
        }
}

But not sure, it is worth at the moment and there might be other places
to be fixed.(I hope Hugh can point out if we are missing something if he
has a time)

If we are reluctant to it, at least, we should write out comment above
frontswap_store about that to notice curious guys who spend many
time to know WHY and smart guys who are going to fix it with nice way.

Mr. Frontswap, What do you think about it?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
