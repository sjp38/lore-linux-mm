Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 073416B0078
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:49 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/16] netvm: Propagate page->pfmemalloc to skb
Date: Thu, 12 Jul 2012 07:40:26 +0100
Message-Id: <1342075232-29267-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075232-29267-1-git-send-email-mgorman@suse.de>
References: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

The skb->pfmemalloc flag gets set to true iff during the slab
allocation of data in __alloc_skb that the the PFMEMALLOC reserves
were used. If the packet is fragmented, it is possible that pages
will be allocated from the PFMEMALLOC reserve without propagating
this information to the skb. This patch propagates page->pfmemalloc
from pages allocated for fragments to the skb.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0336f02..b814bb8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1247,6 +1247,17 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
+	/*
+	 * Propagate page->pfmemalloc to the skb if we can. The problem is
+	 * that not all callers have unique ownership of the page. If
+	 * pfmemalloc is set, we check the mapping as a mapping implies
+	 * page->index is set (index and pfmemalloc share space).
+	 * If it's a valid mapping, we cannot use page->pfmemalloc but we
+	 * do not lose pfmemalloc information as the pages would not be
+	 * allocated using __GFP_MEMALLOC.
+	 */
+	if (page->pfmemalloc && !page->mapping)
+		skb->pfmemalloc	= true;
 	frag->page.p		  = page;
 	frag->page_offset	  = off;
 	skb_frag_size_set(frag, size);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
