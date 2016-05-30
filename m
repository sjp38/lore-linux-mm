Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D9E0A6B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 02:43:05 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o70so86104665lfg.1
        for <linux-mm@kvack.org>; Sun, 29 May 2016 23:43:05 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v132si29104424wme.82.2016.05.29.23.43.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 May 2016 23:43:04 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a136so19488921wme.0
        for <linux-mm@kvack.org>; Sun, 29 May 2016 23:43:04 -0700 (PDT)
Date: Mon, 30 May 2016 08:43:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_reaper: don't call mmput_async() on uninitialized mm
Message-ID: <20160530064302.GA22928@dhcp22.suse.cz>
References: <1464336081-994232-1-git-send-email-arnd@arndb.de>
 <20160527081059.GE27686@dhcp22.suse.cz>
 <20160527125534.b8be57b284599f5424512d09@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527125534.b8be57b284599f5424512d09@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 12:55:34, Andrew Morton wrote:
> On Fri, 27 May 2016 10:10:59 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 27-05-16 10:00:48, Arnd Bergmann wrote:
> > > The change to the oom_reaper to hold a mutex inside __oom_reap_task()
> > > accidentally started calling mmput_async() on the local
> > > mm before that variable got initialized, as reported by gcc
> > > in linux-next:
> > > 
> > > mm/oom_kill.c: In function '__oom_reap_task':
> > > mm/oom_kill.c:537:2: error: 'mm' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > > 
> > > This rearranges the code slightly back to the state before patch
> > > but leaves the lock in place. The error handling in the function
> > > still looks a bit confusing and could probably be improved
> > > but I could not come up with a solution that made me happy
> > > for now.
> > > 
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > > Fixes: mmotm ("oom_reaper: close race with exiting task")
> > 
> > Thanks for catching that Arnd?
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> I think I preferred my version - all those unwinding return statements
> can cause problems..

looks good to me as well.

Thanks!

> --- a/mm/oom_kill.c~oom_reaper-close-race-with-exiting-task-fix
> +++ a/mm/oom_kill.c
> @@ -443,7 +443,7 @@ static bool __oom_reap_task(struct task_
>  {
>  	struct mmu_gather tlb;
>  	struct vm_area_struct *vma;
> -	struct mm_struct *mm;
> +	struct mm_struct *mm = NULL;
>  	struct task_struct *p;
>  	struct zap_details details = {.check_swap_entries = true,
>  				      .ignore_dirty = true};
> @@ -534,7 +534,8 @@ unlock_oom:
>  	 * different context because we shouldn't risk we get stuck there and
>  	 * put the oom_reaper out of the way.
>  	 */
> -	mmput_async(mm);
> +	if (mm)
> +		mmput_async(mm);
>  	return ret;
>  }
>  
> _

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
