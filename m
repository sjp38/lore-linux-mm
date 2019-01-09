Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 59D2A8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 04:07:29 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p9so4818365pfj.3
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 01:07:29 -0800 (PST)
Received: from zg8tmtu5ljg5lje1ms4xmtka.icoremail.net (zg8tmtu5ljg5lje1ms4xmtka.icoremail.net. [159.89.151.119])
        by mx.google.com with SMTP id 133si13017824pfw.64.2019.01.09.01.07.27
        for <linux-mm@kvack.org>;
        Wed, 09 Jan 2019 01:07:27 -0800 (PST)
From: Peng Wang <rocking@whu.edu.cn>
Subject: [PATCH] mm/slub.c: re-randomize random_seq if necessary
Date: Wed,  9 Jan 2019 17:06:27 +0800
Message-Id: <20190109090628.1695-1-rocking@whu.edu.cn>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peng Wang <rocking@whu.edu.cn>

calculate_sizes() could be called in several places
like (red_zone/poison/order/store_user)_store() while
random_seq remains unchanged.

If random_seq is not NULL in calculate_sizes(), re-randomize it.

Signed-off-by: Peng Wang <rocking@whu.edu.cn>
---
 mm/slub.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..2a9d18019545 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3583,6 +3583,15 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	if (oo_objects(s->oo) > oo_objects(s->max))
 		s->max = s->oo;
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+	if (unlikely(s->random_seq)) {
+		kfree(s->random_seq);
+		s->random_seq = NULL;
+		if (init_cache_random_seq(s))
+			return 0;
+	}
+#endif
+
 	return !!oo_objects(s->oo);
 }
 
-- 
2.19.1
