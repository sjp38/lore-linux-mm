Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 18B806B00B6
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 06:45:31 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so634987wib.1
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 03:45:30 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id ck8si6040157wjc.8.2014.06.13.03.45.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 03:45:29 -0700 (PDT)
Received: by mail-wi0-f171.google.com with SMTP id n15so629124wiw.10
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 03:45:29 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [RFC v3 6/7] shm: wait for pins to be released when sealing
Date: Fri, 13 Jun 2014 12:36:58 +0200
Message-Id: <1402655819-14325-7-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>, David Herrmann <dh.herrmann@gmail.com>

We currently fail setting SEAL_WRITE in case there're pending page
references. This patch extends the pin-tests to wait up to 150ms for all
references to be dropped. This is still not perfect in that it doesn't
account for harmless read-only pins, but it's much better than a hard
failure.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 mm/shmem.c | 97 ++++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 82 insertions(+), 15 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index e7c5fe1..ddc3998 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1735,25 +1735,19 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 }
 
 /*
- * Setting SEAL_WRITE requires us to verify there's no pending writer. However,
- * via get_user_pages(), drivers might have some pending I/O without any active
- * user-space mappings (eg., direct-IO, AIO). Therefore, we look at all pages
- * and see whether it has an elevated ref-count. If so, we abort.
- * The caller must guarantee that no new user will acquire writable references
- * to those pages to avoid races.
+ * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
+ * so reuse a tag which we firmly believe is never set or cleared on shmem.
  */
-static int shmem_test_for_pins(struct address_space *mapping)
+#define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
+#define LAST_SCAN               4       /* about 150ms max */
+
+static void shmem_tag_pins(struct address_space *mapping)
 {
 	struct radix_tree_iter iter;
 	void **slot;
 	pgoff_t start;
 	struct page *page;
-	int error;
-
-	/* flush additional refs in lru_add early */
-	lru_add_drain_all();
 
-	error = 0;
 	start = 0;
 	rcu_read_lock();
 
@@ -1764,8 +1758,10 @@ restart:
 			if (radix_tree_deref_retry(page))
 				goto restart;
 		} else if (page_count(page) - page_mapcount(page) > 1) {
-			error = -EBUSY;
-			break;
+			spin_lock_irq(&mapping->tree_lock);
+			radix_tree_tag_set(&mapping->page_tree, iter.index,
+					   SHMEM_TAG_PINNED);
+			spin_unlock_irq(&mapping->tree_lock);
 		}
 
 		if (need_resched()) {
@@ -1775,6 +1771,77 @@ restart:
 		}
 	}
 	rcu_read_unlock();
+}
+
+/*
+ * Setting SEAL_WRITE requires us to verify there's no pending writer. However,
+ * via get_user_pages(), drivers might have some pending I/O without any active
+ * user-space mappings (eg., direct-IO, AIO). Therefore, we look at all pages
+ * and see whether it has an elevated ref-count. If so, we tag them and wait for
+ * them to be dropped.
+ * The caller must guarantee that no new user will acquire writable references
+ * to those pages to avoid races.
+ */
+static int shmem_wait_for_pins(struct address_space *mapping)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	pgoff_t start;
+	struct page *page;
+	int error, scan;
+
+	shmem_tag_pins(mapping);
+
+	error = 0;
+	for (scan = 0; scan <= LAST_SCAN; scan++) {
+		if (!radix_tree_tagged(&mapping->page_tree, SHMEM_TAG_PINNED))
+			break;
+
+		if (!scan)
+			lru_add_drain_all();
+		else if (schedule_timeout_killable((HZ << scan) / 200))
+			scan = LAST_SCAN;
+
+		start = 0;
+		rcu_read_lock();
+restart:
+		radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
+					   start, SHMEM_TAG_PINNED) {
+
+			page = radix_tree_deref_slot(slot);
+			if (radix_tree_exception(page)) {
+				if (radix_tree_deref_retry(page))
+					goto restart;
+
+				page = NULL;
+			}
+
+			if (page &&
+			    page_count(page) - page_mapcount(page) != 1) {
+				if (scan < LAST_SCAN)
+					goto continue_resched;
+
+				/*
+				 * On the last scan, we clean up all those tags
+				 * we inserted; but make a note that we still
+				 * found pages pinned.
+				 */
+				error = -EBUSY;
+			}
+
+			spin_lock_irq(&mapping->tree_lock);
+			radix_tree_tag_clear(&mapping->page_tree,
+					     iter.index, SHMEM_TAG_PINNED);
+			spin_unlock_irq(&mapping->tree_lock);
+continue_resched:
+			if (need_resched()) {
+				cond_resched_rcu();
+				start = iter.index + 1;
+				goto restart;
+			}
+		}
+		rcu_read_unlock();
+	}
 
 	return error;
 }
@@ -1840,7 +1907,7 @@ int shmem_add_seals(struct file *file, unsigned int seals)
 		if (error)
 			goto unlock;
 
-		error = shmem_test_for_pins(file->f_mapping);
+		error = shmem_wait_for_pins(file->f_mapping);
 		if (error) {
 			mapping_allow_writable(file->f_mapping);
 			goto unlock;
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
