Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 540AC6B0037
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 20:42:05 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so9931273pad.8
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 17:42:04 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id ek3si186464pbd.235.2014.02.12.17.42.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 17:42:04 -0800 (PST)
Message-ID: <52FC22DA.9010002@huawei.com>
Date: Thu, 13 Feb 2014 09:41:46 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [3.10.x-stable] process accidentally killed by mce because of huge
 page migration
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, kirill.shutemov@linux.intel.com, hughd@google.com
Cc: Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>

Hi Naoya or Greg,

We found a bug in 3.10.x.
1) use sysfs interface soft_offline_page() to migrate a huge page.
2) the hpage become free after migrate_huge_page().
3) the free hpage is alloced and used by process A.
4) hwpoison flag is set by set_page_hwpoison_huge_page()
5) mce find this poisoned page.
6) process A was killed.
7) other processes which use this page will be killed too.

I tested this bug, one process keeps allocating huge page, and I 
use sysfs interface to soft offline a huge page, then received:
"MCE: Killing UCP:2717 due to hardware memory corruption fault at 8200034"

Upstream kernel is free from this bug because of these two commits:

f15bdfa802bfa5eb6b4b5a241b97ec9fa1204a35
mm/memory-failure.c: fix memory leak in successful soft offlining

c8721bbbdd36382de51cd6b7a56322e0acca2414
mm: memory-hotplug: enable memory hotplug to handle hugepage

The latter is not a bug fix and it's too big, the following patch
can fix this bug.

What do you think? Use the simple fix or backport the big patch?

Thanks,
Xishi Qiu


Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
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
