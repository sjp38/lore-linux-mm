Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9A2830A0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 08:38:33 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p63so116001814wmp.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 05:38:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cu9si28409060wjc.53.2016.02.08.05.38.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 05:38:29 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/5] introduce kcompactd and stop compacting in kswapd
Date: Mon,  8 Feb 2016 14:38:06 +0100
Message-Id: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

The previous RFC is here [1]. It didn't have a cover letter, so the description
and results are in the individual patches.

Changes since v1:
- do only sync compaction in kcompactd (Mel)
- only compact zones up to classzone_idx (Mel)
- move wakeup_kcompactd() call from patch 2 to patch 4 (Mel)
- Patch 3 is separate from Patch 2 for review purposes, although I would just
  fold it in the end (Mel)
- Patch 5 is new
- retested on 4.5-rc1 with 5 repeats, which removed some counter-intuitive
  results and added more confidence

[1] https://lkml.org/lkml/2016/1/26/558

Vlastimil Babka (5):
  mm, kswapd: remove bogus check of balance_classzone_idx
  mm, compaction: introduce kcompactd
  mm, memory hotplug: small cleanup in online_pages()
  mm, kswapd: replace kswapd compaction with waking up kcompactd
  mm, compaction: adapt isolation_suitable flushing to kcompactd

 include/linux/compaction.h        |  16 +++
 include/linux/mmzone.h            |   6 +
 include/linux/vm_event_item.h     |   1 +
 include/trace/events/compaction.h |  55 +++++++++
 mm/compaction.c                   | 230 +++++++++++++++++++++++++++++++++++++-
 mm/internal.h                     |   1 +
 mm/memory_hotplug.c               |  15 ++-
 mm/page_alloc.c                   |   3 +
 mm/vmscan.c                       | 147 ++++++++----------------
 mm/vmstat.c                       |   1 +
 10 files changed, 366 insertions(+), 109 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
