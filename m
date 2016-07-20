Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6131E6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 02:44:33 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so26065375wma.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 23:44:33 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id m68si2590359wma.37.2016.07.19.23.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 23:44:32 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id x83so5348338wma.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 23:44:32 -0700 (PDT)
Date: Wed, 20 Jul 2016 08:44:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from the
 reclaim path
Message-ID: <20160720064429.GB11249@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <alpine.LRH.2.02.1607191749330.1437@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607191749330.1437@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: linux-mm@kvack.org, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Tue 19-07-16 17:50:29, Mikulas Patocka wrote:
> 
> 
> On Mon, 18 Jul 2016, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > There has been a report about OOM killer invoked when swapping out to
> > a dm-crypt device. The primary reason seems to be that the swapout
> > out IO managed to completely deplete memory reserves. Mikulas was
> > able to bisect and explained the issue by pointing to f9054c70d28b
> > ("mm, mempool: only set __GFP_NOMEMALLOC if there are free elements").
> > 
> > The reason is that the swapout path is not throttled properly because
> > the md-raid layer needs to allocate from the generic_make_request path
> > which means it allocates from the PF_MEMALLOC context. dm layer uses
> > mempool_alloc in order to guarantee a forward progress which used to
> > inhibit access to memory reserves when using page allocator. This has
> > changed by f9054c70d28b ("mm, mempool: only set __GFP_NOMEMALLOC if
> > there are free elements") which has dropped the __GFP_NOMEMALLOC
> > protection when the memory pool is depleted.
> > 
> > If we are running out of memory and the only way forward to free memory
> > is to perform swapout we just keep consuming memory reserves rather than
> > throttling the mempool allocations and allowing the pending IO to
> > complete up to a moment when the memory is depleted completely and there
> > is no way forward but invoking the OOM killer. This is less than
> > optimal.
> > 
> > The original intention of f9054c70d28b was to help with the OOM
> > situations where the oom victim depends on mempool allocation to make a
> > forward progress. We can handle that case in a different way, though. We
> > can check whether the current task has access to memory reserves ad an
> > OOM victim (TIF_MEMDIE) and drop __GFP_NOMEMALLOC protection if the pool
> > is empty.
> > 
> > David Rientjes was objecting that such an approach wouldn't help if the
> > oom victim was blocked on a lock held by process doing mempool_alloc. This
> > is very similar to other oom deadlock situations and we have oom_reaper
> > to deal with them so it is reasonable to rely on the same mechanism
> > rather inventing a different one which has negative side effects.
> > 
> > Fixes: f9054c70d28b ("mm, mempool: only set __GFP_NOMEMALLOC if there are free elements")
> > Bisected-by: Mikulas Patocka <mpatocka@redhat.com>
> 
> Bisect was done by Ondrej Kozina.

OK, fixed

> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Reviewed-by: Mikulas Patocka <mpatocka@redhat.com>
> Tested-by: Mikulas Patocka <mpatocka@redhat.com>

Let's see whether we decide to go with this patch or a plain revert. In
any case I will mark the patch for stable so it will end up in both 4.6
and 4.7

Anyway thanks for your and Ondrejs help here!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
