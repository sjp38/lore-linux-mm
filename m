Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id C0DE46B0023
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 19:23:45 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zsmalloc: Add Kconfig for enabling PTE method
Date: Mon,  4 Feb 2013 09:23:41 +0900
Message-Id: <1359937421-19921-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

Zsmalloc has two methods 1) copy-based and 2) pte based to access
allocations that span two pages.
You can see history why we supported two approach from [1].

But it was bad choice that adding hard coding to select architecture
which want to use pte based method. This patch removed it and adds
new Kconfig to select the approach.

This patch is based on next-20130202.

[1] https://lkml.org/lkml/2012/7/11/58

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/Kconfig         |   12 ++++++++++++
 drivers/staging/zsmalloc/zsmalloc-main.c |   11 -----------
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
index 9084565..2359123 100644
--- a/drivers/staging/zsmalloc/Kconfig
+++ b/drivers/staging/zsmalloc/Kconfig
@@ -8,3 +8,15 @@ config ZSMALLOC
 	  non-standard allocator interface where a handle, not a pointer, is
 	  returned by an alloc().  This handle must be mapped in order to
 	  access the allocated space.
+
+config ZSMALLOC_PGTABLE_MAPPING
+        bool "Use page table mapping to access allocations that span two pages"
+        depends on ZSMALLOC
+        default n
+        help
+	  By default, zsmalloc uses a copy-based object mapping method to access
+	  allocations that span two pages. However, if a particular architecture
+	  performs VM mapping faster than copying, then you should select this.
+	  This causes zsmalloc to use page table mapping rather than copying
+	  for object mapping. You can check speed with zsmalloc benchmark[1].
+	  [1] https://github.com/spartacus06/zsmalloc
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 06f73a9..b161ca1 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -218,17 +218,6 @@ struct zs_pool {
 #define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
 #define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
 
-/*
- * By default, zsmalloc uses a copy-based object mapping method to access
- * allocations that span two pages. However, if a particular architecture
- * performs VM mapping faster than copying, then it should be added here
- * so that USE_PGTABLE_MAPPING is defined. This causes zsmalloc to use
- * page table mapping rather than copying for object mapping.
-*/
-#if defined(CONFIG_ARM)
-#define USE_PGTABLE_MAPPING
-#endif
-
 struct mapping_area {
 #ifdef USE_PGTABLE_MAPPING
 	struct vm_struct *vm; /* vm area for mapping object that span pages */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
