Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8IFWujb003369
	for <linux-mm@kvack.org>; Mon, 18 Sep 2006 11:32:56 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8IFWeZ1252404
	for <linux-mm@kvack.org>; Mon, 18 Sep 2006 11:32:41 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8IFWeg0018851
	for <linux-mm@kvack.org>; Mon, 18 Sep 2006 11:32:40 -0400
Subject: [TRIVIAL PATCH] mm: Make filemap_nopage use NOPAGE_SIGBUS
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Mon, 18 Sep 2006 10:32:35 -0500
Message-Id: <1158593555.12797.33.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: trivial@kernel.org
Cc: "ADAM G. LITKE [imap]" <agl@us.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

While reading trough filemap_nopage() I found the 'return NULL'
statements a bit confusing since we already have two constants defined
for ->nopage error conditions.  Since a NULL return value really means
NOPAGE_SIGBUS, just return that to make the code more readable.

Signed-off-by: Adam Litke <agl@us.ibm.com> 

 filemap.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)
diff -upN reference/mm/filemap.c current/mm/filemap.c
--- reference/mm/filemap.c
+++ current/mm/filemap.c
@@ -1454,7 +1454,7 @@ outside_data_content:
 	 * accessible..
 	 */
 	if (area->vm_mm == current->mm)
-		return NULL;
+		return NOPAGE_SIGBUS;
 	/* Fall through to the non-read-ahead case */
 no_cached_page:
 	/*
@@ -1479,7 +1479,7 @@ no_cached_page:
 	 */
 	if (error == -ENOMEM)
 		return NOPAGE_OOM;
-	return NULL;
+	return NOPAGE_SIGBUS;
 
 page_not_uptodate:
 	if (!did_readaround) {
@@ -1548,7 +1548,7 @@ page_not_uptodate:
 	 */
 	shrink_readahead_size_eio(file, ra);
 	page_cache_release(page);
-	return NULL;
+	return NOPAGE_SIGBUS;
 }
 EXPORT_SYMBOL(filemap_nopage);
 
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
