Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB48B6B02C3
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:11:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id t13so13395553qtc.7
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 13:11:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 22si3441519qto.533.2017.08.29.13.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 13:11:45 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 3/4] mm/rmap: update to new mmu_notifier_invalidate_page() semantic
Date: Tue, 29 Aug 2017 16:11:31 -0400
Message-Id: <20170829201132.9292-4-jglisse@redhat.com>
In-Reply-To: <20170829201132.9292-1-jglisse@redhat.com>
References: <20170829201132.9292-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

mmu_notifier_invalidate_page() is now be call from under the spinlock.
Add a call to mmu_notifier_invalidate_range() for user that need to be
able to sleep.

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
 mm/rmap.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index c8993c63eb25..06792e28093c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -887,6 +887,8 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		.address = address,
 		.flags = PVMW_SYNC,
 	};
+	unsigned long start = address, end = address;
+	bool invalidate = false;
 	int *cleaned = arg;
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -927,10 +929,16 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 
 		if (ret) {
 			mmu_notifier_invalidate_page(vma->vm_mm, address);
+			/* range is exclusive */
+			end = address + PAGE_SIZE;
+			invalidate = true;
 			(*cleaned)++;
 		}
 	}
 
+	if (invalidate)
+		mmu_notifier_invalidate_range(vma->vm_mm, start, end);
+
 	return true;
 }
 
@@ -1323,8 +1331,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	};
 	pte_t pteval;
 	struct page *subpage;
-	bool ret = true;
+	bool ret = true, invalidate = false;
 	enum ttu_flags flags = (enum ttu_flags)arg;
+	unsigned long start = address, end = address;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
@@ -1491,7 +1500,14 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		page_remove_rmap(subpage, PageHuge(page));
 		put_page(page);
 		mmu_notifier_invalidate_page(mm, address);
+		/* range is exclusive */
+		end = address + PAGE_SIZE;
+		invalidate = true;
 	}
+
+	if (invalidate)
+		mmu_notifier_invalidate_range(vma->vm_mm, start, end);
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
