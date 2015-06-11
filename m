Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD1E6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 19:50:53 -0400 (EDT)
Received: by qgg3 with SMTP id 3so6545665qgg.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 16:50:53 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k199si1272129qhc.57.2015.06.11.16.50.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 16:50:52 -0700 (PDT)
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t5BNnPBl028136
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 16:50:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1uyg6xgsqr-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 16:50:52 -0700
Received: from facebook.com (2401:db00:20:7003:face:0:4d:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 af67f53a109411e5a6fe24be0593f280-8ccd72a0 for <linux-mm@kvack.org>;	Thu, 11
 Jun 2015 16:50:49 -0700
From: Shaohua Li <shli@fb.com>
Subject: [RFC V3] net: don't wait for order-3 page allocation
Date: Thu, 11 Jun 2015 16:50:48 -0700
Message-ID: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org
Cc: davem@davemloft.net, Kernel-team@fb.com, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com, Eric Dumazet <edumazet@google.com>

We saw excessive direct memory compaction triggered by skb_page_frag_refill.
This causes performance issues and add latency. Commit 5640f7685831e0
introduces the order-3 allocation. According to the changelog, the order-3
allocation isn't a must-have but to improve performance. But direct memory
compaction has high overhead. The benefit of order-3 allocation can't
compensate the overhead of direct memory compaction.

This patch makes the order-3 page allocation atomic. If there is no memory
pressure and memory isn't fragmented, the alloction will still success, so we
don't sacrifice the order-3 benefit here. If the atomic allocation fails,
direct memory compaction will not be triggered, skb_page_frag_refill will
fallback to order-0 immediately, hence the direct memory compaction overhead is
avoided. In the allocation failure case, kswapd is waken up and doing
compaction, so chances are allocation could success next time.

alloc_skb_with_frags is the same.

The mellanox driver does similar thing, if this is accepted, we must fix
the driver too.

V3: fix the same issue in alloc_skb_with_frags as pointed out by Eric
V2: make the changelog clearer

Cc: Eric Dumazet <edumazet@google.com>
Cc: Chris Mason <clm@fb.com>
Cc: Debabrata Banerjee <dbavatar@gmail.com>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 net/core/skbuff.c | 2 +-
 net/core/sock.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3cfff2a..41ec022 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4398,7 +4398,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
 
 		while (order) {
 			if (npages >= 1 << order) {
-				page = alloc_pages(gfp_mask |
+				page = alloc_pages((gfp_mask & ~__GFP_WAIT) |
 						   __GFP_COMP |
 						   __GFP_NOWARN |
 						   __GFP_NORETRY,
diff --git a/net/core/sock.c b/net/core/sock.c
index 292f422..e9855a4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
 
 	pfrag->offset = 0;
 	if (SKB_FRAG_PAGE_ORDER) {
-		pfrag->page = alloc_pages(gfp | __GFP_COMP |
+		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
 					  __GFP_NOWARN | __GFP_NORETRY,
 					  SKB_FRAG_PAGE_ORDER);
 		if (likely(pfrag->page)) {
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
