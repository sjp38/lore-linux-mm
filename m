Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 70C126B0068
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 13:59:33 -0500 (EST)
Date: Thu, 20 Dec 2012 10:59:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] CMA: call to putback_lru_pages
Message-Id: <20121220105919.a4d393ad.akpm@linux-foundation.org>
In-Reply-To: <xa1tobhohi3m.fsf@mina86.com>
References: <1355779504-30798-1-git-send-email-srinivas.pandruvada@linux.intel.com>
	<xa1tlicwiagh.fsf@mina86.com>
	<20121219152736.1daa3d58.akpm@linux-foundation.org>
	<xa1tobhohi3m.fsf@mina86.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org

On Thu, 20 Dec 2012 16:13:33 +0100 Michal Nazarewicz <mina86@mina86.com> wrote:

> On Thu, Dec 20 2012, Andrew Morton <akpm@linux-foundation.org> wrote:
> > __alloc_contig_migrate_range() is a bit twisty.  How does this look?
> >
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: mm/page_alloc.c:__alloc_contig_migrate_range(): cleanup
> >
> > - `ret' is always zero in the we-timed-out case
> > - remove a test-n-branch in the wrapup code
> >
> > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > Cc: Michal Nazarewicz <mina86@mina86.com>
> > Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >
> >  mm/page_alloc.c |    7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> >
> > diff -puN mm/page_alloc.c~mm-page_allocc-__alloc_contig_migrate_range-cleanup mm/page_alloc.c
> > --- a/mm/page_alloc.c~mm-page_allocc-__alloc_contig_migrate_range-cleanup
> > +++ a/mm/page_alloc.c
> > @@ -5804,7 +5804,6 @@ static int __alloc_contig_migrate_range(
> >  			}
> >  			tries = 0;
> >  		} else if (++tries == 5) {
> > -			ret = ret < 0 ? ret : -EBUSY;
> 
> I don't really follow this change.
> 
> If migration for a page failed, migrate_pages() will return a positive
> value, which _alloc_contig_migrate_range() must interpret as a failure,
> but with this change, it is possible to exit the loop after migration of
> some pages failed and with ret > 0 which will be interpret as success.
> 
> On top of that, because ret > 0, ___if (ret < 0) putback_movable_pages()___
> won't be executed thus pages from cc->migratepages will leak.  I must be
> missing something here...

urgh, OK.

> >  /**
> > _
> >
> >
> > Also, what's happening here?
> >
> > 			pfn = isolate_migratepages_range(cc->zone, cc,
> > 							 pfn, end, true);
> > 			if (!pfn) {
> > 				ret = -EINTR;
> > 				break;
> > 			}
> >
> > The isolate_migratepages_range() return value is undocumented and
> > appears to make no sense.  It returns zero if fatal_signal_pending()
> > and if too_many_isolated&&!cc->sync.  Returning -EINTR in the latter
> > case is daft.
> 
> __alloc_contig_migrate_range() is always called with cc->sync == true,
> so the latter never happens in our case.  As such, the condition
> terminates the loop if a fatal signal is pending.

Please prepare a patch which

a) Documents the isolate_migratepages_range() return value.

   This documentation should mention that if
   isolate_migratepages_range() returns zero, the caller must again run
   fatal_signal_pending() to determine the reason for that zero return
   value.  Or if that wasn't the intent then tell us what _was_ the intent.

b) Explains to readers why __alloc_contig_migrate_range() isn't
   buggy when it assumes that a zero return from
   isolate_migratepages_range() means that a signal interrupted
   progress.

But really, unless I'm missing something, the
isolate_migratepages_range() return semantics are just crazy and I expect
that craziness will reveal itself when you try to document it!  I
suspect things would be much improved if it were to return -EINTR on
signal, not 0.

There's a second fatal_signal_pending() check in
isolate_migratepages_range() and this one can't cause a -EINTR return
because the function might have made some progress.  This rather forces
the caller to recheck fatal_signal_pending().

If fatal_signal_pending() was true on entry,
isolate_migratepages_range() might have made no progress and will
return the caller's low_pfn value.  In this case we could return -EINTR
and thereby relieve callers from having to recheck
fatal_signal_pending(), at the expense of having them call
isolate_migratepages_range() a second time.

Or something.  It's a mess.  Please, let's get some rigor and clarity
in there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
