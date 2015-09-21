Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 153796B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 19:27:34 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so129496058pad.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:27:33 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id hp8si41192966pac.226.2015.09.21.16.27.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 16:27:33 -0700 (PDT)
Received: by padbj2 with SMTP id bj2so4540191pad.3
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:27:33 -0700 (PDT)
Date: Mon, 21 Sep 2015 16:27:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
In-Reply-To: <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
Message-ID: <alpine.DEB.2.10.1509211620180.27715@chino.kir.corp.google.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150917192204.GA2728@redhat.com> <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org> <20150918162423.GA18136@redhat.com> <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Stanislav Kozina <skozina@redhat.com>

On Fri, 18 Sep 2015, Christoph Lameter wrote:

> Subject: Allow multiple kills from the OOM killer
> 
> The OOM killer currently aborts if it finds a process that already is having
> access to the reserve memory pool for exit processing. This is done so that
> the reserves are not overcommitted but on the other hand this also allows
> only one process being oom killed at the time. That process may be stuck
> in D state.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/oom_kill.c
> ===================================================================
> --- linux.orig/mm/oom_kill.c	2015-09-18 11:58:52.963946782 -0500
> +++ linux/mm/oom_kill.c	2015-09-18 11:59:42.010684778 -0500
> @@ -264,10 +264,9 @@ enum oom_scan_t oom_scan_process_thread(
>  	 * This task already has access to memory reserves and is being killed.
>  	 * Don't allow any other task to have access to the reserves.
>  	 */
> -	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> -		if (oc->order != -1)
> -			return OOM_SCAN_ABORT;
> -	}
> +	if (test_tsk_thread_flag(task, TIF_MEMDIE))
> +		return OOM_SCAN_CONTINUE;
> +
>  	if (!task->mm)
>  		return OOM_SCAN_CONTINUE;
> 

If this would result in the newly chosen process being guaranteed to exit, 
this would be fine.  Unfortunately, no such guarantee is possible.  If a 
thread is holding a contended mutex that the victim(s) require, this 
serial oom killer could eventually panic the system if that thread is 
OOM_DISABLE.

The solution that we have merged internally is described at 
http://marc.info/?l=linux-kernel&m=144010444913702 -- we provide access to 
memory reserves to processes that find a stalled exit in the oom killer so 
that they may allocate.  It comes along with a test module that takes a 
contended mutex and ensures that forward progress is made as long as 
memory reserves are not depleted.  We can't actually guarantee that memory 
reserves won't be depleted, but we (1) hope that nobody is actually 
allocating a lot of memory before dropping a mutex and (2) want to avoid 
the alternative which is a system livelock.

This will address situations such as

	allocator			oom victim
	---------			----------
	mutex_lock(lock)
	alloc_pages(GFP_KERNEL)
					mutex_lock(lock)
					mutex_unlock(lock)
					handle SIGKILL

since this otherwise results in a livelock without a solution such as 
mine since the GFP_KERNEL allocation stalls forever waiting for the oom 
victim to acquire the mutex and exit.  This also works if the allocator is 
OOM_DISABLE.

This won't handle other situations where the victim gets wedged in D state 
and is not allocating memory, but this is by far the more common 
occurrence that we have dealt with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
