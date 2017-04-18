Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCA96B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 03:33:12 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u5so3614676wmg.13
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 00:33:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n20si6065365wrn.211.2017.04.18.00.33.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 00:33:10 -0700 (PDT)
Date: Tue, 18 Apr 2017 09:33:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170418073307.GF22360@dhcp22.suse.cz>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
 <20170418000319.GC21354@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170418000319.GC21354@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue 18-04-17 09:03:19, Minchan Kim wrote:
> On Mon, Apr 17, 2017 at 10:20:42AM -0500, Christoph Lameter wrote:
> > On Mon, 17 Apr 2017, Sergey Senozhatsky wrote:
> > 
> > > Minchan reported that doing copy_page() on a kmalloc(PAGE_SIZE) page
> > > with DEBUG_SLAB enabled can cause a memory corruption (See below or
> > > lkml.kernel.org/r/1492042622-12074-2-git-send-email-minchan@kernel.org )
> > 
> > Yes the alignment guarantees do not require alignment on a page boundary.
> > 
> > The alignment for kmalloc allocations is controlled by KMALLOC_MIN_ALIGN.
> > Usually this is either double word aligned or cache line aligned.
> > 
> > > that's an interesting problem. arm64 copy_page(), for instance, wants src
> > > and dst to be page aligned, which is reasonable, while generic copy_page(),
> > > on the contrary, simply does memcpy(). there are, probably, other callpaths
> > > that do copy_page() on kmalloc-ed pages and I'm wondering if there is some
> > > sort of a generic fix to the problem.
> > 
> > Simple solution is to not allocate pages via the slab allocator but use
> > the page allocator for this. The page allocator provides proper alignment.
> > 
> > There is a reason it is called the page allocator because if you want a
> > page you use the proper allocator for it.

Agreed. Using the slab allocator for page sized object is just wasting
cycles and additional metadata.

> It would be better if the APIs works with struct page, not address but
> I can imagine there are many cases where don't have struct page itself
> and redundant for kmap/kunmap.

I do not follow. Why would you need kmap for something that is already
in the kernel space?

> Another approach is the API does normal thing for non-aligned prefix and
> tail space and fast thing for aligned space.
> Otherwise, it would be happy if the API has WARN_ON non-page SIZE aligned
> address.

copy_page is a performance sensitive function and I believe that we do
those tricks exactly for this purpose. Why would we want to add an
overhead for the alignment check or WARN_ON when using unaligned
pointers? I do see that debugging a subtle memory corruption is PITA
but that doesn't imply we should clobber the hot path IMHO.

A big fat warning for copy_page would be definitely helpful though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
