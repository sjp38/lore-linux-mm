Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 058106B006C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 15:33:24 -0500 (EST)
Received: by iecrl12 with SMTP id rl12so51288269iec.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:33:23 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id a19si12169149icl.55.2015.03.02.12.33.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 12:33:23 -0800 (PST)
Received: by igbhl2 with SMTP id hl2so19198093igb.0
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:33:23 -0800 (PST)
Date: Mon, 2 Mar 2015 12:33:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 2/4] jbd2: revert must-not-fail allocation loops back to
 GFP_NOFAIL
In-Reply-To: <1425304483-7987-3-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.10.1503021225090.20808@chino.kir.corp.google.com>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz> <1425304483-7987-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Vipul Pandya <vipul@chelsio.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 2 Mar 2015, Michal Hocko wrote:

> This basically reverts 47def82672b3 (jbd2: Remove __GFP_NOFAIL from jbd2
> layer). The deprecation of __GFP_NOFAIL was a bad choice because it led
> to open coding the endless loop around the allocator rather than
> removing the dependency on the non failing allocation. So the
> deprecation was a clear failure and the reality tells us that
> __GFP_NOFAIL is not even close to go away.
> 
> It is still true that __GFP_NOFAIL allocations are generally discouraged
> and new uses should be evaluated and an alternative (pre-allocations or
> reservations) should be considered but it doesn't make any sense to lie
> the allocator about the requirements. Allocator can take steps to help
> making a progress if it knows the requirements.
> 

The changelog should state that this only changes the source code, there 
is no functional change since alloc_buffer_head() and 
kmem_cache_zalloc(transaction_cache) are already implicitly nofail due to 
the allocation order.  The failure code added by the commit you cite are 
never executed.

I agree that if the implementation of the page allocator were to change 
with respect to PAGE_ALLOC_COSTLY_ORDER that we'd need __GFP_NOFAIL and 
that such an allocation is better handled in the page allocator.

> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

GFP_NOFS|__GFP_NOFAIL is scary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
