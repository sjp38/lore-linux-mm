Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 762306B026D
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 05:00:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x78so9286849pff.7
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 02:00:09 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0042.outbound.protection.outlook.com. [104.47.34.42])
        by mx.google.com with ESMTPS id c32si726980plj.55.2017.09.21.02.00.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Sep 2017 02:00:08 -0700 (PDT)
From: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
Subject: [PATCH 1/4] mm: move function alloc_pages_exact_nid out of __meminit
Date: Thu, 21 Sep 2017 14:29:19 +0530
Message-Id: <20170921085922.11659-2-ganapatrao.kulkarni@cavium.com>
In-Reply-To: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Will.Deacon@arm.com, robin.murphy@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

This function can be used on NUMA systems in place of alloc_pages_exact
Adding code to export and to remove __meminit section tagging.

Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
---
 include/linux/gfp.h | 2 +-
 mm/page_alloc.c     | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f780718..a4bd234 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -528,7 +528,7 @@ extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
 void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
 void free_pages_exact(void *virt, size_t size);
-void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
+void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
 #define __get_free_page(gfp_mask) \
 		__get_free_pages((gfp_mask), 0)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c841af8..7975870 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4442,7 +4442,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
  * Like alloc_pages_exact(), but try to allocate on node nid first before falling
  * back.
  */
-void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
+void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 {
 	unsigned int order = get_order(size);
 	struct page *p = alloc_pages_node(nid, gfp_mask, order);
@@ -4450,6 +4450,7 @@ void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 		return NULL;
 	return make_alloc_exact((unsigned long)page_address(p), order, size);
 }
+EXPORT_SYMBOL(alloc_pages_exact_nid);
 
 /**
  * free_pages_exact - release memory allocated via alloc_pages_exact()
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
