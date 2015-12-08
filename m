Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1CBFD6B0256
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:30:53 -0500 (EST)
Received: by wmww144 with SMTP id w144so34316849wmw.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:30:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l10si4867715wjx.231.2015.12.08.07.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 07:30:51 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 02/14] net: tcp_memcontrol: properly detect ancestor socket pressure
Date: Tue,  8 Dec 2015 10:30:12 -0500
Message-Id: <1449588624-9220-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

When charging socket memory, the code currently checks only the local
page counter for excess to determine whether the memcg is under socket
pressure. But even if the local counter is fine, one of the ancestors
could have breached its limit, which should also force this child to
enter socket pressure. This currently doesn't happen.

Fix this by using page_counter_try_charge() first. If that fails, it
means that either the local counter or one of the ancestors are in
excess of their limit, and the child should enter socket pressure.

Fixes: 3e32cb2e0a12 ("mm: memcontrol: lockless page counters")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: David S. Miller <davem@davemloft.net>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/net/sock.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7f89e4b..8133c71 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1190,11 +1190,13 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
 					      unsigned long amt,
 					      int *parent_status)
 {
-	page_counter_charge(&prot->memory_allocated, amt);
+	struct page_counter *counter;
+
+	if (page_counter_try_charge(&prot->memory_allocated, amt, &counter))
+		return;
 
-	if (page_counter_read(&prot->memory_allocated) >
-	    prot->memory_allocated.limit)
-		*parent_status = OVER_LIMIT;
+	page_counter_charge(&prot->memory_allocated, amt);
+	*parent_status = OVER_LIMIT;
 }
 
 static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
