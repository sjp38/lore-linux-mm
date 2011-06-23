Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 45FA1900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 09:39:09 -0400 (EDT)
Date: Thu, 23 Jun 2011 15:39:04 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v2] fadvise: move active pages to inactive list with
 POSIX_FADV_DONTNEED
Message-ID: <20110623133904.GA1479@thinkpad>
References: <1308810981-5286-1-git-send-email-andrea@betterlinux.com>
 <E03B7391-C7D0-4EBE-96FE-C7537F9E353B@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E03B7391-C7D0-4EBE-96FE-C7537F9E353B@mit.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Tso <tytso@MIT.EDU>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 23, 2011 at 08:10:47AM -0400, Theodore Tso wrote:
> 
> On Jun 23, 2011, at 2:36 AM, Andrea Righi wrote:
> 
> > 
> > With the following solution when posix_fadvise(POSIX_FADV_DONTNEED) is
> > called for an active page instead of removing it from the page cache it
> > is added to the tail of the inactive list. Otherwise, if it's already in
> > the inactive list the page is removed from the page cache.
> 
> 
> Have you thought about this heuristic?   If the page is active, try to
> remove it from the current process's page table.  If that drops the
> use count of the page to zero, then drop it from the page cache;
> otherwise, leave it alone.
> 
> That way, if the page is being used by anyone else, we don't touch
> the page at all.   fadvise() should only affect the current process; if
> it's available to non-root users, it shouldn't be affecting other
> processes, and if it is being actively used by some other process,
> removing it from their page tables so it can be put on the inactive
> list counts as interference, doesn't it?

If the page is mapped in other process page tables we don't touch the
page at all (see lru_deactivate_fn in mm/swap.c).

So the heuristic above it's already implemented. I should have said this
explicitly in my description...

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
