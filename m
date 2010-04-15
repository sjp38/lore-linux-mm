Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2F1556B0201
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:06:00 -0400 (EDT)
Message-Id: <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org>
From: Suleiman Souhlal <ssouhlal@freebsd.org>
In-Reply-To: <20100415131106.D174.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Apple Message framework v936)
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if current is kswapd
Date: Thu, 15 Apr 2010 01:05:57 -0700
References: <20100415013436.GO2493@dastard> <20100415130212.D16E.A69D9226@jp.fujitsu.com> <20100415131106.D174.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, suleiman@google.com
List-ID: <linux-mm.kvack.org>


On Apr 14, 2010, at 9:11 PM, KOSAKI Motohiro wrote:

> Now, vmscan pageout() is one of IO throuput degression source.
> Some IO workload makes very much order-0 allocation and reclaim
> and pageout's 4K IOs are making annoying lots seeks.
>
> At least, kswapd can avoid such pageout() because kswapd don't
> need to consider OOM-Killer situation. that's no risk.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

What's your opinion on trying to cluster the writes done by pageout,  
instead of not doing any paging out in kswapd?
Something along these lines:

     Cluster writes to disk due to memory pressure.

     Write out logically adjacent pages to the one we're paging out
     so that we may get better IOs in these situations:
     These pages are likely to be contiguous on disk to the one we're
     writing out, so they should get merged into a single disk IO.

     Signed-off-by: Suleiman Souhlal <suleiman@google.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c26986c..4e5a613 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -48,6 +48,8 @@

  #include "internal.h"

+#define PAGEOUT_CLUSTER_PAGES	16
+
  struct scan_control {
  	/* Incremented by the number of inactive pages that were scanned */
  	unsigned long nr_scanned;
@@ -350,6 +352,8 @@ typedef enum {
  static pageout_t pageout(struct page *page, struct address_space  
*mapping,
  						enum pageout_io sync_writeback)
  {
+	int i;
+
  	/*
  	 * If the page is dirty, only perform writeback if that write
  	 * will be non-blocking.  To prevent this allocation from being
@@ -408,6 +412,37 @@ static pageout_t pageout(struct page *page,  
struct address_space *mapping,
  		}

  		/*
+		 * Try to write out logically adjacent dirty pages too, if
+		 * possible, to get better IOs, as the IO scheduler should
+		 * merge them with the original one, if the file is not too
+		 * fragmented.
+		 */
+		for (i = 1; i < PAGEOUT_CLUSTER_PAGES; i++) {
+			struct page *p2;
+			int err;
+
+			p2 = find_get_page(mapping, page->index + i);
+			if (p2) {
+				if (trylock_page(p2) == 0) {
+					page_cache_release(p2);
+					break;
+				}
+				if (page_mapped(p2))
+					try_to_unmap(p2, 0);
+				if (PageDirty(p2)) {
+					err = write_one_page(p2, 0);
+					page_cache_release(p2);
+					if (err)
+						break;
+				} else {
+					unlock_page(p2);
+					page_cache_release(p2);
+					break;
+				}
+			}
+		}
+
+		/*
  		 * Wait on writeback if requested to. This happens when
  		 * direct reclaiming a large contiguous area and the
  		 * first attempt to free a range of pages fails.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
