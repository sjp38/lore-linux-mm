Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3A4D6B03A8
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 20:03:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t7so9583119pgt.0
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 17:03:22 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e5si12657985pga.100.2017.04.17.17.03.21
        for <linux-mm@kvack.org>;
        Mon, 17 Apr 2017 17:03:21 -0700 (PDT)
Date: Tue, 18 Apr 2017 09:03:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170418000319.GC21354@bbox>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, Apr 17, 2017 at 10:20:42AM -0500, Christoph Lameter wrote:
> On Mon, 17 Apr 2017, Sergey Senozhatsky wrote:
> 
> > Minchan reported that doing copy_page() on a kmalloc(PAGE_SIZE) page
> > with DEBUG_SLAB enabled can cause a memory corruption (See below or
> > lkml.kernel.org/r/1492042622-12074-2-git-send-email-minchan@kernel.org )
> 
> Yes the alignment guarantees do not require alignment on a page boundary.
> 
> The alignment for kmalloc allocations is controlled by KMALLOC_MIN_ALIGN.
> Usually this is either double word aligned or cache line aligned.
> 
> > that's an interesting problem. arm64 copy_page(), for instance, wants src
> > and dst to be page aligned, which is reasonable, while generic copy_page(),
> > on the contrary, simply does memcpy(). there are, probably, other callpaths
> > that do copy_page() on kmalloc-ed pages and I'm wondering if there is some
> > sort of a generic fix to the problem.
> 
> Simple solution is to not allocate pages via the slab allocator but use
> the page allocator for this. The page allocator provides proper alignment.
> 
> There is a reason it is called the page allocator because if you want a
> page you use the proper allocator for it.

It would be better if the APIs works with struct page, not address but
I can imagine there are many cases where don't have struct page itself
and redundant for kmap/kunmap.

Another approach is the API does normal thing for non-aligned prefix and
tail space and fast thing for aligned space.
Otherwise, it would be happy if the API has WARN_ON non-page SIZE aligned
address.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
