Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B431A8D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 17:12:30 -0500 (EST)
Date: Sun, 14 Nov 2010 23:12:22 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Oops while rebalancing, now unmountable.
Message-ID: <20101114221222.GX6809@random.random>
References: <1289236257.3611.3.camel@mars>
 <1289310046-sup-839@think>
 <1289326892.4231.2.camel@mars>
 <1289764507.4303.9.camel@mars>
 <20101114204206.GV6809@random.random>
 <20101114220018.GA4512@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101114220018.GA4512@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Shane Shrybman <shrybman@teksavvy.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2010 at 05:00:18PM -0500, Christoph Hellwig wrote:
> On Sun, Nov 14, 2010 at 09:42:06PM +0100, Andrea Arcangeli wrote:
> > btrfs misses this:
> > 
> > +       .migratepage    = btree_migratepage,
> > 
> > It's a bug that can trigger upstream too (not only with THP) if there
> > are hugepage allocations (like while incrasing nr_hugepages). Chris
> > already fixed it with an experimental patch.
> 
> If the lack of an obscure method causes data corruption something
> is seriously wrong with THP.  At least from the 10.000 foot view

I just wrote above that it can happen upstream without THP. It's not
THP related at all. THP is the consumer, this is a problem in migrate
that will trigger as well with migrate_pages or all other possible
migration APIs.

If more people would be using hugetlbfs they would have noticed
without THP.

> I can't quite figure what the exact issue is, though.
> fallback_migrate_page seems to do the right thing to me for that
> case.
> 
> Btw, there's also another issue with the page migration code when used
> for filesystem pages.  If directly calls into ->writepage instead
> of using the flusher threads.  On most filesystems this will
> "only" cause nasty I/O patterns, but on ext4 for example it will
> be more nasty as ext3 doesn't do conversions from delayed allocations to
> real ones.  So unless you're doing a lot of overwrites it will be
> hard to make any progress in writeout().

+static int btree_migratepage(struct address_space *mapping,
+                       struct page *newpage, struct page *page)
+{
+       /*
+        * we can't safely write a btree page from here,
+        * we haven't done the locking hook
+        */
+       if (PageDirty(page))
+               return -EAGAIN;

fallback_migrate_page would call writeout() which is apparently not
ok in btrfs for locking issues leading to corruption.

> Btw, what codepath does THP call migrate_pages from?  If you don't
> use an explicit thread writeout will be a no-op on btrfs and XFS, too.

THP never calls migrate_pages, it's memory compaction that calls it
from inside alloc_pages(order=9). It got noticed only with THP because
it makes more frequent hugepage allocations than nr_hugepages in
hugetlbfs (and maybe there are more THP users already).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
