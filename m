Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91E1D6B02B4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 03:50:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r62so6661635pfj.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:50:13 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.123])
        by mx.google.com with ESMTPS id c4si158909pgt.257.2017.08.16.00.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 16 Aug 2017 00:50:12 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH] zsmalloc: zs_page_isolate: skip unnecessary loops but not return false if zspage is not inuse
Date: Wed, 16 Aug 2017 15:49:54 +0800
Message-ID: <1502869794-29263-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

Like [1], zs_page_isolate meet the same problem if zspage is not inuse.

After [2], zs_page_migrate can support empty zspage now.

Make this patch to let zs_page_isolate skip unnecessary loops but not
return false if zspage is not inuse.

[1] zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse-fix.patch
[2] zsmalloc-zs_page_migrate-schedule-free_work-if-zspage-is-ZS_EMPTY.patch

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index fb99953..8560c93 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1927,11 +1927,6 @@ bool zs_page_isolate(struct page *page, isolate_mode_t mode)
 	class = pool->size_class[class_idx];
 
 	spin_lock(&class->lock);
-	if (get_zspage_inuse(zspage) == 0) {
-		spin_unlock(&class->lock);
-		return false;
-	}
-
 	/* zspage is isolated for object migration */
 	if (list_empty(&zspage->list) && !is_zspage_isolated(zspage)) {
 		spin_unlock(&class->lock);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
