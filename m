Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 356236B0069
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 03:31:21 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id to1so5579862ieb.16
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 00:31:20 -0700 (PDT)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id y7si29615311ici.21.2014.06.03.00.31.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 00:31:20 -0700 (PDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so5126837pbb.7
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 00:31:19 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] HWPOISON: Fix the handling path of the victimized page frame that belong to non-LUR
Date: Tue,  3 Jun 2014 15:29:42 +0800
Message-Id: <1401780582-9477-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: ak@linux.intel.com, fengguang.wu@intel.com, linux-mm@kvack.org, Chen Yucong <slaoub@gmail.com>

Until now, the kernel has the same policy to handle victimized page frames that
belong to kernel-space(reserved/slab-subsystem) or non-LRU(unknown page state).
In other word, the result of handling either of these victimized page frames is
(IGNORED | FAILED), and the return value of memory_failure() is -EBUSY.

This patch is to avoid that memory_failure() returns very soon due to the "true"
value of (!PageLRU(p)), and it also ensures that action_result() can report more
precise information("reserved kernel",  "kernel slab", and "unknown page state")
instead of "non LRU", especially for memory errors which are detected by memory-scrubbing.

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/memory-failure.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e3154d9..39daadc 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -862,7 +862,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	struct page *hpage = *hpagep;
 	struct page *ppage;
 
-	if (PageReserved(p) || PageSlab(p))
+	if (PageReserved(p) || PageSlab(p) || !PageLRU(p))
 		return SWAP_SUCCESS;
 
 	/*
@@ -1126,9 +1126,6 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 					action_result(pfn, "free buddy, 2nd try", DELAYED);
 				return 0;
 			}
-			action_result(pfn, "non LRU", IGNORED);
-			put_page(p);
-			return -EBUSY;
 		}
 	}
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
