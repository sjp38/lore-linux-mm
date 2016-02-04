Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id DE9CE4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 02:08:54 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so35234297pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 23:08:54 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id vr3si14779160pab.48.2016.02.03.23.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 23:08:53 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id c10so2164253pfc.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 23:08:53 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 1/3] /proc/kpageflags: return KPF_BUDDY for "tail" buddy pages
Date: Thu,  4 Feb 2016 16:08:01 +0900
Message-Id: <1454569683-17918-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Currently /proc/kpageflags returns nothing for "tail" buddy pages, which
is inconvenient when grasping how free pages are distributed. This patch
sets KPF_BUDDY for such pages.

With this patch:

  $ grep MemFree /proc/meminfo ; tools/vm/page-types -b buddy
  MemFree:         3134992 kB
               flags      page-count       MB  symbolic-flags                     long-symbolic-flags
  0x0000000000000400          779272     3044  __________B_______________________________ buddy
  0x0000000000000c00            4385       17  __________BM______________________________ buddy,mmap
               total          783657     3061

783657 pages is 3134628 kB (roughly consistent with the global counter,)
so it's OK.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/page.c             | 2 ++
 include/linux/page-flags.h | 2 ++
 mm/internal.h              | 3 ---
 mm/page_alloc.c            | 2 --
 4 files changed, 4 insertions(+), 5 deletions(-)

diff --git v4.5-rc2-mmotm-2016-02-02-17-08/fs/proc/page.c v4.5-rc2-mmotm-2016-02-02-17-08_patched/fs/proc/page.c
index b2855ee..42998bb 100644
--- v4.5-rc2-mmotm-2016-02-02-17-08/fs/proc/page.c
+++ v4.5-rc2-mmotm-2016-02-02-17-08_patched/fs/proc/page.c
@@ -148,6 +148,8 @@ u64 stable_page_flags(struct page *page)
 	 */
 	if (PageBuddy(page))
 		u |= 1 << KPF_BUDDY;
+	else if (page_count(page) == 0 && is_free_buddy_page(page))
+		u |= 1 << KPF_BUDDY;
 
 	if (PageBalloon(page))
 		u |= 1 << KPF_BALLOON;
diff --git v4.5-rc2-mmotm-2016-02-02-17-08/include/linux/page-flags.h v4.5-rc2-mmotm-2016-02-02-17-08_patched/include/linux/page-flags.h
index 19724e6..5976955 100644
--- v4.5-rc2-mmotm-2016-02-02-17-08/include/linux/page-flags.h
+++ v4.5-rc2-mmotm-2016-02-02-17-08_patched/include/linux/page-flags.h
@@ -593,6 +593,8 @@ static inline void __ClearPageBuddy(struct page *page)
 	atomic_set(&page->_mapcount, -1);
 }
 
+extern bool is_free_buddy_page(struct page *page);
+
 #define PAGE_BALLOON_MAPCOUNT_VALUE (-256)
 
 static inline int PageBalloon(struct page *page)
diff --git v4.5-rc2-mmotm-2016-02-02-17-08/mm/internal.h v4.5-rc2-mmotm-2016-02-02-17-08_patched/mm/internal.h
index 271ad95..06071af 100644
--- v4.5-rc2-mmotm-2016-02-02-17-08/mm/internal.h
+++ v4.5-rc2-mmotm-2016-02-02-17-08_patched/mm/internal.h
@@ -145,9 +145,6 @@ extern int __isolate_free_page(struct page *page, unsigned int order);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
-#ifdef CONFIG_MEMORY_FAILURE
-extern bool is_free_buddy_page(struct page *page);
-#endif
 extern int user_min_free_kbytes;
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
diff --git v4.5-rc2-mmotm-2016-02-02-17-08/mm/page_alloc.c v4.5-rc2-mmotm-2016-02-02-17-08_patched/mm/page_alloc.c
index 555b9d2..d9c8b70 100644
--- v4.5-rc2-mmotm-2016-02-02-17-08/mm/page_alloc.c
+++ v4.5-rc2-mmotm-2016-02-02-17-08_patched/mm/page_alloc.c
@@ -7182,7 +7182,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 }
 #endif
 
-#ifdef CONFIG_MEMORY_FAILURE
 bool is_free_buddy_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
@@ -7201,4 +7200,3 @@ bool is_free_buddy_page(struct page *page)
 
 	return order < MAX_ORDER;
 }
-#endif
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
