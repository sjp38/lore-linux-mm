Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9B176B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 22:28:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u84so214821842pfj.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 19:28:38 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id k190si29826266pgd.116.2016.10.17.19.28.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 19:28:38 -0700 (PDT)
From: <zhouxianrong@huawei.com>
Subject: [PATCH vmalloc] reduce purge_lock range and hold time of vmap_area_lock
Date: Tue, 18 Oct 2016 10:25:21 +0800
Message-ID: <1476757521-3262-1-git-send-email-zhouxianrong@huawei.com>
In-Reply-To: <1476540769-31893-1-git-send-email-zhouxianrong@huawei.com>
References: <1476540769-31893-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, chris@chris-wilson.co.uk, vdavydov.dev@gmail.com, mgorman@techsingularity.net, joe@perches.com, shawn.lin@rock-chips.com, iamjoonsoo.kim@lge.com, kuleshovmail@gmail.com, zhouxianrong@huawei.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

From: z00281421 <z00281421@notesmail.huawei.com>


Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
---
 mm/vmalloc.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e7..e9c9c04 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -661,13 +661,18 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
 	if (nr || force_flush)
 		flush_tlb_kernel_range(*start, *end);
 
+	spin_unlock(&purge_lock);
+
 	if (nr) {
+		unsigned char batch = 0;
 		spin_lock(&vmap_area_lock);
-		llist_for_each_entry_safe(va, n_va, valist, purge_list)
+		llist_for_each_entry_safe(va, n_va, valist, purge_list) {
 			__free_vmap_area(va);
+			if (!batch++)
+				cond_resched_lock(&vmap_area_lock);
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
