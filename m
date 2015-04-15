Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id DDEE46B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 07:55:22 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so50155852pdb.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 04:55:22 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id lk3si6759877pbc.16.2015.04.15.04.55.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 04:55:22 -0700 (PDT)
From: Wang Kai <morgan.wang@huawei.com>
Subject: [PATCH] kmemleak: record accurate early log buffer count and report when exceeded
Date: Wed, 15 Apr 2015 19:49:23 +0800
Message-ID: <1429098563-76831-1-git-send-email-morgan.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

In log_early function, crt_early_log should also count once when
'crt_early_log >= ARRAY_SIZE(early_log)'. Otherwise the reported
count from kmemleak_init is one less than 'actual number'.

Then, in kmemleak_init, if early_log buffer size equal actual
number, kmemleak will init sucessful, so change warning condition
to 'crt_early_log > ARRAY_SIZE(early_log)'.

Signed-off-by: Wang Kai <morgan.wang@huawei.com>
---
 mm/kmemleak.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 5405aff..49956cf 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -814,6 +814,8 @@ static void __init log_early(int op_type, const void *ptr, size_t size,
 	}
 
 	if (crt_early_log >= ARRAY_SIZE(early_log)) {
+		/* kmemleak will stop recording, just count the requests */
+		crt_early_log++;
 		kmemleak_disable();
 		return;
 	}
@@ -1829,7 +1831,8 @@ void __init kmemleak_init(void)
 	object_cache = KMEM_CACHE(kmemleak_object, SLAB_NOLEAKTRACE);
 	scan_area_cache = KMEM_CACHE(kmemleak_scan_area, SLAB_NOLEAKTRACE);
 
-	if (crt_early_log >= ARRAY_SIZE(early_log))
+	/* Don't warning when crt_early_log == ARRAY_SIZE(early_log) */
+	if (crt_early_log > ARRAY_SIZE(early_log))
 		pr_warning("Early log buffer exceeded (%d), please increase "
 			   "DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n", crt_early_log);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
