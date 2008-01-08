Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m089a1CF504462
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 09:36:01 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m089a1Pc2994246
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 10:36:01 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m089a1pn026071
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 10:36:01 +0100
Subject: [rfc][patch 3/4] s390: remove sturct page entries for z/VM DCSS
	memory segments
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <1199784196.25114.11.camel@cotte.boeblingen.de.ibm.com>
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com>
	 <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de>
	 <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de>
	 <476B96D6.2010302@de.ibm.com>  <20071221104701.GE28484@wotan.suse.de>
	 <1199784196.25114.11.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Tue, 08 Jan 2008 10:36:01 +0100
Message-Id: <1199784961.25114.30.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch removes the creation of struct page entries for z/VM DCSS memory segments
that are being loaded.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
--- 


Index: linux-2.6/arch/s390/mm/vmem.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/vmem.c
+++ linux-2.6/arch/s390/mm/vmem.c
@@ -310,8 +310,6 @@ out:
 int add_shared_memory(unsigned long start, unsigned long size)
 {
 	struct memory_segment *seg;
-	struct page *page;
-	unsigned long pfn, num_pfn, end_pfn;
 	int ret;
 
 	mutex_lock(&vmem_mutex);
@@ -326,24 +324,10 @@ int add_shared_memory(unsigned long star
 	if (ret)
 		goto out_free;
 
-	ret = vmem_add_mem(start, size);
+	ret = vmem_add_range(start, size);
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
