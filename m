Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E98C6B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 09:14:16 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 101so109171428qtb.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 06:14:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p31si12140775qtb.49.2016.07.29.06.14.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 06:14:15 -0700 (PDT)
Date: Fri, 29 Jul 2016 16:14:10 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160729161039-mutt-send-email-mst@kernel.org>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160729060422.GA5504@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Fri, Jul 29, 2016 at 08:04:22AM +0200, Michal Hocko wrote:
> On Thu 28-07-16 23:41:53, Michael S. Tsirkin wrote:
> > On Thu, Jul 28, 2016 at 09:42:33PM +0200, Michal Hocko wrote:
> [...]
> > > diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> > > index 349557825428..a327d5362581 100644
> > > --- a/include/linux/uaccess.h
> > > +++ b/include/linux/uaccess.h
> > > @@ -76,6 +76,28 @@ static inline unsigned long __copy_from_user_nocache(void *to,
> > >  #endif		/* ARCH_HAS_NOCACHE_UACCESS */
> > >  
> > >  /*
> > > + * A safe variant of __get_user for for use_mm() users to have a
> > 
> > for for -> for?
> 
> fixed
> 
> > 
> > > + * gurantee that the address space wasn't reaped in the background
> > > + */
> > > +#define __get_user_mm(mm, x, ptr)				\
> > > +({								\
> > > +	int ___gu_err = __get_user(x, ptr);			\
> > 
> > I suspect you need smp_rmb() here to make sure it test does not
> > bypass the memory read.
> > 
> > You will accordingly need smp_wmb() when you set the flag,
> > maybe it's there already - I have not checked.
> 
> As the comment for setting the flag explains the memory barriers
> shouldn't be really needed AFAIU. More on that below.
> 
> [...]
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index ca1cc24ba720..6ccf63fbfc72 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -488,6 +488,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
> > >  		goto unlock_oom;
> > >  	}
> > >  
> > > +	/*
> > > +	 * Tell all users of get_user_mm/copy_from_user_mm that the content
> > > +	 * is no longer stable. No barriers really needed because unmapping
> > > +	 * should imply barriers already
> > 
> > ok
> > 
> > > and the reader would hit a page fault
> > > +	 * if it stumbled over a reaped memory.
> > 
> > This last point I don't get. flag read could bypass data read
> > if that happens data read could happen after unmap
> > yes it might get a PF but you handle that, correct?
> 
> The point I've tried to make is that if the reader really page faults
> then get_user will imply the full barrier already. If get_user didn't
> page fault then the state of the flag is not really important because
> the reaper shouldn't have touched it. Does it make more sense now or
> I've missed your question?

Can task flag read happen before the get_user pagefault?
If it does, task flag could not be set even though
page fault triggered.

> > 
> > > +	 */
> > > +	set_bit(MMF_UNSTABLE, &mm->flags);
> > > +
> > 
> > I would really prefer a callback that vhost would register
> > and stop all accesses. Tell me if you need help on above idea.
> 
> 
> Well, in order to make callback workable the oom reaper would have to
> synchronize with the said callback until it declares all currently
> ongoing accesses done. That means oom reaper would have to block/wait
> and that is something I would really like to prevent from because it
> just adds another possibility of the lockup (say the get_user cannot
> make forward progress because it is stuck in the page fault allocating
> memory). Or do you see any other way how to implement such a callback
> mechanism without blocking on the oom_reaper side?

I'll think it over and respond.

> 
> > But with the above nits addressed,
> > I think this would be acceptable as well.
> 
> Thank you for your review and feedback!
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
