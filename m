Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC153600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 13:00:19 -0400 (EDT)
Date: Thu, 8 Apr 2010 17:59:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/14] Memory compaction core
Message-ID: <20100408165954.GI25756@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-9-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1270224168-14775-9-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2010 at 05:02:42PM +0100, Mel Gorman wrote:
> This patch is the core of a mechanism which compacts memory in a zone by
> relocating movable pages towards the end of the zone.
> 

When merging compaction and transparent huge pages, Andrea spotted and
fixed this problem in his tree but it should go to mmotm as well.

Thanks Andrea.

==== CUT HERE ====
mm,compaction: page buddy can go away before reading page_order while isolating pages for migration

From: Andrea Arcangeli <aarcange@redhat.com>

zone->lock isn't held so the optimisation is unsafe. The page could be
allocated between when PageBuddy is checked and page-order is called. The
scanner will harmlessly walk the other free pages so let's just skip this
optimization.

This is a fix to the patch "Memory compaction core".

[mel@csn.ul.ie: Expanded the changelog]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 mm/compaction.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index dadad52..4fb33f6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -262,10 +262,8 @@ static unsigned long isolate_migratepages(struct zone *zone,
 
 		/* Get the page and skip if free */
 		page = pfn_to_page(low_pfn);
-		if (PageBuddy(page)) {
-			low_pfn += (1 << page_order(page)) - 1;
+		if (PageBuddy(page))
 			continue;
-		}
 
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
