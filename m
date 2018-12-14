Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27E268E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 02:44:42 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so2334562edb.22
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 23:44:42 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k9si1977094edj.5.2018.12.13.23.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 23:44:40 -0800 (PST)
From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH] mm/page_alloc.c: Allow error injection
Date: Fri, 14 Dec 2018 16:43:30 +0900
Message-Id: <20181214074330.18917-1-bpoirier@suse.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Model call chain after should_failslab(). Likewise, we can now use a kprobe
to override the return value of should_fail_alloc_page() and inject
allocation failures into alloc_page*().

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 include/asm-generic/error-injection.h |  1 +
 mm/page_alloc.c                       | 10 ++++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/error-injection.h b/include/asm-generic/error-injection.h
index 296c65442f00..95a159a4137f 100644
--- a/include/asm-generic/error-injection.h
+++ b/include/asm-generic/error-injection.h
@@ -8,6 +8,7 @@ enum {
 	EI_ETYPE_NULL,		/* Return NULL if failure */
 	EI_ETYPE_ERRNO,		/* Return -ERRNO if failure */
 	EI_ETYPE_ERRNO_NULL,	/* Return -ERRNO or NULL if failure */
+	EI_ETYPE_TRUE,		/* Return true if failure */
 };
 
 struct error_injection_entry {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc407216..64861d79dc2d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3053,7 +3053,7 @@ static int __init setup_fail_page_alloc(char *str)
 }
 __setup("fail_page_alloc=", setup_fail_page_alloc);
 
-static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
+static bool __should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
 {
 	if (order < fail_page_alloc.min_order)
 		return false;
@@ -3103,13 +3103,19 @@ late_initcall(fail_page_alloc_debugfs);
 
 #else /* CONFIG_FAIL_PAGE_ALLOC */
 
-static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
+static inline bool __should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
 {
 	return false;
 }
 
 #endif /* CONFIG_FAIL_PAGE_ALLOC */
 
+static noinline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
+{
+	return __should_fail_alloc_page(gfp_mask, order);
+}
+ALLOW_ERROR_INJECTION(should_fail_alloc_page, TRUE);
+
 /*
  * Return true if free base pages are above 'mark'. For high-order checks it
  * will return true of the order-0 watermark is reached and there is at least
-- 
2.19.2
