Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8SJA6hZ027439
	for <linux-mm@kvack.org>; Thu, 28 Sep 2006 15:10:06 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8SJ9wtg107000
	for <linux-mm@kvack.org>; Thu, 28 Sep 2006 15:09:58 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8SJ9wNU003429
	for <linux-mm@kvack.org>; Thu, 28 Sep 2006 15:09:58 -0400
Subject: [TRIVIAL PATCH] mm: Make filemap_nopage use NOPAGE_SIGBUS
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Thu, 28 Sep 2006 19:09:52 +0000
Message-Id: <1159470592.12797.23334.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: "ADAM G. LITKE [imap]" <agl@us.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi Andrew.  This is just a "nice to have" cleanup patch.  Any chance on
getting it merged (lest I forget about it again)?  Thanks.

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
