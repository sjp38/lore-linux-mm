Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 522698E0008
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so17734186pfa.18
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Message-Id: <20181226133351.703380444@intel.com>
Date: Wed, 26 Dec 2018 21:14:57 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 11/21] kvm: allocate page table pages from DRAM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0001-kvm-allocate-page-table-pages-from-DRAM.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Yao Yuan <yuan.yao@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Yao Yuan <yuan.yao@intel.com>

Signed-off-by: Yao Yuan <yuan.yao@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
arch/x86/kvm/mmu.c |   12 +++++++++++-
1 file changed, 11 insertions(+), 1 deletion(-)

--- linux.orig/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.846720344 +0800
+++ linux/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.842719614 +0800
@@ -950,6 +950,16 @@ static void mmu_free_memory_cache(struct
 		kmem_cache_free(cache, mc->objects[--mc->nobjs]);
 }
 
+static unsigned long __get_dram_free_pages(gfp_t gfp_mask)
+{
+       struct page *page;
+
+       page = __alloc_pages(GFP_KERNEL_ACCOUNT, 0, numa_node_id());
+       if (!page)
+	       return 0;
+       return (unsigned long) page_address(page);
+}
+
 static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
 				       int min)
 {
@@ -958,7 +968,7 @@ static int mmu_topup_memory_cache_page(s
 	if (cache->nobjs >= min)
 		return 0;
 	while (cache->nobjs < ARRAY_SIZE(cache->objects)) {
-		page = (void *)__get_free_page(GFP_KERNEL_ACCOUNT);
+		page = (void *)__get_dram_free_pages(GFP_KERNEL_ACCOUNT);
 		if (!page)
 			return cache->nobjs >= min ? 0 : -ENOMEM;
 		cache->objects[cache->nobjs++] = page;
