Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F3402900234
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 09:49:37 -0400 (EDT)
From: Andrea Righi <andrea@betterlinux.com>
Subject: [PATCH v3 0/2] fadvise: support POSIX_FADV_NOREUSE
Date: Fri, 24 Jun 2011 15:49:08 +0200
Message-Id: <1308923350-7932-1-git-send-email-andrea@betterlinux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@mit.edu>, Shaohua Li <shaohua.li@intel.com>, =?UTF-8?q?P=C3=A1draig=20Brady?= <P@draigBrady.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

There were some reported problems in the past about trashing page cache
when a backup software (i.e., rsync) touches a huge amount of pages (see
for example [1]).

This problem has been almost fixed by the Minchan Kim's patch [2] and a
proper use of fadvise() in the backup software. For example this patch
set [3] has been proposed for inclusion in rsync.

However, there can be still other similar trashing problems: when the
backup software reads all the source files, some of them may be part of
the actual working set of the system. When a POSIX_FADV_DONTNEED is
performed _all_ pages are evicted from pagecache, both the working set
and the use-once pages touched only by the backup software.

A previous proposal [4] tried to resolve this problem being less
agressive in invalidating active pages, moving them to the inactive list
intead of just evict them from the page cache.

However, this approach changed completely the old behavior of
invalidate_mapping_pages(), that is not only used by fadvise.

The new solution maps POSIX_FADV_NOREUSE to the less-agressive page
invalidation policy.

With POSIX_FADV_NOREUSE active pages are moved to the tail of the
inactive list, and pages in the inactive list are just removed from page
cache. Pages mapped by other processes or unevictable pages are not
touched at all.

In this way if the backup was the only user of a page, that page will be
immediately removed from the page cache by calling POSIX_FADV_NOREUSE.
If the page was also touched by other tasks it'll be moved to the
inactive list, having another chance of being re-added to the working
set, or simply reclaimed when memory is needed.

In conclusion, now userspace applications that want to drop some page
cache pages can choose between the following advices:

 POSIX_FADV_DONTNEED = drop page cache if possible
 POSIX_FADV_NOREUSE = reduce page cache eligibility

Testcase:

  - create a 1GB file called "zero"
  - run md5sum zero to read all the pages in page cache (this is to
    simulate the user activity on this file)
  - run rsync zero zero_copy
  - re-run md5sum zero (user activity on the working set) and measure
    the time to complete this command

rsync has been patched with [3], using POSIX_FADV_DONTNEED in one case and
POSIX_FADV_NOREUSE in the other case.

Results:

 - after the backup run:
   # perf stat -e block:block_bio_queue md5sum zero

                  avg elapsed time      block:block_bio_queue
 rsync-dontneed              4.24s                      2,072
 rsync-noreuse               2.22s                          0

[1] http://marc.info/?l=rsync&m=128885034930933&w=2
[2] https://lkml.org/lkml/2011/2/20/57
[3] http://lists.samba.org/archive/rsync/2010-November/025827.html
[4] https://lkml.org/lkml/2011/6/23/35

ChangeLog v2 -> v3:
 - do not change the old POSIX_FADV_DONTNEED behavior and implement the less
   aggressive page cache invalidation policy using POSIX_FADV_NOREUSE
 - fix comments in the code

[PATCH v3 1/2] mm: introduce __invalidate_mapping_pages()
[PATCH v3 2/2] fadvise: implement POSIX_FADV_NOREUSE

 include/linux/fs.h |    7 +++++--
 mm/fadvise.c       |   11 ++++++-----
 mm/swap.c          |    2 +-
 mm/truncate.c      |   40 ++++++++++++++++++++++++++++++----------
 4 files changed, 42 insertions(+), 18 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
