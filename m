From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080520162918.8338.60591.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080520162858.8338.22460.sendpatchset@skynet.skynet.ie>
References: <20080520162858.8338.22460.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/3] Move hugetlb_acct_memory()
Date: Tue, 20 May 2008 17:29:18 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, agl@us.ibm.com, andi@firstfloor.org, kenchen@google.com, apw@shadowen.org, abh@cray.com
List-ID: <linux-mm.kvack.org>

A later patch in this set needs to call hugetlb_acct_memory() before it
is defined. This patch moves the function without modification. This makes
later diffs easier to read.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/hugetlb.c |   82 +++++++++++++++++++++++++++---------------------------
 1 file changed, 41 insertions(+), 41 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc2-mm1-clean/mm/hugetlb.c linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/mm/hugetlb.c
--- linux-2.6.26-rc2-mm1-clean/mm/hugetlb.c	2008-05-19 13:36:30.000000000 +0100
+++ linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/mm/hugetlb.c	2008-05-20 11:53:41.000000000 +0100
@@ -716,6 +716,47 @@ unsigned long hugetlb_total_pages(void)
 	return nr_huge_pages * (HPAGE_SIZE / PAGE_SIZE);
 }
 
+static int hugetlb_acct_memory(long delta)
+{
+	int ret = -ENOMEM;
+
+	spin_lock(&hugetlb_lock);
+	/*
+	 * When cpuset is configured, it breaks the strict hugetlb page
+	 * reservation as the accounting is done on a global variable. Such
+	 * reservation is completely rubbish in the presence of cpuset because
+	 * the reservation is not checked against page availability for the
+	 * current cpuset. Application can still potentially OOM'ed by kernel
+	 * with lack of free htlb page in cpuset that the task is in.
+	 * Attempt to enforce strict accounting with cpuset is almost
+	 * impossible (or too ugly) because cpuset is too fluid that
+	 * task or memory node can be dynamically moved between cpusets.
+	 *
+	 * The change of semantics for shared hugetlb mapping with cpuset is
+	 * undesirable. However, in order to preserve some of the semantics,
+	 * we fall back to check against current free page availability as
+	 * a best attempt and hopefully to minimize the impact of changing
+	 * semantics that cpuset has.
+	 */
+	if (delta > 0) {
+		if (gather_surplus_pages(delta) < 0)
+			goto out;
+
+		if (delta > cpuset_mems_nr(free_huge_pages_node)) {
+			return_unused_surplus_pages(delta);
+			goto out;
+		}
+	}
+
+	ret = 0;
+	if (delta < 0)
+		return_unused_surplus_pages((unsigned long) -delta);
+
+out:
+	spin_unlock(&hugetlb_lock);
+	return ret;
+}
+
 /*
  * We cannot handle pagefaults against hugetlb pages at all.  They cause
  * handle_mm_fault() to try to instantiate regular-sized pages in the
@@ -1248,47 +1289,6 @@ static long region_truncate(struct list_
 	return chg;
 }
 
-static int hugetlb_acct_memory(long delta)
-{
-	int ret = -ENOMEM;
-
-	spin_lock(&hugetlb_lock);
-	/*
-	 * When cpuset is configured, it breaks the strict hugetlb page
-	 * reservation as the accounting is done on a global variable. Such
-	 * reservation is completely rubbish in the presence of cpuset because
-	 * the reservation is not checked against page availability for the
-	 * current cpuset. Application can still potentially OOM'ed by kernel
-	 * with lack of free htlb page in cpuset that the task is in.
-	 * Attempt to enforce strict accounting with cpuset is almost
-	 * impossible (or too ugly) because cpuset is too fluid that
-	 * task or memory node can be dynamically moved between cpusets.
-	 *
-	 * The change of semantics for shared hugetlb mapping with cpuset is
-	 * undesirable. However, in order to preserve some of the semantics,
-	 * we fall back to check against current free page availability as
-	 * a best attempt and hopefully to minimize the impact of changing
-	 * semantics that cpuset has.
-	 */
-	if (delta > 0) {
-		if (gather_surplus_pages(delta) < 0)
-			goto out;
-
-		if (delta > cpuset_mems_nr(free_huge_pages_node)) {
-			return_unused_surplus_pages(delta);
-			goto out;
-		}
-	}
-
-	ret = 0;
-	if (delta < 0)
-		return_unused_surplus_pages((unsigned long) -delta);
-
-out:
-	spin_unlock(&hugetlb_lock);
-	return ret;
-}
-
 int hugetlb_reserve_pages(struct inode *inode, long from, long to)
 {
 	long ret, chg;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
