Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1370B6B0036
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 16:23:26 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so7752436pad.22
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 13:23:25 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id bx2si6896545pab.21.2014.08.08.13.23.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Aug 2014 13:23:24 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv6 1/5] lib/genalloc.c: Add power aligned algorithm
Date: Fri,  8 Aug 2014 13:23:13 -0700
Message-Id: <1407529397-6642-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Russell King <linux@arm.linux.org.uk>
Cc: Laura Abbott <lauraa@codeaurora.org>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>


One of the more common algorithms used for allocation
is to align the start address of the allocation to
the order of size requested. Add this as an algorithm
option for genalloc.

Acked-by: Will Deacon <will.deacon@arm.com>
Acked-by: Olof Johansson <olof@lixom.net>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 include/linux/genalloc.h |  4 ++++
 lib/genalloc.c           | 21 +++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
index 1c2fdaa..3cd0934 100644
--- a/include/linux/genalloc.h
+++ b/include/linux/genalloc.h
@@ -110,6 +110,10 @@ extern void gen_pool_set_algo(struct gen_pool *pool, genpool_algo_t algo,
 extern unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
 		unsigned long start, unsigned int nr, void *data);
 
+extern unsigned long gen_pool_first_fit_order_align(unsigned long *map,
+		unsigned long size, unsigned long start, unsigned int nr,
+		void *data);
+
 extern unsigned long gen_pool_best_fit(unsigned long *map, unsigned long size,
 		unsigned long start, unsigned int nr, void *data);
 
diff --git a/lib/genalloc.c b/lib/genalloc.c
index bdb9a45..9758529 100644
--- a/lib/genalloc.c
+++ b/lib/genalloc.c
@@ -481,6 +481,27 @@ unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
 EXPORT_SYMBOL(gen_pool_first_fit);
 
 /**
+ * gen_pool_first_fit_order_align - find the first available region
+ * of memory matching the size requirement. The region will be aligned
+ * to the order of the size specified.
+ * @map: The address to base the search on
+ * @size: The bitmap size in bits
+ * @start: The bitnumber to start searching at
+ * @nr: The number of zeroed bits we're looking for
+ * @data: additional data - unused
+ */
+unsigned long gen_pool_first_fit_order_align(unsigned long *map,
+		unsigned long size, unsigned long start,
+		unsigned int nr, void *data)
+{
+	unsigned long order = (unsigned long) data;
+	unsigned long align_mask = (1 << get_order(nr << order)) - 1;
+
+	return bitmap_find_next_zero_area(map, size, start, nr, align_mask);
+}
+EXPORT_SYMBOL(gen_pool_first_fit_order_align);
+
+/**
  * gen_pool_best_fit - find the best fitting region of memory
  * macthing the size requirement (no alignment constraint)
  * @map: The address to base the search on
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
