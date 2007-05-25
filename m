Message-Id: <20070525051716.030494061@sgi.com>
Date: Thu, 24 May 2007 22:17:16 -0700
From: clameter@sgi.com
Subject: [patch 0/6] Compound Page Enhancements
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

This patch enhances the handling of compound pages in the VM. It may also
be important also for the antifrag patches that need to manage a set of
higher order free pages and also for other uses of compound pages.

For now it simplifies accounting for SLUB pages but the groundwork here is
important for the large block size patches and for allowing to page migration
of larger pages. With this framework we may be able to get to a point where
compound pages keep their flags while they are free and Mel may avoid having
special functions for determining the page order of higher order freed pages.
If we can avoid the setup and teardown of higher order pages then allocation
and release of compound pages will be faster.

Looking at the handling of compound pages we see that the fact that a page
is part of a higher order page is not that interesting. The differentiation
is mainly for head pages and tail pages of higher order pages. Head pages
usually need special handling to accomodate the larger size. It is usually
an error if tail pages are encountered. Or else they need to be treated
like PAGE_SIZE pages. So a compound flag in the page flags is not what we
need. Instead we introduce a flag for the head page and another for the tail
page. The PageCompound test is preserved for backward compatibility and
will test if either PageTail or PageHead has been set.

After this patchset the uses of CompoundPage() will be reduced significantly
in the core VM. The I/O layer will still use CompoundPage() for direct I/O.
However, if we at some point convert direct I/O to also support compound
pages as a single unit then CompoundPage() there may become unecessary as
well as the leftover check in mm/swap.c. We may end up mostly with checks
for PageTail and PageHead.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
