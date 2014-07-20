Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id F0E056B003C
	for <linux-mm@kvack.org>; Sun, 20 Jul 2014 13:35:40 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so5434965wgh.26
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 10:35:40 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id vl8si22970084wjc.152.2014.07.20.10.35.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 20 Jul 2014 10:35:39 -0700 (PDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so5482169wgg.19
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 10:35:39 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v4 6/6] shm: wait for pins to be released when sealing
Date: Sun, 20 Jul 2014 19:34:40 +0200
Message-Id: <1405877680-999-7-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1405877680-999-1-git-send-email-dh.herrmann@gmail.com>
References: <1405877680-999-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>, Alexander Viro <viro@zeniv.linux.org.uk>, David Herrmann <dh.herrmann@gmail.com>

If we set SEAL_WRITE on a file, we must make sure there cannot be any
ongoing write-operations on the file. For write() calls, we simply lock
the inode mutex, for mmap() we simply verify there're no writable
mappings. However, there might be pages pinned by AIO, Direct-IO and
similar operations via GUP. We must make sure those do not write to the
memfd file after we set SEAL_WRITE.

As there is no way to notify GUP users to drop pages or to wait for them
to be done, we implement the wait ourself: When setting SEAL_WRITE, we
check all pages for their ref-count. If it's bigger than 1, we know
there's some user of the page. We then mark the page and wait for up to
150ms for those ref-counts to be dropped. If the ref-counts are not
dropped in time, we refuse the seal operation.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 mm/shmem.c | 110 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 109 insertions(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 770e072..df1aceb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1780,9 +1780,117 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 	return offset;
 }
 
+/*
+ * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
+ * so reuse a tag which we firmly believe is never set or cleared on shmem.
+ */
+#define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
+#define LAST_SCAN               4       /* about 150ms max */
+
+static void shmem_tag_pins(struct address_space *mapping)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	pgoff_t start;
+	struct page *page;
+
+	lru_add_drain();
+	start = 0;
+	rcu_read_lock();
+
+restart:
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		page = radix_tree_deref_slot(slot);
+		if (!page || radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page))
+				goto restart;
+		} else if (page_count(page) - page_mapcount(page) > 1) {
+			spin_lock_irq(&mapping->tree_lock);
+			radix_tree_tag_set(&mapping->page_tree, iter.index,
+					   SHMEM_TAG_PINNED);
+			spin_unlock_irq(&mapping->tree_lock);
+		}
+
+		if (need_resched()) {
+			cond_resched_rcu();
+			start = iter.index + 1;
+			goto restart;
+		}
+	}
+	rcu_read_unlock();
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
 static int shmem_wait_for_pins(struct address_space *mapping)
 {
-	return 0;
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
+
+	return error;
 }
 
 #define F_ALL_SEALS (F_SEAL_SEAL | \
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
