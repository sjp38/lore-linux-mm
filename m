Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 86CBD6B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 08:36:36 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so13267268wgb.26
        for <linux-mm@kvack.org>; Thu, 22 Dec 2011 05:36:34 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 22 Dec 2011 21:36:34 +0800
Message-ID: <CAJd=RBBF=K5hHvEwb6uwZJwS4=jHKBCNYBTJq-pSbJ9j_ZaiaA@mail.gmail.com>
Subject: [PATCH] mm: hugetlb: undo change to page mapcount in fault handler
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Page mapcount is changed only when it is folded into page table entry.

Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Tue Dec 20 21:26:30 2011
+++ b/mm/hugetlb.c	Thu Dec 22 21:29:42 2011
@@ -2509,6 +2509,7 @@ static int hugetlb_no_page(struct mm_str
 {
 	struct hstate *h = hstate_vma(vma);
 	int ret = VM_FAULT_SIGBUS;
+	int anon_rmap = 0;
 	pgoff_t idx;
 	unsigned long size;
 	struct page *page;
@@ -2563,14 +2564,13 @@ retry:
 			spin_lock(&inode->i_lock);
 			inode->i_blocks += blocks_per_huge_page(h);
 			spin_unlock(&inode->i_lock);
-			page_dup_rmap(page);
 		} else {
 			lock_page(page);
 			if (unlikely(anon_vma_prepare(vma))) {
 				ret = VM_FAULT_OOM;
 				goto backout_unlocked;
 			}
-			hugepage_add_new_anon_rmap(page, vma, address);
+			anon_rmap = 1;
 		}
 	} else {
 		/*
@@ -2583,7 +2583,6 @@ retry:
 			      VM_FAULT_SET_HINDEX(h - hstates);
 			goto backout_unlocked;
 		}
-		page_dup_rmap(page);
 	}

 	/*
@@ -2607,6 +2606,10 @@ retry:
 	if (!huge_pte_none(huge_ptep_get(ptep)))
 		goto backout;

+	if (anon_rmap)
+		hugepage_add_new_anon_rmap(page, vma, address);
+	else
+		page_dup_rmap(page);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
