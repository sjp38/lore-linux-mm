Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7626B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 00:21:03 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id qh10so65027176pac.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 21:21:03 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id e88si1058983pfj.182.2016.07.19.21.21.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 21:21:02 -0700 (PDT)
From: Zhou Chengming <zhouchengming1@huawei.com>
Subject: [PATCH] make __section_nr more efficient
Date: Wed, 20 Jul 2016 12:18:30 +0800
Message-ID: <1468988310-11560-1-git-send-email-zhouchengming1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, tj@kernel.org, guohanjun@huawei.com, huawei.libin@huawei.com, zhouchengming1@huawei.com

When CONFIG_SPARSEMEM_EXTREME is disabled, __section_nr can get
the section number with a subtraction directly.

Signed-off-by: Zhou Chengming <zhouchengming1@huawei.com>
---
 mm/sparse.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 5d0cf45..36d7bbb 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -100,11 +100,7 @@ static inline int sparse_index_init(unsigned long section_nr, int nid)
 }
 #endif
 
-/*
- * Although written for the SPARSEMEM_EXTREME case, this happens
- * to also work for the flat array case because
- * NR_SECTION_ROOTS==NR_MEM_SECTIONS.
- */
+#ifdef CONFIG_SPARSEMEM_EXTREME
 int __section_nr(struct mem_section* ms)
 {
 	unsigned long root_nr;
@@ -123,6 +119,12 @@ int __section_nr(struct mem_section* ms)
 
 	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
 }
+#else
+int __section_nr(struct mem_section* ms)
+{
+	return (int)(ms - mem_section[0]);
+}
+#endif
 
 /*
  * During early boot, before section_mem_map is used for an actual
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
