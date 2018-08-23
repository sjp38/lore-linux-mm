Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9B96B28D3
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:59:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t26-v6so3371772pfh.0
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:59:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d81-v6si5203941pfm.226.2018.08.23.07.59.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 07:59:29 -0700 (PDT)
Subject: [PATCH v2] mm, oom: Fix missing tlb_finish_mmu() in
 __oom_reap_task_mm().
References: <1535023848-5554-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180823115957.GF29735@dhcp22.suse.cz>
 <6bf40c7f-3e68-8702-b087-9e37abb2d547@i-love.sakura.ne.jp>
 <20180823140209.GO29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b752d1d5-81ad-7a35-2394-7870641be51c@i-love.sakura.ne.jp>
Date: Thu, 23 Aug 2018 23:11:26 +0900
MIME-Version: 1.0
In-Reply-To: <20180823140209.GO29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Commit 93065ac753e44438 ("mm, oom: distinguish blockable mode for mmu
notifiers") added "continue;" without calling tlb_finish_mmu(). It should
not cause a critical problem but fix anyway because it looks strange.

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
