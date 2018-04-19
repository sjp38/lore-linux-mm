Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A07806B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:16:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q22so2612268pfh.20
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:16:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 37-v6si3275255plc.140.2018.04.19.04.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Apr 2018 04:16:02 -0700 (PDT)
Date: Thu, 19 Apr 2018 04:16:01 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 02/14] mm: Split page_type out from _mapcount
Message-ID: <20180419111601.GA5556@bombadil.infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-3-willy@infradead.org>
 <dba1674f-6126-8cce-4730-24d69e594c97@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dba1674f-6126-8cce-4730-24d69e594c97@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On Thu, Apr 19, 2018 at 11:04:23AM +0200, Vlastimil Babka wrote:
> On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > We're already using a union of many fields here, so stop abusing the
> > _mapcount and make page_type its own field.  That implies renaming some
> > of the machinery that creates PageBuddy, PageBalloon and PageKmemcg;
> > bring back the PG_buddy, PG_balloon and PG_kmemcg names.
> > 
> > As suggested by Kirill, make page_type a bitmask.  Because it starts out
> > life as -1 (thanks to sharing the storage with _mapcount), setting a
> > page flag means clearing the appropriate bit.  This gives us space for
> > probably twenty or so extra bits (depending how paranoid we want to be
> > about _mapcount underflow).
> > 
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  include/linux/mm_types.h   | 13 ++++++-----
> >  include/linux/page-flags.h | 45 ++++++++++++++++++++++----------------
> >  kernel/crash_core.c        |  1 +
> >  mm/page_alloc.c            | 13 +++++------
> >  scripts/tags.sh            |  6 ++---
> >  5 files changed, 43 insertions(+), 35 deletions(-)
> 
> ...
> 
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > index e34a27727b9a..8c25b28a35aa 100644
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -642,49 +642,56 @@ PAGEFLAG_FALSE(DoubleMap)
> >  #endif
> >  
> >  /*
> > - * For pages that are never mapped to userspace, page->mapcount may be
> > - * used for storing extra information about page type. Any value used
> > - * for this purpose must be <= -2, but it's better start not too close
> > - * to -2 so that an underflow of the page_mapcount() won't be mistaken
> > - * for a special page.
> > + * For pages that are never mapped to userspace (and aren't PageSlab),
> > + * page_type may be used.  Because it is initialised to -1, we invert the
> > + * sense of the bit, so __SetPageFoo *clears* the bit used for PageFoo, and
> > + * __ClearPageFoo *sets* the bit used for PageFoo.  We reserve a few high and
> > + * low bits so that an underflow or overflow of page_mapcount() won't be
> > + * mistaken for a page type value.
> >   */
> > -#define PAGE_MAPCOUNT_OPS(uname, lname)					\
> > +
> > +#define PAGE_TYPE_BASE	0xf0000000
> > +/* Reserve		0x0000007f to catch underflows of page_mapcount */
> > +#define PG_buddy	0x00000080
> > +#define PG_balloon	0x00000100
> > +#define PG_kmemcg	0x00000200
> > +
> > +#define PageType(page, flag)						\
> > +	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
> > +
> > +#define PAGE_TYPE_OPS(uname, lname)					\
> >  static __always_inline int Page##uname(struct page *page)		\
> >  {									\
> > -	return atomic_read(&page->_mapcount) ==				\
> > -				PAGE_##lname##_MAPCOUNT_VALUE;		\
> > +	return PageType(page, PG_##lname);				\
> >  }									\
> >  static __always_inline void __SetPage##uname(struct page *page)		\
> >  {									\
> > -	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);	\
> > -	atomic_set(&page->_mapcount, PAGE_##lname##_MAPCOUNT_VALUE);	\
> > +	VM_BUG_ON_PAGE(!PageType(page, 0), page);			\
> 
> I think this debug test does less than you expect? IIUC you want to
> check that no type is yet set, but this will only trigger if something
> cleared one of the bits in top 0xf byte of PAGE_TYPE_BASE?
> Just keep the comparison to -1 then?

With this patchset, it becomes possible to set more than one of the
PageTye bits.  It doesn't make sense to set PageBuddy and PageKmemcg,
but maybe it makes sense to set PageKmemcg and PageTable?

So yes, I weakened this test, but I did so deliberately.
