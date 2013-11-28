Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 652896B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 11:27:44 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so6072107yha.39
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 08:27:44 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id u24si32045471yhg.281.2013.11.28.08.27.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 08:27:43 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id um1so12813582pbc.20
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 08:27:42 -0800 (PST)
Date: Fri, 29 Nov 2013 00:29:13 +0800
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH]mm/vmalloc: interchage the implementation of
 vmalloc_to_{pfn,page}
Message-ID: <20131128162913.GA4234@lcx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, rientjes@google.com, linux-kernel@vger.kernel.org

Currently we are implementing vmalloc_to_pfn() as a wrapper of 
vmalloc_to_page(), which is implemented as follow: 

 1. walks the page talbes to generates the corresponding pfn,
 2. then wraps the pfn to struct page,
 3. returns it.

And vmalloc_to_pfn() re-wraps the vmalloc_to_page() to get the pfn.

This seems too circuitous, so this patch reverses the way:
implementing the vmalloc_to_page() as a wrapper of vmalloc_to_pfn().
This makes vmalloc_to_pfn() and vmalloc_to_page() slightly effective.

No functional change. 

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
mm/vmalloc.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0fdf968..a335e21 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -220,12 +220,12 @@ int is_vmalloc_or_module_addr(const void *x)
 }
 
 /*
- * Walk a vmap address to the struct page it maps.
+ * Walk a vmap address to the physical pfn it maps to.
  */
-struct page *vmalloc_to_page(const void *vmalloc_addr)
+unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
 {
 	unsigned long addr = (unsigned long) vmalloc_addr;
-	struct page *page = NULL;
+	unsigned long pfn;
 	pgd_t *pgd = pgd_offset_k(addr);
 
 	/*
@@ -244,23 +244,23 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 				ptep = pte_offset_map(pmd, addr);
 				pte = *ptep;
 				if (pte_present(pte))
-					page = pte_page(pte);
+					pfn = pte_page(pte);
 				pte_unmap(ptep);
 			}
 		}
 	}
-	return page;
+	return pfn;
 }
-EXPORT_SYMBOL(vmalloc_to_page);
+EXPORT_SYMBOL(vmalloc_to_pfn);
 
 /*
- * Map a vmalloc()-space virtual address to the physical page frame number.
+ * Map a vmalloc()-space virtual address to the struct page.
  */
-unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
+struct page *vmalloc_to_page(const void *vmalloc_addr)
 {
-	return page_to_pfn(vmalloc_to_page(vmalloc_addr));
+	return pfn_to_page(vmalloc_to_pfn(vmalloc_addr));
 }
-EXPORT_SYMBOL(vmalloc_to_pfn);
+EXPORT_SYMBOL(vmalloc_to_page);
 
 
 /*** Global kva allocator ***/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
