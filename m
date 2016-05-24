Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA506B025E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 11:05:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so34986605pfz.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 08:05:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t81si29085760pfj.103.2016.05.24.08.05.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 May 2016 08:05:16 -0700 (PDT)
Subject: Re: [PATCH] mm: oom_kill_process: do not abort if the victim is exiting
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464092642-10363-1-git-send-email-vdavydov@virtuozzo.com>
	<20160524135042.GK8259@dhcp22.suse.cz>
In-Reply-To: <20160524135042.GK8259@dhcp22.suse.cz>
Message-Id: <201605250005.GHH26082.JOtQOSLMFFOFVH@I-love.SAKURA.ne.jp>
Date: Wed, 25 May 2016 00:05:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, vdavydov@virtuozzo.com
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 24-05-16 15:24:02, Vladimir Davydov wrote:
> > After selecting an oom victim, we first check if it's already exiting
> > and if it is, we don't bother killing tasks sharing its mm. We do try to
> > reap its mm though, but we abort if any of the processes sharing it is
> > still alive. This might result in oom deadlock if an exiting task got
> > stuck trying to acquire a lock held by another task sharing the same mm
> > which needs memory to continue: if oom killer happens to keep selecting
> > the stuck task, we won't even try to kill other processes or reap the
> > mm.
> 
> I plan to extend task_will_free_mem to catch this case because we will
> need it for other changes.

Isn't mm_is_reapable() more useful than playing with fatal_signal_pending()
or task_will_free_mem()?

bool mm_is_reapable(struct mm_struct *mm)
{
	struct task_struct *p;

	if (!mm)
		return false;
	if (test_bit(MMF_OOM_REAPABLE, &mm->flags))
		return true;
	if (!down_read_trylock(&mm->mmap_sem))
		return false;
	up_read(&mm->mmap_sem);
	/*
	 * There might be other threads/processes which are either not
	 * dying or even not killable.
	 */
	if (atomic_read(&mm->mm_users) > 1) {
		rcu_read_lock();
		for_each_process(p) {
			bool exiting;

			if (!process_shares_mm(p, mm))
				continue;
			if (fatal_signal_pending(p))
				continue;

			/*
			 * If the task is exiting make sure the whole thread group
			 * is exiting and cannot acces mm anymore.
			 */
			spin_lock_irq(&p->sighand->siglock);
			exiting = signal_group_exit(p->signal);
			spin_unlock_irq(&p->sighand->siglock);
			if (exiting)
				continue;

			/* Give up */
			rcu_read_unlock();
			return false;
		}
		rcu_read_unlock();
	}
	set_bit(MMF_OOM_REAPABLE, &mm->flags);
	return true;
}

 	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 * If the victim's memory is already reapable, don't alarm the sysadmin
+	 * or kill its children or threads, just set TIF_MEMDIE and let the
+	 * OOM reaper reap the victim's memory.
 	 */
 	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
+	if (mm_is_reapable(p->mm)) {
 		mark_oom_victim(p);
-		try_oom_reaper(p);
+		wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
 	}
 	task_unlock(p);

I suggest doing mm_is_reapable() test at __oom_reap_task() side as well
so that we can proceed to next victim by always calling wake_oom_reaper()
whenever TIF_MEMDIE is set.

-	if (can_oom_reap)
-		wake_oom_reaper(victim);
+	wake_oom_reaper(victim);

p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN is not a problem if that p is
already killed (not by the OOM killer) or exiting. We don't need to needlessly
make can_oom_reap false. mm_is_reapable() should do correct test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
