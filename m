Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A13A6B0261
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 04:59:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so12902443wmw.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 01:59:53 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id a131si39030560wme.68.2016.04.15.01.59.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 01:59:51 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 27EF11DC06E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 08:59:51 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 02/28] mm, page_alloc: Use new PageAnonHead helper in the free page fast path
Date: Fri, 15 Apr 2016 09:58:54 +0100
Message-Id: <1460710760-32601-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The PageAnon check always checks for compound_head but this is a relatively
expensive check if the caller already knows the page is a head page. This
patch creates a helper and uses it in the page free path which only operates
on head pages.

With this patch and "Only check PageCompound for high-order pages", the
performance difference on a page allocator microbenchmark is;

                                           4.6.0-rc2                  4.6.0-rc2
                                             vanilla           nocompound-v1r20
Min      alloc-odr0-1               425.00 (  0.00%)           417.00 (  1.88%)
Min      alloc-odr0-2               313.00 (  0.00%)           308.00 (  1.60%)
Min      alloc-odr0-4               257.00 (  0.00%)           253.00 (  1.56%)
Min      alloc-odr0-8               224.00 (  0.00%)           221.00 (  1.34%)
Min      alloc-odr0-16              208.00 (  0.00%)           205.00 (  1.44%)
Min      alloc-odr0-32              199.00 (  0.00%)           199.00 (  0.00%)
Min      alloc-odr0-64              195.00 (  0.00%)           193.00 (  1.03%)
Min      alloc-odr0-128             192.00 (  0.00%)           191.00 (  0.52%)
Min      alloc-odr0-256             204.00 (  0.00%)           200.00 (  1.96%)
Min      alloc-odr0-512             213.00 (  0.00%)           212.00 (  0.47%)
Min      alloc-odr0-1024            219.00 (  0.00%)           219.00 (  0.00%)
Min      alloc-odr0-2048            225.00 (  0.00%)           225.00 (  0.00%)
Min      alloc-odr0-4096            230.00 (  0.00%)           231.00 ( -0.43%)
Min      alloc-odr0-8192            235.00 (  0.00%)           234.00 (  0.43%)
Min      alloc-odr0-16384           235.00 (  0.00%)           234.00 (  0.43%)
Min      free-odr0-1                215.00 (  0.00%)           191.00 ( 11.16%)
Min      free-odr0-2                152.00 (  0.00%)           136.00 ( 10.53%)
Min      free-odr0-4                119.00 (  0.00%)           107.00 ( 10.08%)
Min      free-odr0-8                106.00 (  0.00%)            96.00 (  9.43%)
Min      free-odr0-16                97.00 (  0.00%)            87.00 ( 10.31%)
Min      free-odr0-32                91.00 (  0.00%)            83.00 (  8.79%)
Min      free-odr0-64                89.00 (  0.00%)            81.00 (  8.99%)
Min      free-odr0-128               88.00 (  0.00%)            80.00 (  9.09%)
Min      free-odr0-256              106.00 (  0.00%)            95.00 ( 10.38%)
Min      free-odr0-512              116.00 (  0.00%)           111.00 (  4.31%)
Min      free-odr0-1024             125.00 (  0.00%)           118.00 (  5.60%)
Min      free-odr0-2048             133.00 (  0.00%)           126.00 (  5.26%)
Min      free-odr0-4096             136.00 (  0.00%)           130.00 (  4.41%)
Min      free-odr0-8192             138.00 (  0.00%)           130.00 (  5.80%)
Min      free-odr0-16384            137.00 (  0.00%)           130.00 (  5.11%)

There is a sizable boost to the free allocator performance. While there
is an apparent boost on the allocation side, it's likely a co-incidence
or due to the patches slightly reducing cache footprint.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/page-flags.h | 7 ++++++-
 mm/page_alloc.c            | 2 +-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index f4ed4f1b0c77..ccd04ee1ba2d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -371,10 +371,15 @@ PAGEFLAG(Idle, idle, PF_ANY)
 #define PAGE_MAPPING_KSM	2
 #define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
 
+static __always_inline int PageAnonHead(struct page *page)
+{
+	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
+}
+
 static __always_inline int PageAnon(struct page *page)
 {
 	page = compound_head(page);
-	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
+	return PageAnonHead(page);
 }
 
 #ifdef CONFIG_KSM
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5d205bcfe10d..6812de41f698 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1048,7 +1048,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 			bad += free_pages_check(page + i);
 		}
 	}
-	if (PageAnon(page))
+	if (PageAnonHead(page))
 		page->mapping = NULL;
 	bad += free_pages_check(page);
 	if (bad)
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
