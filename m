Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC386B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 06:44:49 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g8so240251127itb.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 03:44:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r109si1075765ota.107.2016.07.05.03.44.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jul 2016 03:44:48 -0700 (PDT)
Subject: Re: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
	<201607031138.AHB35971.FLVQOtJFOMFHSO@I-love.SAKURA.ne.jp>
	<20160704103931.GA3882@redhat.com>
	<201607042150.CIB00512.FSOtMHLOOVFFQJ@I-love.SAKURA.ne.jp>
	<20160704182549.GB8396@redhat.com>
In-Reply-To: <20160704182549.GB8396@redhat.com>
Message-Id: <201607051943.GHB86443.SOOFFFHJVLMQOt@I-love.SAKURA.ne.jp>
Date: Tue, 5 Jul 2016 19:43:34 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

Oleg Nesterov wrote:
> On 07/04, Tetsuo Handa wrote:
> >
> > Oleg Nesterov wrote:
> > > >
> > > > --- a/kernel/fork.c
> > > > +++ b/kernel/fork.c
> > > > @@ -722,6 +722,7 @@ static inline void __mmput(struct mm_struct *mm)
> > > >  	}
> > > >  	if (mm->binfmt)
> > > >  		module_put(mm->binfmt->module);
> > > > +	exit_oom_mm(mm);
> > >
> > > Is it strictly necessary? At first glance not. Sooner or later oom_reaper() should
> > > find this mm_struct and do exit_oom_mm(). And given that mm->mm_users is already 0
> > > the "extra" __oom_reap_vmas() doesn't really hurt.
> > >
> > > It would be nice to remove exit_oom_mm() from __mmput(); it takes the global spinlock
> > > for the very unlikely case, and if we can avoid it here then perhaps we can remove
> > > ->oom_mm from mm_struct.
> >
> > I changed not to take global spinlock from __mmput() unless that mm was used by
> > TIF_MEMDIE threads.
> 
> This new version doesn't apply on top of 2/8, I can't really understand it...

This new version is not for on top of 2/8, but squashed of all [1-8]/8 patches.

> > +void exit_oom_mm(struct mm_struct *mm)
> > +{
> > +	/* Nothing to do unless mark_oom_victim() was called with this mm. */
> > +	if (!mm->oom_mm.victim)
> > +		return;
> > +#ifdef CONFIG_MMU
> > +	/*
> > +	 * OOM reaper will eventually call __exit_oom_mm().
> > +	 * Allow oom_has_pending_mm() to ignore this mm.
> > +	 */
> > +	set_bit(MMF_OOM_REAPED, &mm->flags);
> 
> If the caller is exit_mm(), then mm->mm_users == 0 and oom_has_pending_mm()
> can check it is zero instead?

I don't think so. Setting MMF_OOM_REAPED indicates that memory used by that
mm is already reclaimed by the OOM reaper or by __mmput(). mm->mm_users == 0
alone does not mean memory used by that mm is already reclaimed.

Making exit_oom_mm() a no-op for CONFIG_MMU=y would be OK, but maybe we don't
want to defer next OOM victim selection in D2 domain which reached this point
due to waiting for OOM reaper to process D1 domain before D2 domain is processed
when OOM event in D1 domain occurred before OOM event in D2 domain occurs.
If OOM reaper tries D2 domain before retrying D1 domain for MAX_OOM_REAP_RETRIES
times, __exit_oom_mm() for D2 domain will be called immediately.



By the way, if this new version works as expected and we don't want oom_mm_lock
spinlock, we can reuse oom_lock like below.

 oom_kill.c |   39 +++++++++++++--------------------------
 1 file changed, 13 insertions(+), 26 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bbd3138..f23b306 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -292,17 +292,16 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 }
 
 static LIST_HEAD(oom_mm_list);
-static DEFINE_SPINLOCK(oom_mm_lock);
 
 static inline void __exit_oom_mm(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 
-	spin_lock(&oom_mm_lock);
+	mutex_lock(&oom_lock);
 	list_del(&mm->oom_mm.list);
 	tsk = mm->oom_mm.victim;
 	mm->oom_mm.victim = NULL;
-	spin_unlock(&oom_mm_lock);
+	mutex_unlock(&oom_lock);
 	/* Drop references taken by mark_oom_victim() */
 	put_task_struct(tsk);
 	mmdrop(mm);
@@ -329,7 +328,6 @@ bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	struct mm_struct *mm;
 	bool ret = false;
 
-	spin_lock(&oom_mm_lock);
 	list_for_each_entry(mm, &oom_mm_list, oom_mm.list) {
 		if (oom_unkillable_task(mm->oom_mm.victim, memcg, nodemask))
 			continue;
@@ -338,7 +336,6 @@ bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 		ret = true;
 		break;
 	}
-	spin_unlock(&oom_mm_lock);
 	return ret;
 }
 
@@ -550,16 +547,12 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 static void oom_reap_task(struct mm_struct *mm, struct task_struct *tsk)
 {
 	int attempts = 0;
-	bool ret;
 
 	/*
 	 * Check MMF_OOM_REAPED after holding oom_lock because
 	 * oom_kill_process() might find this mm pinned.
 	 */
-	mutex_lock(&oom_lock);
-	ret = test_bit(MMF_OOM_REAPED, &mm->flags);
-	mutex_unlock(&oom_lock);
-	if (ret)
+	if (test_bit(MMF_OOM_REAPED, &mm->flags))
 		return;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
@@ -589,8 +582,8 @@ static void oom_reap_task(struct mm_struct *mm, struct task_struct *tsk)
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct mm_struct *mm = NULL;
-		struct task_struct *victim = NULL;
+		struct mm_struct *mm;
+		struct task_struct *victim;
 
 		wait_event_freezable(oom_reaper_wait,
 				     !list_empty(&oom_mm_list));
@@ -599,16 +592,12 @@ static int oom_reaper(void *unused)
 		 * oom_reap_task() raced with mark_oom_victim() by
 		 * other threads sharing this mm.
 		 */
-		spin_lock(&oom_mm_lock);
-		if (!list_empty(&oom_mm_list)) {
-			mm = list_first_entry(&oom_mm_list, struct mm_struct,
-					      oom_mm.list);
-			victim = mm->oom_mm.victim;
-			get_task_struct(victim);
-		}
-		spin_unlock(&oom_mm_lock);
-		if (!mm)
-			continue;
+		mutex_lock(&oom_lock);
+		mm = list_first_entry(&oom_mm_list, struct mm_struct,
+				      oom_mm.list);
+		victim = mm->oom_mm.victim;
+		get_task_struct(victim);
+		mutex_unlock(&oom_lock);
 		oom_reap_task(mm, victim);
 		put_task_struct(victim);
 		__exit_oom_mm(mm);
@@ -652,17 +641,15 @@ void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
 	 * mm->mm_users > 0), __exit_oom_mm() from __mmput() can't be called
 	 * before we add this mm to the list.
 	 */
-	spin_lock(&oom_mm_lock);
 	old_tsk = mm->oom_mm.victim;
 	get_task_struct(tsk);
 	mm->oom_mm.victim = tsk;
 	if (!old_tsk) {
 		atomic_inc(&mm->mm_count);
 		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
-	}
-	spin_unlock(&oom_mm_lock);
-	if (old_tsk)
+	} else {
 		put_task_struct(old_tsk);
+	}
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
