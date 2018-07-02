Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC766B0008
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 09:32:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g16-v6so5737334edq.10
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 06:32:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6-v6si301933edb.343.2018.07.02.06.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 06:32:50 -0700 (PDT)
Date: Mon, 2 Jul 2018 15:32:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: cma: honor __GFP_ZERO flag in cma_alloc()
Message-ID: <20180702133247.GT19043@dhcp22.suse.cz>
References: <CGME20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2@eucas1p2.samsung.com>
 <20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2~3rI_9nj8b0455904559eucas1p2C@eucas1p2.samsung.com>
 <20180613122359.GA8695@bombadil.infradead.org>
 <20180613124001eucas1p2422f7916367ce19fecd40d6131990383~3uKFrT3ML1977219772eucas1p2G@eucas1p2.samsung.com>
 <20180613125546.GB32016@infradead.org>
 <20180613133913.GD20315@dhcp22.suse.cz>
 <20180702132335eucas1p1323fbf51cd5e82a59939d72097acee04~9kAizDyji0466904669eucas1p1w@eucas1p1.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702132335eucas1p1323fbf51cd5e82a59939d72097acee04~9kAizDyji0466904669eucas1p1w@eucas1p1.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 02-07-18 15:23:34, Marek Szyprowski wrote:
> Hi Michal,
> 
> On 2018-06-13 15:39, Michal Hocko wrote:
> > On Wed 13-06-18 05:55:46, Christoph Hellwig wrote:
> >> On Wed, Jun 13, 2018 at 02:40:00PM +0200, Marek Szyprowski wrote:
> >>> It is not only the matter of the spinlocks. GFP_ATOMIC is not supported
> >>> by the
> >>> memory compaction code, which is used in alloc_contig_range(). Right, this
> >>> should be also noted in the documentation.
> >> Documentation is good, asserts are better.  The code should reject any
> >> flag not explicitly supported, or even better have its own flags type
> >> with the few actually supported flags.
> > Agreed. Is the cma allocator used for anything other than GFP_KERNEL
> > btw.? If not then, shouldn't we simply drop the gfp argument altogether
> > rather than give users a false hope for differen gfp modes that are not
> > really supported and grow broken code?
> 
> Nope, all cma_alloc() callers are expected to use it with GFP_KERNEL gfp 
> mask.
> The only flag which is now checked is __GFP_NOWARN. I can change the 
> function
> signature of cma_alloc to:
> struct page *cma_alloc(struct cma *cma, size_t count, unsigned int 
> align, bool no_warn);

Are there any __GFP_NOWARN users? I have quickly hit the indirection
trap and searching for alloc callback didn't tell me really much.

> What about clearing the allocated buffer? Should it be another bool
> parameter, done unconditionally or moved to the callers?

That really depends on callers. I have no idea what they actually ask
for.
-- 
Michal Hocko
SUSE Labs
