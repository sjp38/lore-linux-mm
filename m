Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 706656B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 13:29:38 -0400 (EDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 1/3] resource: Add __adjust_resource() for internal use
Date: Wed, 10 Apr 2013 11:16:59 -0600
Message-Id: <1365614221-685-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1365614221-685-1-git-send-email-toshi.kani@hp.com>
References: <1365614221-685-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com, Toshi Kani <toshi.kani@hp.com>

Added __adjust_resource(), which is called by adjust_resource()
internally after the resource_lock is held.  There is no interface
change to adjust_resource().  This change allows other functions
to call __adjust_resource() internally while the resource_lock is
held.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by : Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 kernel/resource.c |   35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 73f35d4..ae246f9 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -706,24 +706,13 @@ void insert_resource_expand_to_fit(struct resource *root, struct resource *new)
 	write_unlock(&resource_lock);
 }
 
-/**
- * adjust_resource - modify a resource's start and size
- * @res: resource to modify
- * @start: new start value
- * @size: new size
- *
- * Given an existing resource, change its start and size to match the
- * arguments.  Returns 0 on success, -EBUSY if it can't fit.
- * Existing children of the resource are assumed to be immutable.
- */
-int adjust_resource(struct resource *res, resource_size_t start, resource_size_t size)
+static int __adjust_resource(struct resource *res, resource_size_t start,
+				resource_size_t size)
 {
 	struct resource *tmp, *parent = res->parent;
 	resource_size_t end = start + size - 1;
 	int result = -EBUSY;
 
-	write_lock(&resource_lock);
-
 	if (!parent)
 		goto skip;
 
@@ -751,6 +740,26 @@ skip:
 	result = 0;
 
  out:
+	return result;
+}
+
+/**
+ * adjust_resource - modify a resource's start and size
+ * @res: resource to modify
+ * @start: new start value
+ * @size: new size
+ *
+ * Given an existing resource, change its start and size to match the
+ * arguments.  Returns 0 on success, -EBUSY if it can't fit.
+ * Existing children of the resource are assumed to be immutable.
+ */
+int adjust_resource(struct resource *res, resource_size_t start,
+			resource_size_t size)
+{
+	int result;
+
+	write_lock(&resource_lock);
+	result = __adjust_resource(res, start, size);
 	write_unlock(&resource_lock);
 	return result;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
