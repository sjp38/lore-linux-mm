Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6169E6B0274
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:21 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 82so15506945pfp.5
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c1si8782633pfd.416.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 51/62] dca: Remove idr_preload calls
Date: Wed, 22 Nov 2017 13:07:28 -0800
Message-Id: <20171122210739.29916-52-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The IDR now has its own locking, so remove the dca lock and calls to
idr_preload.  Also, there is no need to call idr_destroy on a freshly
initialised IDR.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/dca/dca-sysfs.c | 22 ++++------------------
 1 file changed, 4 insertions(+), 18 deletions(-)

diff --git a/drivers/dca/dca-sysfs.c b/drivers/dca/dca-sysfs.c
index 126cf295b198..afa1d5c0f55e 100644
--- a/drivers/dca/dca-sysfs.c
+++ b/drivers/dca/dca-sysfs.c
@@ -31,7 +31,6 @@
 
 static struct class *dca_class;
 static struct idr dca_idr;
-static spinlock_t dca_idr_lock;
 
 int dca_sysfs_add_req(struct dca_provider *dca, struct device *dev, int slot)
 {
@@ -55,23 +54,14 @@ int dca_sysfs_add_provider(struct dca_provider *dca, struct device *dev)
 	struct device *cd;
 	int ret;
 
-	idr_preload(GFP_KERNEL);
-	spin_lock(&dca_idr_lock);
-
-	ret = idr_alloc(&dca_idr, dca, 0, 0, GFP_NOWAIT);
-	if (ret >= 0)
-		dca->id = ret;
-
-	spin_unlock(&dca_idr_lock);
-	idr_preload_end();
+	ret = idr_alloc(&dca_idr, dca, 0, 0, GFP_KERNEL);
 	if (ret < 0)
 		return ret;
+	dca->id = ret;
 
 	cd = device_create(dca_class, dev, MKDEV(0, 0), NULL, "dca%d", dca->id);
 	if (IS_ERR(cd)) {
-		spin_lock(&dca_idr_lock);
 		idr_remove(&dca_idr, dca->id);
-		spin_unlock(&dca_idr_lock);
 		return PTR_ERR(cd);
 	}
 	dca->cd = cd;
@@ -82,21 +72,17 @@ void dca_sysfs_remove_provider(struct dca_provider *dca)
 {
 	device_unregister(dca->cd);
 	dca->cd = NULL;
-	spin_lock(&dca_idr_lock);
 	idr_remove(&dca_idr, dca->id);
-	spin_unlock(&dca_idr_lock);
 }
 
 int __init dca_sysfs_init(void)
 {
 	idr_init(&dca_idr);
-	spin_lock_init(&dca_idr_lock);
 
 	dca_class = class_create(THIS_MODULE, "dca");
-	if (IS_ERR(dca_class)) {
-		idr_destroy(&dca_idr);
+	if (IS_ERR(dca_class))
 		return PTR_ERR(dca_class);
-	}
+
 	return 0;
 }
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
