Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A876E6B003D
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 18:16:32 -0500 (EST)
Date: Tue, 3 Mar 2009 00:16:28 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mmtom :  add VM_BUG_ON in __get_free_pages
Message-ID: <20090302231628.GA7228@cmpxchg.org>
References: <20090302183148.a4dfcc22.minchan.kim@barrios-desktop> <20090302142757.1cc014aa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090302142757.1cc014aa.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: MinChan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 02, 2009 at 02:27:57PM -0800, Andrew Morton wrote:
> On Mon, 2 Mar 2009 18:31:48 +0900
> MinChan Kim <minchan.kim@gmail.com> wrote:
> 
> > 
> > The __get_free_pages is used in many place. 
> > Also, driver developers can use it freely due to export function.
> > Some developers might use it to allocate high pages by mistake. 
> > 
> > The __get_free_pages can allocate high page using alloc_pages, 
> > but it can't return linear address for high page.
> > 
> > Even worse, in this csse, caller can't free page which are there in high zone. 
> > So, It would be better to add VM_BUG_ON. 
> > 
> > It's based on mmtom 2009-02-27-13-54.
> >  
> > Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/page_alloc.c |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8294107..381056b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1681,6 +1681,13 @@ EXPORT_SYMBOL(__alloc_pages_internal);
> >  unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
> >  {
> >  	struct page * page;
> > +
> > +	/*
> > +	 * __get_free_pages() returns a 32-bit address, which cannot represent
> > +	 * a highmem page
> > +	 */
> > +	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
> > +
> >  	page = alloc_pages(gfp_mask, order);
> >  	if (!page)
> >  		return 0;
> 
> If someone calls __get_free_pages(__GFP_HIGHMEM) then page_address()
> will reliably return NULL and the caller's code will oops.

It will allocate a page, fail to translate it to a virtual address,
return 0 and the caller will think allocation failed because it checks
for the return value.

But the highmem page is still allocated and now leaked, isn't it?

> Yes, there's a decent (and increasing) risk that the developer won't be
> testing the code on a highmem machine, but there are enough highmem
> machines out there that the bug should be discovered pretty quickly.

Another thing is that a device driver developer does not necessarily
has CONFIG_DEBUG_VM set.  Can we expect him to?

> So I'm not sure that this test is worth the additional overhead to a
> fairly frequently called function?

Well, it's only done conditionally if you want to debug the thing
anyway.  But as mentioned above, maybe this isn't the right condition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
