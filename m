Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 379216B13F0
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 19:23:29 -0500 (EST)
From: Andrea Righi <andrea@betterlinux.com>
Subject: [RFC] [PATCH v5 0/3] fadvise: support POSIX_FADV_NOREUSE
Date: Sun, 12 Feb 2012 01:21:35 +0100
Message-Id: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?UTF-8?q?P=C3=A1draig=20Brady?= <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

There were some reported problems in the past about trashing page cache when a
backup software (i.e., rsync) touches a huge amount of pages (see for example
[1]).

This problem was mitigated by the Minchan's patch [2] and a proper use of
fadvise() in the backup software. For example this patch set [3] has been
proposed for inclusion in rsync.

However, there are still other trashing problems: when the backup software
reads all the source files, some of them may be part of the actual working set
of the system. If a POSIX_FADV_DONTNEED is performed _all_ pages are evicted
from pagecache, both the working set and the use-once pages touched only by the
backup.

A previous proposal [4] was to use the POSIX_FADV_NOREUSE hint, currently
implemented as a no-op, to provide a page invalidation policy less agressive
than POSIX_FADV_DONTNEED (by moving active pages to the tail of the inactive
list, and dropping the pages from the inactive list).

However, as correctly pointed out by KOSAKI, this behavior is very different
respect to the POSIX definition:

      POSIX_FADV_NOREUSE
              Specifies that the application expects to access the specified data once and then
              not reuse it thereafter.

The new proposal is to implement POSIX_FADV_NOREUSE as a way to perform a real
drop-behind policy where applications can mark certain intervals of a file as
FADV_NOREUSE before accessing the data.

In this way the marked pages will never blow away the current working set. This
requirement can be satisfied by preventing lru activation of the FADV_NOREUSE
pages. Moreover, all the file cache pages in a FADV_NOREUSE range will be
immediately dropped after a read if the page was not present in the cache
before. The purpose is to preserve as much as possible the previous state of
the file cache memory before reading data in ranges marked via FADV_NOREUSE.

The list of FADV_NOREUSE ranges are maintained into an interval tree [5] inside
the address_space structure (for this a generic interval tree implementation is
also provided by PATCH 1/2). The intervals are dropped when pages are also
dropped from the page cache or when a different caching hint is specified on
the same intervals.

Example:

How this can solve the "backup is trashing my page cache" issue?

The "backup" software can be changed as following:

- before:
  - fd_src = open /path/very_large_file
  - fd_dst = open /backup/very_large_file
  - read from fd_src
  - write to fd_dst
  - close fd_src and fd_dst

- after:
  - fd_src = open /path/large_file
  - fd_dst = open /backup/very_large_file
  - posix_fadvise(fd_src, start, end, POSIX_FADV_NOREUSE)
  - read from fd_src (even multiple times)
  - write to fd_dst
  - posix_fadvise(fd_src, start, end, POSIX_FADV_NORMAL)
  - posix_fadvise(fd_dst, start, end, POSIX_FADV_DONTNEED)
  - close fd_src and fd_dst

Simple test case:

  - read a chunk of 256MB from the middle of a large file (this represents the
    working set)

  - simulate a backup-like software reading the whole file using
    POSIX_FADV_NORMAL, or POSIX_FADV_DONTNEED or POSIX_FADV_NOREUSE

  - re-read the same 256MB chunk from the middle of the file and measure
    the time and the bio submitted (perf stat -e block:block_bio_queue)

The test is done starting both with the working set in the inactive lru list
(the 256MB chunk read once at the beginning of the test) and the working set in
the active lru list (the 256MB chunk read twice at the beginning of the test).

Results:

 inact_working_set = the working set is all in the inactive lru list
   act_working_set = the working set is all in the active lru list

 - block:block_bio_queue (events)
                      inact_working_set act_working_set
  POSIX_FADV_NORMAL               2,052               0
  POSIX_FADV_DONTNEED                 0(*)         2048
  POSIX_FADV_NOREUSE                  0               0

 - elapsed time (sec)
                      inact_working_set act_working_set
  POSIX_FADV_NORMAL               1.013           0.070
  POSIX_FADV_DONTNEED             0.070(*)        1.006
  POSIX_FADV_NOREUSE              0.070           0.070

(*) With POSIX_FADV_DONTNEED I would expect to see the working set pages
dropped from the page cache when it starts in the inactive lru list.

Instead this happens only when we start with the working set all in the active
list. IIUC this happens because when we re-read the pages the second time
they're moved to the per-cpu vector activate_page_pvecs; if the page vector is
not yet drained when we issue the POSIX_FADV_DONTNEED the advice is ignored.

Anyway, for this particular test case the best solution to preserve the state
of the page cache is obviouly the usage of POSIX_FADV_NOREUSE.

