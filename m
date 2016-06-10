Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B17A76B025E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 04:43:55 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so27682835lff.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 01:43:55 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id s10si12703833wjm.110.2016.06.10.01.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 01:43:52 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id k184so16163305wme.2
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 01:43:52 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] slab: make GFP_SLAB_BUG_MASK information more human readable
Date: Fri, 10 Jun 2016 10:43:19 +0200
Message-Id: <1465548200-11384-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <clameter@sgi.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

printk offers %pGg for quite some time so let's use it to get a human
readable list of invalid flags.

The original output would be
[  429.191962] gfp: 2

after the change
[  429.191962] Unexpected gfp: 0x2 (__GFP_HIGHMEM)

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/slab.c | 3 ++-
 mm/slub.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 763096a247f6..03fb724d6e48 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2686,7 +2686,8 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 	 * critical path in kmem_cache_alloc().
 	 */
 	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
-		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
+		gfp_t invalid_mask = flags & GFP_SLAB_BUG_MASK;
+		pr_emerg("Unexpected gfp: %#x (%pGg)\n", invalid_mask, &invalid_mask);
 		BUG();
 	}
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
diff --git a/mm/slub.c b/mm/slub.c
index cbf4e0e07d41..dd5a9eee7df5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1628,7 +1628,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
-		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
+		gfp_t invalid_mask = flags & GFP_SLAB_BUG_MASK;
+		pr_emerg("Unexpected gfp: %#x (%pGg)\n", invalid_mask, &invalid_mask);
 		BUG();
 	}
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
