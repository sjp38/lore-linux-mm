Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB5A6B0269
	for <linux-mm@kvack.org>; Sat,  5 May 2018 16:11:12 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i11-v6so16620858wre.16
        for <linux-mm@kvack.org>; Sat, 05 May 2018 13:11:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k38-v6sor3086704wrk.77.2018.05.05.13.11.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 May 2018 13:11:11 -0700 (PDT)
From: Mathieu Malaterre <malat@debian.org>
Subject: [PATCH] =?UTF-8?q?mm:=20move=20function=20=E2=80=98is=5Fpageblock?= =?UTF-8?q?=5Fremovable=5Fnolock=E2=80=99=20inside=20blockers?=
Date: Sat,  5 May 2018 22:11:06 +0200
Message-Id: <20180505201107.21070-1-malat@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mathieu Malaterre <malat@debian.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Function a??is_pageblock_removable_nolocka?? is not used unless
CONFIG_MEMORY_HOTREMOVE is activated. Move it in between #ifdef sentinel to
match prototype in <linux/memory_hotplug.h>. Silence gcc warning (W=1):

  mm/page_alloc.c:7704:6: warning: no previous prototype for a??is_pageblock_removable_nolocka?? [-Wmissing-prototypes]

Signed-off-by: Mathieu Malaterre <malat@debian.org>
---
 mm/page_alloc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d7962f..94ca579938e5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7701,6 +7701,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	return false;
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
 bool is_pageblock_removable_nolock(struct page *page)
 {
 	struct zone *zone;
@@ -7723,6 +7724,7 @@ bool is_pageblock_removable_nolock(struct page *page)
 
 	return !has_unmovable_pages(zone, page, 0, MIGRATE_MOVABLE, true);
 }
+#endif
 
 #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
 
-- 
2.11.0
