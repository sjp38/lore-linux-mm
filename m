Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 851626B0038
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 11:22:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so15949420wme.4
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 08:22:02 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id e133si11639581wmf.127.2016.12.18.08.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 08:22:01 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id he10so20675914wjc.2
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 08:22:00 -0800 (PST)
Date: Sun, 18 Dec 2016 17:21:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/9] mm: introduce memalloc_nofs_{save,restore} API
Message-ID: <20161218162159.GB8440@dhcp22.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-5-mhocko@kernel.org>
 <7019c051-ebca-7396-54f9-2a1d5805c57b@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7019c051-ebca-7396-54f9-2a1d5805c57b@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm <linux-mm@kvack.org>

On Sat 17-12-16 19:44:22, Tetsuo Handa wrote:
> On 2016/12/15 23:07, Michal Hocko wrote:
> > GFP_NOFS context is used for the following 5 reasons currently
> > 	- to prevent from deadlocks when the lock held by the allocation
> > 	  context would be needed during the memory reclaim
> > 	- to prevent from stack overflows during the reclaim because
> > 	  the allocation is performed from a deep context already
> > 	- to prevent lockups when the allocation context depends on
> > 	  other reclaimers to make a forward progress indirectly
> > 	- just in case because this would be safe from the fs POV
> > 	- silence lockdep false positives
> > 
> > Unfortunately overuse of this allocation context brings some problems
> > to the MM. Memory reclaim is much weaker (especially during heavy FS
> > metadata workloads), OOM killer cannot be invoked because the MM layer
> > doesn't have enough information about how much memory is freeable by the
> > FS layer.
> 
> This series is intended for simply applying "& ~__GFP_FS" mask to allocations
> which are using GFP_KERNEL by error for the current thread, isn't it?

Not really. I've tried to cover that in changelogs but in short I would
like to achieve a state where this api would cover all the recursion
dangerous places with a documentation why and most/all the specific
allocations will not care about NOFS at all. They will simply inherit
NOFS scope when necessary.
 
> > In many cases it is far from clear why the weaker context is even used
> > and so it might be used unnecessarily. We would like to get rid of
> > those as much as possible. One way to do that is to use the flag in
> > scopes rather than isolated cases. Such a scope is declared when really
> > necessary, tracked per task and all the allocation requests from within
> > the context will simply inherit the GFP_NOFS semantic.
> > 
> > Not only this is easier to understand and maintain because there are
> > much less problematic contexts than specific allocation requests, this
> > also helps code paths where FS layer interacts with other layers (e.g.
> > crypto, security modules, MM etc...) and there is no easy way to convey
> > the allocation context between the layers.
> 
> I haven't heard an answer to "a terrible thing" in
> http://lkml.kernel.org/r/20160427200530.GB22544@dhcp22.suse.cz .
> 
> What is your plan for checking whether we need to propagate "& ~__GFP_FS"
> mask to other threads which current thread waits synchronously (e.g.
> wait_for_completion()) from "& ~__GFP_FS" context?

This needs a deeper inspection. First of all we have to find out whether
we have a _relevant_ code which depends on kworkers (without WQ_MEM_RECLAIM)
from the NOFS context. This is not covered in this patch series, though.
I plan to get to it later after we actually finish this step.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
