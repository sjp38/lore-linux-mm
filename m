Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 327BD8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:08:07 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id n17-v6so9234517ioa.5
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:08:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z80-v6si1457191itc.101.2018.09.14.10.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 10:08:05 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
References: <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
 <20180912075054.GZ10951@dhcp22.suse.cz>
 <20180912134203.GJ10951@dhcp22.suse.cz>
 <4ed2213e-c4ca-4ef2-2cc0-17b5c5447325@i-love.sakura.ne.jp>
 <20180913090950.GD20287@dhcp22.suse.cz>
 <c70a8b7c-d1d2-66de-d87e-13a4a410335b@i-love.sakura.ne.jp>
 <20180913113538.GE20287@dhcp22.suse.cz>
 <0897639b-a1d9-2da1-0a1e-a3eeed799a0f@i-love.sakura.ne.jp>
 <20180913134032.GF20287@dhcp22.suse.cz>
 <792a95e1-b81d-b220-f00b-27b7abf969f4@i-love.sakura.ne.jp>
 <20180914141457.GB6081@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <8a766c49-3832-4a34-cba7-c4c24fdca8e0@i-love.sakura.ne.jp>
Date: Sat, 15 Sep 2018 02:07:46 +0900
MIME-Version: 1.0
In-Reply-To: <20180914141457.GB6081@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On 2018/09/14 23:14, Michal Hocko wrote:
> On Fri 14-09-18 22:54:45, Tetsuo Handa wrote:
>> OK, next question.
>> Is it guaranteed that arch_exit_mmap(mm) is safe with the OOM reaper?
> 
> I do not see any obvious problem and we used to allow to race unmaping
> in exit and oom_reaper paths before we had to handle mlocked vmas
> specially.

Although we used to allow arch_exit_mmap() to race, it might be nothing but
we hit mlock() problem first. I want "clearly no problem".



>> Well, anyway, diffstat of your proposal would be
>>
>>  include/linux/oom.h |  2 --
>>  mm/internal.h       |  3 +++
>>  mm/memory.c         | 28 ++++++++++++--------
>>  mm/mmap.c           | 73 +++++++++++++++++++++++++++++++----------------------
>>  mm/oom_kill.c       | 46 ++++++++++++++++++++++++---------
>>  5 files changed, 98 insertions(+), 54 deletions(-)
>>
>> trying to hand over only __free_pgtables() part at the risk of
>> setting MMF_OOM_SKIP without reclaiming any memory due to dropping
>> __oom_reap_task_mm() and scattering down_write()/up_write() inside
>> exit_mmap(), while diffstat of my proposal (not tested yet) would be
>>
>>  include/linux/mm_types.h |   2 +
>>  include/linux/oom.h      |   3 +-
>>  include/linux/sched.h    |   2 +-
>>  kernel/fork.c            |  11 +++
>>  mm/mmap.c                |  42 ++++-------
>>  mm/oom_kill.c            | 182 ++++++++++++++++++++++-------------------------
>>  6 files changed, 117 insertions(+), 125 deletions(-)
>>
>> trying to wait until __mmput() completes and also trying to handle
>> multiple OOM victims in parallel.

Bottom is the fix-up for my proposal. It seems to be working well enough.

 include/linux/oom.h |  1 -
 kernel/fork.c       |  2 +-
 mm/oom_kill.c       | 30 ++++++++++++------------------
 3 files changed, 13 insertions(+), 20 deletions(-)



>>
>> You are refusing timeout based approach but I don't think this is
>> something we have to be frayed around the edge about possibility of
>> overlooking races/bugs because you don't want to use timeout. And you
>> have never showed that timeout based approach cannot work well enough.
> 
> I have tried to explain why I do not like the timeout based approach
> several times alreay and I am getting fed up repeating it over and over
> again.  The main point though is that we know _what_ we are waiting for
> and _how_ we are synchronizing different parts rather than let's wait
> some time and hopefully something happens.

At the risk of overlooking bugs. Quite few persons are checking OOM lockup
possibility which is a dangerous thing for taking your aggressive approach.

> 
> Moreover, we have a backoff mechanism. The new class of oom victims
> with a large amount of memory in page tables can fit into that
> model. The new model adds few more branches to the exit path so if this
> is acceptable for other mm developers then I think this is much more
> preferrable to add a diffrent retry mechanism.
> 

These "few more branches" have to be "clearly no problem" rather than
"passed some stress tests". And so far no response from other mm developers.






diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8a987c6..9d30c15 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -104,7 +104,6 @@ extern unsigned long oom_badness(struct task_struct *p,
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(void);
-extern void exit_oom_mm(struct mm_struct *mm);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/kernel/fork.c b/kernel/fork.c
index 3e662bb..5c32791 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1018,7 +1018,7 @@ static inline void __mmput(struct mm_struct *mm)
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
 	if (oom)
-		exit_oom_mm(mm);
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 	mmdrop(mm);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 01fa0d7..cff41fa 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -561,6 +561,14 @@ static void oom_reap_task(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->signal->oom_mm;
 	unsigned long pages;
 
+	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+		spin_lock(&oom_reaper_lock);
+		list_del(&tsk->oom_victim);
+		spin_unlock(&oom_reaper_lock);
+		/* Drop a reference taken by wake_oom_reaper(). */
+		put_task_struct(tsk);
+		return;
+	}
 	oom_reap_task_mm(tsk, mm);
 	pages = oom_badness_pages(mm);
 	/* Hide this mm from OOM killer if stalled for too long. */
@@ -581,6 +589,7 @@ static int oom_reaper(void *unused)
 {
 	while (true) {
 		struct task_struct *tsk;
+		struct task_struct *tmp;
 
 		if (!list_empty(&oom_reaper_list))
 			schedule_timeout_uninterruptible(HZ / 10);
@@ -588,32 +597,17 @@ static int oom_reaper(void *unused)
 			wait_event_freezable(oom_reaper_wait,
 					     !list_empty(&oom_reaper_list));
 		spin_lock(&oom_reaper_lock);
-		list_for_each_entry(tsk, &oom_reaper_list, oom_victim) {
-			get_task_struct(tsk);
+		list_for_each_entry_safe(tsk, tmp, &oom_reaper_list,
+					 oom_victim) {
 			spin_unlock(&oom_reaper_lock);
 			oom_reap_task(tsk);
 			spin_lock(&oom_reaper_lock);
-			put_task_struct(tsk);
 		}
 		spin_unlock(&oom_reaper_lock);
 	}
 	return 0;
 }
 
-void exit_oom_mm(struct mm_struct *mm)
-{
-	struct task_struct *tsk;
-
-	spin_lock(&oom_reaper_lock);
-	list_for_each_entry(tsk, &oom_reaper_list, oom_victim)
-		if (tsk->signal->oom_mm == mm)
-			break;
-	list_del(&tsk->oom_victim);
-	spin_unlock(&oom_reaper_lock);
-	/* Drop a reference taken by wake_oom_reaper(). */
-	put_task_struct(tsk);
-}
-
 static void wake_oom_reaper(struct task_struct *tsk)
 {
 	struct mm_struct *mm = tsk->signal->oom_mm;
@@ -632,7 +626,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	get_task_struct(tsk);
 
 	spin_lock(&oom_reaper_lock);
-	list_add_tail(&tsk->oom_victim, &oom_reaper_list);
+	list_add(&tsk->oom_victim, &oom_reaper_list);
 	spin_unlock(&oom_reaper_lock);
 	trace_wake_reaper(tsk->pid);
 	wake_up(&oom_reaper_wait);
-- 
1.8.3.1
