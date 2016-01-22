Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 237636B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 13:51:25 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id uo6so46715257pac.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:51:25 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v86si11165666pfi.16.2016.01.22.10.51.24
        for <linux-mm@kvack.org>;
        Fri, 22 Jan 2016 10:51:24 -0800 (PST)
Subject: [PATCH v2] phys_to_pfn_t: use phys_addr_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Jan 2016 10:50:57 -0800
Message-ID: <20160122185056.38786.5705.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20160122184626.GF2948@linux.intel.com>
References: <20160122184626.GF2948@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A dma_addr_t is potentially smaller than a phys_addr_t on some archs.
Don't truncate the address when doing the pfn conversion.

Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Reported-by: Matthew Wilcox <willy@linux.intel.com>
[willy: fix pfn_t_to_phys as well]
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/pfn_t.h             |    4 ++--
 kernel/memremap.c                 |    2 +-
 tools/testing/nvdimm/test/iomap.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index 0703b5360d31..37448ab5fb5c 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -29,7 +29,7 @@ static inline pfn_t pfn_to_pfn_t(unsigned long pfn)
 	return __pfn_to_pfn_t(pfn, 0);
 }
 
-extern pfn_t phys_to_pfn_t(dma_addr_t addr, unsigned long flags);
+extern pfn_t phys_to_pfn_t(phys_addr_t addr, unsigned long flags);
 
 static inline bool pfn_t_has_page(pfn_t pfn)
 {
@@ -48,7 +48,7 @@ static inline struct page *pfn_t_to_page(pfn_t pfn)
 	return NULL;
 }
 
-static inline dma_addr_t pfn_t_to_phys(pfn_t pfn)
+static inline phys_addr_t pfn_t_to_phys(pfn_t pfn)
 {
 	return PFN_PHYS(pfn_t_to_pfn(pfn));
 }
diff --git a/kernel/memremap.c b/kernel/memremap.c
index e517a16cb426..7f6d08f41d72 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -150,7 +150,7 @@ void devm_memunmap(struct device *dev, void *addr)
 }
 EXPORT_SYMBOL(devm_memunmap);
 
-pfn_t phys_to_pfn_t(dma_addr_t addr, unsigned long flags)
+pfn_t phys_to_pfn_t(phys_addr_t addr, unsigned long flags)
 {
 	return __pfn_to_pfn_t(addr >> PAGE_SHIFT, flags);
 }
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index 7ec7df9e7fc7..0c1a7e65bb81 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -113,7 +113,7 @@ void *__wrap_devm_memremap_pages(struct device *dev, struct resource *res,
 }
 EXPORT_SYMBOL(__wrap_devm_memremap_pages);
 
-pfn_t __wrap_phys_to_pfn_t(dma_addr_t addr, unsigned long flags)
+pfn_t __wrap_phys_to_pfn_t(phys_addr_t addr, unsigned long flags)
 {
 	struct nfit_test_resource *nfit_res = get_nfit_res(addr);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
