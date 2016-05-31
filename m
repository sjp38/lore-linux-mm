Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B88B6B025F
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:42:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n2so38836143wma.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:42:50 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e79si17311262wma.12.2016.05.31.00.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 00:42:49 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e3so29715513wme.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:42:48 -0700 (PDT)
Date: Tue, 31 May 2016 09:42:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
Message-ID: <20160531074247.GC26128@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-5-git-send-email-mhocko@kernel.org>
 <20160530192856.GA25696@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160530192856.GA25696@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 30-05-16 21:28:57, Oleg Nesterov wrote:
> On 05/30, Michal Hocko wrote:
> >
> > Make sure to not select vforked task as an oom victim by checking
> > vfork_done in oom_badness.
> 
> I agree, this look like a good change to me... But.
> 
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -176,11 +176,13 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> >  
> >  	/*
> >  	 * Do not even consider tasks which are explicitly marked oom
> > -	 * unkillable or have been already oom reaped.
> > +	 * unkillable or have been already oom reaped or the are in
> > +	 * the middle of vfork
> >  	 */
> >  	adj = (long)p->signal->oom_score_adj;
> >  	if (adj == OOM_SCORE_ADJ_MIN ||
> > -			test_bit(MMF_OOM_REAPED, &p->mm->flags)) {
> > +			test_bit(MMF_OOM_REAPED, &p->mm->flags) ||
> > +			p->vfork_done) {
> 
> I don't think we can trust vfork_done != NULL.
> 
> copy_process() doesn't disallow CLONE_VFORK without CLONE_VM, so with this patch
> it would be trivial to make the exploit which hides a memory hog from oom-killer.

OK, I wasn't aware of this possibility. It sounds really weird because I
thought that the whole point of vfork is to prevent from MM copy
overhead for quick exec.

> So perhaps we need something like
> 
> 		bool in_vfork(p)
> 		{
> 			return	p->vfork_done &&
> 				p->real_parent->mm == mm;
> 
> 			
> 		}
> 
> task_lock() is not enough if CLONE_VM was used along with CLONE_PARENT... so this
> also needs rcu_read_lock() to access ->real_parent.
> 
> Or I am totally confused?

I cannot judge I am afraid. You are definitely much more familiar with
all these subtle details than me.

So what do you think about this follow up:
---
