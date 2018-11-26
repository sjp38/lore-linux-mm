Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76D426B4464
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:26:38 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id h10so22534067plk.12
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:26:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gn15sor2447092plb.64.2018.11.26.15.26.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:26:37 -0800 (PST)
Date: Mon, 26 Nov 2018 15:26:34 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 06/10] mm/khugepaged: collapse_shmem() remember to clear
 holes
In-Reply-To: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811261525080.2275@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

Huge tmpfs testing reminds us that there is no __GFP_ZERO in the gfp
flags khugepaged uses to allocate a huge page - in all common cases it
would just be a waste of effort - so collapse_shmem() must remember to
clear out any holes that it instantiates.

The obvious place to do so, where they are put into the page cache tree,
is not a good choice: because interrupts are disabled there.  Leave it
until further down, once success is assured, where the other pages are
copied (before setting PageUptodate).

Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org # 4.8+
---
 mm/khugepaged.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 65e82f665c7c..1c402d33547e 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1467,7 +1467,12 @@ static void collapse_shmem(struct mm_struct *mm,
 		 * Replacing old pages with new one has succeeded, now we
 		 * need to copy the content and free the old pages.
 		 */
+		index = start;
 		list_for_each_entry_safe(page, tmp, &pagelist, lru) {
+			while (index < page->index) {
+				clear_highpage(new_page + (index % HPAGE_PMD_NR));
+				index++;
+			}
 			copy_highpage(new_page + (page->index % HPAGE_PMD_NR),
 					page);
 			list_del(&page->lru);
@@ -1477,6 +1482,11 @@ static void collapse_shmem(struct mm_struct *mm,
 			ClearPageActive(page);
 			ClearPageUnevictable(page);
 			put_page(page);
+			index++;
+		}
+		while (index < end) {
+			clear_highpage(new_page + (index % HPAGE_PMD_NR));
+			index++;
 		}
 
 		local_irq_disable();
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
