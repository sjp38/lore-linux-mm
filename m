Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C27146B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 10:33:48 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id bs8so4721419wib.6
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 07:33:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gi7si21899645wic.20.2014.06.02.07.33.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 07:33:47 -0700 (PDT)
Message-ID: <538C8B45.6070803@suse.cz>
Date: Mon, 02 Jun 2014 16:33:41 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: [PATCH -mm] mm, compaction: properly signal and act upon lock and
 need_sched() contention - fix
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz>	<1400233673-11477-1-git-send-email-vbabka@suse.cz>	<CAGa+x87-NRyK6kUiXNL_bRNEGm+DR6M3HPSLYEoq4t6Nrtnd_g@mail.gmail.com>	<CAAQ0ZWQDVxAzZVm86ATXd1JGUVoLXj_Y5Ske7htxH_6a4GPKRg@mail.gmail.com>	<537F082F.50501@suse.cz> <CAOMZO5BKaicq7NkoJO4vU5W3hiDike6kSdH+2eD=h0B5BsDjTg@mail.gmail.com>
In-Reply-To: <CAOMZO5BKaicq7NkoJO4vU5W3hiDike6kSdH+2eD=h0B5BsDjTg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabio Estevam <festevam@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Shawn Guo <shawn.guo@linaro.org>, Kevin Hilman <khilman@linaro.org>, Rik van Riel <riel@redhat.com>, Stephen Warren <swarren@wwwdotorg.org>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Olof Johansson <olof@lixom.net>, Greg Thelen <gthelen@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

compact_should_abort() returns true instead of false and vice versa
due to changes between v1 and v2 of the patch. This makes both async
and sync compaction abort with high probability, and has been reported
to cause e.g. soft lockups on some ARM boards, or drivers calling
dma_alloc_coherent() fail to probe with CMA enabled on different boards.

This patch fixes the return value to match comments and callers expecations.

Reported-and-tested-by: Kevin Hilman <khilman@linaro.org>
Reported-and-tested-by: Shawn Guo <shawn.guo@linaro.org>
Tested-by: Stephen Warren <swarren@nvidia.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a525cd4..5175019 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -237,13 +237,13 @@ static inline bool compact_should_abort(struct compact_control *cc)
 	if (need_resched()) {
 		if (cc->mode == MIGRATE_ASYNC) {
 			cc->contended = true;
-			return false;
+			return true;
 		}
 
 		cond_resched();
 	}
 
-	return true;
+	return false;
 }
 
 /* Returns true if the page is within a block suitable for migration to */
-- 1.8.4.5 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
