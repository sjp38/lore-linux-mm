Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7F4D6B480F
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 17:02:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m129-v6so1794259wma.8
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 14:02:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t82-v6sor675389wmg.76.2018.08.28.14.02.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 14:02:09 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH] mm/page_alloc: Clean up check_for_memory
Date: Tue, 28 Aug 2018 23:01:58 +0200
Message-Id: <20180828210158.4617-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, Pavel.Tatashin@microsoft.com, sfr@canb.auug.org.au, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

check_for_memory looks a bit confusing.
First of all, we have this:

if (N_MEMORY == N_NORMAL_MEMORY)
	return;

Checking the ENUM declaration, looks like N_MEMORY canot be equal to
N_NORMAL_MEMORY.
I could not find where N_MEMORY is set to N_NORMAL_MEMORY, or the other
way around either, so unless I am missing something, this condition 
will never evaluate to true.
It makes sense to get rid of it.

Moving forward, the operations whithin the loop look a bit confusing
as well.

We set N_HIGH_MEMORY unconditionally, and then we set N_NORMAL_MEMORY
in case we have CONFIG_HIGHMEM (N_NORMAL_MEMORY != N_HIGH_MEMORY)
and zone <= ZONE_NORMAL.
(N_HIGH_MEMORY falls back to N_NORMAL_MEMORY on !CONFIG_HIGHMEM systems,
and that is why we can just go ahead and set N_HIGH_MEMORY unconditionally)

Although this works, it is a bit subtle.

I think that this could be easier to follow:

First, we should only set N_HIGH_MEMORY in case we have
CONFIG_HIGHMEM.
And then we should set N_NORMAL_MEMORY in case zone <= ZONE_NORMAL,
without further checking whether we have CONFIG_HIGHMEM or not.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/page_alloc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 839e0cc17f2c..6aa947f9e614 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6819,15 +6819,12 @@ static void check_for_memory(pg_data_t *pgdat, int nid)
 {
 	enum zone_type zone_type;
 
-	if (N_MEMORY == N_NORMAL_MEMORY)
-		return;
-
 	for (zone_type = 0; zone_type <= ZONE_MOVABLE - 1; zone_type++) {
 		struct zone *zone = &pgdat->node_zones[zone_type];
 		if (populated_zone(zone)) {
-			node_set_state(nid, N_HIGH_MEMORY);
-			if (N_NORMAL_MEMORY != N_HIGH_MEMORY &&
-			    zone_type <= ZONE_NORMAL)
+			if (IS_ENABLED(CONFIG_HIGHMEM))
+				node_set_state(nid, N_HIGH_MEMORY);
+			if (zone_type <= ZONE_NORMAL)
 				node_set_state(nid, N_NORMAL_MEMORY);
 			break;
 		}
-- 
2.13.6
