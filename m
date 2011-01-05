Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9F7BD6B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 15:30:17 -0500 (EST)
Received: by pwj8 with SMTP id 8so2706095pwj.14
        for <linux-mm@kvack.org>; Wed, 05 Jan 2011 12:30:16 -0800 (PST)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH V2] Do not allow pagesize >= MAX_ORDER pool adjustment
Date: Wed,  5 Jan 2011 13:29:57 -0700
Message-Id: <1294259397-15553-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, caiqian@redhat.com, mhocko@suse.cz, Eric B Munson <emunson@mgebm.net>
List-ID: <linux-mm.kvack.org>

Huge pages with order >= MAX_ORDER must be allocated at boot via
the kernel command line, they cannot be allocated or freed once
the kernel is up and running.  Currently we allow values to be
written to the sysfs and sysctl files controling pool size for these
huge page sizes.  This patch makes the store functions for nr_hugepages
and nr_overcommit_hugepages return -EINVAL when the pool for a
page size >= MAX_ORDER is changed.

Reported-by: CAI Qian <caiqian@redhat.com>

Signed-off-by: Eric B Munson <emunson@mgebm.net>
---
Changes from V1:
 Add check to sysctl handler

 mm/hugetlb.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5cb71a9..15bd633 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1443,6 +1443,12 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 		return -EINVAL;
 
 	h = kobj_to_hstate(kobj, &nid);
+
+	if (h->order >= MAX_ORDER) {
+		NODEMASK_FREE(nodes_allowed);
+		return -EINVAL;
+	}
+
 	if (nid == NUMA_NO_NODE) {
 		/*
 		 * global hstate attribute
@@ -1517,6 +1523,9 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 	unsigned long input;
 	struct hstate *h = kobj_to_hstate(kobj, NULL);
 
+	if (h->order >= MAX_ORDER)
+		return -EINVAL;
+
 	err = strict_strtoul(buf, 10, &input);
 	if (err)
 		return -EINVAL;
@@ -1926,6 +1935,9 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 	if (!write)
 		tmp = h->max_huge_pages;
 
+	if (write && h->order >= MAX_ORDER)
+		return -EINVAL;
+
 	table->data = &tmp;
 	table->maxlen = sizeof(unsigned long);
 	proc_doulongvec_minmax(table, write, buffer, length, ppos);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
