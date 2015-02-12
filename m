Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 97E3B6B0081
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 17:27:06 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wp4so13561319obc.0
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:27:06 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v84si189545oig.101.2015.02.12.14.27.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 14:27:06 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH v5 3/3] mm: cma: release trigger
Date: Thu, 12 Feb 2015 17:26:48 -0500
Message-Id: <1423780008-16727-4-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
References: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: iamjoonsoo.kim@lge.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, lauraa@codeaurora.org, s.strogin@partner.samsung.com, Sasha Levin <sasha.levin@oracle.com>

Provides a userspace interface to trigger a CMA release.

Usage:

	echo [pages] > free

This would provide testing/fuzzing access to the CMA release paths.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/cma_debug.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 5bd6863..6f0b976 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -39,6 +39,60 @@ static void cma_add_to_cma_mem_list(struct cma *cma, struct cma_mem *mem)
 	spin_unlock(&cma->mem_head_lock);
 }
 
+static struct cma_mem *cma_get_entry_from_list(struct cma *cma)
+{
+	struct cma_mem *mem = NULL;
+
+	spin_lock(&cma->mem_head_lock);
+	if (!hlist_empty(&cma->mem_head)) {
+		mem = hlist_entry(cma->mem_head.first, struct cma_mem, node);
+		hlist_del_init(&mem->node);
+	}
+	spin_unlock(&cma->mem_head_lock);
+
+	return mem;
+}
+
+static int cma_free_mem(struct cma *cma, int count)
+{
+	struct cma_mem *mem = NULL;
+
+	while (count) {
+		mem = cma_get_entry_from_list(cma);
+		if (mem == NULL)
+			return 0;
+
+		if (mem->n <= count) {
+			cma_release(cma, mem->p, mem->n);
+			count -= mem->n;
+			kfree(mem);
+		} else if (cma->order_per_bit == 0) {
+			cma_release(cma, mem->p, count);
+			mem->p += count;
+			mem->n -= count;
+			count = 0;
+			cma_add_to_cma_mem_list(cma, mem);
+		} else {
+			pr_debug("cma: cannot release partial block when order_per_bit != 0\n");
+			cma_add_to_cma_mem_list(cma, mem);
+			break;
+		}
+	}
+
+	return 0;
+			
+}
+
+static int cma_free_write(void *data, u64 val)
+{
+        int pages = val;
+	struct cma *cma = data;
+
+        return cma_free_mem(cma, pages);
+}
+
+DEFINE_SIMPLE_ATTRIBUTE(cma_free_fops, NULL, cma_free_write, "%llu\n");
+
 static int cma_alloc_mem(struct cma *cma, int count)
 {
 	struct cma_mem *mem;
@@ -85,6 +139,9 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 	debugfs_create_file("alloc", S_IWUSR, cma_debugfs_root, cma,
 				&cma_alloc_fops);
 
+	debugfs_create_file("free", S_IWUSR, cma_debugfs_root, cma,
+				&cma_free_fops);
+
 	debugfs_create_file("base_pfn", S_IRUGO, tmp,
 				&cma->base_pfn, &cma_debugfs_fops);
 	debugfs_create_file("count", S_IRUGO, tmp,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
