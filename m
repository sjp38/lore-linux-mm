Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6216B0038
	for <linux-mm@kvack.org>; Sat,  3 Sep 2016 21:49:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id c184so77731239oia.1
        for <linux-mm@kvack.org>; Sat, 03 Sep 2016 18:49:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 91si1809083otx.234.2016.09.03.18.49.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 03 Sep 2016 18:49:49 -0700 (PDT)
Subject: Re: [RFC 1/4] mm, oom: do not rely on TIF_MEMDIE for memory reserves access
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
	<1472723464-22866-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472723464-22866-2-git-send-email-mhocko@kernel.org>
Message-Id: <201609041049.GIF51522.FOHLOJVSFOFMtQ@I-love.SAKURA.ne.jp>
Date: Sun, 4 Sep 2016 10:49:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> @@ -816,7 +816,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
> -	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> +	 * its children or threads, just give it access to memory reserves
> +	 * so it can die quickly
>  	 */
>  	task_lock(p);
>  	if (task_will_free_mem(p)) {
> @@ -876,9 +877,9 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	mm = victim->mm;
>  	atomic_inc(&mm->mm_count);
>  	/*
> -	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
> -	 * the OOM victim from depleting the memory reserves from the user
> -	 * space under its control.
> +	 * We should send SIGKILL before granting access to memory reserves
> +	 * in order to prevent the OOM victim from depleting the memory
> +	 * reserves from the user space under its control.
>  	 */

Removing TIF_MEMDIE usage inside comments can be done as a clean up
before this series.



> @@ -3309,6 +3318,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	return alloc_flags;
>  }
>  
> +static bool oom_reserves_allowed(struct task_struct *tsk)
> +{
> +	if (!tsk_is_oom_victim(tsk))
> +		return false;
> +
> +	/*
> +	 * !MMU doesn't have oom reaper so we shouldn't risk the memory reserves
> +	 * depletion and shouldn't give access to memory reserves passed the
> +	 * exit_mm
> +	 */
> +	if (!IS_ENABLED(CONFIG_MMU) && !tsk->mm)
> +		return false;
> +
> +	return true;
> +}
> +

Are you aware that you are trying to make !MMU kernel's allocations not only
after returning exit_mm() but also from __mmput() from mmput() from exit_mm()
fail without allowing access to memory reserves? The comment says only after
returning exit_mm(), but this change is not.



> @@ -3558,8 +3593,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto nopage;
>  	}
>  
> -	/* Avoid allocations with no watermarks from looping endlessly */
> -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> +	/* Avoid allocations for oom victims from looping endlessly */
> +	if (tsk_is_oom_victim(current) && !(gfp_mask & __GFP_NOFAIL))
>  		goto nopage;

This change increases possibility of giving up without trying ALLOC_OOM
(more allocation failure messages), for currently only one thread which
remotely got TIF_MEMDIE when it was between gfp_to_alloc_flags() and
test_thread_flag(TIF_MEMDIE) will give up without trying ALLOC_NO_WATERMARKS
while all threads which remotely got current->signal->oom_mm when they were
between gfp_to_alloc_flags() and test_thread_flag(TIF_MEMDIE) will give up
without trying ALLOC_OOM. I think we should make sure that ALLOC_OOM is
tried (by using a variable which remembers whether
get_page_from_freelist(ALLOC_OOM) was tried).

We are currently allowing TIF_MEMDIE threads try ALLOC_NO_WATERMARKS for
once and give up without invoking the OOM killer. This change makes
current->signal->oom_mm threads try ALLOC_OOM for once and give up without
invoking the OOM killer. This means that allocations for cleanly cleaning
up by oom victims might fail prematurely, but we don't want to scatter
around __GFP_NOFAIL. Since there are reasonable chances of the parallel
memory freeing, we don't need to give up without invoking the OOM killer
again. I think that

-	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+#ifndef CONFIG_MMU
+	/* Avoid allocations for oom victims from looping endlessly */
+	if (tsk_is_oom_victim(current) && !(gfp_mask & __GFP_NOFAIL))
+		goto nopage;
+#endif

is possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
