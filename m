Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1DE6B0089
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 02:50:10 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id oB97o7V3006512
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 23:50:08 -0800
Received: from pvg6 (pvg6.prod.google.com [10.241.210.134])
	by hpaq2.eem.corp.google.com with ESMTP id oB97o5gR015330
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 23:50:06 -0800
Received: by pvg6 with SMTP id 6so651909pvg.37
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 23:50:05 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/2] mlock: do not munlock pages in __do_fault()
Date: Wed,  8 Dec 2010 23:49:39 -0800
Message-Id: <1291880979-16309-3-git-send-email-walken@google.com>
In-Reply-To: <1291880979-16309-1-git-send-email-walken@google.com>
References: <1291880979-16309-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If the page is going to be written to, __do_page needs to break COW.
However, the old page (before breaking COW) was never mapped mapped into
the current pte (__do_fault is only called when the pte is not present),
so vmscan can't have marked the old page as PageMlocked due to being
mapped in __do_fault's VMA. Therefore, __do_fault() does not need to worry
about clearing PageMlocked() on the old page.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/memory.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 68f2dbe..7befd03 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3015,12 +3015,6 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 				goto out;
 			}
 			charged = 1;
-			/*
-			 * Don't let another task, with possibly unlocked vma,
-			 * keep the mlocked page.
-			 */
-			if (vma->vm_flags & VM_LOCKED)
-				clear_page_mlock(vmf.page);
 			copy_user_highpage(page, vmf.page, address, vma);
 			__SetPageUptodate(page);
 		} else {
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
