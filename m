Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC156B0009
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 15:11:33 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v8so1536284pgs.9
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 12:11:33 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 60-v6si1793816pld.65.2018.02.28.12.11.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 12:11:31 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 6/7] lkdtm: crash on overwriting protected pmalloc var
Date: Wed, 28 Feb 2018 22:06:19 +0200
Message-ID: <20180228200620.30026-7-igor.stoppa@huawei.com>
In-Reply-To: <20180228200620.30026-1-igor.stoppa@huawei.com>
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Verify that pmalloc read-only protection is in place: trying to
overwrite a protected variable will crash the kernel.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 drivers/misc/lkdtm.h       |  1 +
 drivers/misc/lkdtm_core.c  |  3 +++
 drivers/misc/lkdtm_perms.c | 28 ++++++++++++++++++++++++++++
 3 files changed, 32 insertions(+)

diff --git a/drivers/misc/lkdtm.h b/drivers/misc/lkdtm.h
index 9e513dcfd809..dcda3ae76ceb 100644
--- a/drivers/misc/lkdtm.h
+++ b/drivers/misc/lkdtm.h
@@ -38,6 +38,7 @@ void lkdtm_READ_BUDDY_AFTER_FREE(void);
 void __init lkdtm_perms_init(void);
 void lkdtm_WRITE_RO(void);
 void lkdtm_WRITE_RO_AFTER_INIT(void);
+void lkdtm_WRITE_RO_PMALLOC(void);
 void lkdtm_WRITE_KERN(void);
 void lkdtm_EXEC_DATA(void);
 void lkdtm_EXEC_STACK(void);
diff --git a/drivers/misc/lkdtm_core.c b/drivers/misc/lkdtm_core.c
index 2154d1bfd18b..c9fd42bda6ee 100644
--- a/drivers/misc/lkdtm_core.c
+++ b/drivers/misc/lkdtm_core.c
@@ -155,6 +155,9 @@ static const struct crashtype crashtypes[] = {
 	CRASHTYPE(ACCESS_USERSPACE),
 	CRASHTYPE(WRITE_RO),
 	CRASHTYPE(WRITE_RO_AFTER_INIT),
+#ifdef CONFIG_PROTECTABLE_MEMORY
+	CRASHTYPE(WRITE_RO_PMALLOC),
+#endif
 	CRASHTYPE(WRITE_KERN),
 	CRASHTYPE(REFCOUNT_INC_OVERFLOW),
 	CRASHTYPE(REFCOUNT_ADD_OVERFLOW),
diff --git a/drivers/misc/lkdtm_perms.c b/drivers/misc/lkdtm_perms.c
index 53b85c9d16b8..0ac9023fd2b0 100644
--- a/drivers/misc/lkdtm_perms.c
+++ b/drivers/misc/lkdtm_perms.c
@@ -9,6 +9,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mman.h>
 #include <linux/uaccess.h>
+#include <linux/pmalloc.h>
 #include <asm/cacheflush.h>
 
 /* Whether or not to fill the target memory area with do_nothing(). */
@@ -104,6 +105,33 @@ void lkdtm_WRITE_RO_AFTER_INIT(void)
 	*ptr ^= 0xabcd1234;
 }
 
+#ifdef CONFIG_PROTECTABLE_MEMORY
+void lkdtm_WRITE_RO_PMALLOC(void)
+{
+	struct gen_pool *pool;
+	int *i;
+
+	pool = pmalloc_create_pool("pool", 0);
+	if (unlikely(!pool)) {
+		pr_info("Failed preparing pool for pmalloc test.");
+		return;
+	}
+
+	i = (int *)pmalloc(pool, sizeof(int), GFP_KERNEL);
+	if (unlikely(!i)) {
+		pr_info("Failed allocating memory for pmalloc test.");
+		pmalloc_destroy_pool(pool);
+		return;
+	}
+
+	*i = INT_MAX;
+	pmalloc_protect_pool(pool);
+
+	pr_info("attempting bad pmalloc write at %p\n", i);
+	*i = 0;
+}
+#endif
+
 void lkdtm_WRITE_KERN(void)
 {
 	size_t size;
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
