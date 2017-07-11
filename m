Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 831DB6B04C5
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 16:40:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y62so3452751pfa.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 13:40:07 -0700 (PDT)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id m11si237677pfa.98.2017.07.11.13.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 13:40:06 -0700 (PDT)
Received: by mail-pg0-x22c.google.com with SMTP id t186so1705555pgb.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 13:40:06 -0700 (PDT)
Date: Tue, 11 Jul 2017 13:40:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
In-Reply-To: <20170711065834.GF24852@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1707111336250.60183@chino.kir.corp.google.com>
References: <20170626130346.26314-1-mhocko@kernel.org> <alpine.DEB.2.10.1707101652260.54972@chino.kir.corp.google.com> <20170711065834.GF24852@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Jul 2017, Michal Hocko wrote:

> This?
> ---
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5dc0ff22d567..e155d1d8064f 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -470,11 +470,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  {
>  	struct mmu_gather tlb;
>  	struct vm_area_struct *vma;
> -	bool ret = true;
>  
>  	if (!down_read_trylock(&mm->mmap_sem))
>  		return false;
>  
> +	/* There is nothing to reap so bail out without signs in the log */
> +	if (!mm->mmap)
> +		goto unlock;
> +
>  	/*
>  	 * Tell all users of get_user/copy_from_user etc... that the content
>  	 * is no longer stable. No barriers really needed because unmapping
> @@ -508,9 +511,10 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  			K(get_mm_counter(mm, MM_ANONPAGES)),
>  			K(get_mm_counter(mm, MM_FILEPAGES)),
>  			K(get_mm_counter(mm, MM_SHMEMPAGES)));
> +unlock:
>  	up_read(&mm->mmap_sem);
>  
> -	return ret;
> +	return true;
>  }
>  
>  #define MAX_OOM_REAP_RETRIES 10

Yes, this folded in with the original RFC patch appears to work better 
with light testing.

However, I think MAX_OOM_REAP_RETRIES and/or the timeout of HZ/10 needs to 
be increased as well to address the issue that Tetsuo pointed out.  The 
oom reaper shouldn't be required to do any work unless it is resolving a 
livelock, and that scenario should be relatively rare.  The oom killer 
being a natural ultra slow path, I think it would be justifiable to wait 
longer or retry more times than simply 1 second before declaring that 
reaping is not possible.  It reduces the likelihood of additional oom 
killing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
