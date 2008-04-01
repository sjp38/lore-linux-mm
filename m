Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m31EKccW090676
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 14:20:38 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m31EKbYc3694600
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 16:20:37 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m31EKbc7024017
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 16:20:37 +0200
Subject: Re: [patch 1/7] mm: introduce VM_MIXEDMAP
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <20080331150426.20d57ddb.akpm@linux-foundation.org>
References: <20080328015238.519230000@nick.local0.net>
	 <20080328015421.905848000@nick.local0.net>
	 <20080331150426.20d57ddb.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 01 Apr 2008 16:20:33 +0200
Message-Id: <1207059633.7075.1.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@suse.de, torvalds@linux-foundation.org, jaredeh@gmail.com, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Am Montag, den 31.03.2008, 15:04 -0700 schrieb Andrew Morton:
> [7/7] needs to be redone please - git-s390 makes functional changes to
> add_shared_memory().

This patch removes struct page entries for DCSS segments that are being loaded.
They can still be accessed correctly, thanks to the struct page-less XIP work
of previous patches.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
---
 arch/s390/mm/vmem.c |   18 +-----------------
 1 files changed, 1 insertion(+), 17 deletions(-)

Index: linux-2.6-marist/arch/s390/mm/vmem.c
===================================================================
--- linux-2.6-marist.orig/arch/s390/mm/vmem.c
+++ linux-2.6-marist/arch/s390/mm/vmem.c
@@ -343,8 +343,6 @@ out:
 int add_shared_memory(unsigned long start, unsigned long size)
 {
 	struct memory_segment *seg;
-	struct page *page;
-	unsigned long pfn, num_pfn, end_pfn;
 	int ret;
 
 	mutex_lock(&vmem_mutex);
@@ -359,24 +357,10 @@ int add_shared_memory(unsigned long star
 	if (ret)
 		goto out_free;
 
-	ret = vmem_add_mem(start, size, 0);
+	ret = vmem_add_range(start, size, 0);
 	if (ret)
 		goto out_remove;
 
-	pfn = PFN_DOWN(start);
-	num_pfn = PFN_DOWN(size);
-	end_pfn = pfn + num_pfn;
-
-	page = pfn_to_page(pfn);
-	memset(page, 0, num_pfn * sizeof(struct page));
-
-	for (; pfn < end_pfn; pfn++) {
-		page = pfn_to_page(pfn);
-		init_page_count(page);
-		reset_page_mapcount(page);
-		SetPageReserved(page);
-		INIT_LIST_HEAD(&page->lru);
-	}
 	goto out;
 
 out_remove:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
