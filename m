Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 699746B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 12:59:44 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 18 Jul 2012 12:59:42 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 398F66E8CFA
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 12:56:02 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6IGu1HS283260
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 12:56:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6IGu1WQ026480
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 13:56:01 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 2/3] zsmalloc: prevent mappping in interrupt context
Date: Wed, 18 Jul 2012 11:55:55 -0500
Message-Id: <1342630556-28686-2-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Because we use per-cpu mapping areas shared among the
pools/users, we can't allow mapping in interrupt context
because it can corrupt another users mappings.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
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
