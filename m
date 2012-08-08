Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id D23316B005A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 02:10:52 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/7] zsmalloc: prevent mappping in interrupt context
Date: Wed,  8 Aug 2012 15:12:15 +0900
Message-Id: <1344406340-14128-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1344406340-14128-1-git-send-email-minchan@kernel.org>
References: <1344406340-14128-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>

From: Seth Jennings <sjenning@linux.vnet.ibm.com>

Because we use per-cpu mapping areas shared among the
pools/users, we can't allow mapping in interrupt context
because it can corrupt another users mappings.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 3c83c65..b86133f 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -75,6 +75,7 @@
 #include <linux/cpumask.h>
 #include <linux/cpu.h>
 #include <linux/vmalloc.h>
+#include <linux/hardirq.h>
 
 #include "zsmalloc.h"
 #include "zsmalloc_int.h"
@@ -761,6 +762,13 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 
 	BUG_ON(!handle);
 
+	/*
+	 * Because we use per-cpu mapping areas shared among the
+	 * pools/users, we can't allow mapping in interrupt context
+	 * because it can corrupt another users mappings.
+	 */
+	BUG_ON(in_interrupt());
+
 	obj_handle_to_location(handle, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
 	class = &pool->size_class[class_idx];
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
