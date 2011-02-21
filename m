Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7F4AD8D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 14:07:55 -0500 (EST)
Date: Mon, 21 Feb 2011 20:07:13 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v6 0/4] fadvise(DONTNEED) support
Message-ID: <20110221190713.GM13092@random.random>
References: <cover.1298212517.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1298212517.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hello,

On Sun, Feb 20, 2011 at 11:43:35PM +0900, Minchan Kim wrote:
> Recently, there was a reported problem about thrashing.
> (http://marc.info/?l=rsync&m=128885034930933&w=2)
> It happens by backup workloads(ex, nightly rsync).
> That's because the workload makes just use-once pages
> and touches pages twice. It promotes the page into

"recently" and "thrashing horribly" seem to signal a regression. Ok
that trying to have backup not messing up the VM working set, but by
any means running rsync in a loop shouldn't lead a server into
"trashing horribly" (other than for the additional disk I/O, just like
if rsync would be using O_DIRECT).

This effort in teaching rsync to tell the VM it's likely an used-once
type of access to the cache is good (tar will need it too), but if
this is a regression like it appears from the words above ("recently"
and "trashing horribly"), I suspect it's much higher priority to fix a
VM regression than to add fadvise support in rsync/tar. Likely if the
system didn't start "trashing horribly", they wouldn't need rsync.

Then fadvise becomes an improvement on top of that.

It'd be nice if at least it was tested if older kernel wouldn't trash
horribly after being left inactive overnight. If it still trashes
horribly with 2.6.18 ok... ignore this, otherwise we need a real fix.

I'm quite comfortable that older kernels would do perfectly ok with a
loop of rsync overnight while the system was idle. I also got people
asking me privately what to do to avoid the backup to swapout, that
further make me believe something regressed recently as older VM code
would never swapout on such a workload, even if you do used twice or 3
times in a row. If it swapout that's the real bug.

I had questions about limiting the pagecache size to a certain amount,
that works too, but that's again a band aid like fadvise, and it's
real minor issue compared to fixing the VM so that at least you can
tell the kernel "nuke all clean cache first", being able to tell the
kernel just that (even if some VM clever algorithm thinks swapping is
better and we want to swap by default) will fix it. We still need a
way to make the kernel behave perfect with zero swapping without
fadvise and without limiting the cache. Maybe setting swappiness to 0
just does that, I suggested that and I heard nothing back.

If you can reproduce I suggest making sure that at least it doesn't
swap anything during the overnight workload as that would signal a
definitive problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
