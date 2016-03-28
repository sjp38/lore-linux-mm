Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A505D6B0260
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 02:30:12 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id x3so130019830pfb.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 23:30:12 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id e3si2667712pap.82.2016.03.27.23.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 23:30:11 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id x3so130019630pfb.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 23:30:11 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 1/2] mm/page_ref: use page_ref helper instead of direct modification of _count
Date: Mon, 28 Mar 2016 15:30:00 +0900
Message-Id: <1459146601-11448-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Berg <johannes@sipsolutions.net>, "David S. Miller" <davem@davemloft.net>, Sunil Goutham <sgoutham@cavium.com>, Chris Metcalf <cmetcalf@mellanox.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

page_reference manipulation functions are introduced to track down
reference count change of the page. Use it instead of direct modification
of _count.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 2 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c       | 2 +-
 mm/filemap.c                                       | 2 +-
 net/wireless/util.c                                | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index fa05e34..8acd7c0 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -23,7 +23,7 @@ static void nicvf_get_page(struct nicvf *nic)
 	if (!nic->rb_pageref || !nic->rb_page)
 		return;
 
-	atomic_add(nic->rb_pageref, &nic->rb_page->_count);
+	page_ref_add(nic->rb_page, nic->rb_pageref);
 	nic->rb_pageref = 0;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 518af32..394c97ff 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -791,7 +791,7 @@ static inline int qede_realloc_rx_buffer(struct qede_dev *edev,
 		 * network stack to take the ownership of the page
 		 * which can be recycled multiple times by the driver.
 		 */
-		atomic_inc(&curr_cons->data->_count);
+		page_ref_inc(curr_cons->data);
 		qede_reuse_page(edev, rxq, curr_cons);
 	}
 
diff --git a/mm/filemap.c b/mm/filemap.c
index a8c69c8..0ebd326 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -213,7 +213,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 			 * some other bad page check should catch it later.
 			 */
 			page_mapcount_reset(page);
-			atomic_sub(mapcount, &page->_count);
+			page_ref_sub(page, mapcount);
 		}
 	}
 
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 9f440a9..e22432a 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -651,7 +651,7 @@ __frame_add_frag(struct sk_buff *skb, struct page *page,
 	struct skb_shared_info *sh = skb_shinfo(skb);
 	int page_offset;
 
-	atomic_inc(&page->_count);
+	page_ref_inc(page);
 	page_offset = ptr - page_address(page);
 	skb_add_rx_frag(skb, sh->nr_frags, page, page_offset, len, size);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
