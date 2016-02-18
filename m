Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id BFAB4828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 15:37:41 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so42080379wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 12:37:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ji7si12796139wjb.247.2016.02.18.12.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 12:37:40 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [RFC PATCH] proc: do not include shmem and driver pages in /proc/meminfo::Cached
Date: Thu, 18 Feb 2016 15:36:41 -0500
Message-Id: <1455827801-13082-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, kernel-team@fb.com

Even before we added MemAvailable, users knew that page cache is
easily convertible to free memory on pressure, and estimated their
"available" memory by looking at the sum of MemFree, Cached, Buffers.
However, "Cached" is calculated using NR_FILE_PAGES, which includes
shmem and random driver pages inserted into the page tables; neither
of which are easily reclaimable, or reclaimable at all. Reclaiming
shmem requires swapping, which is slow. And unlike page cache, which
has fairly conservative dirty limits, all of shmem needs to be written
out before becoming evictable. Without swap, shmem is not evictable at
all. And driver pages certainly never are.

Calling these pages "Cached" is misleading and has resulted in broken
formulas in userspace. They misrepresent the memory situation and
cause either waste or unexpected OOM kills. With 64-bit and per-cpu
memory we are way past the point where the relationship between
virtual and physical memory is meaningful and users can rely on
overcommit protection. OOM kills can not be avoided without wasting
enormous amounts of memory this way. This shifts the management burden
toward userspace, toward applications monitoring their environment and
adjusting their operations. And so where statistics like /proc/meminfo
used to be more informational, we have more and more software relying
on them to make automated decisions based on utilization.

But if userspace is supposed to take over responsibility, it needs a
clear and accurate kernel interface to base its judgement on. And one
of the requirements is certainly that memory consumers with wildly
different reclaimability are not conflated. Adding MemAvailable is a
good step in that direction, but there is software like Sigar[1] in
circulation that might not get updated anytime soon. And even then,
new users will continue to go for the intuitive interpretation of the
Cached item. We can't blame them. There are years of tradition behind
it, starting with the way free(1) and vmstat(8) have always reported
free, buffers, cached. And try as we might, using "Cached" for
unevictable memory is never going to be obvious.

The semantics of Cached including shmem and kernel pages have been
this way forever, dictated by the single-LRU implementation rather
than optimal semantics. So it's an uncomfortable proposal to change it
now. But what other way to fix this for existing users? What other way
to make the interface more intuitive for future users? And what could
break by removing it now? I guess somebody who already subtracts Shmem
from Cached.

What are your thoughts on this?

[1] https://github.com/hyperic/sigar/blob/master/src/os/linux/linux_sigar.c#L323
---
 fs/proc/meminfo.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index df4661abadc4..e19126be1dca 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -43,14 +43,14 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	si_swapinfo(&i);
 	committed = percpu_counter_read_positive(&vm_committed_as);
 
-	cached = global_page_state(NR_FILE_PAGES) -
-			total_swapcache_pages() - i.bufferram;
-	if (cached < 0)
-		cached = 0;
-
 	for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
 		pages[lru] = global_page_state(NR_LRU_BASE + lru);
 
+	cached = pages[LRU_ACTIVE_FILE] + pages[LRU_INACTIVE_FILE];
+	cached -= i.bufferram;
+	if (cached < 0)
+		cached = 0;
+
 	for_each_zone(zone)
 		wmark_low += zone->watermark[WMARK_LOW];
 
-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
