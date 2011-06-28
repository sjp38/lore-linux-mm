Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7FADA9000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 23:46:09 -0400 (EDT)
Subject: [patch]mm: __tlb_remove_page checks correct batch
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 28 Jun 2011 11:46:07 +0800
Message-ID: <1309232767.15392.200.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: a.p.zijlstra@chello.nl, linux-mm <linux-mm@kvack.org>

__tlb_remove_page switchs to a new batch page, but still checks space in the
old batch. This check always fails, and causes force tlb flush.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/memory.c b/mm/memory.c
index 40b7531..9b8a01d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -305,6 +305,7 @@ int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	if (batch->nr == batch->max) {
 		if (!tlb_next_batch(tlb))
 			return 0;
+		batch = tlb->active;
 	}
 	VM_BUG_ON(batch->nr > batch->max);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
