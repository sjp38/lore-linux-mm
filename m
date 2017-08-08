Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36A796B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 18:08:28 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p135so22148015qke.0
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 15:08:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k77si1783157qke.89.2017.08.08.15.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 15:08:27 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/rmap/mmu_notifier: restore mmu_notifier_invalidate_page() semantic
Date: Tue,  8 Aug 2017 18:08:20 -0400
Message-Id: <20170808220820.16503-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Commit c7ab0d2fdc840266b39db94538f74207ec2afbf6 silently modified
semantic of mmu_notifier_invalidate_page() this patch restore it
to its previous semantic ie allowing to sleep inside invalidate_page()
callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/rmap.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 92070cfd63e9..fc1e2ab194c0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -888,6 +888,8 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		.address = address,
 		.flags = PVMW_SYNC,
 	};
+	unsigned long start = address, end = address;
+	bool invalidate = false;
 	int *cleaned = arg;
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -927,11 +929,17 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		}
 
 		if (ret) {
-			mmu_notifier_invalidate_page(vma->vm_mm, address);
+			invalidate = true;
+			end = address;
 			(*cleaned)++;
 		}
 	}
 
+	if (invalidate) {
+		for (address = start; address <= end; address += PAGE_SIZE)
+			mmu_notifier_invalidate_page(vma->vm_mm, address);
+	}
+
 	return true;
 }
 
@@ -1324,7 +1332,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	};
 	pte_t pteval;
 	struct page *subpage;
-	bool ret = true;
+	bool ret = true, invalidate = false;
+	unsigned long start = address, end = address;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
@@ -1528,8 +1537,15 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 discard:
 		page_remove_rmap(subpage, PageHuge(page));
 		put_page(page);
-		mmu_notifier_invalidate_page(mm, address);
+		end = address;
+		invalidate = true;
 	}
+
+	if (invalidate) {
+		for (address = start; address <= end; address += PAGE_SIZE)
+			mmu_notifier_invalidate_page(mm, address);
+	}
+
 	return ret;
 }
 
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
