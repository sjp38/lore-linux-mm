Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6C0800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 05:55:30 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id 67so9410lfq.15
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 02:55:30 -0800 (PST)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id k83si7269718lje.371.2018.01.23.02.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 02:55:28 -0800 (PST)
Subject: [PATCH 2/4] vmalloc: add __vmalloc_area()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 23 Jan 2018 13:55:26 +0300
Message-ID: <151670492590.658225.1645504673972109236.stgit@buzz>
In-Reply-To: <151670492223.658225.4605377710524021456.stgit@buzz>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

This function it the same as __vmalloc_node_range() but returns pointer to
vm_struct rather than virtual address.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/vmalloc.h |    5 +++++
 mm/vmalloc.c            |   39 +++++++++++++++++++++++++++++++++++----
 2 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 1e5d8c392f15..f772346a506e 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -81,6 +81,11 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller);
+extern struct vm_struct *__vmalloc_area(unsigned long size, unsigned long align,
+			unsigned long start, unsigned long end,
+			gfp_t gfp_mask, pgprot_t prot,
+			unsigned long vm_flags, int node,
+			const void *caller);
 #ifndef CONFIG_MMU
 extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
 static inline void *__vmalloc_node_flags_caller(unsigned long size, int node,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cece3fb33cef..ad962be74d53 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1725,7 +1725,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 }
 
 /**
- *	__vmalloc_node_range  -  allocate virtually contiguous memory
+ *	__vmalloc_area  -  allocate virtually contiguous memory
  *	@size:		allocation size
  *	@align:		desired alignment
  *	@start:		vm area range start
@@ -1738,9 +1738,11 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
  *
  *	Allocate enough pages to cover @size from the page level
  *	allocator with @gfp_mask flags.  Map them into contiguous
- *	kernel virtual space, using a pagetable protection of @prot.
+ *	kernel virtual space, using a pagetable protection of @prot
+ *
+ *	Returns the area descriptor on success or %NULL on failure.
  */
-void *__vmalloc_node_range(unsigned long size, unsigned long align,
+struct vm_struct *__vmalloc_area(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller)
@@ -1771,7 +1773,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 
 	kmemleak_vmalloc(area, size, gfp_mask);
 
-	return addr;
+	return area;
 
 fail:
 	warn_alloc(gfp_mask, NULL,
@@ -1780,6 +1782,35 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 }
 
 /**
+ *	__vmalloc_node_range  -  allocate virtually contiguous memory
+ *	@size:		allocation size
+ *	@align:		desired alignment
+ *	@start:		vm area range start
+ *	@end:		vm area range end
+ *	@gfp_mask:	flags for the page level allocator
+ *	@prot:		protection mask for the allocated pages
+ *	@vm_flags:	additional vm area flags (e.g. %VM_NO_GUARD)
+ *	@node:		node to use for allocation or NUMA_NO_NODE
+ *	@caller:	caller's return address
+ *
+ *	Allocate enough pages to cover @size from the page level
+ *	allocator with @gfp_mask flags.  Map them into contiguous
+ *	kernel virtual space, using a pagetable protection of @prot.
+ */
+void *__vmalloc_node_range(unsigned long size, unsigned long align,
+			unsigned long start, unsigned long end, gfp_t gfp_mask,
+			pgprot_t prot, unsigned long vm_flags, int node,
+			const void *caller)
+{
+	struct vm_struct *area;
+
+	area = __vmalloc_area(size, align, start, end, gfp_mask,
+			      prot, vm_flags, node, caller);
+
+	return area ? area->addr : NULL;
+}
+
+/**
  *	__vmalloc_node  -  allocate virtually contiguous memory
  *	@size:		allocation size
  *	@align:		desired alignment

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
