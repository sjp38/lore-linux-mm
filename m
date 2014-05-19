Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id E165B6B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 06:15:00 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so3397310eek.16
        for <linux-mm@kvack.org>; Mon, 19 May 2014 03:15:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f45si14535929eet.39.2014.05.19.03.14.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 03:14:59 -0700 (PDT)
Message-ID: <5379D99E.1020302@suse.cz>
Date: Mon, 19 May 2014 12:14:54 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] mm/compaction: avoid rescanning pageblocks in
 isolate_freepages
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com> <1399464550-26447-1-git-send-email-vbabka@suse.cz> <1399464550-26447-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1399464550-26447-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

I wonder why nobody complained about the build warning... sorry.

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Mon, 19 May 2014 12:02:38 +0200
Subject: mm-compaction-avoid-rescanning-pageblocks-in-isolate_freepages-fix
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Fix a (spurious) build warning:

mm/compaction.c:860:15: warning: a??next_free_pfna?? may be used uninitialized in this function [-Wmaybe-uninitialized]

Seems like the compiler cannot prove that exiting the for loop without updating
next_free_pfn there will mean that the check for crossing the scanners will
trigger. So let's not confuse people who try to see why this warning occurs.

Instead of initializing next_free_pfn to zero with an explaining comment, just
drop the damned variable altogether and work with cc->free_pfn directly as
Nayoa originally suggested.

Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8db9820..b0f939b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -760,7 +760,6 @@ static void isolate_freepages(struct zone *zone,
 	unsigned long block_start_pfn;	/* start of current pageblock */
 	unsigned long block_end_pfn;	/* end of current pageblock */
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
-	unsigned long next_free_pfn; /* start pfn for scaning at next round */
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
@@ -822,7 +821,7 @@ static void isolate_freepages(struct zone *zone,
 			continue;
 
 		/* Found a block suitable for isolating free pages from */
-		next_free_pfn = block_start_pfn;
+		cc->free_pfn = block_start_pfn;
 		isolated = isolate_freepages_block(cc, block_start_pfn,
 					block_end_pfn, freelist, false);
 		nr_freepages += isolated;
@@ -852,9 +851,8 @@ static void isolate_freepages(struct zone *zone,
 	 * so that compact_finished() may detect this
 	 */
 	if (block_start_pfn < low_pfn)
-		next_free_pfn = cc->migrate_pfn;
+		cc->free_pfn = cc->migrate_pfn;
 
-	cc->free_pfn = next_free_pfn;
 	cc->nr_freepages = nr_freepages;
 }
 
-- 
1.8.4.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
