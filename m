Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 609046B008C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 23:47:29 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 10 Jun 2012 21:47:28 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 522B53E4004E
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:47:25 +0000 (WET)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5B3lPxc204252
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 21:47:25 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5B3lOD0025804
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 21:47:24 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH V2] mm/buddy: cleanup on should_fail_alloc_page
Date: Mon, 11 Jun 2012 12:47:22 +0900
Message-Id: <1339386442-29400-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

Currently, function should_fail() has "bool" for its return value, so
it's reasonable to change the return value of function should_fail_alloc_page()
into "bool" as well.

The patch does cleanup on function should_fail_alloc_page() to  have "bool"
for its return value.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..7892f84 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1529,16 +1529,16 @@ static int __init setup_fail_page_alloc(char *str)
 }
 __setup("fail_page_alloc=", setup_fail_page_alloc);
 
-static int should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
+static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
 {
 	if (order < fail_page_alloc.min_order)
-		return 0;
+		return false;
 	if (gfp_mask & __GFP_NOFAIL)
-		return 0;
+		return false;
 	if (fail_page_alloc.ignore_gfp_highmem && (gfp_mask & __GFP_HIGHMEM))
-		return 0;
+		return false;
 	if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & __GFP_WAIT))
-		return 0;
+		return false;
 
 	return should_fail(&fail_page_alloc.attr, 1 << order);
 }
@@ -1578,9 +1578,9 @@ late_initcall(fail_page_alloc_debugfs);
 
 #else /* CONFIG_FAIL_PAGE_ALLOC */
 
-static inline int should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
+static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
 {
-	return 0;
+	return false;
 }
 
 #endif /* CONFIG_FAIL_PAGE_ALLOC */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
