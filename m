Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B1FA06B003A
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 11:25:58 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so7283147pdj.18
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 08:25:58 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUB001491HQNI40@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 07 Oct 2013 16:25:54 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH] frontswap: enable call to invalidate area on swapoff
Date: Mon, 07 Oct 2013 17:25:41 +0200
Message-id: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org
Cc: Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

During swapoff the frontswap_map was NULL-ified before calling
frontswap_invalidate_area(). However the frontswap_invalidate_area()
exits early if frontswap_map is NULL. Invalidate was never called during
swapoff.

This patch moves frontswap_map_set() in swapoff just after calling
frontswap_invalidate_area() so outside of locks
(swap_lock and swap_info_struct->lock). This shouldn't be a problem as
during swapon the frontswap_map_set() is called also outside of any
locks.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 mm/swapfile.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3963fc2..3a4896b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1922,10 +1922,10 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->cluster_info = NULL;
 	p->flags = 0;
 	frontswap_map = frontswap_map_get(p);
-	frontswap_map_set(p, NULL);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 	frontswap_invalidate_area(type);
+	frontswap_map_set(p, NULL);
 	mutex_unlock(&swapon_mutex);
 	free_percpu(p->percpu_cluster);
 	p->percpu_cluster = NULL;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
