Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1FC606B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 08:15:05 -0400 (EDT)
Date: Tue, 9 Jun 2009 20:51:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [10/16] HWPOISON: Handle poisoned pages in
	set_page_dirty()
Message-ID: <20090609125139.GE5589@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184644.190E71D0281@basil.firstfloor.org> <20090609095920.GD14820@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609095920.GD14820@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 05:59:20PM +0800, Nick Piggin wrote:
> On Wed, Jun 03, 2009 at 08:46:43PM +0200, Andi Kleen wrote:
> > 
> > Bail out early in set_page_dirty for poisoned pages. We don't want any
> > of the dirty accounting done or file system write back started, because
> > the page will be just thrown away.
> 
> I don't agree with adding overhead to fastpaths like this. Your
> MCE handler should have already taken care of this so I can't
> see what it can gain.

Agreed to remove this patch. The poisoned page should already be
isolated (in normal cases), and won't reach this code path.

Thanks,
Fengguang

> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > 
> > ---
> >  mm/page-writeback.c |    4 ++++
> >  1 file changed, 4 insertions(+)
> > 
> > Index: linux/mm/page-writeback.c
> > ===================================================================
> > --- linux.orig/mm/page-writeback.c	2009-06-03 19:36:20.000000000 +0200
> > +++ linux/mm/page-writeback.c	2009-06-03 19:36:23.000000000 +0200
> > @@ -1304,6 +1304,10 @@
> >  {
> >  	struct address_space *mapping = page_mapping(page);
> >  
> > +	if (unlikely(PageHWPoison(page))) {
> > +		SetPageDirty(page);
> > +		return 0;
> > +	}
> >  	if (likely(mapping)) {
> >  		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
> >  #ifdef CONFIG_BLOCK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
