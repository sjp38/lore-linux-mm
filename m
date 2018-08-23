Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECA4A6B21F7
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 08:29:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n17-v6so3108075pff.17
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 05:29:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p7-v6si4071405plo.159.2018.08.23.05.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 05:29:29 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, oom: Always call tlb_finish_mmu().
Date: Thu, 23 Aug 2018 20:30:48 +0900
Message-Id: <1535023848-5554-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Commit 93065ac753e44438 ("mm, oom: distinguish blockable mode for mmu
notifiers") added "continue;" without calling tlb_finish_mmu(). I don't
know whether tlb_flush_pending imbalance causes problems other than
extra cost, but at least it looks strange.

More worrisome part in that patch is that I don't know whether using
trylock if blockable == false at entry is really sufficient. For example,
since __gnttab_unmap_refs_async() from gnttab_unmap_refs_async() from
gnttab_unmap_refs_sync() from __unmap_grant_pages() from
unmap_grant_pages() from unmap_if_in_range() from mn_invl_range_start()
involves schedule_delayed_work() which could be blocked on memory
allocation under OOM situation, wait_for_completion() from
gnttab_unmap_refs_sync() might deadlock? I don't know...

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b5b25e4..4f431c1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -522,6 +522,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 
 			tlb_gather_mmu(&tlb, mm, start, end);
 			if (mmu_notifier_invalidate_range_start_nonblock(mm, start, end)) {
+				tlb_finish_mmu(&tlb, start, end);
 				ret = false;
 				continue;
 			}
-- 
1.8.3.1
