Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CEF186B003A
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 03:08:46 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 13 Mar 2013 12:36:24 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id B5A3DE004E
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:40:00 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2D78bAj26280090
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:38:37 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2D78dU2003977
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 18:08:39 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH] mm/hugetlb: fix total hugetlbfs pages count when memory overcommit accouting
Date: Wed, 13 Mar 2013 15:08:31 +0800
Message-Id: <1363158511-21272-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

After commit 42d7395f ("mm: support more pagesizes for MAP_HUGETLB/SHM_HUGETLB")
be merged, kernel permit multiple huge page sizes, and when the system administrator 
has configured the system to provide huge page pools of different sizes, application 
can choose the page size used for their allocation. However, just default size of 
huge page pool is statistical when memory overcommit accouting, the bad is that this 
will result in innocent processes be killed by oom-killer later. Fix it by statistic 
all huge page pools of different sizes provided by administrator.

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
