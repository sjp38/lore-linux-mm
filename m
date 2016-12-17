Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2906B0038
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 05:44:44 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so251479520pgc.1
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 02:44:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h67si12080231pfe.48.2016.12.17.02.44.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Dec 2016 02:44:43 -0800 (PST)
Subject: Re: [PATCH 4/9] mm: introduce memalloc_nofs_{save,restore} API
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-5-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <7019c051-ebca-7396-54f9-2a1d5805c57b@I-love.SAKURA.ne.jp>
Date: Sat, 17 Dec 2016 19:44:22 +0900
MIME-Version: 1.0
In-Reply-To: <20161215140715.12732-5-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>

On 2016/12/15 23:07, Michal Hocko wrote:
> GFP_NOFS context is used for the following 5 reasons currently
> 	- to prevent from deadlocks when the lock held by the allocation
> 	  context would be needed during the memory reclaim
> 	- to prevent from stack overflows during the reclaim because
> 	  the allocation is performed from a deep context already
> 	- to prevent lockups when the allocation context depends on
> 	  other reclaimers to make a forward progress indirectly
> 	- just in case because this would be safe from the fs POV
> 	- silence lockdep false positives
> 
> Unfortunately overuse of this allocation context brings some problems
> to the MM. Memory reclaim is much weaker (especially during heavy FS
> metadata workloads), OOM killer cannot be invoked because the MM layer
> doesn't have enough information about how much memory is freeable by the
> FS layer.

This series is intended for simply applying "& ~__GFP_FS" mask to allocations
which are using GFP_KERNEL by error for the current thread, isn't it?

> 
> In many cases it is far from clear why the weaker context is even used
> and so it might be used unnecessarily. We would like to get rid of
> those as much as possible. One way to do that is to use the flag in
> scopes rather than isolated cases. Such a scope is declared when really
> necessary, tracked per task and all the allocation requests from within
> the context will simply inherit the GFP_NOFS semantic.
> 
> Not only this is easier to understand and maintain because there are
> much less problematic contexts than specific allocation requests, this
> also helps code paths where FS layer interacts with other layers (e.g.
> crypto, security modules, MM etc...) and there is no easy way to convey
> the allocation context between the layers.

I haven't heard an answer to "a terrible thing" in
http://lkml.kernel.org/r/20160427200530.GB22544@dhcp22.suse.cz .

What is your plan for checking whether we need to propagate "& ~__GFP_FS"
mask to other threads which current thread waits synchronously (e.g.
wait_for_completion()) from "& ~__GFP_FS" context?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
