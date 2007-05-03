Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id l43HuEKS017726
	for <linux-mm@kvack.org>; Thu, 3 May 2007 18:56:14 +0100
Received: from an-out-0708.google.com (anac28.prod.google.com [10.100.54.28])
	by spaceape13.eur.corp.google.com with ESMTP id l43Hu7Vf026915
	for <linux-mm@kvack.org>; Thu, 3 May 2007 18:56:08 +0100
Received: by an-out-0708.google.com with SMTP id c28so610987ana
        for <linux-mm@kvack.org>; Thu, 03 May 2007 10:56:00 -0700 (PDT)
Message-ID: <b040c32a0705031055n6a819551j908e9c644816ab1f@mail.gmail.com>
Date: Thu, 3 May 2007 10:55:33 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] pretending cpuset has some form of hugetlb page reservation
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

When cpuset is configured, it breaks the strict hugetlb page
reservation as the accounting is done on a global variable. Such
reservation is completely rubbish in the presence of cpuset because
the reservation is not checked against page availability for the
current cpuset. Application can still potentially OOM'ed by kernel
with lack of free htlb page in cpuset that the task is in.
Attempt to enforce strict accounting with cpuset is almost
impossible (or too ugly) because cpuset is too fluid that
task or memory node can be dynamically moved between cpusets.

The change of semantics for shared hugetlb mapping with cpuset is
undesirable. However, in order to preserve some of the semantics,
we fall back to check against current free page availability as
a best attempt and hopefully to minimize the impact of changing
semantics that cpuset has on hugetlb.


Signed-off-by: Ken Chen <kenchen@google.com>


--- ./mm/hugetlb.c.orig	2007-05-02 18:12:36.000000000 -0700
+++ ./mm/hugetlb.c	2007-05-03 10:50:24.000000000 -0700
@@ -172,6 +172,17 @@ static int __init hugetlb_setup(char *s)
 }
 __setup("hugepages=", hugetlb_setup);

+static unsigned int cpuset_mems_nr(unsigned int *array)
+{
+	int node;
+	unsigned int nr = 0;
+
+	for_each_node_mask(node, cpuset_current_mems_allowed)
+		nr += array[node];
+
+	return nr;
+}
+
 #ifdef CONFIG_SYSCTL
 static void update_and_free_page(struct page *page)
 {
@@ -817,6 +828,26 @@ int hugetlb_reserve_pages(struct inode *
 	chg = region_chg(&inode->i_mapping->private_list, from, to);
 	if (chg < 0)
 		return chg;
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
+	if (chg > cpuset_mems_nr(free_huge_pages_node))
+		return -ENOMEM;
+
 	ret = hugetlb_acct_memory(chg);
 	if (ret < 0)
 		return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
