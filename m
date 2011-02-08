Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 423E48D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 19:48:03 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p180m0SI006411
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:48:01 -0800
Received: from gwb17 (gwb17.prod.google.com [10.200.2.17])
	by hpaq11.eem.corp.google.com with ESMTP id p180lwZc029063
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:47:59 -0800
Received: by gwb17 with SMTP id 17so2430137gwb.2
        for <linux-mm@kvack.org>; Mon, 07 Feb 2011 16:47:58 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/2] mlock: fix race when munlocking pages in do_wp_page()
Date: Mon,  7 Feb 2011 16:47:35 -0800
Message-Id: <1297126056-14322-2-git-send-email-walken@google.com>
In-Reply-To: <1297126056-14322-1-git-send-email-walken@google.com>
References: <1297126056-14322-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

vmscan can lazily find pages that are mapped within VM_LOCKED vmas,
and set the PageMlocked bit on these pages, transfering them onto the
unevictable list. When do_wp_page() breaks COW within a VM_LOCKED vma,
it may need to clear PageMlocked on the old page and set it on the
new page instead.

This change fixes an issue where do_wp_page() was clearing PageMlocked on
the old page while the pte was still pointing to it (as well as rmap).
Therefore, we were not protected against vmscan immediately trasnfering
the old page back onto the unevictable list. This could cause pages to
get stranded there forever.

I propose to move the corresponding code to the end of do_wp_page(),
after the pte (and rmap) have been pointed to the new page. Additionally,
we can use munlock_vma_page() instead of clear_page_mlock(), so that
the old page stays mlocked if there are still other VM_LOCKED vmas
mapping it.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/memory.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 31250fa..32df03c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2219,7 +2219,6 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 							 &ptl);
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
-				page_cache_release(old_page);
 				goto unlock;
 			}
 			page_cache_release(old_page);
@@ -2289,7 +2288,6 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 							 &ptl);
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
-				page_cache_release(old_page);
 				goto unlock;
 			}
 
@@ -2367,16 +2365,6 @@ gotten:
 	}
 	__SetPageUptodate(new_page);
 
-	/*
-	 * Don't let another task, with possibly unlocked vma,
-	 * keep the mlocked page.
-	 */
-	if ((vma->vm_flags & VM_LOCKED) && old_page) {
-		lock_page(old_page);	/* for LRU manipulation */
-		clear_page_mlock(old_page);
-		unlock_page(old_page);
-	}
-
 	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
@@ -2444,10 +2432,20 @@ gotten:
 
 	if (new_page)
 		page_cache_release(new_page);
-	if (old_page)
-		page_cache_release(old_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
+	if (old_page) {
+		/*
+		 * Don't let another task, with possibly unlocked vma,
+		 * keep the mlocked page.
+		 */
+		if ((ret & VM_FAULT_WRITE) && (vma->vm_flags & VM_LOCKED)) {
+			lock_page(old_page);	/* LRU manipulation */
+			munlock_vma_page(old_page);
+			unlock_page(old_page);
+		}
+		page_cache_release(old_page);
+	}
 	return ret;
 oom_free_new:
 	page_cache_release(new_page);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
