Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 989F36B0253
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 10:19:24 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e200so279280820oig.4
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 07:19:24 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id w39si8181670otd.292.2016.10.15.07.19.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 15 Oct 2016 07:19:24 -0700 (PDT)
From: <zhouxianrong@huawei.com>
Subject: [PATCH vmalloc] reduce purge_lock range and hold time of
Date: Sat, 15 Oct 2016 22:12:48 +0800
Message-ID: <1476540769-31893-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, chris@chris-wilson.co.uk, vdavydov.dev@gmail.com, mgorman@techsingularity.net, joe@perches.com, shawn.lin@rock-chips.com, iamjoonsoo.kim@lge.com, kuleshovmail@gmail.com, zhouxianrong@huawei.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

From: z00281421 <z00281421@notesmail.huawei.com>

i think no need to place __free_vmap_area loop in purge_lock;
_free_vmap_area could be non-atomic operations with flushing tlb
but must be done after flush tlb. and the whole__free_vmap_area loops
also could be non-atomic operations. if so we could improve realtime
because the loop times sometimes is larg and spend a few time.

Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
---
 mm/vmalloc.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e7..9d9154d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -661,13 +661,23 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
 	if (nr || force_flush)
 		flush_tlb_kernel_range(*start, *end);
 
+	spin_unlock(&purge_lock);
+
 	if (nr) {
+		/* the batch count should not be too small
+		** because if vmalloc space is few free is first than alloc.
+		*/
+		unsigned char batch = -1;
 		spin_lock(&vmap_area_lock);
-		llist_for_each_entry_safe(va, n_va, valist, purge_list)
+		llist_for_each_entry_safe(va, n_va, valist, purge_list) {
 			__free_vmap_area(va);
+			if (!batch--) {
+				spin_unlock(&vmap_area_lock);
+				spin_lock(&vmap_area_lock);
+			}
+		}
 		spin_unlock(&vmap_area_lock);
 	}
-	spin_unlock(&purge_lock);
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
