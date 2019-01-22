Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 167F68E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:22:07 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so16654521pgb.7
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:22:07 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f10si16684732pln.289.2019.01.22.07.22.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 07:22:05 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] hwpoison-inject: no need to check return value of debugfs_create functions
Date: Tue, 22 Jan 2019 16:21:10 +0100
Message-Id: <20190122152151.16139-11-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

When calling debugfs functions, there is no need to ever check the
return value.  The function can work or not, but the code logic should
never do something different based on this.

Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 mm/hwpoison-inject.c | 67 +++++++++++++++-----------------------------
 1 file changed, 22 insertions(+), 45 deletions(-)

diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index b6ac70616c32..36662d0097d5 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -76,63 +76,40 @@ static void pfn_inject_exit(void)
 
 static int pfn_inject_init(void)
 {
-	struct dentry *dentry;
-
 	hwpoison_dir = debugfs_create_dir("hwpoison", NULL);
-	if (hwpoison_dir == NULL)
-		return -ENOMEM;
 
 	/*
 	 * Note that the below poison/unpoison interfaces do not involve
 	 * hardware status change, hence do not require hardware support.
 	 * They are mainly for testing hwpoison in software level.
 	 */
-	dentry = debugfs_create_file("corrupt-pfn", 0200, hwpoison_dir,
-					  NULL, &hwpoison_fops);
-	if (!dentry)
-		goto fail;
-
-	dentry = debugfs_create_file("unpoison-pfn", 0200, hwpoison_dir,
-				     NULL, &unpoison_fops);
-	if (!dentry)
-		goto fail;
-
-	dentry = debugfs_create_u32("corrupt-filter-enable", 0600,
-				    hwpoison_dir, &hwpoison_filter_enable);
-	if (!dentry)
-		goto fail;
-
-	dentry = debugfs_create_u32("corrupt-filter-dev-major", 0600,
-				    hwpoison_dir, &hwpoison_filter_dev_major);
-	if (!dentry)
-		goto fail;
-
-	dentry = debugfs_create_u32("corrupt-filter-dev-minor", 0600,
-				    hwpoison_dir, &hwpoison_filter_dev_minor);
-	if (!dentry)
-		goto fail;
-
-	dentry = debugfs_create_u64("corrupt-filter-flags-mask", 0600,
-				    hwpoison_dir, &hwpoison_filter_flags_mask);
-	if (!dentry)
-		goto fail;
-
-	dentry = debugfs_create_u64("corrupt-filter-flags-value", 0600,
-				    hwpoison_dir, &hwpoison_filter_flags_value);
-	if (!dentry)
-		goto fail;
+	debugfs_create_file("corrupt-pfn", 0200, hwpoison_dir, NULL,
+			    &hwpoison_fops);
+
+	debugfs_create_file("unpoison-pfn", 0200, hwpoison_dir, NULL,
+			    &unpoison_fops);
+
+	debugfs_create_u32("corrupt-filter-enable", 0600, hwpoison_dir,
+			   &hwpoison_filter_enable);
+
+	debugfs_create_u32("corrupt-filter-dev-major", 0600, hwpoison_dir,
+			   &hwpoison_filter_dev_major);
+
+	debugfs_create_u32("corrupt-filter-dev-minor", 0600, hwpoison_dir,
+			   &hwpoison_filter_dev_minor);
+
+	debugfs_create_u64("corrupt-filter-flags-mask", 0600, hwpoison_dir,
+			   &hwpoison_filter_flags_mask);
+
+	debugfs_create_u64("corrupt-filter-flags-value", 0600, hwpoison_dir,
+			   &hwpoison_filter_flags_value);
 
 #ifdef CONFIG_MEMCG
-	dentry = debugfs_create_u64("corrupt-filter-memcg", 0600,
-				    hwpoison_dir, &hwpoison_filter_memcg);
-	if (!dentry)
-		goto fail;
+	debugfs_create_u64("corrupt-filter-memcg", 0600, hwpoison_dir,
+			   &hwpoison_filter_memcg);
 #endif
 
 	return 0;
-fail:
-	pfn_inject_exit();
-	return -ENOMEM;
 }
 
 module_init(pfn_inject_init);
-- 
2.20.1
