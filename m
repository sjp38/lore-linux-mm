Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 60EF86B0078
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 01:56:37 -0500 (EST)
Received: by pwj10 with SMTP id 10so3502040pwj.6
        for <linux-mm@kvack.org>; Mon, 25 Jan 2010 22:56:34 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 26 Jan 2010 14:56:34 +0800
Message-ID: <cf18f8341001252256q65b90d76vfe3094a1bb5424e7@mail.gmail.com>
Subject: [PATCH] page_alloc: change bit ops 'or' to logical ops in free/new
	page check
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Using logical 'or' in  function free_page_mlock() and
check_new_page() makes code clear and
sometimes more effective (Because it can ignore other condition
compare if the first condition
is already true).

It's Nick's patch "mm: microopt conditions" changed it from logical
ops to bit ops.
Maybe I didn't consider something. If so, please let me know and just
ignore this patch.
Thanks!

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---

diff --git mm/page_alloc.c mm/page_alloc.c
index 05ae4e0..91ece14 100644
--- mm/page_alloc.c
+++ mm/page_alloc.c
@@ -500,9 +500,9 @@ static inline void free_page_mlock(struct page *page)

 static inline int free_pages_check(struct page *page)
 {
-       if (unlikely(page_mapcount(page) |
-               (page->mapping != NULL)  |
-               (atomic_read(&page->_count) != 0) |
+       if (unlikely(page_mapcount(page) ||
+               (page->mapping != NULL)  ||
+               (atomic_read(&page->_count) != 0) ||
                (page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
                bad_page(page);
                return 1;
@@ -671,9 +671,9 @@ static inline void expand(struct zone *zone, struct page *pa
  */
 static inline int check_new_page(struct page *page)
 {
-       if (unlikely(page_mapcount(page) |
-               (page->mapping != NULL)  |
-               (atomic_read(&page->_count) != 0)  |
+       if (unlikely(page_mapcount(page) ||
+               (page->mapping != NULL)  ||
+               (atomic_read(&page->_count) != 0)  ||
                (page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
                bad_page(page);
                return 1;

-- 
Regards,
-Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
