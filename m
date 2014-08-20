Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id A39F56B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 19:59:15 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id x13so8428449qcv.8
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 16:59:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u3si17273442qab.24.2014.08.20.16.59.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Aug 2014 16:59:15 -0700 (PDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 7/7] mm/balloon_compaction: general cleanup 
Date: Wed, 20 Aug 2014 20:58:58 -0300
Message-Id: <60e809f1c932fbbb175d59a750a329f04730717e.1408576903.git.aquini@redhat.com>
In-Reply-To: <20140820150509.4194.24336.stgit@buzz>
References: <20140820150509.4194.24336.stgit@buzz>
In-Reply-To: <5ad4664811559496e563ead974f10e8ee6b4ed47.1408576903.git.aquini@redhat.com>
References: <5ad4664811559496e563ead974f10e8ee6b4ed47.1408576903.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>

On Wed, Aug 20, 2014 at 07:05:09PM +0400, Konstantin Khlebnikov wrote:
> * move special branch for balloon migraion into migrate_pages
> * remove special mapping for balloon and its flag AS_BALLOON_MAP
> * embed struct balloon_dev_info into struct virtio_balloon
> * cleanup balloon_page_dequeue, kill balloon_page_free
> 
> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> ---
>  drivers/virtio/virtio_balloon.c    |   77 ++++---------
>  include/linux/balloon_compaction.h |  107 ++++++------------
>  include/linux/migrate.h            |   11 --
>  include/linux/pagemap.h            |   18 ---
>  mm/balloon_compaction.c            |  214 ++++++++++++------------------------
>  mm/migrate.c                       |   27 +----
>  6 files changed, 130 insertions(+), 324 deletions(-)
> 
Very nice clean-up, just as all other patches in this set.
Please, just consider amending the following changes to this patch of yours

Rafael
---

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index dc7073b..569cf96 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -75,41 +75,6 @@ extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
 #ifdef CONFIG_BALLOON_COMPACTION
 extern bool balloon_page_isolate(struct page *page);
 extern void balloon_page_putback(struct page *page);
-
-/*
- * balloon_page_insert - insert a page into the balloon's page list and make
- *		         the page->mapping assignment accordingly.
- * @page    : page to be assigned as a 'balloon page'
- * @mapping : allocated special 'balloon_mapping'
- * @head    : balloon's device page list head
- *
- * Caller must ensure the page is locked and the spin_lock protecting balloon
- * pages list is held before inserting a page into the balloon device.
- */
-static inline void
-balloon_page_insert(struct balloon_dev_info *balloon, struct page *page)
-{
-	__SetPageBalloon(page);
-	set_page_private(page, (unsigned long)balloon);
-	list_add(&page->lru, &balloon->pages);
-}
-
-/*
- * balloon_page_delete - delete a page from balloon's page list and clear
- *			 the page->mapping assignement accordingly.
- * @page    : page to be released from balloon's page list
- *
- * Caller must ensure the page is locked and the spin_lock protecting balloon
- * pages list is held before deleting a page from the balloon device.
- */
-static inline void balloon_page_delete(struct page *page, bool isolated)
-{
-	__ClearPageBalloon(page);
-	set_page_private(page, 0);
-	if (!isolated)
-		list_del(&page->lru);
-}
-
 int balloon_page_migrate(new_page_t get_new_page, free_page_t put_new_page,
 		unsigned long private, struct page *page,
 		int force, enum migrate_mode mode);
@@ -130,31 +95,6 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
 
 #else /* !CONFIG_BALLOON_COMPACTION */
 
-static inline void *balloon_mapping_alloc(void *balloon_device,
-				const struct address_space_operations *a_ops)
-{
-	return ERR_PTR(-EOPNOTSUPP);
-}
-
-static inline void balloon_mapping_free(struct address_space *balloon_mapping)
-{
-	return;
-}
-
-static inline void
-balloon_page_insert(struct balloon_dev_info *balloon, struct page *page)
-{
-	__SetPageBalloon(page);
-	list_add(&page->lru, head);
-}
-
-static inline void balloon_page_delete(struct page *page, bool isolated)
-{
-	__ClearPageBalloon(page);
-	if (!isolated)
-		list_del(&page->lru);
-}
-
 static inline int balloon_page_migrate(new_page_t get_new_page,
 		free_page_t put_new_page, unsigned long private,
 		struct page *page, int force, enum migrate_mode mode)
@@ -176,6 +116,46 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
 {
 	return GFP_HIGHUSER;
 }
-
 #endif /* CONFIG_BALLOON_COMPACTION */
+
+/*
+ * balloon_page_insert - insert a page into the balloon's page list and make
+ *		         the page->mapping assignment accordingly.
+ * @page    : page to be assigned as a 'balloon page'
+ * @mapping : allocated special 'balloon_mapping'
+ * @head    : balloon's device page list head
+ *
+ * Caller must ensure the page is locked and the spin_lock protecting balloon
+ * pages list is held before inserting a page into the balloon device.
+ */
+static inline void
+balloon_page_insert(struct balloon_dev_info *balloon, struct page *page)
+{
+#ifdef CONFIG_MEMORY_BALLOON
+	__SetPageBalloon(page);
+	set_page_private(page, (unsigned long)balloon);
+	list_add(&page->lru, &balloon->pages);
+	inc_zone_page_state(page, NR_BALLOON_PAGES);
+#endif
+}
+
+/*
+ * balloon_page_delete - delete a page from balloon's page list and clear
+ *			 the page->mapping assignement accordingly.
+ * @page    : page to be released from balloon's page list
+ *
+ * Caller must ensure the page is locked and the spin_lock protecting balloon
+ * pages list is held before deleting a page from the balloon device.
+ */
+static inline void balloon_page_delete(struct page *page, bool isolated)
+{
+#ifdef CONFIG_MEMORY_BALLOON
+	__ClearPageBalloon(page);
+	set_page_private(page, 0);
+	if (!isolated)
+		list_del(&page->lru);
+	dec_zone_page_state(page, NR_BALLOON_PAGES);
+#endif
+}
+
 #endif /* _LINUX_BALLOON_COMPACTION_H */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
