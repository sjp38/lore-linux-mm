Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6576B006C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 08:05:47 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so12609671pac.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:05:46 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ai4si8638158pbc.176.2015.06.09.05.05.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 05:05:46 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so12556455pab.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:05:46 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 1/5] mm/slab_common: allow NULL cache pointer in kmem_cache_destroy()
Date: Tue,  9 Jun 2015 21:04:49 +0900
Message-Id: <1433851493-23685-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

kmem_cache_destroy() does not tolerate a NULL kmem_cache pointer
argument and performs a NULL-pointer dereference. This requires
additional attention and effort from developers/reviewers and
forces all kmem_cache_destroy() callers (200+ as of 4.1) to do
a NULL check

	if (cache)
		kmem_cache_destroy(cache);

Or, otherwise, be invalid kmem_cache_destroy() users.

Tweak kmem_cache_destroy() and NULL-check the pointer there.

Proposed by Andrew Morton.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reported-by: Andrew Morton <akpm@linux-foundation.org>
LKML-reference: https://lkml.org/lkml/2015/6/8/583
---
 mm/slab_common.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8873985..ea69b13 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -641,6 +641,9 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	bool need_rcu_barrier = false;
 	bool busy = false;
 
+	if (unlikely(!s))
+		return;
+
 	BUG_ON(!is_root_cache(s));
 
 	get_online_cpus();
-- 
2.4.3.368.g7974889

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
