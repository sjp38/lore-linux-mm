Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 12C21900234
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 09:49:46 -0400 (EDT)
From: Andrea Righi <andrea@betterlinux.com>
Subject: [PATCH v3 2/2] fadvise: implement POSIX_FADV_NOREUSE
Date: Fri, 24 Jun 2011 15:49:10 +0200
Message-Id: <1308923350-7932-3-git-send-email-andrea@betterlinux.com>
In-Reply-To: <1308923350-7932-1-git-send-email-andrea@betterlinux.com>
References: <1308923350-7932-1-git-send-email-andrea@betterlinux.com>
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

[1] http://marc.info/?l=rsync&m=128885034930933&w=2
[2] https://lkml.org/lkml/2011/2/20/57
[3] http://lists.samba.org/archive/rsync/2010-November/025827.html
[4] https://lkml.org/lkml/2011/6/23/35

Signed-off-by: Andrea Righi <andrea@betterlinux.com>
---
 mm/fadvise.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index 8d723c9..bcc79ac 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -33,7 +33,7 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 	pgoff_t start_index;
 	pgoff_t end_index;
 	unsigned long nrpages;
-	int ret = 0;
+	int ret = 0, force = true;
 
 	if (!file)
 		return -EBADF;
@@ -106,7 +106,7 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 		nrpages = end_index - start_index + 1;
 		if (!nrpages)
 			nrpages = ~0UL;
-		
+
 		ret = force_page_cache_readahead(mapping, file,
 				start_index,
 				nrpages);
@@ -114,7 +114,8 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 			ret = 0;
 		break;
 	case POSIX_FADV_NOREUSE:
-		break;
+		/* Reduce cache eligibility */
+		force = false;
 	case POSIX_FADV_DONTNEED:
 		if (!bdi_write_congested(mapping->backing_dev_info))
 			filemap_flush(mapping);
@@ -124,8 +125,8 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 		end_index = (endbyte >> PAGE_CACHE_SHIFT);
 
 		if (end_index >= start_index)
-			invalidate_mapping_pages(mapping, start_index,
-						end_index);
+			__invalidate_mapping_pages(mapping, start_index,
+						end_index, force);
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
