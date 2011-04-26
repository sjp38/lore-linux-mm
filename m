Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 703FB9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:37:21 -0400 (EDT)
Date: Tue, 26 Apr 2011 17:37:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] mm: readahead page allocations are OK to fail
Message-ID: <20110426093717.GA28812@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@linux.vnet.ibm.com>

Pass __GFP_NORETRY|__GFP_NOWARN for readahead page allocations.

readahead page allocations are completely optional. They are OK to
fail and in particular shall not trigger OOM on themselves.

Reported-by: Dave Young <hidave.darkstar@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/pagemap.h |    6 ++++++
 mm/readahead.c          |    2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

--- linux-next.orig/include/linux/pagemap.h	2011-04-26 14:27:46.000000000 +0800
+++ linux-next/include/linux/pagemap.h	2011-04-26 17:17:13.000000000 +0800
@@ -219,6 +219,12 @@ static inline struct page *page_cache_al
 	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
 }
 
+static inline struct page *page_cache_alloc_readahead(struct address_space *x)
+{
+	return __page_cache_alloc(mapping_gfp_mask(x) |
+				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN);
+}
+
 typedef int filler_t(void *, struct page *);
 
 extern struct page * find_get_page(struct address_space *mapping,
--- linux-next.orig/mm/readahead.c	2011-04-26 14:27:02.000000000 +0800
+++ linux-next/mm/readahead.c	2011-04-26 17:17:25.000000000 +0800
@@ -180,7 +180,7 @@ __do_page_cache_readahead(struct address
 		if (page)
 			continue;
 
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_readahead(mapping);
 		if (!page)
 			break;
 		page->index = page_offset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
