Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B2D9B9000BD
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 18:13:23 -0400 (EDT)
Date: Tue, 28 Jun 2011 15:12:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/2] fadvise: move active pages to inactive list with
 POSIX_FADV_DONTNEED
Message-Id: <20110628151233.f0a279be.akpm@linux-foundation.org>
In-Reply-To: <1309181361-14633-1-git-send-email-andrea@betterlinux.com>
References: <1309181361-14633-1-git-send-email-andrea@betterlinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Theodore Tso <tytso@mit.edu>, Shaohua Li <shaohua.li@intel.com>, =?ISO-8859-1?Q?P?= =?ISO-8859-1?Q?=E1draig?= Brady <P@draigBrady.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 27 Jun 2011 15:29:19 +0200
Andrea Righi <andrea@betterlinux.com> wrote:

> There were some reported problems in the past about trashing page cache when a
> backup software (i.e., rsync) touches a huge amount of pages (see for example
> [1]).
>     
> This problem has been almost fixed by the Minchan Kim's patch [2] and a proper
> use of fadvise() in the backup software. For example this patch set [3] has
> been proposed for inclusion in rsync.
>     
> However, there can be still other similar trashing problems: when the backup
> software reads all the source files, some of them may be part of the actual
> working set of the system. When a POSIX_FADV_DONTNEED is performed _all_ pages
> are evicted from pagecache, both the working set and the use-once pages touched
> only by the backup software.
>     
> With the following solution when POSIX_FADV_DONTNEED is called for an active
> page instead of removing it from the page cache it is added to the tail of the
> inactive list. Otherwise, if it's already in the inactive list the page is
> removed from the page cache. Pages mapped by other processes or unevictable
> pages are not touched at all.
> 
> In this way if the backup was the only user of a page, that page will be
> immediately removed from the page cache by calling POSIX_FADV_DONTNEED.  If the
> page was also touched by other processes it'll be moved to the inactive list,
> having another chance of being re-added to the working set, or simply reclaimed
> when memory is needed.

So if an application touches a page twice and then runs
POSIX_FADV_DONTNEED, that page will now not be freed.

That's a big behaviour change.  For many existing users
POSIX_FADV_DONTNEED simply doesn't work any more!

I'd have thought that adding a new POSIX_FADV_ANDREA would be safer
than this.


The various POSIX_FADV_foo's are so ill-defined that it was a mistake
to ever use them.  We should have done something overtly linux-specific
and given userspace more explicit and direct pagecache control.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
