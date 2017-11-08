Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58D7B440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 10:17:34 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id y206so2275670oiy.8
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 07:17:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s9si1983144oif.252.2017.11.08.07.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 07:17:32 -0800 (PST)
Date: Wed, 8 Nov 2017 17:17:29 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3] virtio_balloon: fix deadlock on OOM
Message-ID: <1510154064-9709-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

fill_balloon doing memory allocations under balloon_lock
can cause a deadlock when leak_balloon is called from
virtballoon_oom_notify and tries to take same lock.

To fix, split page allocation and enqueue and do allocations outside the lock.

Here's a detailed analysis of the deadlock by Tetsuo Handa:

In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
serialize against fill_balloon(). But in fill_balloon(),
alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE]
implies __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, despite __GFP_NORETRY
is specified, this allocation attempt might indirectly depend on somebody
else's __GFP_DIRECT_RECLAIM memory allocation. And such indirect
__GFP_DIRECT_RECLAIM memory allocation might call leak_balloon() via
virtballoon_oom_notify() via blocking_notifier_call_chain() callback via
out_of_memory() when it reached __alloc_pages_may_oom() and held oom_lock
mutex. Since vb->balloon_lock mutex is already held by fill_balloon(), it
will cause OOM lockup.

  Thread1                                       Thread2
    fill_balloon()
      takes a balloon_lock
      balloon_page_enqueue()
        alloc_page(GFP_HIGHUSER_MOVABLE)
          direct reclaim (__GFP_FS context)       takes a fs lock
            waits for that fs lock                  alloc_page(GFP_NOFS)
                                                      __alloc_pages_may_oom()
                                                        takes the oom_lock
                                                        out_of_memory()
                                                          blocking_notifier_call_chain()
                                                            leak_balloon()
                                                              tries to take that balloon_lock and deadlocks

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Changes since v2:
	drop an unused declaration, reported by Tetsuo Hocko
Changes from v1:
	fix a build warning

 drivers/virtio/virtio_balloon.c    | 24 +++++++++++++++++++-----
 include/linux/balloon_compaction.h | 35 ++++++++++++++++++++++++++++++++++-
 mm/balloon_compaction.c            | 28 +++++++++++++++++++++-------
 3 files changed, 74 insertions(+), 13 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index f0b3a0b..7960746 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -143,16 +143,17 @@ static void set_page_pfns(struct virtio_balloon *vb,
 
 static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 {
-	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	unsigned num_allocated_pages;
+	unsigned num_pfns;
+	struct page *page;
+	LIST_HEAD(pages);
 
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
-	mutex_lock(&vb->balloon_lock);
-	for (vb->num_pfns = 0; vb->num_pfns < num;
-	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
-		struct page *page = balloon_page_enqueue(vb_dev_info);
+	for (num_pfns = 0; num_pfns < num;
+	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
+		struct page *page = balloon_page_alloc();
 
 		if (!page) {
 			dev_info_ratelimited(&vb->vdev->dev,
@@ -162,6 +163,19 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 			msleep(200);
 			break;
 		}
+
+		balloon_page_push(&pages, page);
+	}
+
+	mutex_lock(&vb->balloon_lock);
+
+	vb->num_pfns = 0;
+
+	while ((page = balloon_page_pop(&pages))) {
+		balloon_page_enqueue(&vb->vb_dev_info, page);
+
+		vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE;
+
 		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		if (!virtio_has_feature(vb->vdev,
diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index fbbe6da..c4c8df9 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -50,6 +50,7 @@
 #include <linux/gfp.h>
 #include <linux/err.h>
 #include <linux/fs.h>
+#include <linux/list.h>
 
 /*
  * Balloon device information descriptor.
@@ -67,7 +68,9 @@ struct balloon_dev_info {
 	struct inode *inode;
 };
 
-extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
+extern struct page *balloon_page_alloc(void);
+extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
+				 struct page *page);
 extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
 
 static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
@@ -89,6 +92,36 @@ extern int balloon_page_migrate(struct address_space *mapping,
 				struct page *page, enum migrate_mode mode);
 
 /*
+ * balloon_page_push - insert a page into a page list.
+ * @head : pointer to list
+ * @page : page to be added
+ *
+ * Caller must ensure the page is private and protect the list.
+ */
+static inline void balloon_page_push(struct list_head *pages, struct page *page)
+{
+	list_add(&page->lru, pages);
+}
+
+/*
+ * balloon_page_pop - remove a page from a page list.
+ * @head : pointer to list
+ * @page : page to be added
+ *
+ * Caller must ensure the page is private and protect the list.
+ */
+static inline struct page *balloon_page_pop(struct list_head *pages)
+{
+	struct page *page = list_first_entry_or_null(pages, struct page, lru);
+
+	if (!page)
+		return NULL;
+
+	list_del(&page->lru);
+	return page;
+}
+
+/*
  * balloon_page_insert - insert a page into the balloon's page list and make
  *			 the page->private assignment accordingly.
  * @balloon : pointer to balloon device
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 68d2892..ef858d5 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -11,22 +11,37 @@
 #include <linux/balloon_compaction.h>
 
 /*
+ * balloon_page_alloc - allocates a new page for insertion into the balloon
+ *			  page list.
+ *
+ * Driver must call it to properly allocate a new enlisted balloon page.
+ * Driver must call balloon_page_enqueue before definitively removing it from
+ * the guest system.  This function returns the page address for the recently
+ * allocated page or NULL in the case we fail to allocate a new page this turn.
+ */
+struct page *balloon_page_alloc(void)
+{
+	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
+				       __GFP_NOMEMALLOC | __GFP_NORETRY);
+	return page;
+}
+EXPORT_SYMBOL_GPL(balloon_page_alloc);
+
+/*
  * balloon_page_enqueue - allocates a new page and inserts it into the balloon
  *			  page list.
  * @b_dev_info: balloon device descriptor where we will insert a new page to
+ * @page: new page to enqueue - allocated using balloon_page_alloc.
  *
- * Driver must call it to properly allocate a new enlisted balloon page
+ * Driver must call it to properly enqueue a new allocated balloon page
  * before definitively removing it from the guest system.
  * This function returns the page address for the recently enqueued page or
  * NULL in the case we fail to allocate a new page this turn.
  */
-struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
+void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
+			  struct page *page)
 {
 	unsigned long flags;
-	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
-				       __GFP_NOMEMALLOC | __GFP_NORETRY);
-	if (!page)
-		return NULL;
 
 	/*
 	 * Block others from accessing the 'page' when we get around to
@@ -39,7 +54,6 @@ struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
 	__count_vm_event(BALLOON_INFLATE);
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 	unlock_page(page);
-	return page;
 }
 EXPORT_SYMBOL_GPL(balloon_page_enqueue);
 
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
