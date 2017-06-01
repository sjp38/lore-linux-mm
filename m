Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C7E556B02F4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 07:44:05 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n13so37100986ita.7
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 04:44:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e28si18648486ioj.189.2017.06.01.04.44.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 04:44:04 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Date: Thu,  1 Jun 2017 20:43:47 +0900
Message-Id: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

Cong Wang has reported a lockup when running LTP memcg_stress test [1].
Although the cause of allocation stall is unknown (no OOM killer messages
found within partially written output), that test put much stress with
uncontrolled concurrent warn_alloc() calls enough to trigger NMI watchdog
on soft lockup at cpu_relax() loop in dump_stack().

(Immaterial lines removed.)
----------
[16213.477525] Call Trace:
[16213.487314]  [<ffffffff86395ab7>] dump_stack+0x4d/0x66
[16213.497723]  [<ffffffff8619a6c6>] warn_alloc+0x116/0x130
[16213.505627] NMI watchdog: BUG: soft lockup - CPU#5 stuck for 23s! [cleanup:7598]
[16213.505713] CPU: 5 PID: 7598 Comm: cleanup Not tainted 4.9.23.el7.twitter.x86_64 #1
[16213.505714] Hardware name: Dell Inc. PowerEdge C6220/03C9JJ, BIOS 2.2.3 11/07/2013
[16213.505722] RIP: 0010:[<ffffffff86395a93>]  [<ffffffff86395a93>] dump_stack+0x29/0x66
[16213.505795] Call Trace:
[16213.505799]  [<ffffffff8619a6c6>] warn_alloc+0x116/0x130
[16213.505804]  [<ffffffff8619b0bf>] __alloc_pages_slowpath+0x96f/0xbd0
[16213.505807]  [<ffffffff8619b4f6>] __alloc_pages_nodemask+0x1d6/0x230
[16213.505810]  [<ffffffff861e61d5>] alloc_pages_current+0x95/0x140
[16213.505814]  [<ffffffff8619114a>] __page_cache_alloc+0xca/0xe0
[16213.505822]  [<ffffffff86194312>] filemap_fault+0x312/0x4d0
[16213.505826]  [<ffffffff862a8196>] ext4_filemap_fault+0x36/0x50
[16213.505828]  [<ffffffff861c2c71>] __do_fault+0x71/0x130
[16213.505830]  [<ffffffff861c6cec>] handle_mm_fault+0xebc/0x13a0
[16213.505832]  [<ffffffff863b434d>] ? list_del+0xd/0x30
[16213.505833]  [<ffffffff86257e58>] ? ep_poll+0x308/0x320
[16213.505835]  [<ffffffff860509e4>] __do_page_fault+0x254/0x4a0
[16213.505837]  [<ffffffff86050c50>] do_page_fault+0x20/0x70
[16213.505839]  [<ffffffff86700aa2>] page_fault+0x22/0x30
[16213.505877] Code: 5d c3 55 83 c9 ff 48 89 e5 41 54 53 9c 5b fa 65 8b 15 4a 47 c7 79 89 c8 f0 0f b1 15 48 a3 92 00 83 f8 ff 74 0a 39 c2 74 0b 53 9d <f3> 90 eb dd 45 31 e4 eb 06 41 bc 01 00 00 00 48 c7 c7 41 1a a2
[16214.250659] NMI watchdog: BUG: soft lockup - CPU#17 stuck for 22s! [scribed:3905]
[16214.250765] CPU: 17 PID: 3905 Comm: scribed Tainted: G             L 4.9.23.el7.twitter.x86_64 #1
[16214.250767] Hardware name: Dell Inc. PowerEdge C6220/03C9JJ, BIOS 2.2.3 11/07/2013
[16214.250776] RIP: 0010:[<ffffffff86395a93>]  [<ffffffff86395a93>] dump_stack+0x29/0x66
[16214.250840] Call Trace:
[16214.250843]  [<ffffffff8619a6c6>] warn_alloc+0x116/0x130
[16214.250846]  [<ffffffff8619b0bf>] __alloc_pages_slowpath+0x96f/0xbd0
[16214.250849]  [<ffffffff8619b4f6>] __alloc_pages_nodemask+0x1d6/0x230
[16214.250853]  [<ffffffff861e61d5>] alloc_pages_current+0x95/0x140
[16214.250855]  [<ffffffff8619114a>] __page_cache_alloc+0xca/0xe0
[16214.250857]  [<ffffffff86194312>] filemap_fault+0x312/0x4d0
[16214.250859]  [<ffffffff862a8196>] ext4_filemap_fault+0x36/0x50
[16214.250860]  [<ffffffff861c2c71>] __do_fault+0x71/0x130
[16214.250863]  [<ffffffff861c6cec>] handle_mm_fault+0xebc/0x13a0
[16214.250865]  [<ffffffff860c25c1>] ? pick_next_task_fair+0x471/0x4a0
[16214.250869]  [<ffffffff860509e4>] __do_page_fault+0x254/0x4a0
[16214.250871]  [<ffffffff86050c50>] do_page_fault+0x20/0x70
[16214.250873]  [<ffffffff86700aa2>] page_fault+0x22/0x30
[16214.250918] Code: 5d c3 55 83 c9 ff 48 89 e5 41 54 53 9c 5b fa 65 8b 15 4a 47 c7 79 89 c8 f0 0f b1 15 48 a3 92 00 83 f8 ff 74 0a 39 c2 74 0b 53 9d <f3> 90 eb dd 45 31 e4 eb 06 41 bc 01 00 00 00 48 c7 c7 41 1a a2
[16215.157526]  [<ffffffff8619b0bf>] __alloc_pages_slowpath+0x96f/0xbd0
[16215.177523]  [<ffffffff8619b4f6>] __alloc_pages_nodemask+0x1d6/0x230
[16215.197540]  [<ffffffff861e61d5>] alloc_pages_current+0x95/0x140
[16215.217331]  [<ffffffff8619114a>] __page_cache_alloc+0xca/0xe0
[16215.237374]  [<ffffffff86194312>] filemap_fault+0x312/0x4d0
[16215.257136]  [<ffffffff862a8196>] ext4_filemap_fault+0x36/0x50
[16215.276950]  [<ffffffff861c2c71>] __do_fault+0x71/0x130
[16215.287555]  [<ffffffff861c6cec>] handle_mm_fault+0xebc/0x13a0
[16215.307538]  [<ffffffff860509e4>] __do_page_fault+0x254/0x4a0
[16215.327165]  [<ffffffff86050c50>] do_page_fault+0x20/0x70
[16215.346964]  [<ffffffff86700aa2>] page_fault+0x22/0x30
----------

