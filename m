Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D34B96B02AA
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 22:52:26 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gg9so16547590pac.6
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 19:52:26 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0066.outbound.protection.outlook.com. [104.47.0.66])
        by mx.google.com with ESMTPS id y67si6687085pfb.71.2016.11.02.19.52.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Nov 2016 19:52:26 -0700 (PDT)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH 2/2] mm: hugetlb: support gigantic surplus pages
Date: Thu, 3 Nov 2016 10:51:38 +0800
Message-ID: <1478141499-13825-3-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
References: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, Huang Shijie <shijie.huang@arm.com>

When testing the gigantic page whose order is too large for the buddy
allocator, the libhugetlbfs test case "counter.sh" will fail.

The failure is caused by:
 1) kernel fails to allocate a gigantic page for the surplus case.
    And the gather_surplus_pages() will return NULL in the end.

 2) The condition checks for "over-commit" is wrong.

This patch adds code to allocate the gigantic page in the
__alloc_huge_page(). After this patch, gather_surplus_pages()
can return a gigantic page for the surplus case.

This patch also changes the condition checks for:
     return_unused_surplus_pages()
     nr_overcommit_hugepages_store()

After this patch, the counter.sh can pass for the gigantic page.

Acked-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 mm/hugetlb.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0bf4444..2b67aff 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1574,7 +1574,7 @@ static struct page *__alloc_huge_page(struct hstate *h,
 	struct page *page;
 	unsigned int r_nid;
 
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return NULL;
 
 	/*
@@ -1619,7 +1619,13 @@ static struct page *__alloc_huge_page(struct hstate *h,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
+	if (hstate_is_gigantic(h))  {
+		page = alloc_gigantic_page(nid, huge_page_order(h));
+		if (page)
+			prep_compound_gigantic_page(page, huge_page_order(h));
+	} else {
+		page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
+	}
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
@@ -1786,8 +1792,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	/* Uncommit the reservation */
 	h->resv_huge_pages -= unused_resv_pages;
 
-	/* Cannot return gigantic pages currently */
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return;
 
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
@@ -2439,7 +2444,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 	unsigned long input;
 	struct hstate *h = kobj_to_hstate(kobj, NULL);
 
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return -EINVAL;
 
 	err = kstrtoul(buf, 10, &input);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
