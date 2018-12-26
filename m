Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A7AF08E000B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id f69so17813903pff.5
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Message-Id: <20181226133352.189896494@intel.com>
Date: Wed, 26 Dec 2018 21:15:05 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 19/21] mm/migrate.c: add move_pages(MPOL_MF_SW_YOUNG) flag
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0010-migrate-check-if-the-page-is-software-young-when-mov.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Liu Jingqi <jingqi.liu@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Liu Jingqi <jingqi.liu@intel.com>

Introduce MPOL_MF_SW_YOUNG flag to move_pages(). When on,
the already-in-DRAM pages will be set PG_referenced.

Background:
The use space migration daemon will frequently scan page table and
read-clear accessed bits to detect hot/cold pages. Then migrate hot
pages from PMEM to DRAM node. When doing so, it btw tells kernel that
these are the hot page set. This maintains a persistent view of hot/cold
pages between kernel and user space daemon.

The more concrete steps are

1) do multiple scan of page table, count accessed bits
2) highest accessed count => hot pages
3) call move_pages(hot pages, DRAM nodes, MPOL_MF_SW_YOUNG)

(1) regularly clears PTE young, which makes kernel lose access to
    PTE young information

(2) for anonymous pages, user space daemon defines which is hot and
    which is cold

(3) conveys user space view of hot/cold pages to kernel through
    PG_referenced

In the long run, most hot pages could already be in DRAM.
move_pages(MPOL_MF_SW_YOUNG) sets PG_referenced for those already in
DRAM hot pages. But not for newly migrated hot pages. Since they are
expected to put to the end of LRU, thus has long enough time in LRU to
gather accessed/PG_referenced bit and prove to kernel they are really hot.

The daemon may only select DRAM/2 pages as hot for 2 purposes:
- avoid thrashing, eg. some warm pages got promoted then demoted soon
- make sure enough DRAM LRU pages look "cold" to kernel, so that vmscan
  won't run into trouble busy scanning LRU lists

Signed-off-by: Liu Jingqi <jingqi.liu@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/migrate.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

--- linux.orig/mm/migrate.c	2018-12-23 20:37:12.604621319 +0800
+++ linux/mm/migrate.c	2018-12-23 20:37:12.604621319 +0800
@@ -55,6 +55,8 @@
 
 #include "internal.h"
 
+#define MPOL_MF_SW_YOUNG (1<<7)
+
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
@@ -1484,12 +1486,13 @@ static int do_move_pages_to_node(struct
  * the target node
  */
 static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
-		int node, struct list_head *pagelist, bool migrate_all)
+		int node, struct list_head *pagelist, int flags)
 {
 	struct vm_area_struct *vma;
 	struct page *page;
 	unsigned int follflags;
 	int err;
+	bool migrate_all = flags & MPOL_MF_MOVE_ALL;
 
 	down_read(&mm->mmap_sem);
 	err = -EFAULT;
@@ -1519,6 +1522,8 @@ static int add_page_for_migration(struct
 
 	if (PageHuge(page)) {
 		if (PageHead(page)) {
+			if (flags & MPOL_MF_SW_YOUNG)
+				SetPageReferenced(page);
 			isolate_huge_page(page, pagelist);
 			err = 0;
 		}
@@ -1531,6 +1536,8 @@ static int add_page_for_migration(struct
 			goto out_putpage;
 
 		err = 0;
+		if (flags & MPOL_MF_SW_YOUNG)
+			SetPageReferenced(head);
 		list_add_tail(&head->lru, pagelist);
 		mod_node_page_state(page_pgdat(head),
 			NR_ISOLATED_ANON + page_is_file_cache(head),
@@ -1606,7 +1613,7 @@ static int do_pages_move(struct mm_struc
 		 * report them via status
 		 */
 		err = add_page_for_migration(mm, addr, current_node,
-				&pagelist, flags & MPOL_MF_MOVE_ALL);
+				&pagelist, flags);
 		if (!err)
 			continue;
 
@@ -1725,7 +1732,7 @@ static int kernel_move_pages(pid_t pid,
 	nodemask_t task_nodes;
 
 	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_SW_YOUNG))
 		return -EINVAL;
 
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
