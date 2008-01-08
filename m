Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m089a4Pl110866
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 09:36:04 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m089a36g2773192
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 10:36:03 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m089a3jO026128
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 10:36:03 +0100
Subject: [rfc][patch 4/4] s390: mixedmap_refcount_pfn implementation using
	list walk
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <1199784196.25114.11.camel@cotte.boeblingen.de.ibm.com>
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com>
	 <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de>
	 <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de>
	 <476B96D6.2010302@de.ibm.com>  <20071221104701.GE28484@wotan.suse.de>
	 <1199784196.25114.11.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Tue, 08 Jan 2008 10:36:03 +0100
Message-Id: <1199784963.25114.31.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch implements mixedmap_refcount_pfn() for s390 architecture using
list-walk. This is merely meant to be a proof of concept, because we do
prefer spending one valuable pte bit to speed this up.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
--- 
Index: linux-2.6/arch/s390/mm/vmem.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/vmem.c
+++ linux-2.6/arch/s390/mm/vmem.c
@@ -339,6 +339,26 @@ out:
 	return ret;
 }
 
+int mixedmap_refcount_pfn(unsigned long pfn)
+{
+	int rc;
+	struct memory_segment *tmp;
+
+	mutex_lock(&vmem_mutex);
+
+	list_for_each_entry(tmp, &mem_segs, list) {
+		if ((tmp->start >= pfn << PAGE_SHIFT) &&
+		    (tmp->start + tmp->size - 1 < pfn << PAGE_SHIFT)) {
+			rc = 0;
+			goto out;
+		}
+	}
+	rc = 1;
+out:
+	mutex_unlock(&vmem_mutex);
+	return rc;
+}
+
 /*
  * map whole physical memory to virtual memory (identity mapping)
  */
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -28,6 +28,13 @@ extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
 
+/*
+ * This callback is only needed when using VM_MIXEDMAP. It is used by common
+ * code to check if a pfn needs refcounting in the corresponding struct page.
+ */
+extern int mixedmap_refcount_pfn(unsigned long pfn);
+
+
 #ifdef CONFIG_SYSCTL
 extern int sysctl_legacy_va_layout;
 #else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
