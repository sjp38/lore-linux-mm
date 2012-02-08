Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 2D5086B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 16:31:33 -0500 (EST)
Date: Thu, 9 Feb 2012 08:31:28 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/4] radix-tree: iterating general cleanup
Message-ID: <20120208213128.GD12836@dastard>
References: <20120207074905.29797.60353.stgit@zurg>
 <CA+55aFy3NZ2sWX0CNVd9FnPSx0mUKSe0XzDWpDsNfU21p6ebHQ@mail.gmail.com>
 <4F31D03B.9040707@openvz.org>
 <CA+55aFx24n-W4-wTtrfbt9PNvVd7n+SvThnO6OQ74uW4yNrGxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx24n-W4-wTtrfbt9PNvVd7n+SvThnO6OQ74uW4yNrGxw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Feb 07, 2012 at 05:50:59PM -0800, Linus Torvalds wrote:
> On Tue, Feb 7, 2012 at 5:30 PM, Konstantin Khlebnikov
> <khlebnikov@openvz.org> wrote:
> >
> > If do not count comments here actually is negative line count change.
> 
> Ok, fair enough.
> 
> > And if drop (almost) unused radix_tree_gang_lookup_tag_slot() and
> > radix_tree_gang_lookup_slot() total bloat-o-meter score becomes negative
> > too.
> 
> Good.
> 
> > There also some simple bit-hacks: find-next-bit instead of dumb loops in
> > tagged-lookup.
> >
> > Here some benchmark results: there is radix-tree with 1024 slots, I fill and
> > tag every <step> slot,
> > and run lookup for all slots with radix_tree_gang_lookup() and
> > radix_tree_gang_lookup_tag() in the loop.
> > old/new rows -- nsec per iteration over whole tree.
> >
> > tagged-lookup
> > step    1    2     3     4     5     6     7     8     9     10    11    12    13    14    15    16
> > old   7035  5248  4742  4308  4217  4133  4030  3920  4038  3933  3914  3796  3851  3755  3819  3582
> > new   3578  2617  1899  1426  1220  1058  936   822   845   749   695   679   648   575   591   509
> >
> > so, new tagged-lookup always faster, especially for sparse trees.
> 
> Do you have any benchmarks when it's actually used by higher levels,
> though? I guess that will involve find_get_pages(), and we don't have
> all that any of them, but it would be lovely to see some real load
> (even if it is limited to one of the filesystems that uses this)
> numbers too..

It's also a very small tree size to test - 1024 slots is only
4MB of page cache data, but we regularly cache GBs of pages in
a single tree.

> > New normal lookup works faster for dense trees, on sparse trees it slower.

Testing large trees (in the millions of entries) might show
different results - I'd be interested to see the difference there
given that iterating large trees is very common (e.g. in the
writeback code)....

> I think that should be the common case, so that may be fine. Again, it
> would be nice to see numbers that are for something else than just the
> lookup - an actual use of it in some real context.

XFS also uses radix trees for it's inode caches and AG indexes. We
iterate those trees by both normal and tagged lookups in different
contexts, but it is extremely difficult to isolate the tree
traversal from everything else that is going on around them, so I
can't really help with a microbenchmark there...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
