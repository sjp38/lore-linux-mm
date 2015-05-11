Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id BD1936B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 05:04:00 -0400 (EDT)
Received: by obcus9 with SMTP id us9so65441382obc.2
        for <linux-mm@kvack.org>; Mon, 11 May 2015 02:04:00 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id h77si6870974oig.20.2015.05.11.02.03.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 11 May 2015 02:04:00 -0700 (PDT)
From: Wang Kai <morgan.wang@huawei.com>
Subject: [PATCH v2] kmemleak: record accurate early log buffer count and report when exceeded
Date: Mon, 11 May 2015 09:03:41 +0000
Message-ID: <1431335021-117825-1-git-send-email-morgan.wang@huawei.com>
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
 mm/kmemleak.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 5405aff..6a07748 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -814,6 +814,7 @@ static void __init log_early(int op_type, const void *ptr, size_t size,
 	}
 
 	if (crt_early_log >= ARRAY_SIZE(early_log)) {
+		crt_early_log++;
 		kmemleak_disable();
 		return;
 	}
@@ -1829,7 +1830,7 @@ void __init kmemleak_init(void)
 	object_cache = KMEM_CACHE(kmemleak_object, SLAB_NOLEAKTRACE);
 	scan_area_cache = KMEM_CACHE(kmemleak_scan_area, SLAB_NOLEAKTRACE);
 
-	if (crt_early_log >= ARRAY_SIZE(early_log))
+	if (crt_early_log > ARRAY_SIZE(early_log))
 		pr_warning("Early log buffer exceeded (%d), please increase "
 			   "DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n", crt_early_log);
 
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
