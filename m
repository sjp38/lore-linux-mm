Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 65C386B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 13:09:57 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so6266004pbb.6
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:09:57 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MTO00750YCHNX40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 25 Sep 2013 18:09:53 +0100 (BST)
Message-id: <524318DE.7070106@samsung.com>
Date: Wed, 25 Sep 2013 19:09:50 +0200
From: Tomasz Stanislawski <t.stanislaws@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
 <5237FDCC.5010109@oracle.com> <20130923220757.GC16191@variantweb.net>
In-reply-to: <20130923220757.GC16191@variantweb.net>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Bob Liu <bob.liu@oracle.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

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
> 
> This might actually do away with the explicit pool size too as the compressed
> pool pages wouldn't be outside the control of the MM anymore.
> 
> I'm just starting to explore this but I think it has promise.
> 
> Seth
> 

Hi Seth,
There is a problem with the proposed idea.
The radix tree used 'struct address_space' is a part of
a bigger data structure.
The radix tree is used to translate an offset to a page.
That is ok for zswap. But struct page has a field named 'index'.
The MM assumes that this index is an offset in radix tree
where one can find the page. A lot is done by MM to sustain
this consistency.

In case of zbud, there are two swap offset pointing to
the same page. There might be more if zsmalloc is used.
What is worse it is possible that one swap entry could
point to data that cross a page boundary.

Of course, one could try to modify MM to support
multiple mapping of a page in the radix tree.
But I think that MM guys will consider this as a hack
and they will not accept it.

Regards,
Tomasz Stanislawski


> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
