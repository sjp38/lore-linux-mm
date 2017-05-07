Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 99CC46B02C4
	for <linux-mm@kvack.org>; Sat,  6 May 2017 23:12:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q4so40539862pga.4
        for <linux-mm@kvack.org>; Sat, 06 May 2017 20:12:37 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id y135si9586762pfg.349.2017.05.06.20.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 May 2017 20:12:36 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id b23so5458677pfc.0
        for <linux-mm@kvack.org>; Sat, 06 May 2017 20:12:36 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/2] mm/slub: remove a redundant assignment in ___slab_alloc()
Date: Sun,  7 May 2017 11:12:14 +0800
Message-Id: <20170507031215.3130-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

When the code comes to this point, there are two cases:
1. cpu_slab is deactivated
2. cpu_slab is empty

In both cased, cpu_slab->freelist is NULL at this moment.

This patch removes the redundant assignment of cpu_slab->freelist.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 795112b65c61..83332f19d226 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2572,7 +2572,6 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 		page = c->page = slub_percpu_partial(c);
 		slub_set_percpu_partial(c, page);
 		stat(s, CPU_PARTIAL_ALLOC);
-		c->freelist = NULL;
 		goto redo;
 	}
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
