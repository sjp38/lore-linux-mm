Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 201866B0267
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 02:09:14 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id ro13so82834048pac.7
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 23:09:14 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0084.outbound.protection.outlook.com. [104.47.1.84])
        by mx.google.com with ESMTPS id g68si21159173pfc.88.2016.11.13.23.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 13 Nov 2016 23:09:13 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v2 6/6] mm: hugetlb: support gigantic surplus pages
Date: Mon, 14 Nov 2016 15:07:39 +0800
Message-ID: <1479107259-2011-7-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
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

This patch uses __hugetlb_alloc_gigantic_page() to allocate the
gigantic page in the __alloc_huge_page(). After this patch,
 gather_surplus_pages() can return a gigantic page for the surplus case.

This patch also changes the condition checks for:
     return_unused_surplus_pages()
     nr_overcommit_hugepages_store()
     hugetlb_overcommit_handler()

After this patch, the counter.sh can pass for the gigantic page.

Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 mm/hugetlb.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 58a59f0..08e66ca 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1647,7 +1647,7 @@ static struct page *__alloc_huge_page(struct hstate *h,
 	struct page *page;
 	unsigned int r_nid;
 
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return NULL;
 
 	/*
@@ -1692,7 +1692,10 @@ static struct page *__alloc_huge_page(struct hstate *h,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
+	if (hstate_is_gigantic(h))
+		page = __hugetlb_alloc_gigantic_page(h, vma, addr, nid);
+	else
+		page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
@@ -1859,8 +1862,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	/* Uncommit the reservation */
 	h->resv_huge_pages -= unused_resv_pages;
 
-	/* Cannot return gigantic pages currently */
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return;
 
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
@@ -2577,7 +2579,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 	unsigned long input;
 	struct hstate *h = kobj_to_hstate(kobj, NULL);
 
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return -EINVAL;
 
 	err = kstrtoul(buf, 10, &input);
@@ -3018,7 +3020,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 	tmp = h->nr_overcommit_huge_pages;
 
-	if (write && hstate_is_gigantic(h))
+	if (write && hstate_is_gigantic(h) && !gigantic_page_supported())
 		return -EINVAL;
 
 	table->data = &tmp;
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
