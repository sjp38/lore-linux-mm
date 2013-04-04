Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id F2F996B0027
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 05:09:32 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 19:02:19 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 864BD2CE804D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 20:09:26 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r348u5vd9765172
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 19:56:06 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3499P2p025533
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 20:09:25 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 3/6] mm/hugetlb: enable gigantic hugetlb page pools shrinking
Date: Thu,  4 Apr 2013 17:09:11 +0800
Message-Id: <1365066554-29195-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Enable gigantic hugetlb page pools shrinking.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/hugetlb.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index eeaf6f2..328f140 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1416,7 +1416,8 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 {
 	unsigned long min_count, ret;
 
-	if (h->order >= MAX_ORDER)
+	if (h->order >= MAX_ORDER && (!hugetlb_shrink_gigantic_pool ||
+				count > persistent_huge_pages(h)))
 		return h->max_huge_pages;
 
 	/*
@@ -1542,7 +1543,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 		goto out;
 
 	h = kobj_to_hstate(kobj, &nid);
-	if (h->order >= MAX_ORDER) {
+	if (h->order >= MAX_ORDER && !hugetlb_shrink_gigantic_pool) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -2036,7 +2037,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 
 	tmp = h->max_huge_pages;
 
-	if (write && h->order >= MAX_ORDER)
+	if (write && h->order >= MAX_ORDER && !hugetlb_shrink_gigantic_pool)
 		return -EINVAL;
 
 	table->data = &tmp;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
