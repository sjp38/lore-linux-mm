Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 181886B00CD
	for <linux-mm@kvack.org>; Tue,  7 May 2013 19:02:12 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hm14so4359496wib.11
        for <linux-mm@kvack.org>; Tue, 07 May 2013 16:02:10 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH] mm: honor FOLL_GET flag in follow_hugetlb_page v2
Date: Tue,  7 May 2013 18:58:42 -0400
Message-Id: <1367967522-3934-1-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>

From: Jerome Glisse <jglisse@redhat.com>

Do not increase page count if FOLL_GET is not set. None of the
current user can trigger the issue because none of the current
user call __get_user_pages with both the pages array ptr non
NULL and the FOLL_GET flags non set in other word all caller
of __get_user_pages that don't set the FOLL_GET flags also call
with pages == NULL.

v2: Do not use get_page_foll. Improved comment.

Signed-off-by: Jerome Glisse <jglisse@redhat.com>
---
 mm/hugetlb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ca9a7c6..32f323b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2981,7 +2981,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 same_page:
 		if (pages) {
 			pages[i] = mem_map_offset(page, pfn_offset);
-			get_page(pages[i]);
+			if (flags & FOLL_GET) {
+				get_page(pages[i]);
+			}
 		}
 
 		if (vmas)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
