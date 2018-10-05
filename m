Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2166B0269
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 16:56:42 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c8-v6so10646325pfn.2
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 13:56:42 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s17-v6sor4321913pfi.2.2018.10.05.13.56.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 13:56:41 -0700 (PDT)
Date: Fri, 5 Oct 2018 13:56:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, page_alloc: set num_movable in move_freepages()
Message-ID: <alpine.DEB.2.21.1810051355490.212229@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If move_freepages() returns 0 because zone_spans_pfn(), *num_movable can
hold the value from the stack because it does not get initialized in
move_freepages().

Move the initialization to move_freepages_block() to guarantee the value
actually makes sense.

This currently doesn't affect its only caller where num_movable != NULL,
so no bug fix, but just more robust.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2015,10 +2015,6 @@ static int move_freepages(struct zone *zone,
 	          pfn_valid(page_to_pfn(end_page)) &&
 	          page_zone(start_page) != page_zone(end_page));
 #endif
-
-	if (num_movable)
-		*num_movable = 0;
-
 	for (page = start_page; page <= end_page;) {
 		if (!pfn_valid_within(page_to_pfn(page))) {
 			page++;
@@ -2058,6 +2054,9 @@ int move_freepages_block(struct zone *zone, struct page *page,
 	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
 
+	if (num_movable)
+		*num_movable = 0;
+
 	start_pfn = page_to_pfn(page);
 	start_pfn = start_pfn & ~(pageblock_nr_pages-1);
 	start_page = pfn_to_page(start_pfn);
