Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3523F6B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 04:09:54 -0400 (EDT)
Received: by lacdq2 with SMTP id dq2so63971644lac.1
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 01:09:53 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com. [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id i8si1987582lbj.130.2015.09.26.01.09.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 01:09:53 -0700 (PDT)
Received: by lacrr8 with SMTP id rr8so39941262lac.2
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 01:09:52 -0700 (PDT)
Date: Sat, 26 Sep 2015 10:09:43 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCHv2 3/3] zsmalloc: add compaction callbacks
Message-Id: <20150926100943.60420d355d818aa64be0dd9d@gmail.com>
In-Reply-To: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
References: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ddstreet@ieee.org, akpm@linux-foundation.org, Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Add compaction callbacks for zpool compaction API extension.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/zsmalloc.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f135b1b..8f2ddd1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -365,6 +365,19 @@ static void zs_zpool_unmap(void *pool, unsigned long handle)
 	zs_unmap_object(pool, handle);
 }
 
+static unsigned long zs_zpool_compact(void *pool)
+{
+	return zs_compact(pool);
+}
+
+static unsigned long zs_zpool_get_compacted(void *pool)
+{
+	struct zs_pool_stats stats;
+
+	zs_pool_stats(pool, &stats);
+	return stats.pages_compacted;
+}
+
 static u64 zs_zpool_total_size(void *pool)
 {
 	return zs_get_total_pages(pool) << PAGE_SHIFT;
@@ -380,6 +393,8 @@ static struct zpool_driver zs_zpool_driver = {
 	.shrink =	zs_zpool_shrink,
 	.map =		zs_zpool_map,
 	.unmap =	zs_zpool_unmap,
+	.compact =	zs_zpool_compact,
+	.get_num_compacted =	zs_zpool_get_compacted,
 	.total_size =	zs_zpool_total_size,
 };
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
