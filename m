Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E46826B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:54:48 -0400 (EDT)
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090428164248.0c8cffef.akpm@linux-foundation.org>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com>
	 <20090428143244.4e424d36.akpm@linux-foundation.org>
	 <1240958794.938.1045.camel@calx>
	 <20090428160219.ca0123a1.akpm@linux-foundation.org>
	 <1240961469.938.1077.camel@calx>
	 <20090428164248.0c8cffef.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 28 Apr 2009 18:55:10 -0500
Message-Id: <1240962910.938.1084.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 16:42 -0700, Andrew Morton wrote:
> On Tue, 28 Apr 2009 18:31:09 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > On Tue, 2009-04-28 at 16:02 -0700, Andrew Morton wrote:
> > > On Tue, 28 Apr 2009 17:46:34 -0500
> > > Matt Mackall <mpm@selenic.com> wrote:
> > > 
> > > > > > +/* a helper function _not_ intended for more general uses */
> > > > > > +static inline int page_cap_writeback_dirty(struct page *page)
> > > > > > +{
> > > > > > +	struct address_space *mapping;
> > > > > > +
> > > > > > +	if (!PageSlab(page))
> > > > > > +		mapping = page_mapping(page);
> > > > > > +	else
> > > > > > +		mapping = NULL;
> > > > > > +
> > > > > > +	return mapping && mapping_cap_writeback_dirty(mapping);
> > > > > > +}
> > > > > 
> > > > > If the page isn't locked then page->mapping can be concurrently removed
> > > > > and freed.  This actually happened to me in real-life testing several
> > > > > years ago.
> > > > 
> > > > We certainly don't want to be taking locks per page to build the flags
> > > > data here. As we don't have any pretense of being atomic, it's ok if we
> > > > can find a way to do the test that's inaccurate when a race occurs, so
> > > > long as it doesn't dereference null.
> > > > 
> > > > But if there's not an obvious way to do that, we should probably just
> > > > drop this flag bit for this iteration.
> > > 
> > > trylock_page() could be used here, perhaps.
> > > 
> > > Then again, why _not_ just do lock_page()?  After all, few pages are
> > > ever locked.  There will be latency if the caller stumbles across a
> > > page which is under read I/O, but so be it?
> > 
> > As I mentioned just a bit ago, it's really not an unreasonable use case
> > to want to do this on every page in the system back to back. So per page
> > overhead matters. And the odds of stalling on a locked page when
> > visiting 1M pages while under load are probably not negligible.
> 
> The chances of stalling on a locked page are pretty good, and the
> duration of the stall might be long indeed.  Perhaps a trylock is a
> decent compromise - it depends on the value of this metric, and I've
> forgotten what we're talking about ;)
> 
> umm, seems that this flag is needed to enable PG_error, PG_dirty,
> PG_uptodate and PG_writeback reporting.  So simply removing this code
> would put a huge hole in the patchset, no?

We can report those bits anyway. But this patchset does something
clever: it filters irrelevant (and possibly overloaded) bits in various
contexts. 

> > Our lock primitives are pretty low overhead in the fast path, but every
> > cycle counts. The new tests and branches this code already adds are a
> > bit worrisome, but on balance probably worth it.
> 
> That should be easy to quantify (hint).

I'll let Fengguang address both these points.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
