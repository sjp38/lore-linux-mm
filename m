Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BF1CA6B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 09:04:41 -0500 (EST)
Received: by wwf10 with SMTP id 10so4304965wwf.26
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:04:37 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 18 Nov 2011 22:04:37 +0800
Message-ID: <CAJd=RBC+p8033bHNfP=WQ2SU1Y1zRpj+FEi9FdjuFKkjF_=_iA@mail.gmail.com>
Subject: [PATCH] hugetlb: detect race if fail to COW
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

In the error path that we fail to allocate new huge page, before try again, we
have to check race since page_table_lock is re-acquired.

If racing, our job is done.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Fri Nov 18 21:38:30 2011
+++ b/mm/hugetlb.c	Fri Nov 18 21:48:15 2011
@@ -2407,7 +2407,14 @@ retry_avoidcopy:
 				BUG_ON(page_count(old_page) != 1);
 				BUG_ON(huge_pte_none(pte));
 				spin_lock(&mm->page_table_lock);
-				goto retry_avoidcopy;
+				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
+				if (likely(pte_same(huge_ptep_get(ptep), pte)))
+					goto retry_avoidcopy;
+				/*
+				 * race occurs while re-acquiring page_table_lock, and
+				 * our job is done.
+				 */
+				return 0;
 			}
 			WARN_ON_ONCE(1);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
