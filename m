Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7D66B0032
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 11:39:57 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so2801477pab.29
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 08:39:56 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@medulla.variantweb.net>;
	Thu, 3 Oct 2013 11:39:53 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 792BB6E8044
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 11:39:50 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r93Fdpa656950982
	for <linux-mm@kvack.org>; Thu, 3 Oct 2013 15:39:51 GMT
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r93FdlMx023526
	for <linux-mm@kvack.org>; Thu, 3 Oct 2013 11:39:47 -0400
Date: Thu, 3 Oct 2013 10:39:46 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
Message-ID: <20131003153946.GA4695@medulla.variantweb.net>
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
 <5237FDCC.5010109@oracle.com>
 <20130923220757.GC16191@variantweb.net>
 <524318DE.7070106@samsung.com>
 <20130925215744.GA25852@variantweb.net>
 <52455B05.1010603@samsung.com>
 <20130927220045.GA751@variantweb.net>
 <1380529726.11375.11.camel@AMDC1943>
 <20131001210431.GA8941@variantweb.net>
 <1380806660.3392.30.camel@AMDC1943>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380806660.3392.30.camel@AMDC1943>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Tomasz Stanislawski <t.stanislaws@samsung.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Thu, Oct 03, 2013 at 03:24:20PM +0200, Krzysztof Kozlowski wrote:
> On wto, 2013-10-01 at 16:04 -0500, Seth Jennings wrote:
> > Yes, it is very similar.  I'm beginning to like aspects of this patch
> > more as I explore this issue more.
> > 
> > At first, I balked at the idea of yet another abstraction layer, but it
> > is very hard to avoid unless you want to completely collapse zswap and
> > zbud into one another and dissolve the layering.  Then you could do a
> > direct swap_offset -> address mapping.
> 
> After discussion with Tomasz Stanislawski we had an idea of merging the
> trees (zswap's rb and zbud's radix added in these patches) into one tree
> in zbud layer.

I have also been converging on this idea.  It took me a while because I
just wouldn't entertain the idea of there being no translation at the
zswap layer.  But I'm starting to think this is the best way.

It does create more work for any new allocator as a lot of the
complexity has been shifted to that layer.  However, it is the only
layer that it makes since to do this management (reclaim/migration).

> 
> This would simplify the design (if migration was added, of course).
> 
> The idea looks like:
> 1. Get rid of the red-black tree in zswap.
> 2. Add radix tree to zbud (or use radix tree from address space).
>  - Use offset (from swp_entry) as index to radix tree.
>  - zbud page (struct page) stored in tree.
> 4. With both buddies filled one zbud page would be put in radix tree
> twice.
> 5. zbud API would look like:
> zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp, pgoff_t offset)
> zbud_free(struct zbud_pool *pool, pgoff_t offset)
> zbud_map(struct zbud_pool *pool, pgoff_t offset)
> etc.
> 
> 6. zbud_map/unmap() would be a little more complex than now as it would
> took over some code from zswap (finding offset in tree).
> 
> 7. The radix tree would be used for:
>  - finding entry by offset (for zswap_frontswap_load() and others),
>  - migration.
> 
> 8. In case of migration colliding with zbud_map/unmap() the locking
> could be limited (in comparison to my patch). Calling zbud_map() would
> mark a page "dirty". During migration if page was "dirtied" then
> migration would fail with EAGAIN. Of course migration won't start if
> zbud buddy was mapped.
> 
> 
> What do you think about this?

I like it.  We just need to keep reclaim in mind as well as migration.
i.e. need to design with the knowledge that zbud pages will be on the
LRU lists.

Thanks for thinking about this!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
