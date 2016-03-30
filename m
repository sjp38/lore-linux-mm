Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id E86686B0253
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 05:47:52 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id 20so62556026wmh.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 02:47:52 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id t184si4689902wmb.113.2016.03.30.02.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 02:47:51 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 20so13032214wmh.3
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 02:47:51 -0700 (PDT)
Date: Wed, 30 Mar 2016 11:47:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
Message-ID: <20160330094750.GH30729@dhcp22.suse.cz>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1603291510560.11705@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1603291510560.11705@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 29-03-16 15:13:54, David Rientjes wrote:
> On Tue, 29 Mar 2016, Michal Hocko wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 86349586eacb..1c2b7a82f0c4 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -876,6 +876,10 @@ bool out_of_memory(struct oom_control *oc)
> >  		return true;
> >  	}
> >  
> > +	/* The OOM killer does not compensate for IO-less reclaim. */
> > +	if (!(oc->gfp_mask & __GFP_FS))
> > +		return true;
> > +
> >  	/*
> >  	 * Check if there were limitations on the allocation (only relevant for
> >  	 * NUMA) that may require different handling.
> 
> I don't object to this necessarily, but I think we need input from those 
> that have taken the time to implement their own oom notifier to see if 
> they agree.  In the past, they would only be called if reclaim has 
> completely failed; now, they can be called in low memory situations when 
> reclaim has had very little chance to be successful.  Getting an ack from 
> them would be helpful.

I will make sure to put them on the CC and mention this in the changelog
when I post this next time. I personally think that this shouldn't make
much difference in the real life because GFP_NOFS only loads are rare
and we should rather help by releasing memory when it is available
rather than rely on something else to do it for us. Waiting for Godot is
never a good strategy.

> I also think we have discussed this before, but I think the oom notifier 
> handling should be in done in the page allocator proper, i.e. in 
> __alloc_pages_may_oom().  We can leave out_of_memory() for a clear defined 
> purpose: to kill a process when all reclaim has failed.

I vaguely remember there was some issue with that the last time we have
discussed that. It was the duplication from the page fault and allocator
paths AFAIR. Nothing that cannot be handled though but the OOM notifier
API is just too ugly to spread outside OOM proper I guess. Why we cannot
move those users to use proper shrinkers interface (after it gets
extended by a priority of some sort and release some objects only after
we are really in troubles)? Something for a separate discussion,
though...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
