Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF166B026D
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 15:47:33 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id uo6so106736545pac.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:47:33 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id zm10si8537586pac.26.2015.12.29.12.47.31
        for <linux-mm@kvack.org>;
        Tue, 29 Dec 2015 12:47:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm, thp: clear PG_mlocked when last mapping gone
Date: Tue, 29 Dec 2015 23:46:30 +0300
Message-Id: <1451421990-32297-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I missed clear_page_mlock() in page_remove_anon_compound_rmap().
It usually shouldn't cause any problems since we munlock pages
explicitly, but in conjunction with missed munlock in __oom_reap_vmas()
it causes problems:
 http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com

Let's put it in place an mirror behaviour for small pages.

NOTE: I'm not entirely sure why we ever need clear_page_mlock() in
page_remove_rmap() codepath. It looks redundant to me as we munlock
pages anyway. But this is out of scope of the patch.

The patch can be folded into
 "thp: allow mlocked THP again"

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/rmap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/rmap.c b/mm/rmap.c
index 384516fb7495..68af2e32f7ed 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1356,6 +1356,9 @@ static void page_remove_anon_compound_rmap(struct page *page)
 		nr = HPAGE_PMD_NR;
 	}
 
+	if (unlikely(PageMlocked(page)))
+		clear_page_mlock(page);
+
 	if (nr) {
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
 		deferred_split_huge_page(page);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
