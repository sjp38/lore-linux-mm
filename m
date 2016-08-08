Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 31F536B0253
	for <linux-mm@kvack.org>; Sun,  7 Aug 2016 22:54:44 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so571496928pab.1
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 19:54:44 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id ln2si34422346pab.23.2016.08.07.19.54.41
        for <linux-mm@kvack.org>;
        Sun, 07 Aug 2016 19:54:43 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: fix the incorrect hugepages count
Date: Mon, 8 Aug 2016 10:49:06 +0800
Message-ID: <1470624546-902-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

when memory hotplug enable, free hugepages will be freed if movable node offline.
therefore, /proc/sys/vm/nr_hugepages will be incorrect.

The patch fix it by reduce the max_huge_pages when the node offline.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/hugetlb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f904246..3356e3a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1448,6 +1448,7 @@ static void dissolve_free_huge_page(struct page *page)
 		list_del(&page->lru);
 		h->free_huge_pages--;
 		h->free_huge_pages_node[nid]--;
+		h->max_huge_pages--;
 		update_and_free_page(h, page);
 	}
 	spin_unlock(&hugetlb_lock);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
