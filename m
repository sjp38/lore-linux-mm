Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A6CFD6B0253
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 09:26:26 -0500 (EST)
Received: by wmuu63 with SMTP id u63so217095649wmu.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 06:26:26 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id kj9si4633889wjb.72.2015.12.02.06.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 06:26:25 -0800 (PST)
Received: by wmec201 with SMTP id c201so60277189wme.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 06:26:25 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] memcg, vmscan: Do not wait for writeback if killed
Date: Wed,  2 Dec 2015 15:26:18 +0100
Message-Id: <1449066378-4764-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Legacy memcg reclaim waits for pages under writeback to prevent from a
premature oom killer invocation because there was no memcg dirty limit
throttling implemented back then.

This heuristic might complicate situation when the writeback cannot make
forward progress because of the global OOM situation. E.g. filesystem
backed by the loop device relies on the underlying filesystem hosting
the image to make forward progress which cannot be guaranteed and so
we might end up triggering OOM killer to resolve the situation. If the
oom victim happens to be the task stuck in wait_on_page_writeback in the
memcg reclaim then we are basically deadlocked.

Introduce wait_on_page_writeback_killable and use it in this path to
prevent from the issue. shrink_page_list will back off if the wait
was interrupted.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
this came out from the discussion with Vladimir [1]. I haven't seen
a deadlock presented in the above description but I fail to see why
it would be impossible either. wait_on_page_writeback_killable is an
utterly long name but wait_on_page_bit_killable is quite long already
and I felt it is better to use the helper.

Thoughts?

[1] http://lkml.kernel.org/r/1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com

 include/linux/pagemap.h |  8 ++++++++
 mm/vmscan.c             | 11 ++++++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 4d08b6c33557..d3bb8963f8f0 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -532,6 +532,14 @@ static inline void wait_on_page_writeback(struct page *page)
 		wait_on_page_bit(page, PG_writeback);
 }
 
+static inline int wait_on_page_writeback_killable(struct page *page)
+{
+	if (PageWriteback(page))
+		return wait_on_page_bit_killable(page, PG_writeback);
+
+	return 0;
+}
+
 extern void end_page_writeback(struct page *page);
 void wait_for_stable_page(struct page *page);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4589cfdbe405..98a1934493af 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1021,10 +1021,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 			/* Case 3 above */
 			} else {
+				int ret;
+
 				unlock_page(page);
-				wait_on_page_writeback(page);
+				ret = wait_on_page_writeback_killable(page);
 				/* then go back and try same page again */
 				list_add_tail(&page->lru, page_list);
+
+				/*
+				 * We've got killed while waiting here so
+				 * expedite our way out from the reclaim
+				 */
+				if (ret)
+					break;
 				continue;
 			}
 		}
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
