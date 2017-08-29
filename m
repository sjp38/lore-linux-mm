Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C72676B02B4
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:11:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l65so12973613qkc.1
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 13:11:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i1si3597939qkf.452.2017.08.29.13.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 13:11:43 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 2/4] dax/mmu_notifier: update to new mmu_notifier semantic
Date: Tue, 29 Aug 2017 16:11:30 -0400
Message-Id: <20170829201132.9292-3-jglisse@redhat.com>
In-Reply-To: <20170829201132.9292-1-jglisse@redhat.com>
References: <20170829201132.9292-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

mmu_notifier_invalidate_page() can now be call from under the spinlock.
Move it approprietly and add a call to mmu_notifier_invalidate_range()
for user that need to be able to sleep.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
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
 fs/dax.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 865d42c63e23..23cfb055e92e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -650,7 +650,7 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 
 	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, index, index) {
-		unsigned long address;
+		unsigned long start, address, end;
 
 		cond_resched();
 
@@ -676,6 +676,9 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			pmd = pmd_wrprotect(pmd);
 			pmd = pmd_mkclean(pmd);
 			set_pmd_at(vma->vm_mm, address, pmdp, pmd);
+			start = address & PMD_MASK;
+			end = start + PMD_SIZE;
+			mmu_notifier_invalidate_page(vma->vm_mm, address);
 			changed = true;
 unlock_pmd:
 			spin_unlock(ptl);
@@ -691,13 +694,16 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			pte = pte_wrprotect(pte);
 			pte = pte_mkclean(pte);
 			set_pte_at(vma->vm_mm, address, ptep, pte);
+			mmu_notifier_invalidate_page(vma->vm_mm, address);
 			changed = true;
+			start = address;
+			end = start + PAGE_SIZE;
 unlock_pte:
 			pte_unmap_unlock(ptep, ptl);
 		}
 
 		if (changed)
-			mmu_notifier_invalidate_page(vma->vm_mm, address);
+			mmu_notifier_invalidate_range(vma->vm_mm, start, end);
 	}
 	i_mmap_unlock_read(mapping);
 }
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
