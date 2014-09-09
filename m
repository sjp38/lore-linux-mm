Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id E6CE66B005C
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 10:52:32 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id b12so2167482lbj.11
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 07:52:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ck13si18189533lbb.57.2014.09.09.07.52.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 07:52:31 -0700 (PDT)
Date: Tue, 9 Sep 2014 15:52:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: page_alloc: Make paranoid check in move_freepages a
 VM_BUG_ON
Message-ID: <20140909145228.GB12309@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linuxfoundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since 2.6.24 there has been a paranoid check in move_freepages that looks
up the zone of two pages. This is a very slow path and the only time I've
seen this bug trigger recently is when memory initialisation was broken
during patch development. Despite the fact it's a slow path, this patch
converts the check to a VM_BUG_ON anyway as it is served its purpose by now.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0a7ed33..6fbd814 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1014,7 +1014,7 @@ int move_freepages(struct zone *zone,
 	 * Remove at a later date when no bug reports exist related to
 	 * grouping pages by mobility
 	 */
-	BUG_ON(page_zone(start_page) != page_zone(end_page));
+	VM_BUG_ON(page_zone(start_page) != page_zone(end_page));
 #endif
 
 	for (page = start_page; page <= end_page;) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
