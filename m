Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 24E9E6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 13:16:03 -0400 (EDT)
Date: Wed, 17 Jul 2013 19:15:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 05/10] mm: compaction: don't require high order pages
 below min wmark
Message-ID: <20130717171553.GA6552@redhat.com>
References: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
 <1373982114-19774-6-git-send-email-aarcange@redhat.com>
 <51E65210.6040103@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E65210.6040103@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hush Bensen <hush.bensen@gmail.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jul 17, 2013 at 04:13:04AM -0400, Hush Bensen wrote:
> On 07/16/2013 09:41 AM, Andrea Arcangeli wrote:
> > The min wmark should be satisfied with just 1 hugepage. And the other
> > wmarks should be adjusted accordingly. We need to succeed the low
> > wmark check if there's some significant amount of 0 order pages, but
> > we don't need plenty of high order pages because the PF_MEMALLOC paths
> > don't require those. Creating a ton of high order pages that cannot be
> > allocated by the high order allocation paths (no PF_MEMALLOC) is quite
> > wasteful because they can be splitted in lower order pages before
> > anybody has a chance to allocate them.
> >
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >   mm/page_alloc.c | 17 +++++++++++++++++
> >   1 file changed, 17 insertions(+)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index db8fb66..d94503d 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1643,6 +1643,23 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> >   
> >   	if (free_pages - free_cma <= min + lowmem_reserve)
> >   		return false;
> > +	if (!order)
> > +		return true;
> > +
> > +	/*
> > +	 * Don't require any high order page under the min
> > +	 * wmark. Invoking compaction to create lots of high order
> > +	 * pages below the min wmark is wasteful because those
> > +	 * hugepages cannot be allocated without PF_MEMALLOC and the
> > +	 * PF_MEMALLOC paths must not depend on high order allocations
> > +	 * to succeed.
> > +	 */
> > +	min = mark - z->watermark[WMARK_MIN];
> > +	WARN_ON(min < 0);
> > +	if (alloc_flags & ALLOC_HIGH)
> > +		min -= min / 2;
> > +	if (alloc_flags & ALLOC_HARDER)
> > +		min -= min / 4;
> 
> __zone_watermark_ok has these operations for mark, why do it again?

min changed, so I repeat the operation on the new min.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
