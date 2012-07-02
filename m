Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 963BC6B006C
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:16:24 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 15:16:23 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 341D6C9005E
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:16:09 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q62LG8Ub371580
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 17:16:08 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q632l0Xw031463
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 22:47:01 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 2/4] zsmalloc: add single-page object fastpath in unmap
Date: Mon,  2 Jul 2012 16:15:50 -0500
Message-Id: <1341263752-10210-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Improve zs_unmap_object() performance by adding a fast path for
objects that don't span pages.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index a7a6f22..4942d41 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -774,6 +774,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle)
 	}
 
 	zs_copy_map_object(area->vm_buf, page, off, class->size);
+	area->vm_addr = NULL;
 	return area->vm_buf;
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
@@ -788,6 +789,14 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	struct size_class *class;
 	struct mapping_area *area;
 
+	area = &__get_cpu_var(zs_map_area);
+	if (area->vm_addr) {
+		/* single-page object fastpath */
+		kunmap_atomic(area->vm_addr);
+		put_cpu_var(zs_map_area);
+		return;
+	}
+
 	BUG_ON(!handle);
 
 	obj_handle_to_location(handle, &page, &obj_idx);
@@ -795,11 +804,7 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	class = &pool->size_class[class_idx];
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
-	area = &__get_cpu_var(zs_map_area);
-	if (off + class->size <= PAGE_SIZE)
-		kunmap_atomic(area->vm_addr);
-	else
-		zs_copy_unmap_object(area->vm_buf, page, off, class->size);
+	zs_copy_unmap_object(area->vm_buf, page, off, class->size);
 	put_cpu_var(zs_map_area);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
