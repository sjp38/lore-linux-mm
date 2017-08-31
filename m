Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60C2F6B0495
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:18:14 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id l65so2414035qkc.1
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 14:18:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x14si645553qtx.541.2017.08.31.14.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 14:18:13 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 13/13] mm/mmu_notifier: kill invalidate_page
Date: Thu, 31 Aug 2017 17:17:38 -0400
Message-Id: <20170831211738.17922-14-jglisse@redhat.com>
In-Reply-To: <20170831211738.17922-1-jglisse@redhat.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

The invalidate_page callback suffered from 2 pitfalls. First it use to
happen after page table lock was release and thus a new page might have
setup before the call to invalidate_page() happened.

This is in a weird way fix by c7ab0d2fdc840266b39db94538f74207ec2afbf6
that moved the callback under the page table lock but this also break
several existing user of the mmu_notifier API that assumed they could
sleep inside this callback.

The second pitfall was invalidate_page being the only callback not taking
a range of address in respect to invalidation but was giving an address
and a page. Lot of the callback implementer assumed this could never be
THP and thus failed to invalidate the appropriate range for THP.

By killing this callback we unify the mmu_notifier callback API to always
take a virtual address range as input.

Finaly this also simplify the end user life as there is now 2 clear
choice:
  - invalidate_range_start()/end() callback (which allow you to sleep)
  - invalidate_range() where you can not sleep but happen right after
    page table update under page table lock

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
 include/linux/mmu_notifier.h | 25 -------------------------
 mm/mmu_notifier.c            | 14 --------------
 2 files changed, 39 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index c91b3bcd158f..7b2e31b1745a 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -95,17 +95,6 @@ struct mmu_notifier_ops {
 			   pte_t pte);
 
 	/*
-	 * Before this is invoked any secondary MMU is still ok to
-	 * read/write to the page previously pointed to by the Linux
-	 * pte because the page hasn't been freed yet and it won't be
-	 * freed until this returns. If required set_page_dirty has to
-	 * be called internally to this method.
-	 */
-	void (*invalidate_page)(struct mmu_notifier *mn,
-				struct mm_struct *mm,
-				unsigned long address);
-
-	/*
 	 * invalidate_range_start() and invalidate_range_end() must be
 	 * paired and are called only when the mmap_sem and/or the
 	 * locks protecting the reverse maps are held. If the subsystem
@@ -220,8 +209,6 @@ extern int __mmu_notifier_test_young(struct mm_struct *mm,
 				     unsigned long address);
 extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      unsigned long address, pte_t pte);
-extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
@@ -268,13 +255,6 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 		__mmu_notifier_change_pte(mm, address, pte);
 }
 
-static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
-{
-	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_page(mm, address);
-}
-
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
@@ -442,11 +422,6 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 {
 }
 
-static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
-{
-}
-
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 54ca54562928..314285284e6e 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -174,20 +174,6 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 	srcu_read_unlock(&srcu, id);
 }
 
-void __mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
-{
-	struct mmu_notifier *mn;
-	int id;
-
-	id = srcu_read_lock(&srcu);
-	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
-		if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address);
-	}
-	srcu_read_unlock(&srcu, id);
-}
-
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
