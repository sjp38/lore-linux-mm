Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 208406B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 02:21:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH7LCQb032599
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 16:21:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C27F945DE4F
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:21:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72EB945DE57
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:21:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 25644E78006
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:21:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D7DCEF8004
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:21:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/7] Revert "Intel IOMMU: Avoid memory allocation failures in dma map api calls"
In-Reply-To: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
Message-Id: <20091117162041.3DE5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 16:21:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, David Woodhouse <dwmw2@infradead.org>, iommu@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>


commit eb3fa7cb51 said Intel IOMMU

    Intel IOMMU driver needs memory during DMA map calls to setup its
    internal page tables and for other data structures.  As we all know
    that these DMA map calls are mostly called in the interrupt context
    or with the spinlock held by the upper level drivers(network/storage
    drivers), so in order to avoid any memory allocation failure due to
    low memory issues, this patch makes memory allocation by temporarily
    setting PF_MEMALLOC flags for the current task before making memory
    allocation calls.

    We evaluated mempools as a backup when kmem_cache_alloc() fails
    and found that mempools are really not useful here because
     1) We don't know for sure how much to reserve in advance
     2) And mempools are not useful for GFP_ATOMIC case (as we call
        memory alloc functions with GFP_ATOMIC)

    (akpm: point 2 is wrong...)

The above description doesn't justify to waste system emergency memory
at all. Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need
few memory, anyone must not prevent it. Otherwise the system cause
mysterious hang-up and/or OOM Killer invokation.

Plus, akpm already pointed out what we should do.

Then, this patch revert it.

Cc: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: iommu@lists.linux-foundation.org
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 drivers/pci/intel-iommu.c |   30 ++++--------------------------
 1 files changed, 4 insertions(+), 26 deletions(-)

diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index 1840a05..17d6f1e 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -386,31 +386,9 @@ static struct kmem_cache *iommu_domain_cache;
 static struct kmem_cache *iommu_devinfo_cache;
 static struct kmem_cache *iommu_iova_cache;
 
-static inline void *iommu_kmem_cache_alloc(struct kmem_cache *cachep)
-{
-	unsigned int flags;
-	void *vaddr;
-
-	/* trying to avoid low memory issues */
-	flags = current->flags & PF_MEMALLOC;
-	current->flags |= PF_MEMALLOC;
-	vaddr = kmem_cache_alloc(cachep, GFP_ATOMIC);
-	current->flags &= (~PF_MEMALLOC | flags);
-	return vaddr;
-}
-
-
 static inline void *alloc_pgtable_page(void)
 {
-	unsigned int flags;
-	void *vaddr;
-
-	/* trying to avoid low memory issues */
-	flags = current->flags & PF_MEMALLOC;
-	current->flags |= PF_MEMALLOC;
-	vaddr = (void *)get_zeroed_page(GFP_ATOMIC);
-	current->flags &= (~PF_MEMALLOC | flags);
-	return vaddr;
+	return (void *)get_zeroed_page(GFP_ATOMIC);
 }
 
 static inline void free_pgtable_page(void *vaddr)
@@ -420,7 +398,7 @@ static inline void free_pgtable_page(void *vaddr)
 
 static inline void *alloc_domain_mem(void)
 {
-	return iommu_kmem_cache_alloc(iommu_domain_cache);
+	return kmem_cache_alloc(iommu_domain_cache, GFP_ATOMIC);
 }
 
 static void free_domain_mem(void *vaddr)
@@ -430,7 +408,7 @@ static void free_domain_mem(void *vaddr)
 
 static inline void * alloc_devinfo_mem(void)
 {
-	return iommu_kmem_cache_alloc(iommu_devinfo_cache);
+	return kmem_cache_alloc(iommu_devinfo_cache, GFP_ATOMIC);
 }
 
 static inline void free_devinfo_mem(void *vaddr)
@@ -440,7 +418,7 @@ static inline void free_devinfo_mem(void *vaddr)
 
 struct iova *alloc_iova_mem(void)
 {
-	return iommu_kmem_cache_alloc(iommu_iova_cache);
+	return kmem_cache_alloc(iommu_iova_cache, GFP_ATOMIC);
 }
 
 void free_iova_mem(struct iova *iova)
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
