Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 30F516B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:31 -0400 (EDT)
Received: by wizk4 with SMTP id k4so111775725wiz.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:30 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q4si14225890wie.7.2015.04.27.12.06.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:29 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/9] mm: improve OOM mechanism v2
Date: Mon, 27 Apr 2015 15:05:46 -0400
Message-Id: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is a possible deadlock scenario between the page allocator and
the OOM killer.  Most allocations currently retry forever inside the
page allocator, but when the OOM killer is invoked the chosen victim
might try taking locks held by the allocating task.  This series, on
top of many cleanups in the allocator & OOM killer, grants such OOM-
killing allocations access to the system's memory reserves in order
for them to make progress without relying on their own kill to exit.

Changes since v1:
- drop GFP_NOFS deadlock fix (Dave Chinner)
- drop low-order deadlock fix (Michal Hocko)
- fix missing oom_lock in sysrq+f (Michal Hocko)
- fix PAGE_ALLOC_COSTLY retry condition (Michal Hocko)
- ALLOC_NO_WATERMARKS only for OOM victims, not all killed tasks (Tetsuo Handa)
- bump OOM wait timeout from 1s to 5s (Vlastimil Babka & Michal Hocko)

 drivers/staging/android/lowmemorykiller.c |   2 +-
 drivers/tty/sysrq.c                       |   2 +
 include/linux/oom.h                       |  12 +-
 kernel/exit.c                             |   2 +-
 mm/memcontrol.c                           |  20 ++--
 mm/oom_kill.c                             | 167 +++++++---------------------
 mm/page_alloc.c                           | 161 ++++++++++++---------------
 7 files changed, 137 insertions(+), 229 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
