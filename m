Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D121E620089
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:11 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 47 of 67] set recommended min free kbytes
Message-Id: <4eb8c61a13c4de6ab162.1270691490@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

If transparent hugepage is enabled initialize min_free_kbytes to an optimal
value by default. This moves the hugeadm algorithm in kernel.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -86,6 +86,51 @@ struct khugepaged_scan {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
 
+
+static int set_recommended_min_free_kbytes(void)
+{
+	struct zone *zone;
+	int nr_zones = 0;
+	unsigned long recommended_min;
+	extern int min_free_kbytes;
+
+	if (!test_bit(TRANSPARENT_HUGEPAGE_FLAG,
+		      &transparent_hugepage_flags) &&
+	    !test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
+		      &transparent_hugepage_flags) &&
+	    !test_bit(TRANSPARENT_HUGEPAGE_KHUGEPAGED_FLAG,
+		      &transparent_hugepage_flags) &&
+	    !test_bit(TRANSPARENT_HUGEPAGE_KHUGEPAGED_REQ_MADV_FLAG,
+		      &transparent_hugepage_flags))
+		return 0;
+
+	for_each_populated_zone(zone)
+		nr_zones++;
+
+	/* Make sure at least 2 hugepages are free for MIGRATE_RESERVE */
+	recommended_min = HPAGE_PMD_NR * nr_zones * 2;
+
+	/*
+	 * Make sure that on average at least two pageblocks are almost free
+	 * of another type, one for a migratetype to fall back to and a
+	 * second to avoid subsequent fallbacks of other types There are 3
+	 * MIGRATE_TYPES we care about.
+	 */
+	recommended_min += HPAGE_PMD_NR * nr_zones * 3 * 3;
+
+	/* don't ever allow to reserve more than 5% of the lowmem */
+	recommended_min = min(recommended_min,
+			      (unsigned long) nr_free_buffer_pages() / 20);
+	recommended_min <<= (PAGE_SHIFT-10);
+
+	if (recommended_min > min_free_kbytes) {
+		min_free_kbytes = recommended_min;
+		setup_per_zone_wmarks();
+	}
+	return 0;
+}
+late_initcall(set_recommended_min_free_kbytes);
+
 static int start_khugepaged(void)
 {
 	int err = 0;
@@ -113,6 +158,8 @@ static int start_khugepaged(void)
 		mutex_unlock(&khugepaged_mutex);
 		if (wakeup)
 			wake_up_interruptible(&khugepaged_wait);
+
+		set_recommended_min_free_kbytes();
 	} else
 		/* wakeup to exit */
 		wake_up_interruptible(&khugepaged_wait);
@@ -178,9 +225,20 @@ static ssize_t enabled_store(struct kobj
 			     struct kobj_attribute *attr,
 			     const char *buf, size_t count)
 {
-	return double_flag_store(kobj, attr, buf, count,
-				 TRANSPARENT_HUGEPAGE_FLAG,
-				 TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
+	ssize_t ret;
+
+	ret = double_flag_store(kobj, attr, buf, count,
+				TRANSPARENT_HUGEPAGE_FLAG,
+				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
+
+	if (ret > 0 &&
+	    (test_bit(TRANSPARENT_HUGEPAGE_FLAG,
+		      &transparent_hugepage_flags) ||
+	     test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
+		      &transparent_hugepage_flags)))
+		set_recommended_min_free_kbytes();
+
+	return ret;
 }
 static struct kobj_attribute enabled_attr =
 	__ATTR(enabled, 0644, enabled_show, enabled_store);
@@ -495,6 +553,8 @@ static int __init hugepage_init(void)
 
 	start_khugepaged();
 
+	set_recommended_min_free_kbytes();
+
 out:
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
