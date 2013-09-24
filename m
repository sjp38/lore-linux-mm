Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 23D616B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 05:20:28 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id gq1so4636624obb.12
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 02:20:27 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MTM00HUYHWM1N90@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Sep 2013 10:20:24 +0100 (BST)
Message-id: <1380014422.31179.4.camel@AMDC1943>
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Tue, 24 Sep 2013 11:20:22 +0200
In-reply-to: <20130923220757.GC16191@variantweb.net>
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
 <5237FDCC.5010109@oracle.com> <20130923220757.GC16191@variantweb.net>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

Hi,

On pon, 2013-09-23 at 17:07 -0500, Seth Jennings wrote:
> On Tue, Sep 17, 2013 at 02:59:24PM +0800, Bob Liu wrote:
> > Mel mentioned several problems about zswap/zbud in thread "[PATCH v6
> > 0/5] zram/zsmalloc promotion".
> > 
> > Like "it's clunky as hell and the layering between zswap and zbud is
> > twisty" and "I think I brought up its stalling behaviour during review
> > when it was being merged. It would have been preferable if writeback
> > could be initiated in batches and then waited on at the very least..
> >  It's worse that it uses _swap_writepage directly instead of going
> > through a writepage ops.  It would have been better if zbud pages
> > existed on the LRU and written back with an address space ops and
> > properly handled asynchonous writeback."
> > 
> > So I think it would be better if we can address those issues at first
> > and it would be easier to address these issues before adding more new
> > features. Welcome any ideas.
> 
> I just had an idea this afternoon to potentially kill both these birds with one
> stone: Replace the rbtree in zswap with an address_space.
> 
> Each swap type would have its own page_tree to organize the compressed objects
> by type and offset (radix tree is more suited for this anyway) and a_ops that
> could be called by shrink_page_list() (writepage) or the migration code
> (migratepage).
> 
> Then zbud pages could be put on the normal LRU list, maybe at the beginning of
> the inactive LRU so they would live for another cycle through the list, then be
> reclaimed in the normal way with the mapping->a_ops->writepage() pointing to a
> zswap_writepage() function that would decompress the pages and call
> __swap_writepage() on them.

How exactly the address space can be used here? Do you want to point to
zbud pages in address_space.page_tree? If yes then which index should be
used?


Best regards,
Krzysztof



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
