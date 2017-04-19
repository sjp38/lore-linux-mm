Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4F396B03A3
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 02:02:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 18so7423019pfm.18
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 23:02:41 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r81si1392404pfk.4.2017.04.18.23.02.39
        for <linux-mm@kvack.org>;
        Tue, 18 Apr 2017 23:02:40 -0700 (PDT)
Date: Wed, 19 Apr 2017 15:02:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170419060237.GA1636@bbox>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
 <20170418000319.GC21354@bbox>
 <20170418073307.GF22360@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20170418073307.GF22360@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello Michal,

On Tue, Apr 18, 2017 at 09:33:07AM +0200, Michal Hocko wrote:
> On Tue 18-04-17 09:03:19, Minchan Kim wrote:
> > On Mon, Apr 17, 2017 at 10:20:42AM -0500, Christoph Lameter wrote:
> > > On Mon, 17 Apr 2017, Sergey Senozhatsky wrote:
> > > 
> > > > Minchan reported that doing copy_page() on a kmalloc(PAGE_SIZE) page
> > > > with DEBUG_SLAB enabled can cause a memory corruption (See below or
> > > > lkml.kernel.org/r/1492042622-12074-2-git-send-email-minchan@kernel.org )
> > > 
> > > Yes the alignment guarantees do not require alignment on a page boundary.
> > > 
> > > The alignment for kmalloc allocations is controlled by KMALLOC_MIN_ALIGN.
> > > Usually this is either double word aligned or cache line aligned.
> > > 
> > > > that's an interesting problem. arm64 copy_page(), for instance, wants src
> > > > and dst to be page aligned, which is reasonable, while generic copy_page(),
> > > > on the contrary, simply does memcpy(). there are, probably, other callpaths
> > > > that do copy_page() on kmalloc-ed pages and I'm wondering if there is some
> > > > sort of a generic fix to the problem.
> > > 
> > > Simple solution is to not allocate pages via the slab allocator but use
> > > the page allocator for this. The page allocator provides proper alignment.
> > > 
> > > There is a reason it is called the page allocator because if you want a
> > > page you use the proper allocator for it.
> 
> Agreed. Using the slab allocator for page sized object is just wasting
> cycles and additional metadata.
> 
> > It would be better if the APIs works with struct page, not address but
> > I can imagine there are many cases where don't have struct page itself
> > and redundant for kmap/kunmap.
> 
> I do not follow. Why would you need kmap for something that is already
> in the kernel space?

Because it can work with highmem pages.

> 
> > Another approach is the API does normal thing for non-aligned prefix and
> > tail space and fast thing for aligned space.
> > Otherwise, it would be happy if the API has WARN_ON non-page SIZE aligned
> > address.
> 
> copy_page is a performance sensitive function and I believe that we do
> those tricks exactly for this purpose. Why would we want to add an
> overhead for the alignment check or WARN_ON when using unaligned
> pointers? I do see that debugging a subtle memory corruption is PITA
> but that doesn't imply we should clobber the hot path IMHO.

What I wanted is VM_WARN_ON so it shouldn't be no overhead for whom
want really fast kernel. 

> 
> A big fat warning for copy_page would be definitely helpful though.

It's better than as-is but everyone doesn't read comment like such
simple API(e.g., clear_page(void *mem)), esp. And once it happens,
it's really subtle because for exmaple, you have not seen any bug
without slub debug. Based on it, you add new feature and crashed
for testing. To find a bug, you enable slub_debug. Bang.
you encounter a new bug lurked for a long time.
VM_WARN_ON would be valuable but I'm okay any option which might
have better to catch the bug if someone donates his time to fix
it up.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
