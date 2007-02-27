Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1RJZTAK020241
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 14:35:29 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1RJZOrS537624
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 12:35:24 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1RJZNfi023957
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 12:35:24 -0700
From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/5] lumpy: ensure that we compare PageActive and active safely
References: <exportbomb.1172604830@kernel>
Message-ID: <e64dea44318a03a559d7a230d9b14e42@kernel>
Date: Tue, 27 Feb 2007 11:35:23 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Now that we are passing in a boolean active flag we need to
ensure that the result of PageActive(page) is comparible
to that boolean.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b878d54..2bfad79 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -632,7 +632,12 @@ static int __isolate_lru_page(struct page *page, int active)
 {
 	int ret = -EINVAL;
 
-	if (PageLRU(page) && (PageActive(page) == active)) {
+	/*
+	 * When checking the active state, we need to be sure we are
+	 * dealing with comparible boolean values.  Take the logical not
+	 * of each.
+	 */
+	if (PageLRU(page) && (!PageActive(page) == !active)) {
 		ret = -EBUSY;
 		if (likely(get_page_unless_zero(page))) {
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
