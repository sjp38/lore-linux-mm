Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A5D7D6B00EE
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:12:32 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/14] netvm: Propagate page->pfmemalloc to skb
Date: Mon, 20 Jun 2011 14:12:15 +0100
Message-Id: <1308575540-25219-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1308575540-25219-1-git-send-email-mgorman@suse.de>
References: <1308575540-25219-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

The skb->pfmemalloc flag gets set to true iff during the slab
allocation of data in __alloc_skb that the the PFMEMALLOC reserves
were used. If the packet is fragmented, it is possible that pages
will be allocated from the PFMEMALLOC reserve without propagating
this information to the skb. This patch propagates page->pfmemalloc
from pages allocated for fragments to the skb.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/skbuff.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 064d8d4..9f44101 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1124,6 +1124,8 @@ static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
+	if (page->pfmemalloc)
+		skb->pfmemalloc	  = true;
 	frag->page		  = page;
 	frag->page_offset	  = off;
 	frag->size		  = size;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
