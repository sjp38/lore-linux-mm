Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id B998482F7F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 08:14:54 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so53057320igb.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:14:54 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id b35si23621342ioj.138.2015.10.19.05.14.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 05:14:53 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: do not inc NR_PAGETABLE if ptlock_init failed
Date: Mon, 19 Oct 2015 15:14:41 +0300
Message-ID: <1445256881-5205-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If ALLOC_SPLIT_PTLOCKS is defined, ptlock_init may fail, in which case
we shouldn't increment NR_PAGETABLE.

Since small allocations, such as ptlock, normally do not fail (currently
they can fail if kmemcg is used though), this patch does not really fix
anything and should be considered as a code cleanup.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/mm.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6adf4167d664..30ef3b535444 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1553,8 +1553,10 @@ static inline void pgtable_init(void)
 
 static inline bool pgtable_page_ctor(struct page *page)
 {
+	if (!ptlock_init(page))
+		return false;
 	inc_zone_page_state(page, NR_PAGETABLE);
-	return ptlock_init(page);
+	return true;
 }
 
 static inline void pgtable_page_dtor(struct page *page)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
