Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D23086B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 09:25:09 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so2624959pab.29
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 06:25:09 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MU300B7KH7NJJE0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 03 Oct 2013 14:24:21 +0100 (BST)
Message-id: <1380806660.3392.30.camel@AMDC1943>
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Thu, 03 Oct 2013 15:24:20 +0200
In-reply-to: <20131001210431.GA8941@variantweb.net>
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
 <5237FDCC.5010109@oracle.com> <20130923220757.GC16191@variantweb.net>
 <524318DE.7070106@samsung.com> <20130925215744.GA25852@variantweb.net>
 <52455B05.1010603@samsung.com> <20130927220045.GA751@variantweb.net>
 <1380529726.11375.11.camel@AMDC1943> <20131001210431.GA8941@variantweb.net>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Tomasz Stanislawski <t.stanislaws@samsung.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On wto, 2013-10-01 at 16:04 -0500, Seth Jennings wrote:
> Yes, it is very similar.  I'm beginning to like aspects of this patch
> more as I explore this issue more.
> 
> At first, I balked at the idea of yet another abstraction layer, but it
> is very hard to avoid unless you want to completely collapse zswap and
> zbud into one another and dissolve the layering.  Then you could do a
> direct swap_offset -> address mapping.

After discussion with Tomasz Stanislawski we had an idea of merging the
trees (zswap's rb and zbud's radix added in these patches) into one tree
in zbud layer.

This would simplify the design (if migration was added, of course).

The idea looks like:
1. Get rid of the red-black tree in zswap.
2. Add radix tree to zbud (or use radix tree from address space).
 - Use offset (from swp_entry) as index to radix tree.
 - zbud page (struct page) stored in tree.
4. With both buddies filled one zbud page would be put in radix tree
twice.
5. zbud API would look like:
zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp, pgoff_t offset)
zbud_free(struct zbud_pool *pool, pgoff_t offset)
zbud_map(struct zbud_pool *pool, pgoff_t offset)
etc.

6. zbud_map/unmap() would be a little more complex than now as it would
took over some code from zswap (finding offset in tree).

7. The radix tree would be used for:
 - finding entry by offset (for zswap_frontswap_load() and others),
 - migration.

8. In case of migration colliding with zbud_map/unmap() the locking
could be limited (in comparison to my patch). Calling zbud_map() would
mark a page "dirty". During migration if page was "dirtied" then
migration would fail with EAGAIN. Of course migration won't start if
zbud buddy was mapped.


What do you think about this?


Best regards,
Krzysztof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
