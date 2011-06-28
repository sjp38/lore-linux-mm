Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 40A4B6B00FD
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 18:56:52 -0400 (EDT)
Date: Wed, 29 Jun 2011 00:56:45 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v4 0/2] fadvise: move active pages to inactive list with
 POSIX_FADV_DONTNEED
Message-ID: <20110628225645.GB2274@thinkpad>
References: <1309181361-14633-1-git-send-email-andrea@betterlinux.com>
 <20110628151233.f0a279be.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110628151233.f0a279be.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Theodore Tso <tytso@mit.edu>, Shaohua Li <shaohua.li@intel.com>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 28, 2011 at 03:12:33PM -0700, Andrew Morton wrote:
> On Mon, 27 Jun 2011 15:29:19 +0200
> Andrea Righi <andrea@betterlinux.com> wrote:
> 
> > There were some reported problems in the past about trashing page cache when a
> > backup software (i.e., rsync) touches a huge amount of pages (see for example
> > [1]).
> >     
> > This problem has been almost fixed by the Minchan Kim's patch [2] and a proper
> > use of fadvise() in the backup software. For example this patch set [3] has
> > been proposed for inclusion in rsync.
> >     
> > However, there can be still other similar trashing problems: when the backup
> > software reads all the source files, some of them may be part of the actual
> > working set of the system. When a POSIX_FADV_DONTNEED is performed _all_ pages
> > are evicted from pagecache, both the working set and the use-once pages touched
> > only by the backup software.
> >     
> > With the following solution when POSIX_FADV_DONTNEED is called for an active
> > page instead of removing it from the page cache it is added to the tail of the
> > inactive list. Otherwise, if it's already in the inactive list the page is
> > removed from the page cache. Pages mapped by other processes or unevictable
> > pages are not touched at all.
> > 
> > In this way if the backup was the only user of a page, that page will be
> > immediately removed from the page cache by calling POSIX_FADV_DONTNEED.  If the
> > page was also touched by other processes it'll be moved to the inactive list,
> > having another chance of being re-added to the working set, or simply reclaimed
> > when memory is needed.
> 
> So if an application touches a page twice and then runs
> POSIX_FADV_DONTNEED, that page will now not be freed.
> 
> That's a big behaviour change.  For many existing users
> POSIX_FADV_DONTNEED simply doesn't work any more!

Yes. This is the main concern that was raised by Padraig.

> 
> I'd have thought that adding a new POSIX_FADV_ANDREA would be safer
> than this.

Actually Jerry (in cc) proposed
POSIX_FADV_IDONTNEEDTHISBUTIFSOMEBODYELSEDOESTHENDONTTOUCHIT in a
private email. :)

> 
> 
> The various POSIX_FADV_foo's are so ill-defined that it was a mistake
> to ever use them.  We should have done something overtly linux-specific
> and given userspace more explicit and direct pagecache control.

That would give us the possibility to implement a wide range of
different operations (drop, drop if used once, add to the active list,
add to the inactive list, etc..). Some users always complain that they
would like to have a better control over the page cache from userspace.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
