Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9B26B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 11:29:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so55184416lfi.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 08:29:16 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 186si4072869wmz.140.2016.07.21.08.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 08:29:15 -0700 (PDT)
Date: Thu, 21 Jul 2016 11:26:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from the
 reclaim path
Message-ID: <20160721152631.GA30303@cmpxchg.org>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <20160719135426.GA31229@cmpxchg.org>
 <alpine.DEB.2.10.1607191315400.58064@chino.kir.corp.google.com>
 <20160720081541.GF11249@dhcp22.suse.cz>
 <alpine.DEB.2.10.1607201353230.22427@chino.kir.corp.google.com>
 <20160721085202.GC26379@dhcp22.suse.cz>
 <20160721121300.GA21806@cmpxchg.org>
 <20160721145309.GR26379@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160721145309.GR26379@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Thu, Jul 21, 2016 at 04:53:10PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 21 Jul 2016 16:40:59 +0200
> Subject: [PATCH] Revert "mm, mempool: only set __GFP_NOMEMALLOC if there are
>  free elements"
> 
> This reverts commit f9054c70d28bc214b2857cf8db8269f4f45a5e23.
> 
> There has been a report about OOM killer invoked when swapping out to
> a dm-crypt device. The primary reason seems to be that the swapout
> out IO managed to completely deplete memory reserves. Ondrej was

-out

> able to bisect and explained the issue by pointing to f9054c70d28b
> ("mm, mempool: only set __GFP_NOMEMALLOC if there are free elements").
> 
> The reason is that the swapout path is not throttled properly because
> the md-raid layer needs to allocate from the generic_make_request path
> which means it allocates from the PF_MEMALLOC context. dm layer uses
> mempool_alloc in order to guarantee a forward progress which used to
> inhibit access to memory reserves when using page allocator. This has
> changed by f9054c70d28b ("mm, mempool: only set __GFP_NOMEMALLOC if
> there are free elements") which has dropped the __GFP_NOMEMALLOC
> protection when the memory pool is depleted.
> 
> If we are running out of memory and the only way forward to free memory
> is to perform swapout we just keep consuming memory reserves rather than
> throttling the mempool allocations and allowing the pending IO to
> complete up to a moment when the memory is depleted completely and there
> is no way forward but invoking the OOM killer. This is less than
> optimal.
> 
> The original intention of f9054c70d28b was to help with the OOM
> situations where the oom victim depends on mempool allocation to make a
> forward progress. David has mentioned the following backtrace:
> 
> schedule
> schedule_timeout
> io_schedule_timeout
> mempool_alloc
> __split_and_process_bio
> dm_request
> generic_make_request
> submit_bio
> mpage_readpages
> ext4_readpages
> __do_page_cache_readahead
> ra_submit
> filemap_fault
> handle_mm_fault
> __do_page_fault
> do_page_fault
> page_fault
> 
> We do not know more about why the mempool is depleted without being
> replenished in time, though. In any case the dm layer shouldn't depend
> on any allocations outside of the dedicated pools so a forward progress
> should be guaranteed. If this is not the case then the dm should be
> fixed rather than papering over the problem and postponing it to later
> by accessing more memory reserves.
> 
> mempools are a mechanism to maintain dedicated memory reserves to guaratee
> forward progress. Allowing them an unbounded access to the page allocator
> memory reserves is going against the whole purpose of this mechanism.
> 
> Bisected-by: Ondrej Kozina <okozina@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
