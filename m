Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E64656B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:37:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e201so6392899wme.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:37:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id be7si993290wjb.175.2016.05.10.00.37.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:37:07 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 00/13] make direct compaction more deterministic
Date: Tue, 10 May 2016 09:35:50 +0200
Message-Id: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

This is mostly a followup to Michal's oom detection rework, which highlighted
the need for direct compaction to provide better feedback in reclaim/compaction
loop, so that it can reliably recognize when compaction cannot make further
progress, and allocation should invoke OOM killer or fail. We've discussed
this at LSF/MM [1] where I proposed expanding the async/sync migration mode
used in compaction to more general "priorities". This patchset adds one new
priority that just overrides all the heuristics and makes compaction fully
scan all zones. I don't currently think that we need more fine-grained
priorities, but we'll see. Other than that there's some smaller fixes and
cleanups, mainly related to the THP-specific hacks.

Testing/evaluation is pending, but I'm posting it now with hope to help the
discussions around oom detection rework. I also hope for testing the near-OOM
conditions, and the new priority level should also help hugetlbfs allocations
since they use __GFP_RETRY, and it has already been reported that ignoring
compaction heuristics helps these allocations.

The series is based on mmotm git [2] tag mmotm-2016-04-27-15-21-14.
First one needs to git revert the commit 69340d225e8d ("mm: use compaction
feedback for thp backoff conditions") which already happened in mmots.

[1] https://lwn.net/Articles/684611/
[2] git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git

Hugh Dickins (1):
  mm, compaction: don't isolate PageWriteback pages in
    MIGRATE_SYNC_LIGHT mode

Vlastimil Babka (12):
  mm, page_alloc: set alloc_flags only once in slowpath
  mm, page_alloc: don't retry initial attempt in slowpath
  mm, page_alloc: restructure direct compaction handling in slowpath
  mm, page_alloc: make THP-specific decisions more generic
  mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations
  mm, compaction: introduce direct compaction priority
  mm, compaction: simplify contended compaction handling
  mm, compaction: make whole_zone flag ignore cached scanner positions
  mm, compaction: cleanup unused functions
  mm, compaction: add the ultimate direct compaction priority
  mm, compaction: more reliably increase direct compaction priority
  mm, compaction: fix and improve watermark handling

 include/linux/compaction.h |  32 +++----
 include/linux/gfp.h        |   3 +-
 include/linux/mm.h         |   2 +-
 mm/compaction.c            | 196 +++++++++++++++-------------------------
 mm/huge_memory.c           |   8 +-
 mm/internal.h              |  10 +--
 mm/page_alloc.c            | 220 +++++++++++++++++++++------------------------
 mm/page_isolation.c        |   2 +-
 8 files changed, 196 insertions(+), 277 deletions(-)

-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
