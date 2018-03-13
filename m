Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCF36B026E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:27:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t24so7447992pfe.20
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:27:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k128si115588pgc.609.2018.03.13.06.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 06:27:06 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v9 49/61] shmem: Convert shmem_partial_swap_usage to XArray
Date: Tue, 13 Mar 2018 06:26:27 -0700
Message-Id: <20180313132639.17387-50-willy@infradead.org>
In-Reply-To: <20180313132639.17387-1-willy@infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Simpler code because the xarray takes care of things like the limit and
dereferencing the slot.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/shmem.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index cfbffb4b47a2..707430003ec7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -658,29 +658,17 @@ static int shmem_free_swap(struct address_space *mapping,
 unsigned long shmem_partial_swap_usage(struct address_space *mapping,
 						pgoff_t start, pgoff_t end)
 {
-	struct radix_tree_iter iter;
-	void **slot;
+	XA_STATE(xas, &mapping->i_pages, start);
 	struct page *page;
 	unsigned long swapped = 0;
 
 	rcu_read_lock();
-
-	radix_tree_for_each_slot(slot, &mapping->i_pages, &iter, start) {
-		if (iter.index >= end)
-			break;
-
-		page = radix_tree_deref_slot(slot);
-
-		if (radix_tree_deref_retry(page)) {
-			slot = radix_tree_iter_retry(&iter);
-			continue;
-		}
-
+	xas_for_each(&xas, page, end - 1) {
 		if (xa_is_value(page))
 			swapped++;
 
 		if (need_resched()) {
-			slot = radix_tree_iter_resume(slot, &iter);
+			xas_pause(&xas);
 			cond_resched_rcu();
 		}
 	}
-- 
2.16.1
