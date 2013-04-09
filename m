Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 65E0C6B0068
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:51:02 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 07:42:14 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 290992BB0051
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:50:58 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39LbVT524707102
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:37:31 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39LouLt031422
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:50:57 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 11/15] mm: Restructure the compaction part of CMA for
 wider use
Date: Wed, 10 Apr 2013 03:18:17 +0530
Message-ID: <20130409214814.4500.19572.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

CMA uses bits and pieces of the memory compaction algorithms to perform
large contiguous allocations. Those algorithms would be useful for
memory power management too, to evacuate entire regions of memory.
So rewrite the code in a way that helps us to easily reuse the code for
both use-cases.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/compaction.c |   75 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h   |   40 +++++++++++++++++++++++++++++
 mm/page_alloc.c |   51 ++++++++++---------------------------
 3 files changed, 128 insertions(+), 38 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 13912f5..ff9cf23 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -816,6 +816,81 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return ISOLATE_SUCCESS;
 }
 
+/*
+ * Make free pages available within the given range, using compaction to
+ * migrate used pages elsewhere.
+ *
+ * [start, end) must belong to a single zone.
+ *
+ * This function is roughly based on the logic inside compact_zone().
+ */
+int compact_range(struct compact_control *cc, struct aggression_control *ac,
+		  struct free_page_control *fc, unsigned long start,
+		  unsigned long end)
+{
+	unsigned long pfn = start;
+	int ret = 0, tries, migrate_mode;
+
+	if (ac->prep_all)
+		migrate_prep();
+	else
+		migrate_prep_local();
+
+	while (pfn < end || !list_empty(&cc->migratepages)) {
+		if (list_empty(&cc->migratepages)) {
+			cc->nr_migratepages = 0;
+			pfn = isolate_migratepages_range(cc->zone, cc,
+					pfn, end, ac->isolate_unevictable);
+
+			if (!pfn) {
+				ret = -EINTR;
+				break;
+			}
+		}
+
+		for (tries = 0; tries < ac->max_tries; tries++) {
+			if (fatal_signal_pending(current)){
+				ret = -EINTR;
+				goto out;
+			}
+
+			if (ac->reclaim_clean) {
+				int nr_reclaimed;
+
+				nr_reclaimed =
+					reclaim_clean_pages_from_list(cc->zone,
+							&cc->migratepages);
+
+				cc->nr_migratepages -= nr_reclaimed;
+			}
+
+			migrate_mode = cc->sync ? MIGRATE_SYNC : MIGRATE_ASYNC;
+			ret = migrate_pages(&cc->migratepages,
+					    fc->free_page_alloc, fc->alloc_data,
+					    migrate_mode, ac->reason);
+
+			update_nr_listpages(cc);
+		}
+
+		if (tries == ac->max_tries) {
+			ret = ret < 0 ? ret : -EBUSY;
+			break;
+		}
+	}
+
+out:
+	if (ret < 0)
+		putback_movable_pages(&cc->migratepages);
+
+	/* Release free pages and check accounting */
+	if (fc->release_freepages)
+		cc->nr_freepages -= fc->release_freepages(fc->free_data);
+
+	VM_BUG_ON(cc->nr_freepages != 0);
+
+	return ret;
+}
+
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
diff --git a/mm/internal.h b/mm/internal.h
index 8562de0..398fe73 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -110,6 +110,42 @@ extern bool is_free_buddy_page(struct page *page);
 /*
  * in mm/compaction.c
  */
+
+struct free_page_control {
+
+	/* Function used to allocate free pages as target of migration. */
+	struct page * (*free_page_alloc)(struct page *migratepage,
+					 unsigned long data,
+					 int **result);
+
+	unsigned long alloc_data;	/* Private data for free_page_alloc() */
+
+	/*
+	 * Function to release the accumulated free pages after the compaction
+	 * run.
+	 */
+	unsigned long (*release_freepages)(unsigned long info);
+	unsigned long free_data;	/* Private data for release_freepages() */
+};
+
+/*
+ * aggression_control gives us fine-grained control to specify how aggressively
+ * we want to compact memory.
+ */
+struct aggression_control {
+	bool isolate_unevictable;	/* Isolate unevictable pages too */
+	bool prep_all;			/* Use migrate_prep() instead of
+					 * migrate_prep_local().
+					 */
+	bool reclaim_clean;		/* Reclaim clean page cache pages */
+	int max_tries;			/* No. of tries to migrate the
+					 * isolated pages before giving up.
+					 */
+	int reason;			/* Reason for compaction, passed on
+					 * as reason for migrate_pages().
+					 */
+};
+
 /*
  * compact_control is used to track pages being migrated and the free pages
  * they are being migrated to during memory compaction. The free_pfn starts
@@ -144,6 +180,10 @@ unsigned long
 isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	unsigned long low_pfn, unsigned long end_pfn, bool unevictable);
 
+int compact_range(struct compact_control *cc, struct aggression_control *ac,
+		  struct free_page_control *fc, unsigned long start,
+		  unsigned long end);
+
 #endif
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 541e4ab..f31ca94 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6226,46 +6226,21 @@ static unsigned long pfn_max_align_up(unsigned long pfn)
 static int __alloc_contig_migrate_range(struct compact_control *cc,
 					unsigned long start, unsigned long end)
 {
-	/* This function is based on compact_zone() from compaction.c. */
-	unsigned long nr_reclaimed;
-	unsigned long pfn = start;
-	unsigned int tries = 0;
-	int ret = 0;
-
-	migrate_prep();
-
-	while (pfn < end || !list_empty(&cc->migratepages)) {
-		if (fatal_signal_pending(current)) {
-			ret = -EINTR;
-			break;
-		}
-
-		if (list_empty(&cc->migratepages)) {
-			cc->nr_migratepages = 0;
-			pfn = isolate_migratepages_range(cc->zone, cc,
-							 pfn, end, true);
-			if (!pfn) {
-				ret = -EINTR;
-				break;
-			}
-			tries = 0;
-		} else if (++tries == 5) {
-			ret = ret < 0 ? ret : -EBUSY;
-			break;
-		}
+	struct aggression_control ac = {
+		.isolate_unevictable = true,
+		.prep_all = true,
+		.reclaim_clean = true,
+		.max_tries = 5,
+		.reason = MR_CMA,
+	};
 
-		nr_reclaimed = reclaim_clean_pages_from_list(cc->zone,
-							&cc->migratepages);
-		cc->nr_migratepages -= nr_reclaimed;
+	struct free_page_control fc = {
+		.free_page_alloc = alloc_migrate_target,
+		.alloc_data = 0,
+		.release_freepages = NULL,
+	};
 
-		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
-				    0, MIGRATE_SYNC, MR_CMA);
-	}
-	if (ret < 0) {
-		putback_movable_pages(&cc->migratepages);
-		return ret;
-	}
-	return 0;
+	return compact_range(cc, &ac, &fc, start, end);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
