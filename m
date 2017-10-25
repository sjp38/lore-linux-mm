Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71D6F6B0253
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:34:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b192so336476pga.14
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 09:34:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c11si896925pll.252.2017.10.25.09.34.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 09:34:28 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171025110955.jsc4lqjbg6ww5va6@dhcp22.suse.cz>
	<201710252115.JII86453.tFFSLHQOOOVMJF@I-love.SAKURA.ne.jp>
	<20171025124147.bvd4huwtykf6icmb@dhcp22.suse.cz>
	<201710252358.IIA46427.HFFSOOOQLtFMJV@I-love.SAKURA.ne.jp>
	<20171025150548.nvuwc3y3m5vi23uk@dhcp22.suse.cz>
In-Reply-To: <20171025150548.nvuwc3y3m5vi23uk@dhcp22.suse.cz>
Message-Id: <201710260034.GAB81218.FLJQVFOHtSOOMF@I-love.SAKURA.ne.jp>
Date: Thu, 26 Oct 2017 00:34:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: hannes@cmpxchg.org, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> On Wed 25-10-17 23:58:33, Tetsuo Handa wrote:
> > I thought something like
> > 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3872,6 +3872,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> >         unsigned int stall_timeout = 10 * HZ;
> >         unsigned int cpuset_mems_cookie;
> >         int reserve_flags;
> > +       static DEFINE_MUTEX(warn_lock);
> > 
> >         /*
> >          * In the slowpath, we sanity check order to avoid ever trying to
> > @@ -4002,11 +4003,15 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> >                 goto nopage;
> > 
> >         /* Make sure we know about allocations which stall for too long */
> > -       if (time_after(jiffies, alloc_start + stall_timeout)) {
> > -               warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
> > -                       "page allocation stalls for %ums, order:%u",
> > -                       jiffies_to_msecs(jiffies-alloc_start), order);
> > -               stall_timeout += 10 * HZ;
> > +       if (time_after(jiffies, alloc_start + stall_timeout) &&
> > +           mutex_trylock(&warn_lock)) {
> > +               if (!mutex_is_locked(&oom_lock)) {
> 
> The check for oom_lock just doesn't make any sense. The lock can be take
> at any time after the check.

The check for oom_lock is optimistic. If we go pessimistic, we will
need to use oom_printk_lock, but you don't like oom_printk_lock, do you?
Anyway, let's remove warn_alloc().

> 
> > +                       warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
> > +                                  "page allocation stalls for %ums, order:%u",
> > +                                  jiffies_to_msecs(jiffies-alloc_start), order);
> > +                       stall_timeout += 10 * HZ;
> > +               }
> > +               mutex_unlock(&warn_lock);
> >         }
> > 
> >         /* Avoid recursion of direct reclaim */
> > 
> > for isolating the OOM killer messages and the stall warning messages (in order to
> > break continuation condition in console_unlock()), and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
