Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 784936B028F
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 13:13:59 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id u8so170700986lbk.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 10:13:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kd3si32270918wjb.84.2016.04.04.10.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 10:13:58 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/3] mm: workingset: only do workingset activations on reads
Date: Mon,  4 Apr 2016 13:13:36 -0400
Message-Id: <1459790018-6630-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
References: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Rik van Riel <riel@redhat.com>

When rewriting a page, the data in that page is replaced with new
data. This means that evicting something else from the active file
list, in order to cache data that will be replaced by something else,
is likely to be a waste of memory.

It is better to save the active list for frequently read pages, because
reads actually use the data that is in the page.

This patch ignores partial writes, because it is unclear whether the
complexity of identifying those is worth any potential performance
gain obtained from better caching pages that see repeated partial
writes at large enough intervals to not get caught by the use-twice
promotion code used for the inactive file list.

Reported-by: Andres Freund <andres@anarazel.de>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/filemap.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index a8c69c8..ca33816 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -713,8 +713,12 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 		 * The page might have been evicted from cache only
 		 * recently, in which case it should be activated like
 		 * any other repeatedly accessed page.
+		 * The exception is pages getting rewritten; evicting other
+		 * data from the working set, only to cache data that will
+		 * get overwritten with something else, is a waste of memory.
 		 */
-		if (shadow && workingset_refault(shadow)) {
+		if (!(gfp_mask & __GFP_WRITE) &&
+		    shadow && workingset_refault(shadow)) {
 			SetPageActive(page);
 			workingset_activation(page);
 		} else
-- 
2.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
