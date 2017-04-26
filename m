Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2629B6B02E1
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 05:10:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s22so40637297pfs.0
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 02:10:50 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id p5si24694620pgn.312.2017.04.26.02.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 02:10:49 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id 63so16708483pgh.0
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 02:10:49 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 1/2] mm: hwpoison: call shake_page() unconditionally
Date: Wed, 26 Apr 2017 18:10:40 +0900
Message-Id: <1493197841-23986-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1493197841-23986-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1493197841-23986-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xiaolong.ye@intel.com, Andrew Morton <akpm@linux-foundation.org>, Chen Gong <gong.chen@linux.intel.com>, lkp@01.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

shake_page() is called before going into core error handling code in order
to ensure that the error page is flushed from lru_cache lists where pages
stay during transferring among LRU lists.
But currently it's not fully functional because when the page is linked to
lru_cache by calling activate_page(), its PageLRU flag is set and
shake_page() is skipped. The result is to fail error handling with "still
referenced by 1 users" message.
When the page is linked to lru_cache by isolate_lru_page(), its PageLRU is
clear, so that's fine.

This patch makes shake_page() unconditionally called to avoild the failure.

Link: http://lkml.kernel.org/r/20170417055948.GM31394@yexl-desktop
Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hwpoison-inject.c |  3 +--
 mm/memory-failure.c  | 27 +++++++++++----------------
 2 files changed, 12 insertions(+), 18 deletions(-)

diff --git v4.11-rc6-mmotm-2017-04-13-14-50/mm/hwpoison-inject.c v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/hwpoison-inject.c
index 9d26fd9..356df05 100644
--- v4.11-rc6-mmotm-2017-04-13-14-50/mm/hwpoison-inject.c
+++ v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/hwpoison-inject.c
@@ -34,8 +34,7 @@ static int hwpoison_inject(void *data, u64 val)
 	if (!hwpoison_filter_enable)
 		goto inject;
 
-	if (!PageLRU(hpage) && !PageHuge(p))
-		shake_page(hpage, 0);
+	shake_page(hpage, 0);
 	/*
 	 * This implies unable to support non-LRU pages.
 	 */
diff --git v4.11-rc6-mmotm-2017-04-13-14-50/mm/memory-failure.c v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/memory-failure.c
index 8c02811..77cf9c3 100644
--- v4.11-rc6-mmotm-2017-04-13-14-50/mm/memory-failure.c
+++ v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/memory-failure.c
@@ -220,6 +220,9 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
  */
 void shake_page(struct page *p, int access)
 {
+	if (PageHuge(p))
+		return;
+
 	if (!PageSlab(p)) {
 		lru_add_drain_all();
 		if (PageLRU(p))
@@ -1140,22 +1143,14 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 * The check (unnecessarily) ignores LRU pages being isolated and
 	 * walked by the page reclaim code, however that's not a big loss.
 	 */
-	if (!PageHuge(p)) {
-		if (!PageLRU(p))
-			shake_page(p, 0);
-		if (!PageLRU(p)) {
-			/*
-			 * shake_page could have turned it free.
-			 */
-			if (is_free_buddy_page(p)) {
-				if (flags & MF_COUNT_INCREASED)
-					action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
-				else
-					action_result(pfn, MF_MSG_BUDDY_2ND,
-						      MF_DELAYED);
-				return 0;
-			}
-		}
+	shake_page(p, 0);
+	/* shake_page could have turned it free. */
+	if (!PageLRU(p) && is_free_buddy_page(p)) {
+		if (flags & MF_COUNT_INCREASED)
+			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
+		else
+			action_result(pfn, MF_MSG_BUDDY_2ND, MF_DELAYED);
+		return 0;
 	}
 
 	lock_page(hpage);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
