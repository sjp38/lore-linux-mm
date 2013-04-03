Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 212A96B0037
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 19:52:47 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx1so1179285pab.14
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 16:52:46 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [RFC PATCH 4/4] vrange: Enable purging of file backed volatile ranges
Date: Wed,  3 Apr 2013 16:52:23 -0700
Message-Id: <1365033144-15156-5-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

Rework the victim range selection to also support
file backed volatile ranges.

Cc: linux-mm@kvack.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Arun Sharma <asharma@fb.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Jason Evans <je@fb.com>
Cc: sanjay@google.com
Cc: Paul Turner <pjt@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/vrange.h |    8 ++++
 mm/vrange.c            |  118 +++++++++++++++++++++++++++++++++---------------
 2 files changed, 89 insertions(+), 37 deletions(-)

diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 91960eb..bada2bd 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -47,6 +47,14 @@ static inline struct mm_struct *vrange_get_owner_mm(struct vrange *vrange)
 	return container_of(vrange->owner, struct mm_struct, vroot);
 }
 
+static inline
+struct address_space *vrange_get_owner_mapping(struct vrange *vrange)
+{
+	if (vrange_type(vrange) != VRANGE_FILE)
+		return NULL;
+	return container_of(vrange->owner, struct address_space, vroot);
+}
+
 
 void vrange_init(void);
 extern void mm_exit_vrange(struct mm_struct *mm);
diff --git a/mm/vrange.c b/mm/vrange.c
index 671909c..b652513 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -690,8 +690,9 @@ static unsigned int discard_vma_pages(struct zone *zone, struct mm_struct *mm,
 	return ret;
 }
 
-unsigned int discard_vrange(struct zone *zone, struct vrange *vrange,
-				int nr_to_discard)
+static unsigned int discard_anon_vrange(struct zone *zone,
+					struct vrange *vrange,
+					int nr_to_discard)
 {
 	struct mm_struct *mm;
 	unsigned long start = vrange->node.start;
@@ -732,52 +733,91 @@ out:
 	return nr_discarded;
 }
 
+static unsigned int discard_file_vrange(struct zone *zone,
+					struct vrange *vrange,
+					int nr_to_discard)
+{
+	struct address_space *mapping;
+	unsigned long start = vrange->node.start;
+	unsigned long end = vrange->node.last;
+	unsigned long count = ((end-start) >> PAGE_CACHE_SHIFT);
+
+	mapping = vrange_get_owner_mapping(vrange);
+
+	truncate_inode_pages_range(mapping, start, end);
+	vrange->purged = true;
+
+	return count;
+}
+
+unsigned int discard_vrange(struct zone *zone, struct vrange *vrange,
+				int nr_to_discard)
+{
+	if (vrange_type(vrange) == VRANGE_ANON)
+		return discard_anon_vrange(zone, vrange, nr_to_discard);
+	return discard_file_vrange(zone, vrange, nr_to_discard);
+}
+
+
+/* Take a vrange refcount and depending on the type
+ * the vrange->owner's mm refcount or inode refcount
+ */
+static int hold_victim_vrange(struct vrange *vrange)
+{
+	if (vrange_type(vrange) == VRANGE_ANON) {
+		struct mm_struct *mm = vrange_get_owner_mm(vrange);
+
+
+		if (atomic_read(&mm->mm_users) == 0)
+			return -1;
+
+
+		if (!atomic_inc_not_zero(&vrange->refcount))
+			return -1;
+		/*
+		 * we need to access mmap_sem further routine so
+		 * need to get a refcount of mm.
+		 * NOTE: We guarantee mm_count isn't zero in here because
+		 * if we found vrange from LRU list, it means we are
+		 * before exit_vrange or remove_vrange.
+		 */
+		atomic_inc(&mm->mm_count);
+	} else {
+		struct address_space *mapping;
+		mapping = vrange_get_owner_mapping(vrange);
+
+		if (!atomic_inc_not_zero(&vrange->refcount))
+			return -1;
+		__iget(mapping->host);
+	}
+
+	return 0;
+}
+
+
+
 /*
- * Get next victim vrange from LRU and hold a vrange refcount
- * and vrange->mm's refcount.
+ * Get next victim vrange from LRU and hold needed refcounts.
  */
 static struct vrange *get_victim_vrange(void)
 {
-	struct mm_struct *mm;
 	struct vrange *vrange = NULL;
 	struct list_head *cur, *tmp;
 
 	spin_lock(&lru_lock);
 	list_for_each_prev_safe(cur, tmp, &lru_vrange) {
 		vrange = list_entry(cur, struct vrange, lru);
-		mm = vrange_get_owner_mm(vrange);
-
-		if (!mm) {
-			vrange = NULL;
-			continue;
-		}
 
-		/* the process is exiting so pass it */
-		if (atomic_read(&mm->mm_users) == 0) {
+		if (hold_victim_vrange(vrange)) {
 			list_del_init(&vrange->lru);
 			vrange = NULL;
 			continue;
 		}
 
-		/* vrange is freeing so continue to loop */
-		if (!atomic_inc_not_zero(&vrange->refcount)) {
-			list_del_init(&vrange->lru);
-			vrange = NULL;
-			continue;
-		}
-
-		/*
-		 * we need to access mmap_sem further routine so
-		 * need to get a refcount of mm.
-		 * NOTE: We guarantee mm_count isn't zero in here because
-		 * if we found vrange from LRU list, it means we are
-		 * before mm_exit_vrange or remove_vrange.
-		 */
-		atomic_inc(&mm->mm_count);
-
 		/* Isolate vrange */
 		list_del_init(&vrange->lru);
 		break;
+
 	}
 
 	spin_unlock(&lru_lock);
@@ -786,11 +826,18 @@ static struct vrange *get_victim_vrange(void)
 
 static void put_victim_range(struct vrange *vrange)
 {
-	struct mm_struct *mm = vrange_get_owner_mm(vrange);
-
 	put_vrange(vrange);
-	if (mm)
+
+	if (vrange_type(vrange) == VRANGE_ANON) {
+		struct mm_struct *mm = vrange_get_owner_mm(vrange);
+
 		mmdrop(mm);
+	} else {
+		struct address_space *mapping;
+
+		mapping = vrange_get_owner_mapping(vrange);
+		iput(mapping->host);
+	}
 }
 
 unsigned int discard_vrange_pages(struct zone *zone, int nr_to_discard)
@@ -799,11 +846,8 @@ unsigned int discard_vrange_pages(struct zone *zone, int nr_to_discard)
 	unsigned int nr_discarded = 0;
 
 	start_vrange = vrange = get_victim_vrange();
-	if (start_vrange) {
-		struct mm_struct *mm = vrange_get_owner_mm(vrange);
-		atomic_inc(&start_vrange->refcount);
-		atomic_inc(&mm->mm_count);
-	}
+	if (start_vrange)
+		hold_victim_vrange(start_vrange);
 
 	while (vrange) {
 		nr_discarded += discard_vrange(zone, vrange, nr_to_discard);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
