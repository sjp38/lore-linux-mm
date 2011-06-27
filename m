Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C10886B011C
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 09:30:21 -0400 (EDT)
From: Andrea Righi <andrea@betterlinux.com>
Subject: [PATCH v4 2/2] fadvise: move active pages to inactive list with POSIX_FADV_DONTNEED
Date: Mon, 27 Jun 2011 15:29:21 +0200
Message-Id: <1309181361-14633-3-git-send-email-andrea@betterlinux.com>
In-Reply-To: <1309181361-14633-1-git-send-email-andrea@betterlinux.com>
References: <1309181361-14633-1-git-send-email-andrea@betterlinux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Theodore Tso <tytso@mit.edu>, Shaohua Li <shaohua.li@intel.com>, =?UTF-8?q?P=C3=A1draig=20Brady?= <P@draigBrady.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

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

With the following solution when POSIX_FADV_DONTNEED is called for an
active page instead of removing it from the page cache it is added to
the tail of the inactive list. Otherwise, if it's already in the
inactive list the page is removed from the page cache. Pages mapped by
other processes or unevictable pages are not touched at all.

In this way if the backup was the only user of a page, that page will be
immediately removed from the page cache by calling POSIX_FADV_DONTNEED.
If the page was also touched by other processes it'll be moved to the
inactive list, having another chance of being re-added to the working
set, or simply reclaimed when memory is needed.

Previous discussion about this topic can be found in [4].

 [1] http://marc.info/?l=rsync&m=128885034930933&w=2
 [2] https://lkml.org/lkml/2011/2/20/57
 [3] http://lists.samba.org/archive/rsync/2010-November/025827.html
 [4] http://marc.info/?l=linux-kernel&m=130877950220314&w=2

Signed-off-by: Andrea Righi <andrea@betterlinux.com>
---
 mm/fadvise.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index 8d723c9..a59c1af 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -106,7 +106,7 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 		nrpages = end_index - start_index + 1;
 		if (!nrpages)
 			nrpages = ~0UL;
-		
+
 		ret = force_page_cache_readahead(mapping, file,
 				start_index,
 				nrpages);
@@ -123,9 +123,16 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
 		end_index = (endbyte >> PAGE_CACHE_SHIFT);
 
+		/*
+		 * Reduce cache eligibility.
+		 *
+		 * This does not guarantee that pages are always dropped from
+		 * page cache: active pages will be moved to the tail of the
+		 * inactive list; inactive pages will be dropped if possible.
+		 */
 		if (end_index >= start_index)
-			invalidate_mapping_pages(mapping, start_index,
-						end_index);
+			__invalidate_mapping_pages(mapping, start_index,
+						end_index, false);
 		break;
 	default:
 		ret = -EINVAL;
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
