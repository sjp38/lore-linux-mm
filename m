Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 098646B2CEB
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 14:54:44 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id k125so3048264pga.5
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:54:44 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s123si3095407pgs.93.2018.11.22.11.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 11:54:43 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.19 34/36] mm, memory_hotplug: check zone_movable in has_unmovable_pages
Date: Thu, 22 Nov 2018 14:52:38 -0500
Message-Id: <20181122195240.13123-34-sashal@kernel.org>
In-Reply-To: <20181122195240.13123-1-sashal@kernel.org>
References: <20181122195240.13123-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Michal Hocko <mhocko@suse.com>

[ Upstream commit 9d7899999c62c1a81129b76d2a6ecbc4655e1597 ]

Page state checks are racy.  Under a heavy memory workload (e.g.  stress
-m 200 -t 2h) it is quite easy to hit a race window when the page is
allocated but its state is not fully populated yet.  A debugging patch to
dump the struct page state shows

  has_unmovable_pages: pfn:0x10dfec00, found:0x1, count:0x0
  page:ffffea0437fb0000 count:1 mapcount:1 mapping:ffff880e05239841 index:0x7f26e5000 compound_mapcount: 1
  flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)

Note that the state has been checked for both PageLRU and PageSwapBacked
already.  Closing this race completely would require some sort of retry
logic.  This can be tricky and error prone (think of potential endless
or long taking loops).

Workaround this problem for movable zones at least.  Such a zone should
only contain movable pages.  Commit 15c30bc09085 ("mm, memory_hotplug:
make has_unmovable_pages more robust") has told us that this is not
strictly true though.  Bootmem pages should be marked reserved though so
we can move the original check after the PageReserved check.  Pages from
other zones are still prone to races but we even do not pretend that
memory hotremove works for those so pre-mature failure doesn't hurt that
much.

Link: http://lkml.kernel.org/r/20181106095524.14629-1-mhocko@kernel.org
Fixes: 15c30bc09085 ("mm, memory_hotplug: make has_unmovable_pages more robust")
Signed-off-by: Michal Hocko <mhocko@suse.com>
Reported-by: Baoquan He <bhe@redhat.com>
Tested-by: Baoquan He <bhe@redhat.com>
Acked-by: Baoquan He <bhe@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e2ef1c17942f..3a4065312938 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7690,6 +7690,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		if (PageReserved(page))
 			goto unmovable;
 
+		/*
+		 * If the zone is movable and we have ruled out all reserved
+		 * pages then it should be reasonably safe to assume the rest
+		 * is movable.
+		 */
+		if (zone_idx(zone) == ZONE_MOVABLE)
+			continue;
+
 		/*
 		 * Hugepages are not in LRU lists, but they're movable.
 		 * We need not scan over tail pages bacause we don't
-- 
2.17.1
