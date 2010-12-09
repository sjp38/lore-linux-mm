Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 965CA6B0089
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 02:50:10 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id oB97o8Kx027020
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 23:50:08 -0800
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by hpaq11.eem.corp.google.com with ESMTP id oB97o4Ix008436
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 23:50:07 -0800
Received: by pwi8 with SMTP id 8so477905pwi.6
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 23:50:04 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/2] mlock: fix race when munlocking pages in do_wp_page()
Date: Wed,  8 Dec 2010 23:49:38 -0800
Message-Id: <1291880979-16309-2-git-send-email-walken@google.com>
In-Reply-To: <1291880979-16309-1-git-send-email-walken@google.com>
References: <1291880979-16309-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

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
index d21e1f2..68f2dbe 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2183,7 +2183,6 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 							 &ptl);
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
-				page_cache_release(old_page);
 				goto unlock;
 			}
 			page_cache_release(old_page);
@@ -2253,7 +2252,6 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 							 &ptl);
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
-				page_cache_release(old_page);
 				goto unlock;
 			}
 
@@ -2331,16 +2329,6 @@ gotten:
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
 
@@ -2408,10 +2396,20 @@ gotten:
 
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
