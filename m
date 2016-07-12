Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0503F6B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 01:02:11 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e139so8516381oib.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 22:02:11 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id n9si9803150itn.14.2016.07.11.22.02.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 22:02:10 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH 1/2] kexec: remove unnecessary unusable_pages
Date: Tue, 12 Jul 2016 12:56:42 +0800
Message-ID: <1468299403-27954-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ebiederm@xmission.com, dyoung@redhat.com, horms@verge.net.au, vgoyal@redhat.com, yinghai@kernel.org, akpm@linux-foundation.org
Cc: kexec@lists.infradead.org, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

In general, kexec alloc pages from buddy system, it cannot exceed
the physical address in the system.

The patch just remove this unnecessary code, no functional change.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 include/linux/kexec.h |  1 -
 kernel/kexec_core.c   | 13 -------------
 2 files changed, 14 deletions(-)

diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index e8acb2b..26e4917 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -162,7 +162,6 @@ struct kimage {
 
 	struct list_head control_pages;
 	struct list_head dest_pages;
-	struct list_head unusable_pages;
 
 	/* Address of next control page to allocate for crash kernels. */
 	unsigned long control_page;
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 56b3ed0..448127d 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -257,9 +257,6 @@ struct kimage *do_kimage_alloc_init(void)
 	/* Initialize the list of destination pages */
 	INIT_LIST_HEAD(&image->dest_pages);
 
-	/* Initialize the list of unusable pages */
-	INIT_LIST_HEAD(&image->unusable_pages);
-
 	return image;
 }
 
@@ -517,10 +514,6 @@ static void kimage_free_extra_pages(struct kimage *image)
 {
 	/* Walk through and free any extra destination pages I may have */
 	kimage_free_page_list(&image->dest_pages);
-
-	/* Walk through and free any unusable pages I have cached */
-	kimage_free_page_list(&image->unusable_pages);
-
 }
 void kimage_terminate(struct kimage *image)
 {
@@ -647,12 +640,6 @@ static struct page *kimage_alloc_page(struct kimage *image,
 		page = kimage_alloc_pages(gfp_mask, 0);
 		if (!page)
 			return NULL;
-		/* If the page cannot be used file it away */
-		if (page_to_pfn(page) >
-				(KEXEC_SOURCE_MEMORY_LIMIT >> PAGE_SHIFT)) {
-			list_add(&page->lru, &image->unusable_pages);
-			continue;
-		}
 		addr = page_to_pfn(page) << PAGE_SHIFT;
 
 		/* If it is the destination page we want use it */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
