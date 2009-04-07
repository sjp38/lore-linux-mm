Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED535F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:17:08 -0400 (EDT)
Date: Tue, 7 Apr 2009 22:17:08 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] [8/16] POISON: Add various poison checks in mm/memory.c
Message-ID: <20090407201708.GA4220@cmpxchg.org>
References: <20090407509.382219156@firstfloor.org> <20090407151005.4E24B1D046D@basil.firstfloor.org> <20090407190330.GB3818@cmpxchg.org> <20090407193145.GU17934@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090407193145.GU17934@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 09:31:45PM +0200, Andi Kleen wrote:
> On Tue, Apr 07, 2009 at 09:03:30PM +0200, Johannes Weiner wrote:
> > On Tue, Apr 07, 2009 at 05:10:05PM +0200, Andi Kleen wrote:
> > > 
> > > Bail out early when poisoned pages are found in page fault handling.
> > > Since they are poisoned they should not be mapped freshly
> > > into processes.
> > > 
> > > This is generally handled in the same way as OOM, just a different
> > > error code is returned to the architecture code.
> > > 
> > > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > > 
> > > ---
> > >  mm/memory.c |    7 +++++++
> > >  1 file changed, 7 insertions(+)
> > > 
> > > Index: linux/mm/memory.c
> > > ===================================================================
> > > --- linux.orig/mm/memory.c	2009-04-07 16:39:39.000000000 +0200
> > > +++ linux/mm/memory.c	2009-04-07 16:39:39.000000000 +0200
> > > @@ -2560,6 +2560,10 @@
> > >  		goto oom;
> > >  	__SetPageUptodate(page);
> > >  
> > > +	/* Kludge for now until we take poisoned pages out of the free lists */
> > > +	if (unlikely(PagePoison(page)))
> > > +		return VM_FAULT_POISON;
> > > +
> > 
> > When memory_failure() hits a page still on the free list
> 
> It won't free it then. Later on it will take it out of the free lists,
> but that code is not written yet.
> 
> > (!page_count()) then the get_page() in memory_failure() will trigger a
> > VM_BUG.  So either this check is unneeded or it should be
> 
> So no bug
> > get_page_unless_zero() in memory_failure()?
> 
> That's not what this is handling.  The issue is that sometimes
> the process can still freeing it and we need to make sure it 
> never hits the free lists.

I think we missed each other here.  I wasn't talking about _why_ you
take that reference -- that is clear.  But I see these two
possibilities:

  a) memory_failure() is called on a page on the free list, the
  get_page() will trigger a bug because the refcount is 0

  b) if that is not possible, the above check is not needed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
