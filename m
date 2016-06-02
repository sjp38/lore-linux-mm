Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB2A6B0005
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 11:50:48 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ne4so25992654lbc.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:50:48 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t202si50876027wmt.7.2016.06.02.08.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 08:50:47 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a136so16986789wme.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:50:46 -0700 (PDT)
Date: Thu, 2 Jun 2016 17:50:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/6] mm, oom: task_will_free_mem should skip oom_reaped
 tasks
Message-ID: <20160602155045.GV1995@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464876183-15559-1-git-send-email-mhocko@kernel.org>
 <201606030024.BIJ82362.MFOVJFHQOOtSLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606030024.BIJ82362.MFOVJFHQOOtSLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Fri 03-06-16 00:24:31, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index dacfb6ab7b04..d6e121decb1a 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -766,6 +766,15 @@ bool task_will_free_mem(struct task_struct *task)
> >  		return true;
> >  	}
> >  
> > +	/*
> > +	 * This task has already been drained by the oom reaper so there are
> > +	 * only small chances it will free some more
> > +	 */
> > +	if (test_bit(MMF_OOM_REAPED, &mm->flags)) {
> > +		task_unlock(p);
> > +		return false;
> > +	}
> > +
> 
> I think this check should be done before
> 
> 	if (atomic_read(&mm->mm_users) <= 1) {
> 		task_unlock(p);
> 		return true;
> 	}
> 
> because it is possible that task_will_free_mem(task) is the only thread
> using task->mm (i.e. atomic_read(&mm->mm_users) == 1).

definitely true. I am growing blind for this code.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
