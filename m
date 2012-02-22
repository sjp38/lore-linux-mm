Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 137F46B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 07:35:36 -0500 (EST)
Received: by vcbf13 with SMTP id f13so7020320vcb.14
        for <linux-mm@kvack.org>; Wed, 22 Feb 2012 04:35:34 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 22 Feb 2012 20:35:34 +0800
Message-ID: <CAJd=RBALNtedfq+PLPnGKd4i4D0mLiVPdW_7pWWopnSZNC_vqA@mail.gmail.com>
Subject: [PATCH] mm: hugetlb: bail out unmapping after serving reference page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>

When unmapping given VM range, we could bail out if a reference page is
supplied and it is unmapped, which is a minor optimization.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Wed Feb 22 19:34:12 2012
+++ b/mm/hugetlb.c	Wed Feb 22 19:50:26 2012
@@ -2280,6 +2280,9 @@ void __unmap_hugepage_range(struct vm_ar
 		if (pte_dirty(pte))
 			set_page_dirty(page);
 		list_add(&page->lru, &page_list);
+
+		if (page == ref_page)
+			break;
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
