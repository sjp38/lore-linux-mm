Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 591AB6B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 21:33:59 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so11705074pbc.13
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 18:33:59 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id cb2si1151538pbb.184.2014.02.13.18.33.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 18:33:58 -0800 (PST)
Message-ID: <52FD807F.5010105@huawei.com>
Date: Fri, 14 Feb 2014 10:33:35 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 3.10.x] mm: fix process accidentally killed by mce because
 of huge page migration
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, Linux MM <linux-mm@kvack.org>, stable@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Naoya or Greg,

We found a bug in 3.10.x.
The problem is that we accidentally have a hwpoisoned hugepage in free
hugepage list. It could happend in the the following scenario:

        process A                           process B

  migrate_huge_page
  put_page (old hugepage)
    linked to free hugepage list
                                     hugetlb_fault
                                       hugetlb_no_page
                                         alloc_huge_page
                                           dequeue_huge_page_vma
                                             dequeue_huge_page_node
                                               (steal hwpoisoned hugepage)
  set_page_hwpoison_huge_page
  dequeue_hwpoisoned_huge_page
    (fail to dequeue)

I tested this bug, one process keeps allocating huge page, and I 
use sysfs interface to soft offline a huge page, then received:
"MCE: Killing UCP:2717 due to hardware memory corruption fault at 8200034"

Upstream kernel is free from this bug because of these two commits:

f15bdfa802bfa5eb6b4b5a241b97ec9fa1204a35
mm/memory-failure.c: fix memory leak in successful soft offlining

c8721bbbdd36382de51cd6b7a56322e0acca2414
mm: memory-hotplug: enable memory hotplug to handle hugepage

The first one, although the problem is about memory leak, this patch
moves unset_migratetype_isolate(), which is important to avoid the race.
The latter is not a bug fix and it's too big, so I rewrite a small one.

The following patch can fix this bug.(please apply f15bdfa802bf first)


Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7c5eb85..6cb5b3b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -21,6 +21,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/page-isolation.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -517,9 +518,15 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
-	if (list_empty(&h->hugepage_freelists[nid]))
+	list_for_each_entry(page, &h->hugepage_freelists[nid], lru)
+		if (!is_migrate_isolate_page(page))
+			break;
+	/*
+	 * if 'non-isolated free hugepage' not found on the list,
+	 * the allocation fails.
+	 */
+	if (&h->hugepage_freelists[nid] == &page->lru)
 		return NULL;
-	page = list_entry(h->hugepage_freelists[nid].next, struct page, lru);
 	list_move(&page->lru, &h->hugepage_activelist);
 	set_page_refcounted(page);
 	h->free_huge_pages--;
-- 
1.7.1 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
