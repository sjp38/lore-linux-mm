Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB6756B000A
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:10:00 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id l1so2464106pga.1
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:10:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b68si60290pgc.276.2018.02.16.09.09.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Feb 2018 09:09:59 -0800 (PST)
Date: Fri, 16 Feb 2018 09:09:55 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
Message-ID: <20180216170955.GA17591@bombadil.infradead.org>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
 <20180214095911.GB28460@dhcp22.suse.cz>
 <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com>
 <20180215144525.GG7275@dhcp22.suse.cz>
 <20180215151129.GB12360@bombadil.infradead.org>
 <alpine.DEB.2.20.1802150947240.1902@nuc-kabylake>
 <20180215204817.GB22948@bombadil.infradead.org>
 <alpine.DEB.2.20.1802160941500.9660@nuc-kabylake>
 <20180216160116.GA24395@bombadil.infradead.org>
 <alpine.DEB.2.20.1802161002260.10336@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802161002260.10336@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Fri, Feb 16, 2018 at 10:08:28AM -0600, Christopher Lameter wrote:
> On Fri, 16 Feb 2018, Matthew Wilcox wrote:
> > I don't understand this response.  I'm not suggesting mixing objects
> > of different sizes within the same page.  The vast majority of slabs
> > use order-0 pages, a few use order-1 pages and larger sizes are almost
> > unheard of.  I'm suggesting the slab have it's own private arena of pages
> > that it uses for allocating pages to slabs; when an entire page comes
> > free in a slab, it is returned to the arena.  When the arena is empty,
> > slab requests another arena from the page allocator.
> 
> This just shifts the fragmentation problem because the 2M page cannot be
> released until all 4k or 8k pages within that 2M page are freed. How is
> that different from the page allocator which cannot coalesce an 2M page
> until all fragments have been released?

I'm not proposing releasing this 2MB page, unless it naturally frees up.
I'm saying that by restricting allocations to be within this 2MB page,
we prevent allocating from the adjacent 2MB page.

The workload I'm thinking of looks like this ... maybe the result of
running 'file' on every inode in a directory:

do {
	Allocate an inode
	Allocate a page of pagecache
} while (lots of times);

naively, we allocate a page for the inode slab, then 3-6 pages for page
cache (depending on the filesystem), then we allocate another page for
the inode slab, then another 3-6 pages of page cache, and so on.  So the
pages end up looking like this:

IPPPPPIP|PPPPIPPP|PPIPPPPP|IPPPPPIP|...

Now we need an order-3 allocation.  We can't get there just by releasing
page cache pages because there's inode slab pages in there, so we need to
shrink the inode caches as well.  I'm proposing:

IIIIII00|PPPPPPPP|PPPPPPPP|PPPPPPPP|PP...

and we can get our order-3 allocation just by releasing page cache pages.

> The kernelcore already does something similar by limiting the
> general unmovable allocs to a section of memory.

Right!  But Michal's unhappy about kernelcore (see the beginning of this
thread), and so I'm proposing an alternative.

> Maybe what we should do is raise the lowest allocation size instead and
> allocate 2^x groups of pages to certain purposes?
> 
> I.e. have a base allocation size of 16k and if the alloc was a page cache
> page then use the remainder for the neigboring pages.

Yes, there are a lot of ideas like this floating around; I know Kirill's
interested in this kind of thing not just for THP but also for faultaround.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
