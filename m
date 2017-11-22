Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07A616B02CA
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x202so17288751pgx.1
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n12si14252687pgr.71.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 55/62] firewire: Remove call to idr_preload
Date: Wed, 22 Nov 2017 13:07:32 -0800
Message-Id: <20171122210739.29916-56-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

core-cdev uses a spinlock to protect several elements, including the IDR.
Rather than reusing the IDR's spinlock for all of this, preallocate the
necessary memory by allocating a NULL pointer and then replace it with
the resource pointer once we have the spinlock.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/firewire/core-cdev.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/firewire/core-cdev.c b/drivers/firewire/core-cdev.c
index a301fcf46e88..52c22c39744e 100644
--- a/drivers/firewire/core-cdev.c
+++ b/drivers/firewire/core-cdev.c
@@ -486,28 +486,24 @@ static int ioctl_get_info(struct client *client, union ioctl_arg *arg)
 static int add_client_resource(struct client *client,
 			       struct client_resource *resource, gfp_t gfp_mask)
 {
-	bool preload = gfpflags_allow_blocking(gfp_mask);
 	unsigned long flags;
 	int ret;
 
-	if (preload)
-		idr_preload(gfp_mask);
-	spin_lock_irqsave(&client->lock, flags);
+	ret = idr_alloc(&client->resource_idr, NULL, 0, 0, gfp_mask);
+	if (ret < 0)
+		return ret;
 
-	if (client->in_shutdown)
+	spin_lock_irqsave(&client->lock, flags);
+	if (client->in_shutdown) {
+		idr_remove(&client->resource_idr, ret);
 		ret = -ECANCELED;
-	else
-		ret = idr_alloc(&client->resource_idr, resource, 0, 0,
-				GFP_NOWAIT);
-	if (ret >= 0) {
+	} else {
+		idr_replace(&client->resource_idr, resource, ret);
 		resource->handle = ret;
 		client_get(client);
 		schedule_if_iso_resource(resource);
 	}
-
 	spin_unlock_irqrestore(&client->lock, flags);
-	if (preload)
-		idr_preload_end();
 
 	return ret < 0 ? ret : 0;
 }
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
