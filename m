Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65E246B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 06:27:28 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id y77so26820301ioe.15
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 03:27:28 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h191si1751774iof.140.2017.06.16.03.27.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 03:27:27 -0700 (PDT)
Subject: Re: Re: [patch] mm, oom: prevent additional oom kills before memory is freed
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1706151459530.64172@chino.kir.corp.google.com>
	<20170615221236.GB22341@dhcp22.suse.cz>
	<201706160054.v5G0sY7c064781@www262.sakura.ne.jp>
	<20170616083946.GC30580@dhcp22.suse.cz>
In-Reply-To: <20170616083946.GC30580@dhcp22.suse.cz>
Message-Id: <201706161927.EII04611.VOFFMLJOOFHQSt@I-love.SAKURA.ne.jp>
Date: Fri, 16 Jun 2017 19:27:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 16-06-17 09:54:34, Tetsuo Handa wrote:
> [...]
> > And the patch you proposed is broken.
> 
> Thanks for your testing!
>  
> > ----------
> > [  161.846202] Out of memory: Kill process 6331 (a.out) score 999 or sacrifice child
> > [  161.850327] Killed process 6331 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [  161.858503] ------------[ cut here ]------------
> > [  161.861512] kernel BUG at mm/memory.c:1381!
> 
> BUG_ON(addr >= end) suggests our vma has trimmed. I guess I see what is
> going on here.
> __oom_reap_task_mm				exit_mmap
> 						  free_pgtables
> 						  up_write(mm->mmap_sem)
>   down_read_trylock(&mm->mmap_sem)
>   						  remove_vma
>     unmap_page_range
> 
> So we need to extend the mmap_sem coverage. See the updated diff (not
> the full proper patch yet).

That diff is still wrong. We need to prevent __oom_reap_task_mm() from calling
unmap_page_range() when __mmput() already called exit_mm(), by setting/checking
MMF_OOM_SKIP like shown below.

diff --git a/kernel/fork.c b/kernel/fork.c
index e53770d..5ef715c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -902,6 +902,11 @@ static inline void __mmput(struct mm_struct *mm)
 	exit_aio(mm);
 	ksm_exit(mm);
 	khugepaged_exit(mm); /* must run before exit_mmap */
+	/*
+	 * oom reaper might race with exit_mmap so make sure we won't free
+	 * page tables under its feet
+	 */
+	down_write(&mm->mmap_sem);
 	exit_mmap(mm);
 	mm_put_huge_zero_page(mm);
 	set_mm_exe_file(mm, NULL);
@@ -913,6 +918,7 @@ static inline void __mmput(struct mm_struct *mm)
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
 	set_bit(MMF_OOM_SKIP, &mm->flags);
+	up_write(&mm->mmap_sem);
 	mmdrop(mm);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143..98cca19 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -493,12 +493,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		goto unlock_oom;
 	}
 
-	/*
-	 * increase mm_users only after we know we will reap something so
-	 * that the mmput_async is called only when we have reaped something
-	 * and delayed __mmput doesn't matter that much
-	 */
-	if (!mmget_not_zero(mm)) {
+	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
 		up_read(&mm->mmap_sem);
 		goto unlock_oom;
 	}
@@ -537,13 +532,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
-
-	/*
-	 * Drop our reference but make sure the mmput slow path is called from a
-	 * different context because we shouldn't risk we get stuck there and
-	 * put the oom_reaper out of the way.
-	 */
-	mmput_async(mm);
 unlock_oom:
 	mutex_unlock(&oom_lock);
 	return ret;



> 
> > Please carefully consider the reason why there is VM_BUG_ON() in __mmput(),
> > and clarify in your patch that what are possible side effects of racing
> > uprobe_clear_state()/exit_aio()/ksm_exit()/exit_mmap() etc. with
> > __oom_reap_task_mm()
> 
> Yes that definitely needs to be checked. We basically rely on the racing
> part of the __mmput to not modify the address space. oom_reaper doesn't
> touch any vma state except it unmaps pages which can run in parallel.
> exit_aio->kill_ioctx seemingly does vm_munmap but it a) uses the
> mmap_sem for write and b) it doesn't actually unmap because exit_aio
> does ctx->mmap_size = 0. {ksm,khugepaged}_exit just do some houskeeping
> which is not modifying the address space. I hope I will find some more
> time to work on this next week. Additional test would be highly
> appreciated of course.

Since the OOM reaper does not reap hugepages, khugepaged_exit() part could be
safe. But ksm_exit() part might interfere. If it is guaranteed to be safe,
what will go wrong if we move uprobe_clear_state()/exit_aio()/ksm_exit() etc.
to just before mmdrop() (i.e. after setting MMF_OOM_SKIP) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
