Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 4D2F16B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 08:35:27 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so12486250wgb.2
        for <linux-mm@kvack.org>; Fri, 23 Dec 2011 05:35:25 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 23 Dec 2011 21:35:25 +0800
Message-ID: <CAJd=RBB-d19=Z0og0i5OrbUVCQFozaqMbVs9Fzw23j=-EFc+DQ@mail.gmail.com>
Subject: [PATCH] mm: hugetlb: fix non-atomic enqueue of huge page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: hugetlb: fix non-atomic enqueue of huge page

If huge page is enqueued under the protection of hugetlb_lock, then
the operation is atomic and safe.

Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Tue Dec 20 21:26:30 2011
+++ b/mm/hugetlb.c	Fri Dec 23 21:16:28 2011
@@ -901,7 +901,6 @@ retry:
 	h->resv_huge_pages += delta;
 	ret = 0;

-	spin_unlock(&hugetlb_lock);
 	/* Free the needed pages to the hugetlb pool */
 	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
 		if ((--needed) < 0)
@@ -915,6 +914,7 @@ retry:
 		VM_BUG_ON(page_count(page));
 		enqueue_huge_page(h, page);
 	}
+	spin_unlock(&hugetlb_lock);

 	/* Free unnecessary surplus pages to the buddy allocator */
 free:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
