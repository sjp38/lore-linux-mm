Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEEB928089F
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 00:34:58 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d185so219007150pgc.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 21:34:58 -0800 (PST)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id d20si9131398pfb.20.2017.02.08.21.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 21:34:57 -0800 (PST)
From: Miles Chen <miles.chen@mediatek.com>
Subject: [PATCH] mm: cleanups for printing phys_addr_t and dma_addr_t
Date: Thu, 9 Feb 2017 13:34:49 +0800
Message-ID: <1486618489-13912-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, Miles Chen <miles.chen@mediatek.com>

cleanup rest of dma_addr_t and phys_addr_t type casting in mm
use %pad for dma_addr_t
use %pa for phys_addr_t

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/dmapool.c | 16 ++++++++--------
 mm/vmalloc.c |  2 +-
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index abcbfe8..cef82b8 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -434,11 +434,11 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
 		spin_unlock_irqrestore(&pool->lock, flags);
 		if (pool->dev)
 			dev_err(pool->dev,
-				"dma_pool_free %s, %p (bad vaddr)/%Lx\n",
-				pool->name, vaddr, (unsigned long long)dma);
+				"dma_pool_free %s, %p (bad vaddr)/%pad\n",
+				pool->name, vaddr, &dma);
 		else
-			pr_err("dma_pool_free %s, %p (bad vaddr)/%Lx\n",
-			       pool->name, vaddr, (unsigned long long)dma);
+			pr_err("dma_pool_free %s, %p (bad vaddr)/%pad\n",
+			       pool->name, vaddr, &dma);
 		return;
 	}
 	{
@@ -450,11 +450,11 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
 			}
 			spin_unlock_irqrestore(&pool->lock, flags);
 			if (pool->dev)
-				dev_err(pool->dev, "dma_pool_free %s, dma %Lx already free\n",
-					pool->name, (unsigned long long)dma);
+				dev_err(pool->dev, "dma_pool_free %s, dma %pad already free\n",
+					pool->name, &dma);
 			else
-				pr_err("dma_pool_free %s, dma %Lx already free\n",
-				       pool->name, (unsigned long long)dma);
+				pr_err("dma_pool_free %s, dma %pad already free\n",
+				       pool->name, &dma);
 			return;
 		}
 	}
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3ca82d4..05c594d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2654,7 +2654,7 @@ static int s_show(struct seq_file *m, void *p)
 		seq_printf(m, " pages=%d", v->nr_pages);
 
 	if (v->phys_addr)
-		seq_printf(m, " phys=%llx", (unsigned long long)v->phys_addr);
+		seq_printf(m, " phys=%pa", &v->phys_addr);
 
 	if (v->flags & VM_IOREMAP)
 		seq_puts(m, " ioremap");
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
