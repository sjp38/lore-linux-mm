Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 158CB6B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 03:42:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so78186658wmu.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 00:42:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hm2si76320271wjb.167.2017.01.03.00.42.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 00:42:16 -0800 (PST)
Date: Tue, 3 Jan 2017 09:42:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3 -v3] GFP_NOFAIL cleanups
Message-ID: <20170103084211.GB30111@dhcp22.suse.cz>
References: <20161220134904.21023-1-mhocko@kernel.org>
 <20170102154858.GC18048@dhcp22.suse.cz>
 <201701031036.IBE51044.QFLFSOHtFOJVMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701031036.IBE51044.QFLFSOHtFOJVMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 03-01-17 10:36:31, Tetsuo Handa wrote:
[...]
> I'm OK with "[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator
> slowpath" given that we describe that we make __GFP_NOFAIL stronger than
> __GFP_NORETRY with this patch in the changelog.

Again. __GFP_NORETRY | __GFP_NOFAIL is nonsense! I do not really see any
reason to describe all the nonsense combinations of gfp flags.

> But I don't think "[PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
> automatically" is correct. Firstly, we need to confirm
> 
>   "The pre-mature OOM killer is a real issue as reported by Nils Holland"
> 
> in the changelog is still true because we haven't tested with "[PATCH] mm, memcg:
> fix the active list aging for lowmem requests when memcg is enabled" applied and
> without "[PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
> automatically" and "[PATCH 3/3] mm: help __GFP_NOFAIL allocations which do not
> trigger OOM killer" applied.

Yes I have dropped the reference to this report already in my local
patch because in this particular case the issue was somewhere else
indeed!

> Secondly, as you are using __GFP_NORETRY in "[PATCH] mm: introduce kv[mz]alloc
> helpers" as a mean to enforce not to invoke the OOM killer
> 
> 	/*
> 	 * Make sure that larger requests are not too disruptive - no OOM
> 	 * killer and no allocation failure warnings as we have a fallback
> 	 */
> 	if (size > PAGE_SIZE)
> 		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
> 
> , we can use __GFP_NORETRY as a mean to enforce not to invoke the OOM killer
> rather than applying "[PATCH 2/3] mm, oom: do not enfore OOM killer for
> __GFP_NOFAIL automatically".
> 
> Additionally, although currently there seems to be no
> kv[mz]alloc(GFP_KERNEL | __GFP_NOFAIL) users, kvmalloc_node() in
> "[PATCH] mm: introduce kv[mz]alloc helpers" will be confused when a
> kv[mz]alloc(GFP_KERNEL | __GFP_NOFAIL) user comes in in the future because
> "[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator slowpath" makes
> __GFP_NOFAIL stronger than __GFP_NORETRY.

Using NOFAIL in kv[mz]alloc simply makes no sense at all. The vmalloc
fallback would be simply unreachable!

> My concern with "[PATCH 3/3] mm: help __GFP_NOFAIL allocations which
> do not trigger OOM killer" is
> 
>   "AFAIU, this is an allocation path which doesn't block a forward progress
>    on a regular IO. It is merely a check whether there is a new medium in
>    the CDROM (aka regular polling of the device). I really fail to see any
>    reason why this one should get any access to memory reserves at all."
> 
> in http://lkml.kernel.org/r/20161218163727.GC8440@dhcp22.suse.cz .
> Indeed that trace is a __GFP_DIRECT_RECLAIM and it might not be blocking
> other workqueue items which a regular I/O depend on, I think there are
> !__GFP_DIRECT_RECLAIM memory allocation requests for issuing SCSI commands
> which could potentially start failing due to helping GFP_NOFS | __GFP_NOFAIL
> allocations with memory reserves. If a SCSI disk I/O request fails due to
> GFP_ATOMIC memory allocation failures because we allow a FS I/O request to
> use memory reserves, it adds a new problem.

Do you have any example of such a request? Anything that requires
a forward progress during IO should be using mempools otherwise it
is broken pretty much by design already. Also IO depending on NOFS
allocations sounds pretty much broken already. So I suspect the above
reasoning is just bogus.

That being said, to summarize your arguments again. 1) you do not like
that a combination of __GFP_NORETRY | __GFP_NOFAIL is not documented
to never fail, 2) based on that you argue that kv[mvz]alloc with
__GFP_NOFAIL will never reach vmalloc and 3) that there might be some IO
paths depending on NOFS|NOFAIL allocation which would have harder time
to make forward progress.

I would call 1 and 2 just bogus and 3 highly dubious at best. Do not
get me wrong but this is not what I call a useful review feedback yet
alone a reason to block these patches. If there are any reasons to not
merge them these are not those.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
