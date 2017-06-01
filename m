Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B6B3B6B02FA
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:17 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l128so27205240iol.12
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:17 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id 21si18722269ion.116.2017.06.01.01.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:17 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id f102so4171591ioi.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:16 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 5/9] mm: soft-offline: dissolve free hugepage if soft-offlined
Date: Thu,  1 Jun 2017 17:16:55 +0900
Message-Id: <1496305019-5493-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Now we have code to rescue most of healthy pages from a hwpoisoned
hugepage.  So let's apply it to soft_offline_free_page too.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git v4.12-rc3/mm/memory-failure.c v4.12-rc3_patched/mm/memory-failure.c
index e03903f..a5f52cc 100644
--- v4.12-rc3/mm/memory-failure.c
+++ v4.12-rc3_patched/mm/memory-failure.c
@@ -1693,7 +1693,7 @@ static void soft_offline_free_page(struct page *page)
 	if (!TestSetPageHWPoison(head)) {
 		num_poisoned_pages_inc();
 		if (PageHuge(head))
-			dequeue_hwpoisoned_huge_page(head);
+			dissolve_free_huge_page(page);
 	}
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
