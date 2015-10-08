Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2BCAC6B0254
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 10:04:14 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so26805756wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 07:04:13 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id ea15si11824609wic.111.2015.10.08.07.04.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 07:04:12 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so30086849wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 07:04:12 -0700 (PDT)
Date: Thu, 8 Oct 2015 16:04:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20151008140411.GC426@dhcp22.suse.cz>
References: <20150921153252.GA21988@redhat.com>
 <20150921161203.GD19811@dhcp22.suse.cz>
 <20150922160608.GA2716@redhat.com>
 <20150923205923.GB19054@dhcp22.suse.cz>
 <20151006184502.GA15787@redhat.com>
 <201510072003.DCC69259.tJOOFOFFMLQSVH@I-love.SAKURA.ne.jp>
 <20151007120016.GB20428@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151007120016.GB20428@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Wed 07-10-15 14:00:16, Oleg Nesterov wrote:
> On 10/07, Tetsuo Handa wrote:
> >
> > Oleg Nesterov wrote:
> > > Anyway. Perhaps it makes sense to abort the for_each_vma() loop if
> > > freed_enough_mem() == T. But it is absolutely not clear to me how we
> > > should define this freed_enough_mem(), so I think we should do this
> > > later.
> >
> > Maybe
> >
> >   bool freed_enough_mem(void) { !atomic_read(&oom_victims); }
> >
> > if we change to call mark_oom_victim() on all threads which should be
> > killed as OOM victims.
> 
> Well, in this case
> 
> 	if (atomic_read(&mm->mm_users) == 1)
> 		break;
> 
> makes much more sense. Plus we do not need to change mark_oom_victim().
> 
> Lets discuss this later?

Yes I do not think this is that important if a kernel thread is going to
reclaim the address space. It will effectively free memory on behalf of
the victim so a longer scan shouldn't be such a big problem. At least
not for the first implementation.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
