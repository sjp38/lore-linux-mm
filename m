Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE3F8D003B
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 19:48:03 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p180m2Rg024160
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:48:02 -0800
Received: from yia25 (yia25.prod.google.com [10.243.65.25])
	by kpbe16.cbf.corp.google.com with ESMTP id p180m0iE025333
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:48:01 -0800
Received: by yia25 with SMTP id 25so2039075yia.28
        for <linux-mm@kvack.org>; Mon, 07 Feb 2011 16:48:00 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/2] mlock: do not munlock pages in __do_fault()
Date: Mon,  7 Feb 2011 16:47:36 -0800
Message-Id: <1297126056-14322-3-git-send-email-walken@google.com>
In-Reply-To: <1297126056-14322-1-git-send-email-walken@google.com>
References: <1297126056-14322-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

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
index 32df03c..8e8c1832 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3051,12 +3051,6 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
