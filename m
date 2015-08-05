Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 922FC6B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 08:28:58 -0400 (EDT)
Received: by pabxd6 with SMTP id xd6so17580249pab.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 05:28:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id kj10si5174080pdb.43.2015.08.05.05.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 05:28:57 -0700 (PDT)
Subject: Re: [RFC 3/8] mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
	<1438768284-30927-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1438768284-30927-4-git-send-email-mhocko@kernel.org>
Message-Id: <201508052128.FIJ56269.QHSFOVFLOJOMFt@I-love.SAKURA.ne.jp>
Date: Wed, 5 Aug 2015 21:28:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, mhocko@suse.com

Reduced to only linux-mm.

> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> GFP_NOFS allocations are not allowed to invoke the OOM killer since
> their reclaim abilities are severely diminished.  However, without the
> OOM killer available there is no hope of progress once the reclaimable
> pages have been exhausted.

Excuse me, but I still cannot understand. Why are !__GFP_FS allocations
considered as "their reclaim abilities are severely diminished"?

It seems to me that not only GFP_NOFS allocation requests but also
almost all types of memory allocation requests do not include
__GFP_NO_KSWAPD flag.

Therefore, while a thread which called __alloc_pages_slowpath(GFP_NOFS)
cannot reclaim FS memory, I assume that kswapd kernel threads which are
woken up by the thread via wakeup_kswapd() via wake_all_kswapds() can
reclaim FS memory by calling balance_pgdat(). Is this assumption correct?

If the assumption is correct, when kswapd kernel threads returned from
balance_pgdat() or got stuck inside reclaiming functions (e.g. blocked at
mutex_lock() inside slab's shrinker functions), I think that the thread
which called __alloc_pages_slowpath(GFP_NOFS) has reclaimed FS memory
as if the thread called __alloc_pages_slowpath(GFP_KERNEL), and therefore
the thread qualifies calling out_of_memory() as with __GFP_FS allocations.

> 
> Don't risk hanging these allocations.  Leave it to the allocation site
> to implement the fallback policy for failing allocations.

Are there memory pages which kswapd kernel threads cannot reclaim
but __alloc_pages_slowpath(GFP_KERNEL) allocations can reclaim
when __alloc_pages_slowpath(GFP_NOFS) allocations are hanging?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
