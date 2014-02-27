Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 985CC6B007B
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 23:39:57 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id m10so1462743eaj.39
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 20:39:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p44si6207498eeu.131.2014.02.26.20.39.54
        for <linux-mm@kvack.org>;
        Wed, 26 Feb 2014 20:39:55 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/3] mm: call vma_adjust_trans_huge() only for thp-enabled vma
Date: Wed, 26 Feb 2014 23:39:37 -0500
Message-Id: <1393475977-3381-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

vma_adjust() is called also for vma(VM_HUGETLB) and it could happen that
we happen to try to split hugetlbfs hugepage. So exclude the possibility.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mmap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git next-20140220.orig/mm/mmap.c next-20140220/mm/mmap.c
index f53397806d7f..45a9c0d51e3f 100644
--- next-20140220.orig/mm/mmap.c
+++ next-20140220/mm/mmap.c
@@ -772,7 +772,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
-	vma_adjust_trans_huge(vma, start, end, adjust_next);
+	if (transparent_hugepage_enabled(vma))
+		vma_adjust_trans_huge(vma, start, end, adjust_next);
 
 	anon_vma = vma->anon_vma;
 	if (!anon_vma && adjust_next)
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
