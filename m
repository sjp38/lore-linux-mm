Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3AD46B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 09:49:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u138so34354533wmu.2
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 06:49:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m41si10189327wrf.516.2017.10.10.06.49.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 06:49:17 -0700 (PDT)
Date: Tue, 10 Oct 2017 15:49:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmalloc: back off only when the current task is OOM
 killed
Message-ID: <20171010134916.x5iskqymwjj6akpo@dhcp22.suse.cz>
References: <1507633133-5720-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171010115436.nzgo4ewodx5pyrw7@dhcp22.suse.cz>
 <201710102147.IGJ90612.OQSFMFLVtOOJFH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710102147.IGJ90612.OQSFMFLVtOOJFH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, alan@llwyncelyn.cymru, hch@lst.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 10-10-17 21:47:02, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 10-10-17 19:58:53, Tetsuo Handa wrote:
> > > Commit 5d17a73a2ebeb8d1 ("vmalloc: back off when the current task is
> > > killed") revealed two bugs [1] [2] that were not ready to fail vmalloc()
> > > upon SIGKILL. But since the intent of that commit was to avoid unlimited
> > > access to memory reserves, we should have checked tsk_is_oom_victim()
> > > rather than fatal_signal_pending().
> > > 
> > > Note that even with commit cd04ae1e2dc8e365 ("mm, oom: do not rely on
> > > TIF_MEMDIE for memory reserves access"), it is possible to trigger
> > > "complete depletion of memory reserves"
> > 
> > How would that be possible? OOM victims are not allowed to consume whole
> > reserves and the vmalloc context would have to do something utterly
> > wrong like PF_MEMALLOC to make this happen. Protecting from such a code
> > is simply pointless.
> 
> Oops. I was confused when writing that part.
> Indeed, "complete" was demonstrated without commit cd04ae1e2dc8e365.
> 
> > 
> > > and "extra OOM kills due to depletion of memory reserves"
> > 
> > and this is simply the case for the most vmalloc allocations because
> > they are not reflected in the oom selection so if there is a massive
> > vmalloc consumer it is very likely that we will kill a large part the
> > userspace before hitting the user context on behalf which the vmalloc
> > allocation is performed.
> 
> If there is a massive alloc_page() loop it is as well very likely that
> we will kill a large part the userspace before hitting the user context
> on behalf which the alloc_page() allocation is performed.

exactly!

> I think that massive vmalloc() consumers should be (as well as massive
> alloc_page() consumers) careful such that they will be chosen as first OOM
> victim, for vmalloc() does not abort as soon as an OOM occurs.

No. This would require to spread those checks all over the place. That
is why we have that logic inside the allocator which fails the
allocation at certain point in time. Large/unbound/user controlled sized
allocations from the kernel are always a bug and really hard one to
protect from. It is simply impossible to know the intention.

> Thus, I used
> set_current_oom_origin()/clear_current_oom_origin() when I demonstrated
> "complete" depletion.

which was a completely artificial example as already mentioned.

> > I have tried to explain this is not really needed before but you keep
> > insisting which is highly annoying. The patch as is is not harmful but
> > it is simply _pointless_ IMHO.
> 
> Then, how can massive vmalloc() consumers become careful?
> Explicitly use __vmalloc() and pass __GFP_NOMEMALLOC ?
> Then, what about adding some comment like "Never try to allocate large
> memory using plain vmalloc(). Use __vmalloc() with __GFP_NOMEMALLOC." ?

Come on! Seriously we do expect some competence from the code running in
the kernel space. We do not really need to add a comment that you
shouldn't shoot your head because it might hurt. Please try to focus on
real issues. There are many of them to chase after...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
