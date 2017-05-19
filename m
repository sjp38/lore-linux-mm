Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D69E12803C1
	for <linux-mm@kvack.org>; Fri, 19 May 2017 07:26:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j28so53249587pfk.14
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:26:16 -0700 (PDT)
Received: from mail-pf0-f193.google.com (mail-pf0-f193.google.com. [209.85.192.193])
        by mx.google.com with ESMTPS id s18si7906523pfs.171.2017.05.19.04.26.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 04:26:15 -0700 (PDT)
Received: by mail-pf0-f193.google.com with SMTP id u26so9282844pfd.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:26:15 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, oom: make sure that the oom victim uses memory reserves
Date: Fri, 19 May 2017 13:26:03 +0200
Message-Id: <20170519112604.29090-2-mhocko@kernel.org>
In-Reply-To: <20170519112604.29090-1-mhocko@kernel.org>
References: <20170519112604.29090-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Roman Gushchin has noticed that we kill two tasks when the memory hog
killed from page fault path:
[   25.721494] allocate invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[   25.725658] allocate cpuset=/ mems_allowed=0
[   25.727033] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
[   25.729215] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
[   25.729598] Call Trace:
[   25.729598]  dump_stack+0x63/0x82
[   25.729598]  dump_header+0x97/0x21a
[   25.729598]  ? do_try_to_free_pages+0x2d7/0x360
[   25.729598]  ? security_capable_noaudit+0x45/0x60
[   25.729598]  oom_kill_process+0x219/0x3e0
[   25.729598]  out_of_memory+0x11d/0x480
[   25.729598]  __alloc_pages_slowpath+0xc84/0xd40
[   25.729598]  __alloc_pages_nodemask+0x245/0x260
[   25.729598]  alloc_pages_vma+0xa2/0x270
[   25.729598]  __handle_mm_fault+0xca9/0x10c0
[   25.729598]  handle_mm_fault+0xf3/0x210
[   25.729598]  __do_page_fault+0x240/0x4e0
[   25.729598]  trace_do_page_fault+0x37/0xe0
[   25.729598]  do_async_page_fault+0x19/0x70
[   25.729598]  async_page_fault+0x28/0x30

which leads to VM_FAULT_OOM and so to another out_of_memory when bailing
out from the #PF
[   25.817589] allocate invoked oom-killer: gfp_mask=0x0(), nodemask=(null),  order=0, oom_score_adj=0
[   25.818821] allocate cpuset=/ mems_allowed=0
[   25.819259] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
[   25.819847] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
[   25.820549] Call Trace:
[   25.820733]  dump_stack+0x63/0x82
[   25.820961]  dump_header+0x97/0x21a
[   25.820961]  ? security_capable_noaudit+0x45/0x60
[   25.820961]  oom_kill_process+0x219/0x3e0
[   25.820961]  out_of_memory+0x11d/0x480
[   25.820961]  pagefault_out_of_memory+0x68/0x80
[   25.820961]  mm_fault_error+0x8f/0x190
[   25.820961]  ? handle_mm_fault+0xf3/0x210
[   25.820961]  __do_page_fault+0x4b2/0x4e0
[   25.820961]  trace_do_page_fault+0x37/0xe0
[   25.820961]  do_async_page_fault+0x19/0x70
[   25.820961]  async_page_fault+0x28/0x30

We wouldn't choose another task normally because oom_evaluate_task will
skip selecting another task while there is an existing oom victim but we
can race with the oom_reaper which can set MMF_OOM_SKIP and so select
another task.  Tetsuo Handa has pointed out that 9a67f6488eca926f ("mm:
consolidate GFP_NOFAIL checks in the allocator slowpath") made this more
probable because prior to this patch we have retried the allocation with
access to memory reserves which is likely to succeed.

Make sure we at least attempted to allocate with no watermarks before
bailing out and failing the allocation.

Reported-by: Roman Gushchin <guro@fb.com>
Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Fixes: 9a67f6488eca926f ("mm: consolidate GFP_NOFAIL checks in the allocator slowpath")
Cc: stable # 4.11+
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a26e19c3e1ff..db8017cd13bb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3873,7 +3873,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE))
+	if (alloc_flags == ALLOC_NO_WATERMARKS && test_thread_flag(TIF_MEMDIE))
 		goto nopage;
 
 	/* Retry as long as the OOM killer is making progress */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
