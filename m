Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C04E16B0253
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 21:59:23 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so41829701pac.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 18:59:23 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id hm2si30684274pac.186.2015.11.24.18.59.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 18:59:23 -0800 (PST)
Date: Wed, 25 Nov 2015 11:59:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/compaction: __compact_pgdat() code cleanuup
Message-ID: <20151125025947.GD9563@js1304-P5Q-DELUXE>
References: <1448346282-5435-1-git-send-email-iamjoonsoo.kim@lge.com>
 <565424AD.7030808@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565424AD.7030808@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Yaowei Bai <bywxiaobai@163.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 24, 2015 at 09:49:49AM +0100, Vlastimil Babka wrote:
> On 11/24/2015 07:24 AM, Joonsoo Kim wrote:
> >This patch uses is_via_compact_memory() to distinguish direct compaction.
> >And it also reduces indentation on compaction_defer_reset
> >by filtering failure case. There is no functional change.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/compaction.c | 15 +++++++++------
> >  1 file changed, 9 insertions(+), 6 deletions(-)
> >
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index de3e1e7..2b1a15e 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -1658,14 +1658,17 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
> >  				!compaction_deferred(zone, cc->order))
> >  			compact_zone(zone, cc);
> >
> >-		if (cc->order > 0) {
> >-			if (zone_watermark_ok(zone, cc->order,
> >-						low_wmark_pages(zone), 0, 0))
> >-				compaction_defer_reset(zone, cc->order, false);
> >-		}
> >-
> >  		VM_BUG_ON(!list_empty(&cc->freepages));
> >  		VM_BUG_ON(!list_empty(&cc->migratepages));
> >+
> >+		if (is_via_compact_memory(cc->order))
> >+			continue;
> 
> That's fine.
> 
> >+		if (!zone_watermark_ok(zone, cc->order,
> >+				low_wmark_pages(zone), 0, 0))
> >+			continue;
> >+
> >+		compaction_defer_reset(zone, cc->order, false);
> 
> Here I'd personally find the way of "if(watermark_ok) defer_reset()"
> logic easier to follow.

Okay. Will change it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
