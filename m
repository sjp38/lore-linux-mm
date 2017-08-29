Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C18116B0292
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:11:41 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v29so13309880qtv.10
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 13:11:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p21si3687826qta.220.2017.08.29.13.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 13:11:41 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 1/4] mm/mmu_notifier: document new behavior for mmu_notifier_invalidate_page()
Date: Tue, 29 Aug 2017 16:11:29 -0400
Message-Id: <20170829201132.9292-2-jglisse@redhat.com>
In-Reply-To: <20170829201132.9292-1-jglisse@redhat.com>
References: <20170829201132.9292-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

The invalidate page callback use to happen outside the page table spinlock
and thus callback use to be allow to sleep. This is no longer the case.
However now all call to mmu_notifier_invalidate_page() are bracketed by
call to mmu_notifier_invalidate_range_start/mmu_notifier_invalidate_range_end

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
 include/linux/mmu_notifier.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index c91b3bcd158f..acc72167b9cb 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -100,6 +100,12 @@ struct mmu_notifier_ops {
 	 * pte because the page hasn't been freed yet and it won't be
 	 * freed until this returns. If required set_page_dirty has to
 	 * be called internally to this method.
+	 *
+	 * Note that previously this callback wasn't call from under
+	 * a spinlock and thus you were able to sleep inside it. This
+	 * is no longer the case. However now all call to this callback
+	 * is either bracketed by call to range_start()/range_end() or
+	 * follow by a call to invalidate_range().
 	 */
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
