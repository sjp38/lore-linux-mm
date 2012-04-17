Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 2E3566B0083
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 08:28:25 -0400 (EDT)
Received: by lbbgp10 with SMTP id gp10so2893088lbb.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 05:28:23 -0700 (PDT)
Subject: [PATCH linux-next] mm/hugetlb: fix warning in
 alloc_huge_page/dequeue_huge_page_vma
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 17 Apr 2012 16:28:19 +0400
Message-ID: <20120417122819.7438.26117.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

This patch fixes gcc warning (and bug?) introduced in linux-next commit cc9a6c877
("cpuset: mm: reduce large amounts of memory barrier related damage v3")

Local variable "page" can be uninitialized if nodemask from vma policy does not
intersects with nodemask from cpuset. Even if it wouldn't happens it's better to
initialize this variable explicitly than to introduce kernel oops on weird corner case.

mm/hugetlb.c: In function a??alloc_huge_pagea??:
mm/hugetlb.c:1135:5: warning: a??pagea?? may be used uninitialized in this function

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Mel Gorman <mgorman@suse.de>
---
 mm/hugetlb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4314a88..dcf4a55 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -532,7 +532,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
 				unsigned long address, int avoid_reserve)
 {
-	struct page *page;
+	struct page *page = NULL;
 	struct mempolicy *mpol;
 	nodemask_t *nodemask;
 	struct zonelist *zonelist;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
