Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id A92B36B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 07:31:00 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 16:56:38 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id D7EEDE004A
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 17:02:16 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2EBUohk5374294
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 17:00:50 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2EBUqiD006483
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 22:30:54 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3] mm/hugetlb: fix total hugetlbfs pages count when memory overcommit accouting
Date: Thu, 14 Mar 2013 19:30:46 +0800
Message-Id: <1363260646-26896-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v2 -> v3:
  * update patch description, spotted by Michal
 v1 -> v2:
  * update patch description, spotted by Michal

"hugetlb_total_pages is used for overcommit calculations but the
current implementation considers only default hugetlb page size (which
is either the first defined hugepage size or the one specified by
default_hugepagesz kernel boot parameter).

If the system is configured for more than one hugepage size (which is
possible since a137e1cc hugetlbfs: per mount huge page sizes) then
the overcommit estimation done by __vm_enough_memory (resp. shown by
meminfo_proc_show) is not precise - there is an impression of more
available/allowed memory. This can lead to an unexpected ENOMEM/EFAULT
resp. SIGSEGV when memory is accounted."

The patch should also push to 2.6.27 stable tree.

Testcase:
boot: hugepagesz=1G hugepages=1
the default overcommit ratio is 50
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
