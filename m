Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 019DD6B0253
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 03:09:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a136so6587619wme.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 00:09:56 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id d8si4488970wju.41.2016.06.01.00.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 00:09:55 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n184so3329226wmn.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 00:09:55 -0700 (PDT)
Date: Wed, 1 Jun 2016 09:09:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
Message-ID: <20160601070954.GC26601@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-5-git-send-email-mhocko@kernel.org>
 <20160530192856.GA25696@redhat.com>
 <20160531074247.GC26128@dhcp22.suse.cz>
 <20160531214338.GB26582@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531214338.GB26582@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 31-05-16 23:43:38, Oleg Nesterov wrote:
> On 05/31, Michal Hocko wrote:
> >
> > On Mon 30-05-16 21:28:57, Oleg Nesterov wrote:
> > >
> > > I don't think we can trust vfork_done != NULL.
> > >
> > > copy_process() doesn't disallow CLONE_VFORK without CLONE_VM, so with this patch
> > > it would be trivial to make the exploit which hides a memory hog from oom-killer.
> >
> > OK, I wasn't aware of this possibility.
> 
> Neither was me ;) I noticed this during this review.

Heh, as I've said in other email, this is a land of dragons^Wsurprises.
 
> > > Or I am totally confused?
> >
> > I cannot judge I am afraid. You are definitely much more familiar with
> > all these subtle details than me.
> 
> OK, I just verified that clone(CLONE_VFORK|SIGCHLD) really works to be sure.

great, thanks

> > +/* expects to be called with task_lock held */
> > +static inline bool in_vfork(struct task_struct *tsk)
> > +{
> > +	bool ret;
> > +
> > +	/*
> > +	 * need RCU to access ->real_parent if CLONE_VM was used along with
> > +	 * CLONE_PARENT
> > +	 */
> > +	rcu_read_lock();
> > +	ret = tsk->vfork_done && tsk->real_parent->mm == tsk->mm;
> > +	rcu_read_unlock();
> > +
> > +	return ret;
> > +}
> 
> Yes, but may I ask to add a comment? And note that "expects to be called with
> task_lock held" looks misleading, we do not need the "stable" tsk->vfork_done
> since we only need to check if it is NULL or not.

OK, I thought it was needed for the stability but as you explain below
this is not really true...

> It would be nice to explain that
> 
> 	1. we check real_parent->mm == tsk->mm because CLONE_VFORK does not
> 	   imply CLONE_VM
> 
> 	2. CLONE_VFORK can be used with CLONE_PARENT/CLONE_THREAD and thus
> 	   ->real_parent is not necessarily the task doing vfork(), so in
> 	   theory we can't rely on task_lock() if we want to dereference it.
> 
> 	   And in this case we can't trust the real_parent->mm == tsk->mm
> 	   check, it can be false negative. But we do not care, if init or
> 	   another oom-unkillable task does this it should blame itself.

I've stolen this explanation and put it right there.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
