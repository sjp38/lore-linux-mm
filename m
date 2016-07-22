Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 217B16B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:05:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so33036300wmp.3
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:05:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7si566924wjv.12.2016.07.22.05.05.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:05:20 -0700 (PDT)
Date: Fri, 22 Jul 2016 14:05:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
Message-ID: <20160722120519.GJ794@dhcp22.suse.cz>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160721112140.GG26379@dhcp22.suse.cz>
 <201607222009.DII64068.VHMSQJtOOFOLFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607222009.DII64068.VHMSQJtOOFOLFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Fri 22-07-16 20:09:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 12-07-16 22:29:15, Tetsuo Handa wrote:
> > > This series is an update of
> > > http://lkml.kernel.org/r/201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp .
> > > 
> > > This series is based on top of linux-next-20160712 +
> > > http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org .
> > 
> > I was thinking about this vs. signal_struct::oom_mm [1] and came to the
> > conclusion that as of now they are mostly equivalent wrt. oom livelock
> > detection and coping with it. So for now any of them should be good to
> > go. Good!
> > 
> > Now what about future plans? I would like to get rid of TIF_MEMDIE
> > altogether and give access to memory reserves to oom victim when they
> > allocate the memory. Something like:
> 
> Before doing so, can we handle a silent hang up caused by lowmem livelock
> at http://lkml.kernel.org/r/20160211225929.GU14668@dastard ? It is a nearly
> 7 years old bug (since commit 35cd78156c499ef8 "vmscan: throttle direct
> reclaim when too many pages are isolated already") which got no progress
> so far.

I do not see any dependecy/relation on/to the OOM work. I am even not
sure why you are bringing that up here.

> Also, can we apply "[RFC PATCH 2/6] oom, suspend: fix oom_killer_disable vs.
> pm suspend properly" at
> http://lkml.kernel.org/r/1467365190-24640-3-git-send-email-mhocko@kernel.org
> regardless of oom_mm_list vs. signal_struct::oom_mm ?

Why would we want to hurry? The current workaround should work just fine
for such an unlikely event like oom during suspend. Besides that I would
like to have the stable mm (whichever approach we decide) patches in the
mmotm after the merge window closes and target 4.9. That would include
the above as well.

[...]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 788e4f22e0bb..34446f49c2e1 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3358,7 +3358,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> >  		else if (!in_interrupt() &&
> >  				((current->flags & PF_MEMALLOC) ||
> > -				 unlikely(test_thread_flag(TIF_MEMDIE))))
> > +				 tsk_is_oom_victim(current))
> >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> >  	}
> >  #ifdef CONFIG_CMA
> > 
> > where tsk_is_oom_victim wouldn't require the given task to go via
> > out_of_memory. This would solve some of the problems we have right now
> > when a thread doesn't get access to memory reserves because it never
> > reaches out_of_memory (e.g. recently mentioned mempool_alloc doing
> > __GFP_NORETRY). It would also make the code easier to follow. If we want
> > to implement that we need an easy to implement tsk_is_oom_victim
> > obviously. With the signal_struct::oom_mm this is really trivial thing.
> > I am not sure we can do that with the mm list though because we are
> > loosing the task->mm at certain point in time.
> 
> bool tsk_is_oom_victim(void)
> {
> 	return current->mm && test_bit(MMF_OOM_KILLED, &current->mm->flags) &&
> 		 (fatal_signal_pending(current) || (current->flags & PF_EXITING));
> }

which doesn't work as soon as exit_mm clears the mm which is exactly
the concern I have raised above.

> 
> >                                                The only way I can see
> > this would fly would be preserving TIF_MEMDIE and setting it for all
> > threads but I am not sure this is very much better and puts the mm list
> > approach to a worse possition from my POV.
> > 
> 
> But do we still need ALLOC_NO_WATERMARKS for OOM victims?

Yes as a safety net for cases when the oom_reaper cannot reclaim enough
to get us out of OOM. Maybe one day we can make the oom_reaper
completely bullet proof and granting access to memory reserves would be
pointless. One reason I want to get rid of TIF_MEMDIE is that all would
need to do at that time would be a single line dropping
tsk_is_oom_victim from gfp_to_alloc_flags.

> I didn't have a
> chance to post below series but I'm suspecting that we need to distinguish
> "threads killed by the OOM killer" and "threads killed by SIGKILL" and
> "threads normally exiting via exit()".

Let's stick to discussing the two approaches for now before proposing
even further changes please. I have a serious interest to collect all
the arguments speaking for the two solutions to do an educated decision.
Can we stay on track and get to some conclusion, please?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
