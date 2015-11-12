Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id CE2EB6B0256
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 18:42:10 -0500 (EST)
Received: by wmec201 with SMTP id c201so57694223wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:42:10 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a6si1438916wmh.59.2015.11.12.15.42.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 15:42:09 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 03/14] net: tcp_memcontrol: properly detect ancestor socket pressure
Date: Thu, 12 Nov 2015 18:41:22 -0500
Message-Id: <1447371693-25143-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When charging socket memory, the code currently checks only the local
page counter for excess to determine whether the memcg is under socket
pressure. But even if the local counter is fine, one of the ancestors
could have breached its limit, which should also force this child to
enter socket pressure. This currently doesn't happen.

Fix this by using page_counter_try_charge() first. If that fails, it
means that either the local counter or one of the ancestors are in
excess of their limit, and the child should enter socket pressure.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/net/sock.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index bbf7c2c..c4b33c9 100644
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
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
