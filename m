Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBE26B02F3
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:12:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u12so10615853pgo.4
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:42 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id t127si2226161pfd.377.2017.05.17.07.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 07:12:41 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id u187so1991631pgb.1
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:41 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/6] mm/slub: not include cpu_partial data in cpu_slabs sysfs
Date: Wed, 17 May 2017 22:11:42 +0800
Message-Id: <20170517141146.11063-3-richard.weiyang@gmail.com>
In-Reply-To: <20170517141146.11063-1-richard.weiyang@gmail.com>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

There are four level slabs:

    CPU
    CPU_PARTIAL
    PARTIAL
    FULL

In current implementation, cpu_slabs sysfs would give statistics including
the first two levels. While there is another sysfs entry cpu_partial_slabs
gives details on the second level slab statistics. Since each cpu has one
slab for the first level, the current cpu_slabs output is easy to be
calculated from cpu_partial_slabs.

This patch removes the cpu_partial data in cpu_slabs for more specific slab
statistics and leave room to retrieve objects and total objects on CPU
level in the future.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1100d2e75870..c7dddf22829d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4762,19 +4762,6 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 
 			total += x;
 			nodes[node] += x;
-
-			page = slub_percpu_partial_read_once(c);
-			if (page) {
-				node = page_to_nid(page);
-				if (flags & SO_TOTAL)
-					WARN_ON_ONCE(1);
-				else if (flags & SO_OBJECTS)
-					WARN_ON_ONCE(1);
-				else
-					x = page->pages;
-				total += x;
-				nodes[node] += x;
-			}
 		}
 	}
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
