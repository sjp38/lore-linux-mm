Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5996C6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 10:20:49 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so84384674wma.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 07:20:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bv17si67020602wjb.0.2017.01.04.07.20.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 07:20:47 -0800 (PST)
Date: Wed, 4 Jan 2017 16:20:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3 -v3] GFP_NOFAIL cleanups
Message-ID: <20170104152043.GQ25453@dhcp22.suse.cz>
References: <20170102154858.GC18048@dhcp22.suse.cz>
 <201701031036.IBE51044.QFLFSOHtFOJVMO@I-love.SAKURA.ne.jp>
 <20170103084211.GB30111@dhcp22.suse.cz>
 <201701032338.EFH69294.VOMSHFLOFOtQFJ@I-love.SAKURA.ne.jp>
 <20170103204014.GA13873@dhcp22.suse.cz>
 <201701042322.EEG05759.FOMOVLSFJFHOQt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701042322.EEG05759.FOMOVLSFJFHOQt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 04-01-17 23:22:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 03-01-17 23:38:30, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Tue 03-01-17 10:36:31, Tetsuo Handa wrote:
> > > > [...]
> > > > > I'm OK with "[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator
> > > > > slowpath" given that we describe that we make __GFP_NOFAIL stronger than
> > > > > __GFP_NORETRY with this patch in the changelog.
> > > > 
> > > > Again. __GFP_NORETRY | __GFP_NOFAIL is nonsense! I do not really see any
> > > > reason to describe all the nonsense combinations of gfp flags.
> > > 
> > > Before [PATCH 1/3]:
> > > 
> > >   __GFP_NORETRY is used as "Do not invoke the OOM killer. Fail allocation
> > >   request even if __GFP_NOFAIL is specified if direct reclaim/compaction
> > >   did not help."
> > > 
> > >   __GFP_NOFAIL is used as "Never fail allocation request unless __GFP_NORETRY
> > >   is specified even if direct reclaim/compaction did not help."
> > > 
> > > After [PATCH 1/3]:
> > > 
> > >   __GFP_NORETRY is used as "Do not invoke the OOM killer. Fail allocation
> > >   request unless __GFP_NOFAIL is specified."
> > > 
> > >   __GFP_NOFAIL is used as "Never fail allocation request even if direct
> > >   reclaim/compaction did not help. Invoke the OOM killer unless __GFP_NORETRY is
> > >   specified."
> > > 
> > > Thus, __GFP_NORETRY | __GFP_NOFAIL perfectly makes sense as
> > > "Never fail allocation request if direct reclaim/compaction did not help.
> > > But do not invoke the OOM killer even if direct reclaim/compaction did not help."
> > 
> > Stop this! Seriously... This is just wasting time...
> 
> You are free to ignore me. But

my last reply in this subthread

> >  * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
> >  *   return NULL when direct reclaim and memory compaction have failed to allow
> >  *   the allocation to succeed.  The OOM killer is not called with the current
> >  *   implementation.
> > 
> >  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
> >  *   cannot handle allocation failures. New users should be evaluated carefully
> >  *   (and the flag should be used only when there is no reasonable failure
> >  *   policy) but it is definitely preferable to use the flag rather than
> >  *   opencode endless loop around allocator.
> > 
> > Can you see how the two are asking for opposite behavior?  Asking for
> > not retrying for ever and not failing and rather retrying for ever
> > simply doesn't make any sense in any reasonable universe I can think
> > of. Therefore I think that it is fair to say that behavior is undefined
> > when both are specified.
> 
> I consider that I'm using __GFP_NORETRY as a mean to avoid calling the OOM
> killer rather than avoid retrying indefinitely. Therefore, I want

This would be an abuse. Not invoking the oom killer is an implementation
detail and can change in the future. This is documented.

>   __GFP_NOOOMKILL: The VM implementation must not call the OOM killer when
>   direct reclaim and memory compaction have failed to allow the allocation
>   to succeed.

I am not going to give such a flag to users. The longer I am looking
into how those flags are used the more I am convinced that they are very
often wrong when trying to be too clever. Decision whether to trigger
OOM killer or not is the MM internal thing and _no code_ outside the MM
proper has any word into it.
 
> and __GFP_NOOOMKILL | __GFP_NOFAIL makes sense.

and this example just shows why I think that my cautiousness is
justified...

> Technically PATCH 1/3 allows __GFP_NOOOMKILL | __GFP_NOFAIL emulation
> via __GFP_NOFAIL | __GFP_NOFAIL. If you don't like such emulation,
> I welcome __GFP_NOOOMKILL.
> 
> > 
> > Considering there are _no_ users which would do that any further
> > discussion about this is just pointless and I will not respond to any
> > further emails in this direction.
> > 
> > This is just ridiculous!
> 
> Regardless of whether we define __GFP_NOOOMKILL, I wonder we need PATCH 2/3 now
> because currently premature OOM killer invocation due to !__GFP_FS && __GFP_NOFAIL
> is a prophetical problem. We can consider PATCH 2/3 (or __GFP_NOOOMKILL) when
> someone reported OOM killer invocation via !__GFP_FS && __GFP_NOFAIL and
> confirmed that the memory counter says premature enough to suppress the OOM
> killer invocation.

Again. GFP_NOFS should behave consistently regardless GFP_NOFAIL. The
mere fact that the opencoded endless loop around GFP_NOFS behaves
differently is something to raise a red flag. I want to fix that. So no,
I really do not want to keep the status quo.

[...]
> > > I'm unable to obtain nice backtraces, but I think we can confirm that
> > > there are GFP_ATOMIC allocations (e.g. sg_alloc_table_chained() calls
> > > __sg_alloc_table(GFP_ATOMIC)) when we are using SCSI disks.
> > 
> > How are those blocking further progress? Failing atomic allocations are
> > nothing to lose sleep over. They cannot be, pretty by definition, relied
> > on to make a further progress.
> 
> So, regarding simple SCSI disk case, it is guaranteed that disk I/O request
> can recover from transient failures (e.g. timeout?) and complete unless
> fatal failures (e.g. hardware out of order?) occur, isn't it? Then,
> PATCH 3/3 would be helpful for this case.
> 
> What about other cases, such as loopback devices ( /dev/loopX ) and/or
> networking storage? Are they also guaranteed that I/O requests never be
> blocked on memory allocation requests which are not allowed to access
> memory reserves? If yes, PATCH 3/3 would be helpful. If no, I think
> what we need is a mechanism to propagate allowing access to memory
> reserves similar to scope GFP_NOFS API.

Again, which cannot recover from GFP_ATOMIC requests is broken by
definition.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
