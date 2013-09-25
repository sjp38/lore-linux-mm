Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C96A96B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 17:57:53 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so402400pab.11
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 14:57:53 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Wed, 25 Sep 2013 17:57:50 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 29CED38C8045
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 17:57:46 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PLvkP13932432
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 21:57:46 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8PLvj7e024336
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 18:57:46 -0300
Date: Wed, 25 Sep 2013 16:57:44 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
Message-ID: <20130925215744.GA25852@variantweb.net>
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
 <5237FDCC.5010109@oracle.com>
 <20130923220757.GC16191@variantweb.net>
 <524318DE.7070106@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524318DE.7070106@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: Bob Liu <bob.liu@oracle.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Wed, Sep 25, 2013 at 07:09:50PM +0200, Tomasz Stanislawski wrote:
> > I just had an idea this afternoon to potentially kill both these birds with one
> > stone: Replace the rbtree in zswap with an address_space.
> > 
> > Each swap type would have its own page_tree to organize the compressed objects
> > by type and offset (radix tree is more suited for this anyway) and a_ops that
> > could be called by shrink_page_list() (writepage) or the migration code
> > (migratepage).
> > 
> > Then zbud pages could be put on the normal LRU list, maybe at the beginning of
> > the inactive LRU so they would live for another cycle through the list, then be
> > reclaimed in the normal way with the mapping->a_ops->writepage() pointing to a
> > zswap_writepage() function that would decompress the pages and call
> > __swap_writepage() on them.
> > 
> > This might actually do away with the explicit pool size too as the compressed
> > pool pages wouldn't be outside the control of the MM anymore.
> > 
> > I'm just starting to explore this but I think it has promise.
> > 
> > Seth
> > 
> 
> Hi Seth,
> There is a problem with the proposed idea.
> The radix tree used 'struct address_space' is a part of
> a bigger data structure.
> The radix tree is used to translate an offset to a page.
> That is ok for zswap. But struct page has a field named 'index'.
> The MM assumes that this index is an offset in radix tree
> where one can find the page. A lot is done by MM to sustain
> this consistency.

Yes, this is how it is for page cache pages.  However, the MM is able to
work differently with anonymous pages.  In the case of an anonymous
page, the mapping field points to an anon_vma struct, or, if ksm in
enabled and dedup'ing the page, a private ksm tracking structure.  If
the anonymous page is fully unmapped and resides only in the swap cache,
the page mapping is NULL.  So there is precedent for the fields to mean
other things.

The question is how to mark and identify zbud pages among the other page
types that will be on the LRU.  There are many ways.  The question is
what is the best and most acceptable way.

> 
> In case of zbud, there are two swap offset pointing to
> the same page. There might be more if zsmalloc is used.
> What is worse it is possible that one swap entry could
> point to data that cross a page boundary.

We just won't set page->index since it doesn't have a good meaning in
our case.  Swap cache pages also don't use index, although is seems to
me that they could since there is a 1:1 mapping of a swap cache page to
a swap offset and the index field isn't being used for anything else.
But I digress...

> 
> Of course, one could try to modify MM to support
> multiple mapping of a page in the radix tree.
> But I think that MM guys will consider this as a hack
> and they will not accept it.

Yes, it will require some changes to the MM to handle zbud pages on the
LRU.  I'm thinking that it won't be too intrusive, depending on how we
choose to mark zbud pages.

Seth

> 
> Regards,
> Tomasz Stanislawski
> 
> 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
