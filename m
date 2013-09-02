Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 60B416B0031
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 07:43:18 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: fix accounting on page_remove_rmap()
Date: Mon,  2 Sep 2013 14:43:11 +0300
Message-Id: <1378122191-15479-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ning Qu <quning@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There's typo in page_remove_rmap(): we increase NR_ANON_PAGES counter
instead of decreasing it. Let's fix this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Ning Qu <quning@google.com>
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 52cc59a..6219f07 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1156,7 +1156,7 @@ void page_remove_rmap(struct page *page)
 			__dec_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
-				hpage_nr_pages(page));
+				-hpage_nr_pages(page));
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
