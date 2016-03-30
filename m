Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 456ED6B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:47:08 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id zm5so39052088pac.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:47:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ey12si5980105pac.203.2016.03.30.04.47.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Mar 2016 04:47:06 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
	<alpine.DEB.2.10.1603291510560.11705@chino.kir.corp.google.com>
	<20160330094750.GH30729@dhcp22.suse.cz>
In-Reply-To: <20160330094750.GH30729@dhcp22.suse.cz>
Message-Id: <201603302046.CBJ39064.LFVQOHOOJtFSMF@I-love.SAKURA.ne.jp>
Date: Wed, 30 Mar 2016 20:46:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 29-03-16 15:13:54, David Rientjes wrote:
> > On Tue, 29 Mar 2016, Michal Hocko wrote:
> > 
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 86349586eacb..1c2b7a82f0c4 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -876,6 +876,10 @@ bool out_of_memory(struct oom_control *oc)
> > >  		return true;
> > >  	}
> > >  
> > > +	/* The OOM killer does not compensate for IO-less reclaim. */
> > > +	if (!(oc->gfp_mask & __GFP_FS))
> > > +		return true;
> > > +

This patch will disable pagefault_out_of_memory() because currently
pagefault_out_of_memory() is passing oc->gfp_mask == 0.

Because of current behavior, calling oom notifiers from !__GFP_FS seems
to be safe.

> > >  	/*
> > >  	 * Check if there were limitations on the allocation (only relevant for
> > >  	 * NUMA) that may require different handling.
> > 
> > I don't object to this necessarily, but I think we need input from those 
> > that have taken the time to implement their own oom notifier to see if 
> > they agree.  In the past, they would only be called if reclaim has 
> > completely failed; now, they can be called in low memory situations when 
> > reclaim has had very little chance to be successful.  Getting an ack from 
> > them would be helpful.
> 
> I will make sure to put them on the CC and mention this in the changelog
> when I post this next time. I personally think that this shouldn't make
> much difference in the real life because GFP_NOFS only loads are rare

GFP_NOFS only loads are rare. But some GFP_KERNEL load which got TIF_MEMDIE
might be waiting for GFP_NOFS or GFP_NOIO loads to make progress.

I think we are not ready to handle situations where out_of_memory() is called
again after current thread got TIF_MEMDIE due to __GFP_NOFAIL allocation
request when we ran out of memory reserves. We should not assume that the
victim target thread does not have TIF_MEMDIE yet. I think we can handle it
by making mark_oom_victim() return a bool and return via shortcut only if
mark_oom_victim() successfully set TIF_MEMDIE. Though I don't like the
shortcut approach that lacks a guaranteed unlocking mechanism.

> and we should rather help by releasing memory when it is available
> rather than rely on something else to do it for us. Waiting for Godot is
> never a good strategy.
> 
> > I also think we have discussed this before, but I think the oom notifier 
> > handling should be in done in the page allocator proper, i.e. in 
> > __alloc_pages_may_oom().  We can leave out_of_memory() for a clear defined 
> > purpose: to kill a process when all reclaim has failed.
> 
> I vaguely remember there was some issue with that the last time we have
> discussed that. It was the duplication from the page fault and allocator
> paths AFAIR. Nothing that cannot be handled though but the OOM notifier
> API is just too ugly to spread outside OOM proper I guess. Why we cannot
> move those users to use proper shrinkers interface (after it gets
> extended by a priority of some sort and release some objects only after
> we are really in troubles)? Something for a separate discussion,
> though...

Calling oom notifiers from SysRq-f is what we want?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
