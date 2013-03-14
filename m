Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DAD8D6B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 06:50:30 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 20:43:45 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 07D402BB0023
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 21:50:26 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2EAoM8764422072
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 21:50:22 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2EAoP5j018977
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 21:50:25 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2] mm/hugetlb: fix total hugetlbfs pages count when memory overcommit accouting
Date: Thu, 14 Mar 2013 18:49:49 +0800
Message-Id: <1363258189-24945-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v1 -> v2:
  * update patch description, spotted by Michal

hugetlb_total_pages() does not account for all the supported hugepage
sizes. This can lead to incorrect calculation of the total number of
page frames used by hugetlb. This patch corrects the issue.

Testcase:
boot: hugepagesz=1G hugepages=1
before patch:
egrep 'CommitLimit' /proc/meminfo
CommitLimit:     55434168 kB
after patch:
egrep 'CommitLimit' /proc/meminfo
CommitLimit:     54909880 kB

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index cdb64e4..9e25040 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2124,8 +2124,11 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
 /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
 unsigned long hugetlb_total_pages(void)
 {
-	struct hstate *h = &default_hstate;
-	return h->nr_huge_pages * pages_per_huge_page(h);
+	struct hstate *h;
+	unsigned long nr_total_pages = 0;
+	for_each_hstate(h)
+		nr_total_pages += h->nr_huge_pages * pages_per_huge_page(h);
+	return nr_total_pages;
 }
 
 static int hugetlb_acct_memory(struct hstate *h, long delta)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
