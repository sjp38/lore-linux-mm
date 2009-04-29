Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 054DC6B005A
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 23:34:02 -0400 (EDT)
Date: Wed, 29 Apr 2009 11:33:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090429033358.GA10719@localhost>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428143244.4e424d36.akpm@linux-foundation.org> <1240958794.938.1045.camel@calx> <20090428160219.ca0123a1.akpm@linux-foundation.org> <1240961469.938.1077.camel@calx> <20090428164248.0c8cffef.akpm@linux-foundation.org> <1240962910.938.1084.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1240962910.938.1084.camel@calx>
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "adobriyan@gmail.com" <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 07:55:10AM +0800, Matt Mackall wrote:
> On Tue, 2009-04-28 at 16:42 -0700, Andrew Morton wrote:
> > On Tue, 28 Apr 2009 18:31:09 -0500
> > Matt Mackall <mpm@selenic.com> wrote:
> > 
> > > On Tue, 2009-04-28 at 16:02 -0700, Andrew Morton wrote:
> > > > On Tue, 28 Apr 2009 17:46:34 -0500
> > > > Matt Mackall <mpm@selenic.com> wrote:
> > > > 
> > > > > > > +/* a helper function _not_ intended for more general uses */
> > > > > > > +static inline int page_cap_writeback_dirty(struct page *page)
> > > > > > > +{
> > > > > > > +	struct address_space *mapping;
> > > > > > > +
> > > > > > > +	if (!PageSlab(page))
> > > > > > > +		mapping = page_mapping(page);
> > > > > > > +	else
> > > > > > > +		mapping = NULL;
> > > > > > > +
> > > > > > > +	return mapping && mapping_cap_writeback_dirty(mapping);
> > > > > > > +}
> > > > > > 
> > > > > > If the page isn't locked then page->mapping can be concurrently removed
> > > > > > and freed.  This actually happened to me in real-life testing several
> > > > > > years ago.
> > > > > 
> > > > > We certainly don't want to be taking locks per page to build the flags
> > > > > data here. As we don't have any pretense of being atomic, it's ok if we
> > > > > can find a way to do the test that's inaccurate when a race occurs, so
> > > > > long as it doesn't dereference null.
> > > > > 
> > > > > But if there's not an obvious way to do that, we should probably just
> > > > > drop this flag bit for this iteration.
> > > > 
> > > > trylock_page() could be used here, perhaps.
> > > > 
> > > > Then again, why _not_ just do lock_page()?  After all, few pages are
> > > > ever locked.  There will be latency if the caller stumbles across a
> > > > page which is under read I/O, but so be it?
> > > 
> > > As I mentioned just a bit ago, it's really not an unreasonable use case
> > > to want to do this on every page in the system back to back. So per page
> > > overhead matters. And the odds of stalling on a locked page when
> > > visiting 1M pages while under load are probably not negligible.
> > 
> > The chances of stalling on a locked page are pretty good, and the
> > duration of the stall might be long indeed.  Perhaps a trylock is a
> > decent compromise - it depends on the value of this metric, and I've
> > forgotten what we're talking about ;)
> > 
> > umm, seems that this flag is needed to enable PG_error, PG_dirty,
> > PG_uptodate and PG_writeback reporting.  So simply removing this code
> > would put a huge hole in the patchset, no?
> 
> We can report those bits anyway. But this patchset does something
> clever: it filters irrelevant (and possibly overloaded) bits in various
> contexts. 
> 
> > > Our lock primitives are pretty low overhead in the fast path, but every
> > > cycle counts. The new tests and branches this code already adds are a
> > > bit worrisome, but on balance probably worth it.
> > 
> > That should be easy to quantify (hint).
> 
> I'll let Fengguang address both these points.

A quick micro bench: 100 runs on another T7300@2GHz 2GB laptop:

             user      system       total
no lock      0.270     22.850       23.607 
trylock      0.310     25.890       26.484 
                       +13.3%       +12.2%

But anyway, the plan is to move filtering to user space and eliminate
the complex kernel logics.

The IO filtering is no longer possible in user space, but I didn't see
the error/dirty/writeback bits on this testing system. So I guess it
won't be a big loss.

The huge/gigantic page filtering is also not possible in user space.
So I tend to add a KPF_HUGE flag to distinguish (hardware supported)
huge pages from normal (software) compound pages. Any objections?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
