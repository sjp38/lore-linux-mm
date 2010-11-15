Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 345EC8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 13:23:24 -0500 (EST)
Date: Mon, 15 Nov 2010 13:23:14 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Oops while rebalancing, now unmountable.
Message-ID: <20101115182314.GA2493@infradead.org>
References: <1289236257.3611.3.camel@mars>
 <1289310046-sup-839@think>
 <1289326892.4231.2.camel@mars>
 <1289764507.4303.9.camel@mars>
 <20101114204206.GV6809@random.random>
 <20101114220018.GA4512@infradead.org>
 <20101114221222.GX6809@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101114221222.GX6809@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Shane Shrybman <shrybman@teksavvy.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2010 at 11:12:22PM +0100, Andrea Arcangeli wrote:
> I just wrote above that it can happen upstream without THP. It's not
> THP related at all. THP is the consumer, this is a problem in migrate
> that will trigger as well with migrate_pages or all other possible
> migration APIs.
> 
> If more people would be using hugetlbfs they would have noticed
> without THP.

Okay, it seems THP is really just the messenger for bad VM practices
here.

> +static int btree_migratepage(struct address_space *mapping,
> +                       struct page *newpage, struct page *page)
> +{
> +       /*
> +        * we can't safely write a btree page from here,
> +        * we haven't done the locking hook
> +        */
> +       if (PageDirty(page))
> +               return -EAGAIN;
> 
> fallback_migrate_page would call writeout() which is apparently not
> ok in btrfs for locking issues leading to corruption.

Hmm, it seems the issue for that particular problem is indeedin btrfs.
If it needs external locking for writing out data it should not
implement ->writepage to start with.  Chris, can you explain what's
going on with the btree code? It's pretty funny both in the
btree_writepage which goes directly into extent_write_full_page
if PF_MEMALLOC is not set, but otherwise does much more complicated
work, and also in btree_writepages which skips various WB_SYNC_NONE,
including the very weird check for for_kupdate.

What's the story behing all this and the corruption that Andrea found?

> > Btw, what codepath does THP call migrate_pages from?  If you don't
> > use an explicit thread writeout will be a no-op on btrfs and XFS, too.
> 
> THP never calls migrate_pages, it's memory compaction that calls it
> from inside alloc_pages(order=9). It got noticed only with THP because
> it makes more frequent hugepage allocations than nr_hugepages in
> hugetlbfs (and maybe there are more THP users already).

Well, s/THP/compaction/ and the same problem applies.  The modern
filesystem all have stopped from writeback happening either at all
or at least for the delalloc case from direct reclaim.  Calling
into this code from alloc_pages for filesystem backed pages is thus
rather pointless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
