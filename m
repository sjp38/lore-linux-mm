Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C27E46B01C1
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 01:43:55 -0400 (EDT)
Date: Tue, 15 Jun 2010 15:43:44 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: vmscan fix mapping use after free
Message-ID: <20100615054343.GE6138@laptop>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
 <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
 <20100614231144.GG6590@dastard>
 <20100614162143.04783749.akpm@linux-foundation.org>
 <20100615003943.GK6590@dastard>
 <4C16D46D.3020302@redhat.com>
 <20100614184544.32b1c371.akpm@linux-foundation.org>
 <4C16FCAE.4050607@redhat.com>
 <20100614213732.034b4a13.akpm@linux-foundation.org>
 <20100615051242.GD6138@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615051242.GD6138@laptop>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 03:12:42PM +1000, Nick Piggin wrote:
> > Once that page is unlocked, we can't touch *mapping - its inode can be
> > concurrently reclaimed.  Although I guess the technique in
> > handle_write_error() can be reused.
> 
> Nasty. That guy needs to be using lock_page_nosync().
--

Need lock_page_nosync here because we have no reference to the mapping when
taking the page lock.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -296,7 +296,7 @@ static int may_write_to_queue(struct bac
 static void handle_write_error(struct address_space *mapping,
 				struct page *page, int error)
 {
-	lock_page(page);
+	lock_page_nosync(page);
 	if (page_mapping(page) == mapping)
 		mapping_set_error(mapping, error);
 	unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
