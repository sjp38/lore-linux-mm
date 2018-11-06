Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 787F36B02FE
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:55:35 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id g16-v6so5412865eds.20
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:55:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o58-v6sor27771723edc.21.2018.11.06.01.55.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 01:55:33 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, memory_hotplug: check zone_movable in has_unmovable_pages
Date: Tue,  6 Nov 2018 10:55:24 +0100
Message-Id: <20181106095524.14629-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Baoquan He <bhe@redhat.com>, Oscar Salvador <OSalvador@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Page state checks are racy. Under a heavy memory workload (e.g. stress
-m 200 -t 2h) it is quite easy to hit a race window when the page is
allocated but its state is not fully populated yet. A debugging patch to
dump the struct page state shows
: [  476.575516] has_unmovable_pages: pfn:0x10dfec00, found:0x1, count:0x0
: [  476.582103] page:ffffea0437fb0000 count:1 mapcount:1 mapping:ffff880e05239841 index:0x7f26e5000 compound_mapcount: 1
: [  476.592645] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)

Note that the state has been checked for both PageLRU and PageSwapBacked
already. Closing this race completely would require some sort of retry
logic. This can be tricky and error prone (think of potential endless
or long taking loops).

Workaround this problem for movable zones at least. Such a zone should
only contain movable pages. 15c30bc09085 ("mm, memory_hotplug: make
has_unmovable_pages more robust") has told us that this is not strictly
true though. Bootmem pages should be marked reserved though so we can
move the original check after the PageReserved check. Pages from other
zones are still prone to races but we even do not pretend that memory
hotremove works for those so pre-mature failure doesn't hurt that much.

Reported-and-tested-by: Baoquan He <bhe@redhat.com>
Acked-by: Baoquan He <bhe@redhat.com>
Fixes: "mm, memory_hotplug: make has_unmovable_pages more robust")
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
this has been reported [1] and we have tried multiple things to address
the issue. The only reliable way was to reintroduce the movable zone
check into has_unmovable_pages. This time it should be safe also for
the bug originally fixed by 15c30bc09085.

[1] http://lkml.kernel.org/r/20181101091055.GA15166@MiWiFi-R3L-srv
 mm/page_alloc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 863d46da6586..c6d900ee4982 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7788,6 +7788,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
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
2.19.1
