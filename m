Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 390196B02AB
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:12 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p53so306367154qtp.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:12 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id c9si14789825qkb.271.2016.09.26.08.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:11 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 07/12] mm: hwpoison: fix race between unpoisoning and freeing migrate source page
Date: Mon, 26 Sep 2016 11:22:29 -0400
Message-Id: <20160926152234.14809-8-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

During testing thp migration, I saw the BUG_ON triggered due to the race between
soft offline and unpoison (what I actually saw was "bad page" warning of freeing
page with PageActive set, then subsequent bug messages differ each time.)

I tried to solve similar problem a few times (see commit f4c18e6f7b5b ("mm:
check __PG_HWPOISON separately from PAGE_FLAGS_CHECK_AT_*",) but the new
workload brings out a new problem of the previous solution.

Let's say that unpoison never works well if the target page is not properly
contained,) so now I'm going in the direction of limiting unpoison function
(as commit 230ac719c500 ("mm/hwpoison: don't try to unpoison containment-failed
pages" does). This patch takes another step in the direction by ensuring that
the target page is kicked out from any pcplist. With this change, the dirty hack
of calling put_page() instead of putback_lru_page() when migration reason is
MR_MEMORY_FAILURE is not necessary any more, so it's reverted.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index de88f33..e105f91 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1435,6 +1435,13 @@ int unpoison_memory(unsigned long pfn)
 		return 0;
 	}
 
+	/*
+	 * Soft-offlined pages might stay in PCP list because it's freed via
+	 * putback_lru_page(), and such pages shouldn't be unpoisoned because
+	 * it could cause list corruption. So let's drain pages to avoid that.
+	 */
+	shake_page(page, 0);
+
 	nr_pages = 1 << compound_order(page);
 
 	if (!get_hwpoison_page(p)) {
@@ -1678,7 +1685,8 @@ static int __soft_offline_page(struct page *page, int flags)
 				pfn, ret, page->flags);
 			if (ret > 0)
 				ret = -EIO;
-		}
+		} else if (!TestSetPageHWPoison(page))
+			num_poisoned_pages_inc();
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",
 			pfn, ret, page_count(page), page->flags);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
