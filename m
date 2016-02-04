Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id F3C354403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 01:46:39 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p63so102576541wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:46:39 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id c5si15691800wjf.227.2016.02.03.22.46.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 22:46:38 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id 128so10700383wmz.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:46:38 -0800 (PST)
Date: Thu, 4 Feb 2016 07:46:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/5] mm, oom_reaper: report success/failure
Message-ID: <20160204064636.GD8581@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-5-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1602031505210.10331@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602031505210.10331@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 03-02-16 15:10:57, David Rientjes wrote:
> On Wed, 3 Feb 2016, Michal Hocko wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 8e345126d73e..b87acdca2a41 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -420,6 +420,7 @@ static struct task_struct *oom_reaper_th;
> >  static struct task_struct *task_to_reap;
> >  static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
> >  
> > +#define K(x) ((x) << (PAGE_SHIFT-10))
> >  static bool __oom_reap_task(struct task_struct *tsk)
> >  {
> >  	struct mmu_gather tlb;
> > @@ -476,6 +477,11 @@ static bool __oom_reap_task(struct task_struct *tsk)
> >  		}
> >  	}
> >  	tlb_finish_mmu(&tlb, 0, -1);
> > +	pr_info("oom_reaper: reaped process :%d (%s) anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lulB\n",
> > +			task_pid_nr(tsk), tsk->comm,
> > +			K(get_mm_counter(mm, MM_ANONPAGES)),
> > +			K(get_mm_counter(mm, MM_FILEPAGES)),
> > +			K(get_mm_counter(mm, MM_SHMEMPAGES)));
> >  	up_read(&mm->mmap_sem);
> >  
> >  	/*
> 
> This is a bit misleading, it would appear that the rss values are what was 
> reaped when in fact they represent just the values of the mm being reaped.  
> We have already printed these values as an artifact in the kernel log.

Yes and the idea was to provide the after state to compare before and
after. That's why I have kept the similar format. Just dropped the
virtual memory size because that doesn't make any sense in this context
now.

> I think it would be helpful to show anon-rss after reaping, however, so we 
> can compare to the previous anon-rss that was reported.  And, I agree that 
> leaving behind a message in the kernel log that reaping has been 
> successful is worthwhile.  So this line should just show what anon-rss is 
> after reaping and make it clear that this is not the memory reaped.

Does
"oom_reaper: reaped process %d (%s) current memory anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB "

sound any better?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
