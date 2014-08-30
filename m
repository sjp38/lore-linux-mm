Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id D92796B003A
	for <linux-mm@kvack.org>; Sat, 30 Aug 2014 12:41:25 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id b17so4068375lan.8
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:41:25 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id rt5si4848532lbb.2.2014.08.30.09.41.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 30 Aug 2014 09:41:24 -0700 (PDT)
Received: by mail-la0-f50.google.com with SMTP id mc6so4204617lab.9
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:41:24 -0700 (PDT)
Subject: [PATCH v2 2/6] mm/balloon_compaction: keep ballooned pages away
 from normal migration path
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 30 Aug 2014 20:41:13 +0400
Message-ID: <20140830164113.29066.25879.stgit@zurg>
In-Reply-To: <20140830163834.29066.98205.stgit@zurg>
References: <20140830163834.29066.98205.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>

Proper testing shows yet another problem in balloon migration: it works only
once for each page. balloon_page_movable() check page flags and page_count.
In __unmap_and_move page is locked, reference counter is elevated, so
balloon_page_movable() _always_ fails here. As result in __unmap_and_move()
migration goes to the normal migration path.

Balloon ->migratepage() is so special, it returns MIGRATEPAGE_BALLOON_SUCCESS
instead of MIGRATEPAGE_SUCCESS. After that in move_to_new_page() successfully
migrated page got NULL into its mapping pointer and loses connectivity with
balloon and ability for further migration.

It's safe to use __is_movable_balloon_page here: page is isolated and pinned.

Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: stable <stable@vger.kernel.org> # v3.8
---
 include/linux/balloon_compaction.h |    5 +++++
 mm/migrate.c                       |    2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 53d482e..284fc1d 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -258,6 +258,11 @@ static inline void balloon_page_delete(struct page *page)
 	list_del(&page->lru);
 }
 
+static inline bool __is_movable_balloon_page(struct page *page)
+{
+	return false;
+}
+
 static inline bool balloon_page_movable(struct page *page)
 {
 	return false;
diff --git a/mm/migrate.c b/mm/migrate.c
index 905b1aa..57c94f9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -873,7 +873,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(balloon_page_movable(page))) {
+	if (unlikely(__is_movable_balloon_page(page))) {
 		/*
 		 * A ballooned page does not need any special attention from
 		 * physical to virtual reverse mapping procedures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
