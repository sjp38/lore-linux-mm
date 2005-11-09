Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA9NbfVw027988
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:37:41 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA9NbfCV120176
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:37:41 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA9Nbef5029718
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:37:40 -0500
Subject: [PATCH 1/4] Hugetlb: Remove duplicate i_size check
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1131578925.28383.9.camel@localhost.localdomain>
References: <1131578925.28383.9.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 09 Nov 2005 17:36:49 -0600
Message-Id: <1131579410.28383.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, wli@holomorphy.com, hugh@veritas.com, rohit.seth@intel.com, kenneth.w.chen@intel.com, "ADAM G. LITKE [imap]" <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-26 at 12:00 +1000, David Gibson wrote:
> - The check against i_size was duplicated: once in
>   find_lock_huge_page() and again in hugetlb_fault() after taking the
>   page_table_lock.  We only really need the locked one, so remove the
>   other.

Original post by David Gibson <david@gibson.dropbear.id.au>

Version 2: Wed 9 Nov 2005
	Split this cleanup out into a standalone patch

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
Signed-off-by: Adam Litke <agl@us.ibm.com>
---
 hugetlb.c |    7 -------
 1 files changed, 7 deletions(-)
diff -upN reference/mm/hugetlb.c current/mm/hugetlb.c
--- reference/mm/hugetlb.c
+++ current/mm/hugetlb.c
@@ -344,19 +344,12 @@ static struct page *find_lock_huge_page(
 {
 	struct page *page;
 	int err;
-	struct inode *inode = mapping->host;
-	unsigned long size;
 
 retry:
 	page = find_lock_page(mapping, idx);
 	if (page)
 		goto out;
 
-	/* Check to make sure the mapping hasn't been truncated */
-	size = i_size_read(inode) >> HPAGE_SHIFT;
-	if (idx >= size)
-		goto out;
-
 	if (hugetlb_get_quota(mapping))
 		goto out;
 	page = alloc_huge_page();

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
