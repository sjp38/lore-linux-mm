Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id D1B496B0068
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 21:39:17 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 21:39:16 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B9F8C38C8056
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 21:39:14 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5K1dE4W154214
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 21:39:14 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5K1dDuY009467
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 21:39:14 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH RESEND 1/2] mm/compaction: cleanup on compaction_deferred
Date: Wed, 20 Jun 2012 09:39:07 +0800
Message-Id: <1340156348-18875-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, minchan@kernel.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

When CONFIG_COMPACTION is enabled, compaction_deferred() tries
to recalculate the deferred limit again, which isn't necessary.

When CONFIG_COMPACTION is disabled, compaction_deferred() should
return "true" or "false" since it has "bool" for its return value.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/compaction.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 51a90b7..133ddcf 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -58,7 +58,7 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	if (++zone->compact_considered > defer_limit)
 		zone->compact_considered = defer_limit;
 
-	return zone->compact_considered < (1UL << zone->compact_defer_shift);
+	return zone->compact_considered < defer_limit;
 }
 
 #else
@@ -85,7 +85,7 @@ static inline void defer_compaction(struct zone *zone, int order)
 
 static inline bool compaction_deferred(struct zone *zone, int order)
 {
-	return 1;
+	return true;
 }
 
 #endif /* CONFIG_COMPACTION */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
