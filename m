Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25C556B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 09:53:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so80465813wmz.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 06:53:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a187si19973134wmc.108.2016.09.06.06.53.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 06:53:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/4] reintroduce compaction feedback for OOM decisions
Date: Tue,  6 Sep 2016 15:52:54 +0200
Message-Id: <20160906135258.18335-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>

After several people reported OOM's for order-2 allocations in 4.7 due to
Michal Hocko's OOM rework, he reverted the part that considered compaction
feedback [1] in the decisions to retry reclaim/compaction. This was to provide
a fix quickly for 4.8 rc and 4.7 stable series, while mmotm had an almost
complete solution that instead improved compaction reliability.

This series completes the mmotm solution and reintroduces the compaction
feedback into OOM decisions. The first two patches restore the state of mmotm
before the temporary solution was merged, the last patch should be the missing
piece for reliability. The third patch restricts the hardened compaction to
non-costly orders, since costly orders don't result in OOMs in the first place.

Some preliminary testing suggested that this approach should work, but I would
like to ask all who experienced the regression to please retest this. You will
need to apply this series on top of tag mmotm-2016-08-31-16-06 from the mmotm
git tree [2]. Thanks in advance!

[1] http://marc.info/?i=20160822093249.GA14916%40dhcp22.suse.cz%3E
[2] git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git

Vlastimil Babka (4):
  Revert "mm, oom: prevent premature OOM killer invocation for high
    order request"
  mm, compaction: more reliably increase direct compaction priority
  mm, compaction: restrict full priority to non-costly orders
  mm, compaction: make full priority ignore pageblock suitability

 include/linux/compaction.h |  1 +
 mm/compaction.c            | 11 ++++++---
 mm/internal.h              |  1 +
 mm/page_alloc.c            | 58 ++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 66 insertions(+), 5 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
