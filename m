Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 076696B0491
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:18:09 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q38so2290328qte.4
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 14:18:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w129si8731961qkd.37.2017.08.31.14.18.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 14:18:08 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 11/13] xen/gntdev: update to new mmu_notifier semantic
Date: Thu, 31 Aug 2017 17:17:36 -0400
Message-Id: <20170831211738.17922-12-jglisse@redhat.com>
In-Reply-To: <20170831211738.17922-1-jglisse@redhat.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, =?UTF-8?q?Roger=20Pau=20Monn=C3=A9?= <roger.pau@citrix.com>, moderated for non-subscribers <xen-devel@lists.xenproject.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Roger Pau MonnA(C) <roger.pau@citrix.com>
Cc: xen-devel@lists.xenproject.org (moderated for non-subscribers)
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/xen/gntdev.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index f3bf8f4e2d6c..82360594fa8e 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -484,13 +484,6 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
 	mutex_unlock(&priv->lock);
 }
 
-static void mn_invl_page(struct mmu_notifier *mn,
-			 struct mm_struct *mm,
-			 unsigned long address)
-{
-	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE);
-}
-
 static void mn_release(struct mmu_notifier *mn,
 		       struct mm_struct *mm)
 {
@@ -522,7 +515,6 @@ static void mn_release(struct mmu_notifier *mn,
 
 static const struct mmu_notifier_ops gntdev_mmu_ops = {
 	.release                = mn_release,
-	.invalidate_page        = mn_invl_page,
 	.invalidate_range_start = mn_invl_range_start,
 };
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
