Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC976B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 18:12:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c12so30896317pfk.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:12:58 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id g2si12879121plk.487.2017.06.20.15.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 15:12:57 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id s66so75530643pfs.1
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:12:57 -0700 (PDT)
Date: Tue, 20 Jun 2017 15:12:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom_kill: Close race window of needlessly selecting
 new victims.
In-Reply-To: <201706171417.JHG48401.JOQLHMFSVOOFtF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1706201509170.109574@chino.kir.corp.google.com>
References: <20170615103909.GG1486@dhcp22.suse.cz> <alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com> <20170615214133.GB20321@dhcp22.suse.cz> <201706162122.ACE95321.tOFLOOVFFHMSJQ@I-love.SAKURA.ne.jp> <20170616141255.GN30580@dhcp22.suse.cz>
 <201706171417.JHG48401.JOQLHMFSVOOFtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 17 Jun 2017, Tetsuo Handa wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 04c9143..cf1d331 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -470,38 +470,9 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  {
>  	struct mmu_gather tlb;
>  	struct vm_area_struct *vma;
> -	bool ret = true;
> -
> -	/*
> -	 * We have to make sure to not race with the victim exit path
> -	 * and cause premature new oom victim selection:
> -	 * __oom_reap_task_mm		exit_mm
> -	 *   mmget_not_zero
> -	 *				  mmput
> -	 *				    atomic_dec_and_test
> -	 *				  exit_oom_victim
> -	 *				[...]
> -	 *				out_of_memory
> -	 *				  select_bad_process
> -	 *				    # no TIF_MEMDIE task selects new victim
> -	 *  unmap_page_range # frees some memory
> -	 */
> -	mutex_lock(&oom_lock);
> -
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> -		ret = false;
> -		goto unlock_oom;
> -	}
>  
> -	/*
> -	 * increase mm_users only after we know we will reap something so
> -	 * that the mmput_async is called only when we have reaped something
> -	 * and delayed __mmput doesn't matter that much
> -	 */
> -	if (!mmget_not_zero(mm)) {
> -		up_read(&mm->mmap_sem);
> -		goto unlock_oom;
> -	}
> +	if (!down_read_trylock(&mm->mmap_sem))
> +		return false;
>  
>  	/*
>  	 * Tell all users of get_user/copy_from_user etc... that the content
> @@ -537,16 +508,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  			K(get_mm_counter(mm, MM_FILEPAGES)),
>  			K(get_mm_counter(mm, MM_SHMEMPAGES)));
>  	up_read(&mm->mmap_sem);
> -
> -	/*
> -	 * Drop our reference but make sure the mmput slow path is called from a
> -	 * different context because we shouldn't risk we get stuck there and
> -	 * put the oom_reaper out of the way.
> -	 */
> -	mmput_async(mm);
> -unlock_oom:
> -	mutex_unlock(&oom_lock);
> -	return ret;
> +	return true;
>  }
>  
>  #define MAX_OOM_REAP_RETRIES 10
> @@ -569,12 +531,31 @@ static void oom_reap_task(struct task_struct *tsk)
>  
>  done:
>  	tsk->oom_reaper_list = NULL;
> +	/*
> +	 * Drop a mm_users reference taken by mark_oom_victim().
> +	 * A mm_count reference taken by mark_oom_victim() remains.
> +	 */
> +	mmput_async(mm);

This doesn't prevent serial oom killing for either the system oom killer 
or for the memcg oom killer.

The oom killer cannot detect tsk_is_oom_victim() if the task has either 
been removed from the tasklist or has already done cgroup_exit().  For 
memcg oom killings in particular, cgroup_exit() is usually called very 
shortly after the oom killer has sent the SIGKILL.  If the oom reaper does 
not fail (for example by failing to grab mm->mmap_sem) before another 
memcg charge after cgroup_exit(victim), additional processes are killed 
because the iteration does not view the victim.

This easily kills all processes attached to the memcg with no memory 
freeing from any victim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
