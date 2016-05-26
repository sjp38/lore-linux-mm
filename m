Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C95F66B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 10:59:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f75so47388006wmf.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 07:59:32 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id z7si5269367wmz.39.2016.05.26.07.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 07:59:31 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id e3so6228541wme.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 07:59:31 -0700 (PDT)
Date: Thu, 26 May 2016 16:59:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm, oom: do not loop over all tasks if there are no
 external tasks sharing mm
Message-ID: <20160526145930.GF23675@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-2-git-send-email-mhocko@kernel.org>
 <201605262330.EEB52182.OtMFOJHFLOSFVQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605262330.EEB52182.OtMFOJHFLOSFVQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu 26-05-16 23:30:06, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 5bb2f7698ad7..0e33e912f7e4 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -820,6 +820,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  	task_unlock(victim);
> >  
> >  	/*
> > +	 * skip expensive iterations over all tasks if we know that there
> > +	 * are no users outside of threads in the same thread group
> > +	 */
> > +	if (atomic_read(&mm->mm_users) <= get_nr_threads(victim))
> > +		goto oom_reap;
> 
> Is this really safe? Isn't it possible that victim thread's thread group has
> more than atomic_read(&mm->mm_users) threads which are past exit_mm() and blocked
> at exit_task_work() which are before __exit_signal() from release_task() from
> exit_notify()?

You are right. The race window between exit_mm and __exit_signal is
really large. I thought about == check instead but that wouldn't work
for the same reason, dang, it looked so promissing.

Scratch this patch then.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
