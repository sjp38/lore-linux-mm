Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id EF5556B0071
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 03:51:13 -0400 (EDT)
Received: by lacny3 with SMTP id ny3so32328285lac.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:13 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com. [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id cr7si9837023lad.33.2015.06.15.00.51.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 00:51:12 -0700 (PDT)
Received: by labbc20 with SMTP id bc20so16039317lab.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:11 -0700 (PDT)
Subject: [PATCH RFC v0 4/6] mm/migrate: page migration without page isolation
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 15 Jun 2015 10:51:07 +0300
Message-ID: <20150615075107.18112.64594.stgit@zurg>
In-Reply-To: <20150615073926.18112.59207.stgit@zurg>
References: <20150615073926.18112.59207.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

migrate_pagevec() does the same job as migrate_pages() but it works with
chained page vector instead of list of isolated pages.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/migrate.h |    4 ++
 mm/migrate.c            |   98 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 102 insertions(+)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index cac1c09..04553f5 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -33,6 +33,10 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
 		unsigned long private, enum migrate_mode mode, int reason);
+struct pagevec;
+extern int migrate_pagevec(struct pagevec *pages, new_page_t get_new_page,
+		free_page_t put_new_page, unsigned long private,
+		enum migrate_mode mode, int reason);
 
 extern int migrate_prep(void);
 extern int migrate_prep_local(void);
diff --git a/mm/migrate.c b/mm/migrate.c
index eca80b3..775cc9d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1153,6 +1153,104 @@ out:
 	return rc;
 }
 
+/*
+ * migrate_pagevec - migrate the pages specified in a page vector, to the free
+ *		     pages supplied as the target for the page migration
+ *
+ * @pages:		The vector of pages to be migrated.
+ * @get_new_page:	The function used to allocate free pages to be used
+ *			as the target of the page migration.
+ * @put_new_page:	The function used to free target pages if migration
+ *			fails, or NULL if no special handling is necessary.
+ * @private:		Private data to be passed on to get_new_page()
+ * @mode:		The migration mode that specifies the constraints for
+ *			page migration, if any.
+ * @reason:		The reason for page migration.
+ *
+ * The function returns after 10 attempts or if no pages are movable any more
+ * because the vector has become empty or no retryable pages exist any more.
+ * This function keeps all pages in the page vector but reorders them.
+ *
+ * Returns the number of pages that were not migrated, or an error code.
+ */
+int migrate_pagevec(struct pagevec *pages, new_page_t get_new_page,
+		    free_page_t put_new_page, unsigned long private,
+		    enum migrate_mode mode, int reason)
+{
+	int nr_to_scan = INT_MAX;
+	int nr_failed = 0;
+	int nr_succeeded = 0;
+	int nr_retry, pass;
+	struct page *page;
+	int swapwrite = current->flags & PF_SWAPWRITE;
+	int rc;
+
+	if (!swapwrite)
+		current->flags |= PF_SWAPWRITE;
+
+	for (pass = 0; pass < 10 && nr_to_scan; pass++) {
+		struct pagevec *pvec, *retry_pvec = pages;
+		int index, retry_index = 0;
+
+		nr_retry = 0;
+		pagevec_for_each_vec_and_page(pages, pvec, index, page) {
+			cond_resched();
+
+			if (!nr_to_scan--)
+				goto next_pass;
+
+			if (PageHuge(page))
+				rc = unmap_and_move_huge_page(get_new_page,
+						put_new_page, private, page,
+						pass > 2, mode);
+			else
+				rc = unmap_and_move(get_new_page, put_new_page,
+						private, page, pass > 2, mode);
+
+			switch(rc) {
+			case -ENOMEM:
+				goto out;
+			case -EAGAIN:
+				nr_retry++;
+				/* move page to the head for next pass */
+				swap(pvec->pages[index],
+				     retry_pvec->pages[retry_index]);
+				if (++retry_index == retry_pvec->nr) {
+					retry_pvec = pagevec_next(retry_pvec);
+					retry_index = 0;
+				}
+				break;
+			case MIGRATEPAGE_SUCCESS:
+				nr_succeeded++;
+				break;
+			default:
+				/*
+				 * Permanent failure (-EBUSY, -ENOSYS, etc.):
+				 * unlike -EAGAIN case, the failed page is
+				 * removed from migration page list and not
+				 * retried in the next outer loop.
+				 */
+				nr_failed++;
+				break;
+			}
+		}
+next_pass:
+		nr_to_scan = nr_retry;
+	}
+	rc = nr_failed + nr_retry;
+out:
+	if (nr_succeeded)
+		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
+	if (nr_failed)
+		count_vm_events(PGMIGRATE_FAIL, nr_failed);
+	trace_mm_migrate_pages(nr_succeeded, nr_failed, mode, reason);
+
+	if (!swapwrite)
+		current->flags &= ~PF_SWAPWRITE;
+
+	return rc;
+}
+
 #ifdef CONFIG_NUMA
 /*
  * Move a list of individual pages

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