Both the printk() flooding problem caused by uncontrolled concurrent
warn_alloc() calls and the OOM killer being unable to send SIGKILL problem
caused by preemption were already pointed out by me [2], but these problems
are left unfixed because Michal does not like serialization from allocation
path because he is worrying about unexpected side effects [3].

But it's time to at least workaround this problem because the former
problem is now reported by other than me. We have a choice (spinlock or
mutex or [4]) here for serializing warn_alloc() messages.

If we can assume that that NMI context never calls __alloc_pages_nodemask()
without __GFP_NOWARN, we could use a spinlock so that all memory allocation
stall/failure messages do not get mixed. But since the lockup above was
triggered by busy waiting at dump_stack(), we might still hit lockups if
we do busy waiting at warn_alloc(). Thus, spinlock is not a safe choice.

If we can give up serializing !__GFP_DIRECT_RECLAIM memory allocation
failure messages, we could use a mutex. Although avoid mixing both memory
allocation stall/failure messages and the OOM killer messages would be
nice, oom_lock mutex should not be used for this purpose, for waiting for
oom_lock mutex at warn_alloc() can prevent anybody from calling
out_of_memory() from __alloc_pages_may_oom() (i.e. after all lockups).

Therefore, this patch uses a mutex dedicated for warn_alloc() like
suggested in [3]. I believe that the safest fix is [4] which offloads
reporting of allocation stalls to the khungtaskd kernel thread so that
we can eliminate a lot of noisy duplicates, avoid ratelimit filtering
which randomly drops important traces needed for debugging, and allow
triggering more useful actions.

[1] http://lkml.kernel.org/r/CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com
[2] http://lkml.kernel.org/r/1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
[3] http://lkml.kernel.org/r/20161212125535.GA3185@dhcp22.suse.cz
[4] http://lkml.kernel.org/r/1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Suggested-by: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 mm/page_alloc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 682ecac..4f98ff6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3185,10 +3185,13 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	va_list args;
 	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
 				      DEFAULT_RATELIMIT_BURST);
+	static DEFINE_MUTEX(warn_alloc_lock);
 
 	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
 		return;
 
+	if (gfp_mask & __GFP_DIRECT_RECLAIM)
+		mutex_lock(&warn_alloc_lock);
 	pr_warn("%s: ", current->comm);
 
 	va_start(args, fmt);
@@ -3207,6 +3210,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 	dump_stack();
 	warn_alloc_show_mem(gfp_mask, nodemask);
+	if (gfp_mask & __GFP_DIRECT_RECLAIM)
+		mutex_unlock(&warn_alloc_lock);
 }
 
 static inline struct page *
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
