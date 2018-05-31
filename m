Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 903776B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 06:11:12 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id q4-v6so13521595ote.6
        for <linux-mm@kvack.org>; Thu, 31 May 2018 03:11:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z47-v6si5034069otz.253.2018.05.31.03.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 03:11:10 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
References: <20180525083118.GI11881@dhcp22.suse.cz>
 <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
 <20180525114213.GJ11881@dhcp22.suse.cz>
 <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
 <20180528124313.GC27180@dhcp22.suse.cz>
 <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
 <20180529060755.GH27180@dhcp22.suse.cz>
 <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <16eca862-5fa6-2333-8a81-94a2c2692758@i-love.sakura.ne.jp>
Date: Thu, 31 May 2018 19:10:48 +0900
MIME-Version: 1.0
In-Reply-To: <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, torvalds@linux-foundation.org
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org

On 2018/05/30 8:07, Andrew Morton wrote:
> On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
>>> I suggest applying
>>> this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
>>
>> Well, I hope the whole pile gets merged in the upcoming merge window
>> rather than stall even more.
> 
> I'm more inclined to drop it all.  David has identified significant
> shortcomings and I'm not seeing a way of addressing those shortcomings
> in a backward-compatible fashion.  Therefore there is no way forward
> at present.
> 

Can we apply my patch as-is first? My patch mitigates lockup regression
which should be able to be easily backported to stable kernels. We can
later evaluate whether moving the short sleep to should_reclaim_retry()
has negative impact.

Also we can eliminate the short sleep in Roman's patch before deciding
whether we can merge Roman's patchset in the upcoming merge window.



>From 4b356c742a3f1b720d5b709792fe68b25d800902 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 12 May 2018 12:27:52 +0900
Subject: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.

When I was examining a bug which occurs under CPU + memory pressure, I
observed that a thread which called out_of_memory() can sleep for minutes
at schedule_timeout_killable(1) with oom_lock held when many threads are
doing direct reclaim.

The whole point of the sleep is give the OOM victim some time to exit.
But since commit 27ae357fa82be5ab ("mm, oom: fix concurrent munlock and
oom reaper unmap, v3") changed the OOM victim to wait for oom_lock in order
to close race window at exit_mmap(), the whole point of this sleep is lost
now. We need to make sure that the thread which called out_of_memory() will
release oom_lock shortly. Therefore, this patch brings the sleep to outside
of the OOM path.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/oom_kill.c   | 38 +++++++++++++++++---------------------
 mm/page_alloc.c |  7 ++++++-
 2 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8ba6cb8..23ce67f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -479,6 +479,21 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
+/*
+ * We have to make sure not to cause premature new oom victim selection.
+ *
+ * __alloc_pages_may_oom()     oom_reap_task_mm()/exit_mmap()
+ *   mutex_trylock(&oom_lock)
+ *   get_page_from_freelist(ALLOC_WMARK_HIGH) # fails
+ *                               unmap_page_range() # frees some memory
+ *                               set_bit(MMF_OOM_SKIP)
+ *   out_of_memory()
+ *     select_bad_process()
+ *       test_bit(MMF_OOM_SKIP) # selects new oom victim
+ *   mutex_unlock(&oom_lock)
+ *
+ * Therefore, the callers hold oom_lock when calling this function.
+ */
 void __oom_reap_task_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
@@ -523,20 +538,6 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	bool ret = true;
 
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
 	mutex_lock(&oom_lock);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
@@ -1077,15 +1078,9 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen && oc->chosen != (void *)-1UL) {
+	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
 	return !!oc->chosen;
 }
 
@@ -1111,4 +1106,5 @@ void pagefault_out_of_memory(void)
 		return;
 	out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
+	schedule_timeout_killable(1);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d..458ed32 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3478,7 +3478,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	 */
 	if (!mutex_trylock(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 
@@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
+		/*
+		 * This schedule_timeout_*() serves as a guaranteed sleep for
+		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
+		 */
+		if (!tsk_is_oom_victim(current))
+			schedule_timeout_uninterruptible(1);
 		goto retry;
 	}
 
-- 
1.8.3.1
