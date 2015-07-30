Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9368A6B0260
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:04:35 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so39081834ykd.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:04:35 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id t144si1281469ywe.114.2015.07.30.10.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:04:26 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv3 07/10] xen/balloon: make alloc_xenballoon_pages() always allocate low pages
Date: Thu, 30 Jul 2015 18:03:09 +0100
Message-ID: <1438275792-5726-8-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>

All users of alloc_xenballoon_pages() wanted low memory pages, so
remove the option for high memory.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>
---
 arch/x86/xen/grant-table.c         |  2 +-
 drivers/xen/balloon.c              | 21 ++++++++-------------
 drivers/xen/grant-table.c          |  2 +-
 drivers/xen/privcmd.c              |  2 +-
 drivers/xen/xenbus/xenbus_client.c |  3 +--
 include/xen/balloon.h              |  3 +--
 6 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/arch/x86/xen/grant-table.c b/arch/x86/xen/grant-table.c
index 1580e7a..e079500 100644
--- a/arch/x86/xen/grant-table.c
+++ b/arch/x86/xen/grant-table.c
@@ -133,7 +133,7 @@ static int __init xlated_setup_gnttab_pages(void)
 		kfree(pages);
 		return -ENOMEM;
 	}
-	rc = alloc_xenballooned_pages(nr_grant_frames, pages, 0 /* lowmem */);
+	rc = alloc_xenballooned_pages(nr_grant_frames, pages);
 	if (rc) {
 		pr_warn("%s Couldn't balloon alloc %ld pfns rc:%d\n", __func__,
 			nr_grant_frames, rc);
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index e8b45e8..2a01da7 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -136,17 +136,16 @@ static void balloon_append(struct page *page)
 }
 
 /* balloon_retrieve: rescue a page from the balloon, if it is not empty. */
-static struct page *balloon_retrieve(bool prefer_highmem)
+static struct page *balloon_retrieve(bool require_lowmem)
 {
 	struct page *page;
 
 	if (list_empty(&ballooned_pages))
 		return NULL;
 
-	if (prefer_highmem)
-		page = list_entry(ballooned_pages.prev, struct page, lru);
-	else
-		page = list_entry(ballooned_pages.next, struct page, lru);
+	page = list_entry(ballooned_pages.next, struct page, lru);
+	if (require_lowmem && PageHighMem(page))
+		return NULL;
 	list_del(&page->lru);
 
 	if (PageHighMem(page))
@@ -522,24 +521,20 @@ EXPORT_SYMBOL_GPL(balloon_set_new_target);
  * alloc_xenballooned_pages - get pages that have been ballooned out
  * @nr_pages: Number of pages to get
  * @pages: pages returned
- * @highmem: allow highmem pages
  * @return 0 on success, error otherwise
  */
-int alloc_xenballooned_pages(int nr_pages, struct page **pages, bool highmem)
+int alloc_xenballooned_pages(int nr_pages, struct page **pages)
 {
 	int pgno = 0;
 	struct page *page;
 	mutex_lock(&balloon_mutex);
 	while (pgno < nr_pages) {
-		page = balloon_retrieve(highmem);
-		if (page && (highmem || !PageHighMem(page))) {
+		page = balloon_retrieve(true);
+		if (page) {
 			pages[pgno++] = page;
 		} else {
 			enum bp_state st;
-			if (page)
-				balloon_append(page);
-			st = decrease_reservation(nr_pages - pgno,
-					highmem ? GFP_HIGHUSER : GFP_USER);
+			st = decrease_reservation(nr_pages - pgno, GFP_USER);
 			if (st != BP_DONE)
 				goto out_undo;
 		}
diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
index 62f591f..a4b702c 100644
--- a/drivers/xen/grant-table.c
+++ b/drivers/xen/grant-table.c
@@ -687,7 +687,7 @@ int gnttab_alloc_pages(int nr_pages, struct page **pages)
 	int i;
 	int ret;
 
-	ret = alloc_xenballooned_pages(nr_pages, pages, false);
+	ret = alloc_xenballooned_pages(nr_pages, pages);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 5a29616..59cfec9 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -401,7 +401,7 @@ static int alloc_empty_pages(struct vm_area_struct *vma, int numpgs)
 	if (pages == NULL)
 		return -ENOMEM;
 
-	rc = alloc_xenballooned_pages(numpgs, pages, 0);
+	rc = alloc_xenballooned_pages(numpgs, pages);
 	if (rc != 0) {
 		pr_warn("%s Could not alloc %d pfns rc:%d\n", __func__,
 			numpgs, rc);
diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
index 9ad3272..2a2da04 100644
--- a/drivers/xen/xenbus/xenbus_client.c
+++ b/drivers/xen/xenbus/xenbus_client.c
@@ -614,8 +614,7 @@ static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
 	if (!node)
 		return -ENOMEM;
 
-	err = alloc_xenballooned_pages(nr_grefs, node->hvm.pages,
-				       false /* lowmem */);
+	err = alloc_xenballooned_pages(nr_grefs, node->hvm.pages);
 	if (err)
 		goto out_err;
 
diff --git a/include/xen/balloon.h b/include/xen/balloon.h
index c8aee7a..83efdeb 100644
--- a/include/xen/balloon.h
+++ b/include/xen/balloon.h
@@ -22,8 +22,7 @@ extern struct balloon_stats balloon_stats;
 
 void balloon_set_new_target(unsigned long target);
 
-int alloc_xenballooned_pages(int nr_pages, struct page **pages,
-		bool highmem);
+int alloc_xenballooned_pages(int nr_pages, struct page **pages);
 void free_xenballooned_pages(int nr_pages, struct page **pages);
 
 struct device;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
