Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EB9E46B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 14:33:13 -0400 (EDT)
Received: by eyh5 with SMTP id 5so2393765eyh.14
        for <linux-mm@kvack.org>; Sun, 05 Sep 2010 11:33:14 -0700 (PDT)
From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 13/14] mm: mempolicy: Check return code of check_range
Date: Sun,  5 Sep 2010 22:33:08 +0400
Message-Id: <1283711588-7628-1-git-send-email-segooon@gmail.com>
Sender: owner-linux-mm@kvack.org
To: kernel-janitors@vger.kernel.org
Cc: Vasiliy Kulikov <segooon@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vasiliy Kulikov <segooon@gmail.com>

Function check_range may return ERR_PTR(...). Check for it.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 Compile tested.

 mm/mempolicy.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f969da5..b73f02c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -924,12 +924,15 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 	nodemask_t nmask;
 	LIST_HEAD(pagelist);
 	int err = 0;
+	struct vm_area_struct *vma;
 
 	nodes_clear(nmask);
 	node_set(source, nmask);
 
-	check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
+	vma = check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
+	if (IS_ERR(vma))
+		return PTR_ERR(vma);
 
 	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_node_page, dest, 0);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
