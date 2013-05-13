Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A85276B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 06:21:27 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/4] Obey mark_page_accessed hint given by filesystems v2
Date: Mon, 13 May 2013 11:21:18 +0100
Message-Id: <1368440482-27909-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>
Cc: Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

This series is in need of Tested-by's and some reviewing before it can be
pushed anywhere. The performance of the tests I ran were not sensitive
to the premature reclaim of buffer pages although I was able to show
the average age of buffer pages is now higher as expected. Also note the
comments I make about the average age of file pages versus buffer pages
at the end of this mail that I'd like filesystem people to think about.

Changelog since V1
o Add tracepoint to model age of page types			(mel)

Andrew Perepechko reported a problem whereby pages are being prematurely
evicted as the mark_page_accessed() hint is ignored for pages that are
currently on a pagevec -- http://www.spinics.net/lists/linux-ext4/msg37340.html .
Alexey Lyahkov and Robin Dong have also reported problems recently that
could be due to hot pages reaching the end of the inactive list too quickly
and be reclaimed.

Rather than addressing this on a per-filesystem basis, this series aims
to fix the mark_page_accessed() interface by deferring what LRU a page
is added to pagevec drain time and allowing mark_page_accessed() to call
SetPageActive on a pagevec page.

Patch 1 adds two tracepoints for LRU page activation and insertion. Using
	these processes it's possible to build a model of pages in the
	LRU that can be processed offline.

Patch 2 defers making the decision on what LRU to add a page to until when
	the pagevec is drained.

Patch 3 searches the local pagevec for pages to mark PageActive on
	mark_page_accessed. The changelog explains why only the local
	pagevec is examined.

Patch 4 tidies up the API.

postmark, a dd-based test and fs-mark both single and threaded mode were
run but none of them showed any performance degradation or gain as a result
of the patch.

Using patch 1, I built a *very* basic model of the LRU to examine
offline what the average age of different page types on the LRU were in
milliseconds. Of course, capturing the trace distorts the test as it's
written to local disk but it does not matter for the purposes of this test.
The average age of pages in milliseconds were

				    vanilla deferdrain
Average age mapped anon:               1454       1855
Average age mapped file:             127841     143755
Average age unmapped anon:               85        157
Average age unmapped file:            73633      39368
Average age unmapped buffers:         74054     116636

The LRU activity was mostly files which you'd expect for a dd-based
workload. Note that the average age of buffer pages is increased by the
series and it is expected this is due to the fact that the buffer pages are
now getting added to the active list when drained from the pagevecs. Note
that the average age of the unmapped file data is decreased as they are
still added to the inactive list and are reclaimed before the buffers. There
is no guarantee this is a universal win for all workloads and it would be
nice if the filesystem people gave some thought as to whether this decision
is generally a win or a loss.

 fs/cachefiles/rdwr.c           | 30 ++++----------
 fs/nfs/dir.c                   |  7 +---
 include/linux/pagevec.h        | 34 +---------------
 include/trace/events/pagemap.h | 89 ++++++++++++++++++++++++++++++++++++++++++
 mm/swap.c                      | 82 +++++++++++++++++++++++++-------------
 5 files changed, 154 insertions(+), 88 deletions(-)
 create mode 100644 include/trace/events/pagemap.h

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
