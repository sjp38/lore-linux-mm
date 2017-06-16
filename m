Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 67FFE6B02FD
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 04:39:50 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v60so6545695wrc.7
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 01:39:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r186si2346003wmr.109.2017.06.16.01.39.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 01:39:49 -0700 (PDT)
Date: Fri, 16 Jun 2017 10:39:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [patch] mm, oom: prevent additional oom kills before memory
 is freed
Message-ID: <20170616083946.GC30580@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706151459530.64172@chino.kir.corp.google.com>
 <20170615221236.GB22341@dhcp22.suse.cz>
 <201706160054.v5G0sY7c064781@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706160054.v5G0sY7c064781@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-06-17 09:54:34, Tetsuo Handa wrote:
[...]
> And the patch you proposed is broken.

Thanks for your testing!
 
> ----------
> [  161.846202] Out of memory: Kill process 6331 (a.out) score 999 or sacrifice child
> [  161.850327] Killed process 6331 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  161.858503] ------------[ cut here ]------------
> [  161.861512] kernel BUG at mm/memory.c:1381!

BUG_ON(addr >= end) suggests our vma has trimmed. I guess I see what is
going on here.
__oom_reap_task_mm				exit_mmap
						  free_pgtables
						  up_write(mm->mmap_sem)
  down_read_trylock(&mm->mmap_sem)
  						  remove_vma
    unmap_page_range

So we need to extend the mmap_sem coverage. See the updated diff (not
the full proper patch yet).

> Please carefully consider the reason why there is VM_BUG_ON() in __mmput(),
> and clarify in your patch that what are possible side effects of racing
> uprobe_clear_state()/exit_aio()/ksm_exit()/exit_mmap() etc. with
> __oom_reap_task_mm()

Yes that definitely needs to be checked. We basically rely on the racing
part of the __mmput to not modify the address space. oom_reaper doesn't
touch any vma state except it unmaps pages which can run in parallel.
exit_aio->kill_ioctx seemingly does vm_munmap but it a) uses the
mmap_sem for write and b) it doesn't actually unmap because exit_aio
does ctx->mmap_size = 0. {ksm,khugepaged}_exit just do some houskeeping
which is not modifying the address space. I hope I will find some more
time to work on this next week. Additional test would be highly
appreciated of course.

---
diff --git a/mm/mmap.c b/mm/mmap.c
index 3bd5ecd20d4d..ca58f8a2a217 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2962,6 +2962,11 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
+	/*
+	 * oom reaper might race with exit_mmap so make sure we won't free
+	 * page tables or unmap VMAs under its feet
+	 */
+	down_write(&mm->mmap_sem);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
@@ -2975,6 +2980,7 @@ void exit_mmap(struct mm_struct *mm)
 		vma = remove_vma(vma);
 	}
 	vm_unacct_memory(nr_accounted);
+	up_write(&mm->mmap_sem);
 }
 
 /* Insert vm structure into process list sorted by address
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0e2c925e7826..3df464f0f48b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -494,16 +494,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 
 	/*
-	 * increase mm_users only after we know we will reap something so
-	 * that the mmput_async is called only when we have reaped something
-	 * and delayed __mmput doesn't matter that much
-	 */
-	if (!mmget_not_zero(mm)) {
-		up_read(&mm->mmap_sem);
-		goto unlock_oom;
-	}
-
-	/*
 	 * Tell all users of get_user/copy_from_user etc... that the content
 	 * is no longer stable. No barriers really needed because unmapping
 	 * should imply barriers already and the reader would hit a page fault
@@ -537,13 +527,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
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
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
