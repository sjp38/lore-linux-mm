Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4FCBC900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 09:57:19 -0400 (EDT)
Date: Thu, 23 Jun 2011 15:57:13 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH RFC] fadvise: move active pages to inactive list with
 POSIX_FADV_DONTNEED
Message-ID: <20110623135713.GB1479@thinkpad>
References: <1308779480-4950-1-git-send-email-andrea@betterlinux.com>
 <4E03200D.60704@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4E03200D.60704@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 23, 2011 at 12:14:21PM +0100, Padraig Brady wrote:
> On 22/06/11 22:51, Andrea Righi wrote:
> > There were some reported problems in the past about trashing page cache
> > when a backup software (i.e., rsync) touches a huge amount of pages (see
> > for example [1]).
> > 
> > This problem has been almost fixed by the Minchan Kim's patch [2] and a
> > proper use of fadvise() in the backup software. For example this patch
> > set [3] has been proposed for inclusion in rsync.
> > 
> > However, there can be still other similar trashing problems: when the
> > backup software reads all the source files, some of them may be part of
> > the actual working set of the system. When a
> > posix_fadvise(POSIX_FADV_DONTNEED) is performed _all_ pages are evicted
> > from pagecache, both the working set and the use-once pages touched only
> > by the backup software.
> > 
> > With the following solution when posix_fadvise(POSIX_FADV_DONTNEED) is
> > called for an active page instead of removing it from the page cache it
> > is added to the tail of the inactive list. Otherwise, if it's already in
> > the inactive list the page is removed from the page cache.
> > 
> > In this way if the backup was the only user of a page, that page will
> > be immediately removed from the page cache by calling
> > posix_fadvise(POSIX_FADV_DONTNEED). If the page was also touched by
> > other processes it'll be moved to the inactive list, having another
> > chance of being re-added to the working set, or simply reclaimed when
> > memory is needed.
> > 
> > Testcase:
> > 
> >   - create a 1GB file called "zero"
> >   - run md5sum zero to read all the pages in page cache (this is to
> >     simulate the user activity on this file)
> >   - run "rsync zero zero_copy" (rsync is patched with [3])
> >   - re-run md5sum zero (user activity on the working set) and measure
> >     the time to complete this command
> > 
> > The test has been performed using 3.0.0-rc4 vanilla and with this patch
> > applied (3.0.0-rc4-fadvise).
> > 
> > Results:
> >                   avg elapsed time      block:block_bio_queue
> >  3.0.0-rc4                  4.127s                      8,214
> >  3.0.0-rc4-fadvise          2.146s                          0
> > 
> > In the first case the file is evicted from page cache completely and we
> > must re-read it from the disk. In the second case the file is still in
> > page cache (in the inactive list) and we don't need any other additional
> > I/O operation.
> > 
> > [1] http://marc.info/?l=rsync&m=128885034930933&w=2
> > [2] https://lkml.org/lkml/2011/2/20/57
> > [3] http://lists.samba.org/archive/rsync/2010-November/025827.html
> > 
> > Signed-off-by: Andrea Righi <andrea@betterlinux.com>
> 
> Hmm, What if you do want to evict it from the cache for testing purposes?
> Perhaps this functionality should be associated with POSIX_FADV_NOREUSE?
> dd has been recently modified to support invalidating the cache for a file,
> and it uses POSIX_FADV_DONTNEED for that.
> http://git.sv.gnu.org/gitweb/?p=coreutils.git;a=commitdiff;h=5f311553

I don't have any objection to associate POSIX_FADV_NOREUSE to this
functionality. Actually maintaining a specific functionality to drop
file cache pages can be useful, indeed.

However, I'm not sure if POSIX_FADV_NOREUSE or POSIX_FADV_DONTNEED
either are suitable.

According to the standard:

 POSIX_FADV_NOREUSE = data will be accessed only once
 POSIX_FADV_DONTNEED = data will not be accessed in the near future

So, associating the "drop the page cache" semantic sounds like an
implementation detail and applications shouldn't implicitly rely on this
behaviour.

Let's wait a bit to see also other opinions.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
