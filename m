Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1446B02F3
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 15:05:33 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u63so12528619qkb.5
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 12:05:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x23si2742613qta.246.2017.08.29.12.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 12:05:32 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [RFC PATCH] mm/rmap: do not call mmu_notifier_invalidate_page() v3
Date: Tue, 29 Aug 2017 15:05:26 -0400
Message-Id: <20170829190526.8767-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

Some MMU notifier need to be able to sleep during callback. This was
broken by c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use
page_vma_mapped_walk()").

This patch restore the sleep ability and properly capture the range of
address that needs to be invalidated.

Relevent threads:
https://lkml.kernel.org/r/20170809204333.27485-1-jglisse@redhat.com
https://lkml.kernel.org/r/20170804134928.l4klfcnqatni7vsc@black.fi.intel.com
https://marc.info/?l=kvm&m=150327081325160&w=2

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bernhard Held <berny156@gmx.de>
Cc: Adam Borowski <kilobyte@angband.pl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: Wanpeng Li <kernellwp@gmail.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Mike Galbraith <efault@gmx.de>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: axie <axie@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/rmap.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index c8993c63eb25..0b25b720f494 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -888,6 +888,8 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		.flags = PVMW_SYNC,
 	};
 	int *cleaned = arg;
+	bool invalidate = false;
+	unsigned long start = address, end = address;
 
 	while (page_vma_mapped_walk(&pvmw)) {
 		int ret = 0;
@@ -905,6 +907,9 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			entry = pte_mkclean(entry);
 			set_pte_at(vma->vm_mm, address, pte, entry);
 			ret = 1;
+			invalidate = true;
+			/* range is exclusive */
+			end = pvmw.address + PAGE_SIZE;
 		} else {
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 			pmd_t *pmd = pvmw.pmd;
@@ -919,18 +924,22 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			entry = pmd_mkclean(entry);
 			set_pmd_at(vma->vm_mm, address, pmd, entry);
 			ret = 1;
+			invalidate = true;
+			/* range is exclusive */
+			end = pvmw.address + PAGE_SIZE;
 #else
 			/* unexpected pmd-mapped page? */
 			WARN_ON_ONCE(1);
 #endif
 		}
 
-		if (ret) {
-			mmu_notifier_invalidate_page(vma->vm_mm, address);
+		if (ret)
 			(*cleaned)++;
-		}
 	}
 
+	if (invalidate)
+		mmu_notifier_invalidate_range(vma->vm_mm, start, end);
+
 	return true;
 }
 
@@ -1323,8 +1332,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	};
 	pte_t pteval;
 	struct page *subpage;
-	bool ret = true;
+	bool ret = true, invalidate = false;
 	enum ttu_flags flags = (enum ttu_flags)arg;
+	unsigned long start = address, end = address;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
@@ -1490,8 +1500,14 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 discard:
 		page_remove_rmap(subpage, PageHuge(page));
 		put_page(page);
-		mmu_notifier_invalidate_page(mm, address);
+		invalidate = true;
+		/* range is exclusive */
+		end = address + PAGE_SIZE;
 	}
+
+	if (invalidate)
+		mmu_notifier_invalidate_range(mm, start, end);
+
 	return ret;
 }
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
