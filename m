Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 47D6D6B0258
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 08:36:15 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so13090594igb.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 05:36:15 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id a5si41277833pdj.194.2015.09.03.05.36.09
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 05:36:09 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 1/7] mm: drop page->slab_page
Date: Thu,  3 Sep 2015 15:35:52 +0300
Message-Id: <1441283758-92774-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>

Since 8456a648cf44 ("slab: use struct page for slab management") nobody
uses slab_page field in struct page.

Let's drop it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andi Kleen <ak@linux.intel.com>
---
 include/linux/mm_types.h |  1 -
 mm/slab.c                | 17 +++--------------
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 0038ac7466fd..58620ac7f15c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -140,7 +140,6 @@ struct page {
 #endif
 		};
 
-		struct slab *slab_page; /* slab fields */
 		struct rcu_head rcu_head;	/* Used by SLAB
 						 * when destroying via RCU
 						 */
diff --git a/mm/slab.c b/mm/slab.c
index 200e22412a16..649044f26e5d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1888,21 +1888,10 @@ static void slab_destroy(struct kmem_cache *cachep, struct page *page)
 
 	freelist = page->freelist;
 	slab_destroy_debugcheck(cachep, page);
-	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
-		struct rcu_head *head;
-
-		/*
-		 * RCU free overloads the RCU head over the LRU.
-		 * slab_page has been overloeaded over the LRU,
-		 * however it is not used from now on so that
-		 * we can use it safely.
-		 */
-		head = (void *)&page->rcu_head;
-		call_rcu(head, kmem_rcu_free);
-
-	} else {
+	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
+		call_rcu(&page->rcu_head, kmem_rcu_free);
+	else
 		kmem_freepages(cachep, page);
-	}
 
 	/*
 	 * From now on, we don't use freelist
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
