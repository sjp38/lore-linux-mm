Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 40D136B025C
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:29:26 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so11172267igb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:29:26 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id j9si11340419ige.71.2015.09.15.03.29.25
        for <linux-mm@kvack.org>;
        Tue, 15 Sep 2015 03:29:25 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 2/7] slab, slub: use page->rcu_head instead of page->lru plus cast
Date: Tue, 15 Sep 2015 13:28:10 +0300
Message-Id: <1442312895-124384-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>

We have properly typed page->rcu_head, no need to cast page->lru.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux.com>
---
 mm/slab.c | 17 +++--------------
 mm/slub.c |  5 +----
 2 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index c77ebe6cc87c..90ba9170e0c3 100644
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
diff --git a/mm/slub.c b/mm/slub.c
index f614b5dc396b..6b6e771df1c7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1507,10 +1507,7 @@ static void free_slab(struct kmem_cache *s, struct page *page)
 			VM_BUG_ON(s->reserved != sizeof(*head));
 			head = page_address(page) + offset;
 		} else {
-			/*
-			 * RCU free overloads the RCU head over the LRU
-			 */
-			head = (void *)&page->lru;
+			head = &page->rcu_head;
 		}
 
 		call_rcu(head, rcu_free_slab);
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
