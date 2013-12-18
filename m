Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 763A36B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 17:51:15 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id uq1so2391949igb.1
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:51:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 9si1735026icd.80.2013.12.18.14.51.13
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 14:51:14 -0800 (PST)
Date: Wed, 18 Dec 2013 17:03:14 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] mm,numa,THP: initialize hstate for THP page size
Message-ID: <20131218170314.1e57bea7@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Chao Yang <chayang@redhat.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, mgorman@suse.de, Veaceslav Falico <vfalico@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Michel Lespinasse <walken@google.com>, Michal Hocko <mhocko@suse.cz>

When hugetlbfs is started with a non-default page size, it is
possible that no hstate is initialized for the page sized used
by transparent huge pages.

This causes copy_huge_page to crash on a null pointer. Make
sure we always have an hpage initialized for the page sized
used by THP.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Chao Yang <chayang@redhat.com>
---
 mm/huge_memory.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5749bcf..583e9d3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -624,6 +624,13 @@ static int __init hugepage_init(void)
 		return -EINVAL;
 	}
 
+	/*
+	 * Make sure an hstate is initialized for our page size,
+	 * even if hugetlbfs is using a non-default page size.
+	 */
+	if (!size_to_hstate(PMD_PAGE_SIZE))
+		hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
+
 	err = hugepage_init_sysfs(&hugepage_kobj);
 	if (err)
 		return err;


-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
