Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id B18A06B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:36:56 -0500 (EST)
Received: by lfs39 with SMTP id 39so62663416lfs.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:36:56 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q140si16426075lfe.67.2015.11.25.07.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 07:36:54 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] vmscan: do not throttle kthreads due to too_many_isolated
Date: Wed, 25 Nov 2015 18:36:41 +0300
Message-ID: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Block device drivers often hand off io request processing to kernel
threads (example: device mapper). If such a thread calls kmalloc, it can
dive into direct reclaim path and end up waiting for too_many_isolated
to return false, blocking writeback. This can lead to a dead lock if the
pages were isolated by processes performing memcg reclaim, because they
call wait_on_page_writeback upon encountering a page under writeback,
which will never finish if bio_endio is to be called by the kernel
thread stuck in the reclaimer, waiting for the isolated pages to be put
back.

I've never encountered such a dead lock on vanilla kernel, neither have
I tried to reproduce it. However, I faced it with an out-of-tree block
device driver, which uses a kernel thread for completing bios: the
kernel thread got stuck busy-checking too_many_isolated on the DMA zone,
which had only 3 inactive and 68 isolated file pages (2163 pages were
free); the pages were isolated by memcg processes waiting for writeback
to finish. I don't see anything that could prevent this in case of e.g.
device mapper.

Let's fix this problem by making too_many_isolated always return false
for kernel threads. Apart from fixing the possible dead lock in case of
the legacy cgroup hierarchy, this makes sense even if the unified
hierarchy is used, where processes performing memcg reclaim will never
call wait_on_page_writeback, because kernel threads might be responsible
for cleaning pages necessary for reclaim - BTW throttle_direct_reclaim
never throttles kernel threads for the same reason.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9d553b07bb86..0f1318a52b23 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1457,7 +1457,7 @@ static int too_many_isolated(struct zone *zone, int file,
 {
 	unsigned long inactive, isolated;
 
-	if (current_is_kswapd())
+	if (current->flags & PF_KTHREAD)
 		return 0;
 
 	if (!sane_reclaim(sc))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
