Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f53.google.com (mail-oa0-f53.google.com [209.85.219.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD196B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 18:08:14 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id i7so1281123oag.12
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 15:08:14 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Mon, 23 Sep 2013 16:08:12 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id BBAD919D8043
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 16:08:08 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8NM84Vm205736
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 16:08:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8NM83iS009650
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 16:08:04 -0600
Date: Mon, 23 Sep 2013 17:07:57 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
Message-ID: <20130923220757.GC16191@variantweb.net>
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
 <5237FDCC.5010109@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5237FDCC.5010109@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Tue, Sep 17, 2013 at 02:59:24PM +0800, Bob Liu wrote:
> Mel mentioned several problems about zswap/zbud in thread "[PATCH v6
> 0/5] zram/zsmalloc promotion".
> 
> Like "it's clunky as hell and the layering between zswap and zbud is
> twisty" and "I think I brought up its stalling behaviour during review
> when it was being merged. It would have been preferable if writeback
> could be initiated in batches and then waited on at the very least..
>  It's worse that it uses _swap_writepage directly instead of going
> through a writepage ops.  It would have been better if zbud pages
> existed on the LRU and written back with an address space ops and
> properly handled asynchonous writeback."
> 
> So I think it would be better if we can address those issues at first
> and it would be easier to address these issues before adding more new
> features. Welcome any ideas.

I just had an idea this afternoon to potentially kill both these birds with one
stone: Replace the rbtree in zswap with an address_space.

Each swap type would have its own page_tree to organize the compressed objects
by type and offset (radix tree is more suited for this anyway) and a_ops that
could be called by shrink_page_list() (writepage) or the migration code
(migratepage).

Then zbud pages could be put on the normal LRU list, maybe at the beginning of
the inactive LRU so they would live for another cycle through the list, then be
reclaimed in the normal way with the mapping->a_ops->writepage() pointing to a
zswap_writepage() function that would decompress the pages and call
__swap_writepage() on them.

This might actually do away with the explicit pool size too as the compressed
pool pages wouldn't be outside the control of the MM anymore.

I'm just starting to explore this but I think it has promise.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
