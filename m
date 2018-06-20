Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 336936B0006
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:09:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g20-v6so462814pfi.2
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:09:33 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r10-v6si3395620pfe.121.2018.06.20.15.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 15:09:31 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 1/3] vmalloc: Add __vmalloc_node_try_addr function
Date: Wed, 20 Jun 2018 15:09:28 -0700
Message-Id: <1529532570-21765-2-git-send-email-rick.p.edgecombe@intel.com>
In-Reply-To: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com
Cc: kristen.c.accardi@intel.com, dave.hansen@intel.com, arjan.van.de.ven@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Create __vmalloc_node_try_addr function that tries to allocate at a specific
address.  The implementation relies on __vmalloc_node_range for the bulk of the
work.  To keep this function from spamming the logs when an allocation failure
is fails, __vmalloc_node_range is changed to only warn when __GFP_NOWARN is not
set.  This behavior is consistent with this flags interpretation in
alloc_vmap_area.

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/vmalloc.h |  3 +++
 mm/vmalloc.c            | 41 +++++++++++++++++++++++++++++++++++++++--
 2 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c9..6eaa896 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -82,6 +82,9 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller);
+extern void *__vmalloc_node_try_addr(unsigned long addr, unsigned long size,
+			gfp_t gfp_mask,	pgprot_t prot, unsigned long vm_flags,
+			int node, const void *caller);
 #ifndef CONFIG_MMU
 extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
 static inline void *__vmalloc_node_flags_caller(unsigned long size, int node,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cfea25b..9e0820c9 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1710,6 +1710,42 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 }
 
 /**
+ *	__vmalloc_try_addr  -  try to alloc at a specific address
+ *	@addr:		address to try
+ *	@size:		size to try
+ *	@gfp_mask:	flags for the page level allocator
+ *	@prot:		protection mask for the allocated pages
+ *	@vm_flags:	additional vm area flags (e.g. %VM_NO_GUARD)
+ *	@node:		node to use for allocation or NUMA_NO_NODE
+ *	@caller:	caller's return address
+ *
+ *	Try to allocate at the specific address. If it succeeds the address is
+ *	returned. If it fails NULL is returned.  It may trigger TLB flushes.
+ */
+void *__vmalloc_node_try_addr(unsigned long addr, unsigned long size,
+			gfp_t gfp_mask,	pgprot_t prot, unsigned long vm_flags,
+			int node, const void *caller)
+{
+	unsigned long addr_end;
+	unsigned long vsize = PAGE_ALIGN(size);
+
+	if (!vsize || (vsize >> PAGE_SHIFT) > totalram_pages)
+		return NULL;
+
+	if (!(vm_flags & VM_NO_GUARD))
+		vsize += PAGE_SIZE;
+
+	addr_end = addr + vsize;
+
+	if (addr > addr_end)
+		return NULL;
+
+	return __vmalloc_node_range(size, 1, addr, addr_end,
+				gfp_mask | __GFP_NOWARN, prot, vm_flags, node,
+				caller);
+}
+
+/**
  *	__vmalloc_node_range  -  allocate virtually contiguous memory
  *	@size:		allocation size
  *	@align:		desired alignment
@@ -1759,8 +1795,9 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	return addr;
 
 fail:
-	warn_alloc(gfp_mask, NULL,
-			  "vmalloc: allocation failure: %lu bytes", real_size);
+	if (!(gfp_mask & __GFP_NOWARN))
+		warn_alloc(gfp_mask, NULL,
+			"vmalloc: allocation failure: %lu bytes", real_size);
 	return NULL;
 }
 
-- 
2.7.4