Regression test:

 for i in `seq 1 10`; do
    fio --name=fio --directory=. --rw=read --bs=4K --size=1G --numjobs=4 | grep READ:
 done

 - before:
   READ: io=4096.0MB, aggrb=244737KB/s, minb=62652KB/s, maxb=63474KB/s, mint=16916msec, maxt=17138msec
   READ: io=4096.0MB, aggrb=242263KB/s, minb=62019KB/s, maxb=64380KB/s, mint=16678msec, maxt=17313msec
   READ: io=4096.0MB, aggrb=241913KB/s, minb=61929KB/s, maxb=62766KB/s, mint=17107msec, maxt=17338msec
   READ: io=4096.0MB, aggrb=244337KB/s, minb=62550KB/s, maxb=63776KB/s, mint=16836msec, maxt=17166msec
   READ: io=4096.0MB, aggrb=242768KB/s, minb=62148KB/s, maxb=62517KB/s, mint=17175msec, maxt=17277msec
   READ: io=4096.0MB, aggrb=242796KB/s, minb=62155KB/s, maxb=63191KB/s, mint=16992msec, maxt=17275msec
   READ: io=4096.0MB, aggrb=244352KB/s, minb=62554KB/s, maxb=63392KB/s, mint=16938msec, maxt=17165msec
   READ: io=4096.0MB, aggrb=242011KB/s, minb=61954KB/s, maxb=62368KB/s, mint=17216msec, maxt=17331msec
   READ: io=4096.0MB, aggrb=241676KB/s, minb=61869KB/s, maxb=63738KB/s, mint=16846msec, maxt=17355msec
   READ: io=4096.0MB, aggrb=242319KB/s, minb=62033KB/s, maxb=63362KB/s, mint=16946msec, maxt=17309msec

   avg aggrb = 242917KB/s, avg mint = 16965msec, avg maxt = 17267msec

 - after:
   READ: io=4096.0MB, aggrb=243968KB/s, minb=62455KB/s, maxb=63306KB/s, mint=16961msec, maxt=17192msec
   READ: io=4096.0MB, aggrb=242979KB/s, minb=62202KB/s, maxb=63127KB/s, mint=17009msec, maxt=17262msec
   READ: io=4096.0MB, aggrb=242473KB/s, minb=62073KB/s, maxb=62285KB/s, mint=17239msec, maxt=17298msec
   READ: io=4096.0MB, aggrb=244494KB/s, minb=62590KB/s, maxb=63272KB/s, mint=16970msec, maxt=17155msec
   READ: io=4096.0MB, aggrb=244352KB/s, minb=62554KB/s, maxb=63269KB/s, mint=16971msec, maxt=17165msec
   READ: io=4096.0MB, aggrb=241969KB/s, minb=61944KB/s, maxb=63444KB/s, mint=16924msec, maxt=17334msec
   READ: io=4096.0MB, aggrb=243303KB/s, minb=62285KB/s, maxb=62543KB/s, mint=17168msec, maxt=17239msec
   READ: io=4096.0MB, aggrb=243232KB/s, minb=62267KB/s, maxb=63109KB/s, mint=17014msec, maxt=17244msec
   READ: io=4096.0MB, aggrb=241969KB/s, minb=61944KB/s, maxb=62652KB/s, mint=17138msec, maxt=17334msec
   READ: io=4096.0MB, aggrb=241649KB/s, minb=61862KB/s, maxb=62616KB/s, mint=17148msec, maxt=17357msec

   avg aggrb = 243038KB/s, avg mint = 17054msec, avg maxt = 17258msec

No obvious performance regression was found according to this simple test.

Credits:
 - Some of the routines to implement the generic interval tree has been taken
   from the x86 PAT code, that uses interval trees to keep track of PAT ranges
   (in the future it would be interesting to convert also the x86 PAT code to
   use the generic interval tree implementation).

 - The idea to store the FADV_NOREUSE intervals into the address_space
   structure as been inspired by the John's POSIX_FADV_VOLATILE patch [6].

References:
 [1] http://marc.info/?l=rsync&m=128885034930933&w=2
 [2] https://lkml.org/lkml/2011/2/20/57
 [3] http://lists.samba.org/archive/rsync/2010-November/025827.html
 [4] http://thread.gmane.org/gmane.linux.kernel.mm/65493
 [5] http://en.wikipedia.org/wiki/Interval_tree
 [6] http://thread.gmane.org/gmane.linux.kernel/1218654

ChangeLog v4 -> v5:
 - completely new redesign: implement the expected drop-behind policy
   maintaining the list of FADV_NOREUSE ranges inside the file

[PATCH v5 1/3] kinterval: routines to manipulate generic intervals
[PATCH v5 2/3] mm: filemap: introduce mark_page_usedonce
[PATCH v5 3/3] fadvise: implement POSIX_FADV_NOREUSE

 fs/inode.c                |    3 +
 include/linux/fs.h        |   12 ++
 include/linux/kinterval.h |  126 ++++++++++++
 include/linux/swap.h      |    1 +
 lib/Makefile              |    2 +-
 lib/kinterval.c           |  483 +++++++++++++++++++++++++++++++++++++++++++++
 mm/fadvise.c              |   18 ++-
 mm/filemap.c              |   95 +++++++++-
 mm/swap.c                 |   24 +++
 9 files changed, 760 insertions(+), 4 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
