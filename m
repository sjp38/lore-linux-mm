Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C37616B02FD
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:32:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c184so17729746wmd.6
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 23:32:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e12si6320681wrd.321.2017.07.26.23.32.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 23:32:07 -0700 (PDT)
Date: Thu, 27 Jul 2017 08:32:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170727063202.GA20970@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170725152639.GP29716@redhat.com>
 <20170725154514.GN26723@dhcp22.suse.cz>
 <20170725182619.GQ29716@redhat.com>
 <20170726054533.GA960@dhcp22.suse.cz>
 <20170726163928.GB29716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726163928.GB29716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 26-07-17 18:39:28, Andrea Arcangeli wrote:
> On Wed, Jul 26, 2017 at 07:45:33AM +0200, Michal Hocko wrote:
> > Yes, exit_aio is the only blocking call I know of currently. But I would
> > like this to be as robust as possible and so I do not want to rely on
> > the current implementation. This can change in future and I can
> > guarantee that nobody will think about the oom path when adding
> > something to the final __mmput path.
> 
> I think ksm_exit may block too waiting for allocations, the generic
> idea is those calls before exit_mmap can cause a problem yes.

I thought that ksm used __GFP_NORETRY but haven't checked too deeply.
Anyway I guess we agree that enabling oom_reaper to race with the final
__mmput is desirable?

[...]
> > This will work more or less the same to what we have currently.
> > 
> > [victim]		[oom reaper]				[oom killer]
> > do_exit			__oom_reap_task_mm
> >   mmput
> >     __mmput
> > 			  mmget_not_zero
> > 			    test_and_set_bit(MMF_OOM_SKIP)
> > 			    					oom_evaluate_task
> > 								   # select next victim 
> > 			  # reap the mm
> >       unmap_vmas
> >
> > so we can select a next victim while the current one is still not
> > completely torn down.
> 
> How does oom_evaluate_task possibly run at the same time of
> test_and_set_bit in __oom_reap_task_mm considering both are running
> under the oom_lock?

You are absolutely right. This race is impossible. It was just me
assuming we are going to get rid of the oom_lock because I have that
idea in the back of my head and I would really like to get rid of
it. Global locks are nasty and I would prefer dropping it if we can.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
