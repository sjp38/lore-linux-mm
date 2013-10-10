Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 965A39C0005
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:18 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so3074581pab.20
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:18 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 28/34] tile: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:53 +0300
Message-Id: <1381428359-14843-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chris Metcalf <cmetcalf@tilera.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
---
 arch/tile/mm/pgtable.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 4fd9ec0b58..5e86eac4bf 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -241,6 +241,11 @@ struct page *pgtable_alloc_one(struct mm_struct *mm, unsigned long address,
 	if (p == NULL)
 		return NULL;
 
+	if (!pgtable_page_ctor(p)) {
+		__free_pages(p, L2_USER_PGTABLE_ORDER);
+		return NULL;
+	}
+
 	/*
 	 * Make every page have a page_count() of one, not just the first.
 	 * We don't use __GFP_COMP since it doesn't look like it works
@@ -251,7 +256,6 @@ struct page *pgtable_alloc_one(struct mm_struct *mm, unsigned long address,
 		inc_zone_page_state(p+i, NR_PAGETABLE);
 	}
 
-	pgtable_page_ctor(p);
 	return p;
 }
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
