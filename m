Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0GI1SPa414478
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 18:01:28 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0GI1S1j2289896
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 19:01:28 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0GI1Sui006429
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 19:01:28 +0100
Subject: [patch] #ifdef very expensive debug check in page fault path
From: Carsten Otte <cotte@de.ibm.com>
Content-Type: text/plain
Date: Wed, 16 Jan 2008 19:01:28 +0100
Message-Id: <1200506488.32116.11.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, schwidefsky@de.ibm.com, holger.wolf@de.ibm.com
List-ID: <linux-mm.kvack.org>

This patch puts #ifdef CONFIG_DEBUG_VM around a check in vm_normal_page
that verifies that a pfn is valid. This patch increases performance of
the page fault microbenchmark in lmbench by 13% and overall dbench
performance by 7% on s390x.  pfn_valid() is an expensive operation on
s390 that needs a high double digit amount of CPU cycles.
Nick Piggin suggested that pfn_valid() involves an array lookup on
systems with sparsemem, and therefore is an expensive operation there
too.
The check looks like a clear debug thing to me, it should never trigger
on regular kernels. And if a pte is created for an invalid pfn, we'll
find out once the memory gets accessed later on anyway. Please consider
inclusion of this patch into mm.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
--- 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -392,6 +392,7 @@ struct page *vm_normal_page(struct vm_ar
 			return NULL;
 	}
 
+#ifdef CONFIG_DEBUG_VM
 	/*
 	 * Add some anal sanity checks for now. Eventually,
 	 * we should just do "return pfn_to_page(pfn)", but
@@ -402,6 +403,7 @@ struct page *vm_normal_page(struct vm_ar
 		print_bad_pte(vma, pte, addr);
 		return NULL;
 	}
+#endif
 
 	/*
 	 * NOTE! We still have PageReserved() pages in the page 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
