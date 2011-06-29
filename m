Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 67F726B00F5
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 10:05:05 -0400 (EDT)
Date: Wed, 29 Jun 2011 16:04:53 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v4 0/2] fadvise: move active pages to inactive list with
 POSIX_FADV_DONTNEED
Message-ID: <20110629140453.GA13456@thinkpad>
References: <1309181361-14633-1-git-send-email-andrea@betterlinux.com>
 <20110628151233.f0a279be.akpm@linux-foundation.org>
 <20110628225645.GB2274@thinkpad>
 <20110628160347.a5ffcc26.akpm@linux-foundation.org>
 <4E0B0A76.5010204@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4E0B0A76.5010204@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Theodore Tso <tytso@mit.edu>, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 29, 2011 at 12:20:22PM +0100, Padraig Brady wrote:
> On 29/06/11 00:03, Andrew Morton wrote:
> > On Wed, 29 Jun 2011 00:56:45 +0200
> > Andrea Righi <andrea@betterlinux.com> wrote:
> > 
> >>>>
> >>>> In this way if the backup was the only user of a page, that page will be
> >>>> immediately removed from the page cache by calling POSIX_FADV_DONTNEED.  If the
> >>>> page was also touched by other processes it'll be moved to the inactive list,
> >>>> having another chance of being re-added to the working set, or simply reclaimed
> >>>> when memory is needed.
> >>>
> >>> So if an application touches a page twice and then runs
> >>> POSIX_FADV_DONTNEED, that page will now not be freed.
> >>>
> >>> That's a big behaviour change.  For many existing users
> >>> POSIX_FADV_DONTNEED simply doesn't work any more!
> >>
> >> Yes. This is the main concern that was raised by P__draig.
> >>
> >>>
> >>> I'd have thought that adding a new POSIX_FADV_ANDREA would be safer
> >>> than this.
> >>
> >> Actually Jerry (in cc) proposed
> >> POSIX_FADV_IDONTNEEDTHISBUTIFSOMEBODYELSEDOESTHENDONTTOUCHIT in a
> >> private email. :)
> > 
> > Sounds good.  Needs more underscores though.
> > 
> >>>
> >>>
> >>> The various POSIX_FADV_foo's are so ill-defined that it was a mistake
> >>> to ever use them.  We should have done something overtly linux-specific
> >>> and given userspace more explicit and direct pagecache control.
> >>
> >> That would give us the possibility to implement a wide range of
> >> different operations (drop, drop if used once, add to the active list,
> >> add to the inactive list, etc..). Some users always complain that they
> >> would like to have a better control over the page cache from userspace.
> > 
> > Well, I'd listen to proposals ;)
> > 
> > One thing we must be careful about is to not expose things like "active
> > list" to userspace.  linux-4.5 may not _have_ an active list, and its
> > implementors would hate us and would have to jump through hoops to
> > implement vaguely compatible behaviour in the new scheme.
> > 
> > So any primitives which are exposed should be easily implementable and
> > should *make sense* within any future scheme...
> 
> Agreed.
> 
> In fairness to posix_fadvise(), I think it's designed to
> specify hints for the current process' use of data
> so that it can get at it more efficiently and also be
> allow the system to manipulate cache more efficiently.
> I.E. it's not meant for direct control of the cache.
> 
> That being said, existing use has allowed this,
> and it would be nice not to change without consideration.
> 
> I've mentioned how high level cache control functions
> might map to the existing FADV knobs here:
> 
> http://marc.info/?l=linux-kernel&m=130917619416123&w=2
> 
> cheers,
> Padraig.

OK, your proposal seems a good start to implement a better cache control
interface.

Basically you're proposing to provide the following operations:
 1. DROP
 2. DROP if used once
 3. ADD
 4. ADD if there's space

I would also add for sure:
 5. ADD and will use once

Some of them are already implemented by the available fadvise()
operations, like 1 (POSIX_FADV_DONTNEED) and 3 (POSIX_FADV_WILLNEED).
Option 5 can be mapped to POSIX_FADV_NOREUSE, but it's not yet
implemented.

I need to think a little bit more about all of this. I'll try to post a
new RFC, proposing the list of high-level operations to implement the
better page cache control from userspace.

Suggestions, comments, ideas are always welcome.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
