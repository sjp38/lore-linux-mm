Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C82106B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 09:59:29 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so26697961pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 06:59:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bz4si3879179pab.40.2015.08.27.06.59.28
        for <linux-mm@kvack.org>;
        Thu, 27 Aug 2015 06:59:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 2/7] slub: use page->rcu_head instead of page->lru plus cast
Date: Thu, 27 Aug 2015 16:59:16 +0300
Message-Id: <1440683961-32839-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1440683961-32839-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1440683961-32839-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>

We have properly typed page->rcu_head, no need to cast page->lru.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>
---
 mm/slub.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 816df0016555..869642d03b22 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1510,10 +1510,7 @@ static void free_slab(struct kmem_cache *s, struct page *page)
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
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
