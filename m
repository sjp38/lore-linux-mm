Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5406B0038
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 21:35:16 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so605043pdj.2
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 18:35:15 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id tf1si769645pbc.15.2014.07.22.18.35.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jul 2014 18:35:14 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv4 2/5] lib/genalloc.c: Add genpool range check function
Date: Tue, 22 Jul 2014 18:35:05 -0700
Message-Id: <1406079308-5232-3-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1406079308-5232-1-git-send-email-lauraa@codeaurora.org>
References: <1406079308-5232-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

After allocating an address from a particular genpool,
there is no good way to verify if that address actually
belongs to a genpool. Introduce addr_in_gen_pool which
will return if an address plus size falls completely
within the genpool range.

Acked-by: Will Deacon <will.deacon@arm.com>
Reviewed-by: Olof Johansson <olof@lixom.net>
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 include/linux/genalloc.h |  3 +++
 lib/genalloc.c           | 29 +++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
index 3cd0934..1ccaab4 100644
--- a/include/linux/genalloc.h
+++ b/include/linux/genalloc.h
@@ -121,6 +121,9 @@ extern struct gen_pool *devm_gen_pool_create(struct device *dev,
 		int min_alloc_order, int nid);
 extern struct gen_pool *dev_get_gen_pool(struct device *dev);
 
+bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
+			size_t size);
+
 #ifdef CONFIG_OF
 extern struct gen_pool *of_get_named_gen_pool(struct device_node *np,
 	const char *propname, int index);
diff --git a/lib/genalloc.c b/lib/genalloc.c
index 9758529..66edf93 100644
--- a/lib/genalloc.c
+++ b/lib/genalloc.c
@@ -403,6 +403,35 @@ void gen_pool_for_each_chunk(struct gen_pool *pool,
 EXPORT_SYMBOL(gen_pool_for_each_chunk);
 
 /**
+ * addr_in_gen_pool - checks if an address falls within the range of a pool
+ * @pool:	the generic memory pool
+ * @start:	start address
+ * @size:	size of the region
+ *
+ * Check if the range of addresses falls within the specified pool. Takes
+ * the rcu_read_lock for the duration of the check.
+ */
+bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
+			size_t size)
+{
+	bool found = false;
+	unsigned long end = start + size;
+	struct gen_pool_chunk *chunk;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(chunk, &(pool)->chunks, next_chunk) {
+		if (start >= chunk->start_addr && start <= chunk->end_addr) {
+			if (end <= chunk->end_addr) {
+				found = true;
+				break;
+			}
+		}
+	}
+	rcu_read_unlock();
+	return found;
+}
+
+/**
  * gen_pool_avail - get available free space of the pool
  * @pool: pool to get available free space
  *
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
