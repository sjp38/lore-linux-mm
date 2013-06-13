Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 8898C6B0036
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 15:19:34 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 13 Jun 2013 13:19:33 -0600
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id E14CAC9003E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 15:19:30 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5DJJVNQ57933940
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 15:19:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5DJJULc029378
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 16:19:30 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] zswap: init under_reclaim
Date: Thu, 13 Jun 2013 14:19:14 -0500
Message-Id: <1371151154-22360-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Bob Liu reported a memory leak in zswap.  This was due to the
under_reclaim field in the zbud header not being initialized
to 0, which resulted in zbud_free() not freeing the page
under the false assumption that the page was undergoing
zbud reclaim.

This patch properly initializes the under_reclaim field.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Reported-by: Bob Liu <bob.liu@oracle.com>
---
 mm/zbud.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/zbud.c b/mm/zbud.c
index d63ae6e..9bb4710 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -138,6 +138,7 @@ static struct zbud_header *init_zbud_page(struct page *page)
 	zhdr->last_chunks = 0;
 	INIT_LIST_HEAD(&zhdr->buddy);
 	INIT_LIST_HEAD(&zhdr->lru);
+	zhdr->under_reclaim = 0;
 	return zhdr;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
