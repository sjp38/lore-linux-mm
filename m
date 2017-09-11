Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8136B02B8
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 07:05:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t3so16244803pgt.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 04:05:17 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50104.outbound.protection.outlook.com. [40.107.5.104])
        by mx.google.com with ESMTPS id f5si5643785pgq.140.2017.09.11.04.05.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 04:05:15 -0700 (PDT)
Subject: [PATCH] ksm: Fix unlocked iteration over vmas in
 cmp_and_merge_page()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 11 Sep 2017 14:05:05 +0300
Message-ID: <150512788393.10691.8868381099691121308.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com, minchan@kernel.org, mhocko@suse.com, zhongjiang@huawei.com, mingo@kernel.org, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ktkhai@virtuozzo.com

In this place mm is unlocked, so vmas or list may change.
Down read mmap_sem to protect them from modifications.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
(and compile-tested-by)
---
 mm/ksm.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index db20f8436bc3..86f0db3d6cdb 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1990,6 +1990,7 @@ static void stable_tree_append(struct rmap_item *rmap_item,
  */
 static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 {
+	struct mm_struct *mm = rmap_item->mm;
 	struct rmap_item *tree_rmap_item;
 	struct page *tree_page = NULL;
 	struct stable_node *stable_node;
@@ -2062,9 +2063,11 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	if (ksm_use_zero_pages && (checksum == zero_checksum)) {
 		struct vm_area_struct *vma;
 
-		vma = find_mergeable_vma(rmap_item->mm, rmap_item->address);
+		down_read(&mm->mmap_sem);
+		vma = find_mergeable_vma(mm, rmap_item->address);
 		err = try_to_merge_one_page(vma, page,
 					    ZERO_PAGE(rmap_item->address));
+		up_read(&mm->mmap_sem);
 		/*
 		 * In case of failure, the page was not really empty, so we
 		 * need to continue. Otherwise we're done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
