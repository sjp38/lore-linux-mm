Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 504976B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:38:56 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id kq3so14097246wjc.1
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:38:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t202si2940529wmd.108.2017.01.20.02.38.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 02:38:55 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/4] fix premature OOM regression in 4.7+ due to cpuset races
Date: Fri, 20 Jan 2017 11:38:39 +0100
Message-Id: <20170120103843.24587-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Changes since v1:
- add/remove comments per Michal Hocko and Hillf Danton
- move no_zone: label in patch 3 so we don't miss part of ac initialization

This is v2 of my attempt to fix the recent report based on LTP cpuset stress
test [1]. The intention is to go to stable 4.9 LTSS with this, as triggering
repeated OOMs is not nice. That's why the patches try to be not too intrusive.

Unfortunately why investigating I found that modifying the testcase to use
per-VMA policies instead of per-task policies will bring the OOM's back, but
that seems to be much older and harder to fix problem. I have posted a RFC [2]
but I believe that fixing the recent regressions has a higher priority.

Longer-term we might try to think how to fix the cpuset mess in a better and
less error prone way. I was for example very surprised to learn, that cpuset
updates change not only task->mems_allowed, but also nodemask of mempolicies.
Until now I expected the parameter to alloc_pages_nodemask() to be stable.
I wonder why do we then treat cpusets specially in get_page_from_freelist()
and distinguish HARDWALL etc, when there's unconditional intersection between
mempolicy and cpuset. I would expect the nodemask adjustment for saving
overhead in g_p_f(), but that clearly doesn't happen in the current form.
So we have both crazy complexity and overhead, AFAICS.

[1] https://lkml.kernel.org/r/CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com
[2] https://lkml.kernel.org/r/7c459f26-13a6-a817-e508-b65b903a8378@suse.cz

Vlastimil Babka (4):
  mm, page_alloc: fix check for NULL preferred_zone
  mm, page_alloc: fix fast-path race with cpuset update or removal
  mm, page_alloc: move cpuset seqcount checking to slowpath
  mm, page_alloc: fix premature OOM when racing with cpuset mems update

 include/linux/mmzone.h |  6 ++++-
 mm/page_alloc.c        | 68 ++++++++++++++++++++++++++++++++++----------------
 2 files changed, 52 insertions(+), 22 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
