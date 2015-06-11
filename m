Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1E86B0038
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 18:27:21 -0400 (EDT)
Received: by padev16 with SMTP id ev16so10380000pad.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:27:21 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id pm1si2656462pbc.4.2015.06.11.15.27.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 15:27:20 -0700 (PDT)
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t5BMOs35002770
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:27:19 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1uy7af17qd-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:27:19 -0700
Received: from facebook.com (2401:db00:20:7003:face:0:4d:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 047b2ac6108911e584310002c9521c9e-3d1dc2a0 for <linux-mm@kvack.org>;	Thu, 11
 Jun 2015 15:27:17 -0700
From: Shaohua Li <shli@fb.com>
Subject: [RFC v2] net: use atomic allocation for order-3 page allocation
Date: Thu, 11 Jun 2015 15:27:16 -0700
Message-ID: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
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

The mellanox driver does similar thing, if this is accepted, we must fix
the driver too.

V2: make the changelog clearer

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 net/core/sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
