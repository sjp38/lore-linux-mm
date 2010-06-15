Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0EF6B0250
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 11:44:31 -0400 (EDT)
Date: Tue, 15 Jun 2010 16:44:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615154410.GP26788@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-12-git-send-email-mel@csn.ul.ie> <20100614231144.GG6590@dastard> <20100614162143.04783749.akpm@linux-foundation.org> <20100615003943.GK6590@dastard> <20100614183957.ad0cdb58.akpm@linux-foundation.org> <20100615032034.GR6590@dastard> <20100614211515.dd9880dc.akpm@linux-foundation.org> <20100615114342.GD26788@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100615114342.GD26788@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 12:43:42PM +0100, Mel Gorman wrote:
> <SNIP on whether sorting should be in page cache or block layer>
> 
> > It would be interesting to code up a little test patch though, see if
> > there's benefit to be had going down this path.
> > 
> 
> I'll do this just to see what it looks like. To be frank, I lack taste when
> it comes to how the block layer and filesystem should behave so am having
> troube deciding if sorting the pages prior to submission is a good thing or
> if it would just encourage bad or lax behaviour in the IO submission queueing.
> 

The patch to sort the list being cleaned by reclaim looks like this.
It's not actually tested

vmscan: Sort pages being queued for IO before submitting to the filesystem

While page reclaim submits dirty pages in batch, it doesn't change the
order in which the IO is issued - it is still issued in LRU order. Given
that they are issued in a short period of time now, rather than across a
longer scan period, it is likely that it will not be any faster as:

        a) IO will not be started as soon, and
        b) the IO scheduler still only has a small re-ordering
           window and will choke just as much on random IO patterns.

This patch uses list_sort() function to sort
the list; sorting the list of pages by mapping and page->index
within the mapping would result in all the pages on each mapping
being sent down in ascending offset order at once - exactly how the
filesystems want IO to be sent to it.

Credit mostly goes to Dave Chinner for this idea and the changelog text.

----

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 68b3d22..02ab246 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -32,6 +32,7 @@
 #include <linux/topology.h>
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
+#include <linux/list_sort.h>
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
 #include <linux/delay.h>
@@ -651,6 +652,34 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
 		__pagevec_free(&freed_pvec);
 }
 
+/* Sort based on mapping then index */
+static int page_writeback_cmp(void *data, struct list_head *a, struct list_head *b)
+{
+	struct page *ap = list_entry(a, struct page, lru);
+	struct page *bp = list_entry(b, struct page, lru);
+	pgoff_t diff;
+
+	/*
+	 * Page not locked but it's not critical, the mapping is just for sorting
+	 * If the mapping is no longer valid, it's of little consequence
+	 */
+	if (ap->mapping != bp->mapping) {
+		if (ap->mapping < bp->mapping)
+			return -1;
+		if (ap->mapping > bp->mapping)
+			return 1;
+		return 0;
+	}
+	
+	/* Then index */
+	diff = ap->index - bp->index;
+	if (diff < 0)
+		return -1;
+	if (diff > 0)
+		return 1;
+	return 0;
+}
+
 static noinline_for_stack void clean_page_list(struct list_head *page_list,
 				struct scan_control *sc)
 {
@@ -660,6 +689,8 @@ static noinline_for_stack void clean_page_list(struct list_head *page_list,
 	if (!sc->may_writepage)
 		return;
 
+	list_sort(NULL, page_list, page_writeback_cmp);
+
 	/* Write the pages out to disk in ranges where possible */
 	while (!list_empty(page_list)) {
 		struct address_space *mapping;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
