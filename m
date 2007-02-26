Date: Mon, 26 Feb 2007 03:37:12 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/3] mm: fix PageUptodate memorder
Message-ID: <20070226023712.GA23985@wotan.suse.de>
References: <20070215051822.7443.30110.sendpatchset@linux.site> <20070215051851.7443.65811.sendpatchset@linux.site> <20070225040657.eb4fc159.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070225040657.eb4fc159.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 25, 2007 at 04:06:57AM -0800, Andrew Morton wrote:
> 
> What an unpleasing patchset.  I really really hope we really have a bug in
> there, and that all this crap isn't pointless uglification.

It's the same bug for file pages as we had for anonymous pages, which
the POWER guys actually hit. Do you disagree? I like this patch much
better than the smp_wmb that we currently do just for anon pages.

> We _do_ need a flush_dcaceh_page() in all cases which you're concerned
> about.  Perhaps we should stick the appropriate barriers in there.

I think the memorder problem is conceptually a page data vs PG_uptodate
one, because the read-side assumes that the data will be initialised before
PG_uptodate is set.

After the page is uptodate, you don't need subsequent barriers (that you
would get via flush_dcache_page), because we've never really tried to
impose any synchronisation on parallel read vs write.

A memory barrier in flush_dcache_page would do the trick as well, I think,
but it is not really any better. It is misleading because it is not the
canonical fix. And we'd still need the smp_rmb in the PageUptodate read-side.

> > On Thu, 15 Feb 2007 08:31:31 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:
> > +static inline void SetNewPageUptodate(struct page *page)
> > +{
> > +	/*
> > +	 * S390 sets page dirty bit on IO operations, which is why it is
> > +	 * cleared in SetPageUptodate. This is not an issue for newly
> > +	 * allocated pages that are brought uptodate by zeroing memory.
> > +	 */
> > +	smp_wmb();
> > +	__set_bit(PG_uptodate, &(page)->flags);
> > +}
> 
> __SetPageUptodate() might be more conventional.

I guess so. I guess that the __ variants *can* only be used on new pages
anyway. I wanted to make it clear that it wasn't a non-atomic version of
exactly the same operation, but __SetPageUptodate probably would be fine.

> Boy we'd better get the callers of this little handgrenade right.

Newly initialised pages, before they become visible to anyone else. We
could put a BUG_ON(page_count(page) != 1); in there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
