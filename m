Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id A1D586B00EB
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:22:25 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 11:14:50 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KBGm7n3432612
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:16:48 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KBM5p5019744
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:05 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 3/9] hugetlbfs: Add new region handling functions.
Date: Mon, 20 Feb 2012 16:51:36 +0530
Message-Id: <1329736902-26870-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

These functions takes an extra argument and only merge regions if the data value
matches. This help us to build regions with difference hugetlb cgroup values.
Last patch in the series will merge this to existing region code, having this as
separate allows us to add cgroup support shared and private mapping in separate
patchset.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/hugetlb_cgroup.c |  127 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 127 insertions(+), 0 deletions(-)

diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgroup.c
index 75dbdd8..9bd2691 100644
--- a/fs/hugetlbfs/hugetlb_cgroup.c
+++ b/fs/hugetlbfs/hugetlb_cgroup.c
@@ -31,9 +31,136 @@ struct hugetlb_cgroup {
 	struct res_counter memhuge[HUGE_MAX_HSTATE];
 };
 
+struct file_region_with_data {
+	struct list_head link;
+	long from;
+	long to;
+	unsigned long data;
+};
+
 struct cgroup_subsys hugetlb_subsys __read_mostly;
 struct hugetlb_cgroup *root_h_cgroup __read_mostly;
 
+/*
+ * A vairant of region_add that only merges regions only if data
+ * match.
+ */
+static long region_chg_with_same(struct list_head *head,
+				 long f, long t, unsigned long data)
+{
+	long chg = 0;
+	struct file_region_with_data *rg, *nrg, *trg;
+
+	/* Locate the region we are before or in. */
+	list_for_each_entry(rg, head, link)
+		if (f <= rg->to)
+			break;
+	/*
+	 * If we are below the current region then a new region is required.
+	 * Subtle, allocate a new region at the position but make it zero
+	 * size such that we can guarantee to record the reservation.
+	 */
+	if (&rg->link == head || t < rg->from) {
+		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+		if (!nrg)
+			return -ENOMEM;
+		nrg->from = f;
+		nrg->to = f;
+		nrg->data = data;
+		INIT_LIST_HEAD(&nrg->link);
+		list_add(&nrg->link, rg->link.prev);
+		return t - f;
+	}
+	/*
+	 * f rg->from t rg->to
+	 */
+	if (f < rg->from && data != rg->data) {
+		/* we need to allocate a new region */
+		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+		if (!nrg)
+			return -ENOMEM;
+		nrg->from = f;
+		nrg->to = f;
+		nrg->data = data;
+		INIT_LIST_HEAD(&nrg->link);
+		list_add(&nrg->link, rg->link.prev);
+	}
+
+	/* Round our left edge to the current segment if it encloses us. */
+	if (f > rg->from)
+		f = rg->from;
+	chg = t - f;
+
+	/* Check for and consume any regions we now overlap with. */
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		if (rg->from > t)
+			return chg;
+		/*
+		 * rg->from f rg->to t
+		 */
+		if (t > rg->to && data != rg->data) {
+			/* we need to allocate a new region */
+			nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+			if (!nrg)
+				return -ENOMEM;
+			nrg->from = rg->to;
+			nrg->to  = rg->to;
+			nrg->data = data;
+			INIT_LIST_HEAD(&nrg->link);
+			list_add(&nrg->link, &rg->link);
+		}
+		/*
+		 * update charge
+		 */
+		if (rg->to > t) {
+			chg += rg->to - t;
+			t = rg->to;
+		}
+		chg -= rg->to - rg->from;
+	}
+	return chg;
+}
+
+static void region_add_with_same(struct list_head *head,
+				 long f, long t, unsigned long data)
+{
+	struct file_region_with_data *rg, *nrg, *trg;
+
+	/* Locate the region we are before or in. */
+	list_for_each_entry(rg, head, link)
+		if (f <= rg->to)
+			break;
+
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+
+		if (rg->from > t)
+			return;
+		if (&rg->link == head)
+			return;
+
+		/*FIXME!! this can possibly delete few regions */
+		/* We need to worry only if we match data */
+		if (rg->data == data) {
+			if (f < rg->from)
+				rg->from = f;
+			if (t > rg->to) {
+				/* if we are the last entry */
+				if (rg->link.next == head) {
+					rg->to = t;
+					break;
+				} else {
+					nrg = list_entry(rg->link.next,
+							 typeof(*nrg), link);
+					rg->to = nrg->from;
+				}
+			}
+		}
+		f = rg->to;
+	}
+}
+
 static inline
 struct hugetlb_cgroup *css_to_hugetlbcgroup(struct cgroup_subsys_state *s)
 {
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
