Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 425886B026A
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:43:17 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h82-v6so1519520lfi.8
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:43:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g77-v6sor1680313lfl.87.2018.04.13.06.43.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Apr 2018 06:43:15 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 6/6] lkdtm: crash on overwriting protected pmalloc var
Date: Fri, 13 Apr 2018 17:41:31 +0400
Message-Id: <20180413134131.4651-7-igor.stoppa@huawei.com>
In-Reply-To: <20180413134131.4651-1-igor.stoppa@huawei.com>
References: <20180413134131.4651-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, corbet@lwn.net
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Verify that pmalloc read-only protection is in place: trying to
overwrite a protected variable will crash the kernel.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 drivers/misc/lkdtm/core.c  |  3 +++
 drivers/misc/lkdtm/lkdtm.h |  1 +
 drivers/misc/lkdtm/perms.c | 25 +++++++++++++++++++++++++
 3 files changed, 29 insertions(+)

diff --git a/drivers/misc/lkdtm/core.c b/drivers/misc/lkdtm/core.c
index 2154d1bfd18b..c9fd42bda6ee 100644
--- a/drivers/misc/lkdtm/core.c
+++ b/drivers/misc/lkdtm/core.c
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
diff --git a/drivers/misc/lkdtm/lkdtm.h b/drivers/misc/lkdtm/lkdtm.h
index 9e513dcfd809..dcda3ae76ceb 100644
--- a/drivers/misc/lkdtm/lkdtm.h
+++ b/drivers/misc/lkdtm/lkdtm.h
@@ -38,6 +38,7 @@ void lkdtm_READ_BUDDY_AFTER_FREE(void);
 void __init lkdtm_perms_init(void);
 void lkdtm_WRITE_RO(void);
 void lkdtm_WRITE_RO_AFTER_INIT(void);
+void lkdtm_WRITE_RO_PMALLOC(void);
 void lkdtm_WRITE_KERN(void);
 void lkdtm_EXEC_DATA(void);
 void lkdtm_EXEC_STACK(void);
diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 53b85c9d16b8..4660ff0bfa44 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -9,6 +9,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mman.h>
 #include <linux/uaccess.h>
+#include <linux/pmalloc.h>
 #include <asm/cacheflush.h>
 
 /* Whether or not to fill the target memory area with do_nothing(). */
@@ -104,6 +105,30 @@ void lkdtm_WRITE_RO_AFTER_INIT(void)
 	*ptr ^= 0xabcd1234;
 }
 
+#ifdef CONFIG_PROTECTABLE_MEMORY
+void lkdtm_WRITE_RO_PMALLOC(void)
+{
+	struct pmalloc_pool *pool;
+	int *i;
+
+	pool = pmalloc_create_pool();
+	if (WARN(!pool, "Failed preparing pool for pmalloc test."))
+		return;
+
+	i = (int *)pmalloc(pool, sizeof(int));
+	if (WARN(!i, "Failed allocating memory for pmalloc test.")) {
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
