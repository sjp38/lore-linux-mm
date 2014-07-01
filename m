Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id C30A96B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 10:46:35 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id j15so7857338qaq.12
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 07:46:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u3si29548047qar.47.2014.07.01.07.46.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 07:46:35 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] rmap: fix pgoff calculation to handle hugepage correctly
Date: Tue,  1 Jul 2014 10:46:22 -0400
Message-Id: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

I triggered VM_BUG_ON() in vma_address() when I try to migrate an anonymous
hugepage with mbind() in the kernel v3.16-rc3. This is because pgoff's
calculation in rmap_walk_anon() fails to consider compound_order() only to
have an incorrect value. So this patch fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git v3.16-rc3.orig/mm/rmap.c v3.16-rc3/mm/rmap.c
index b7e94ebbd09e..8cc964c6bd8d 100644
--- v3.16-rc3.orig/mm/rmap.c
+++ v3.16-rc3/mm/rmap.c
@@ -1639,7 +1639,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
 static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct anon_vma *anon_vma;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = page->index << compound_order(page);
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
