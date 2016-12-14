Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07F6A6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 15:40:31 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so14670935wjb.3
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 12:40:30 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s71si9099539wme.62.2016.12.14.12.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 12:40:29 -0800 (PST)
Date: Wed, 14 Dec 2016 15:35:30 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: consolidate GFP_NOFAIL checks in the allocator
 slowpath
Message-ID: <20161214203530.GA18561@cmpxchg.org>
References: <20161214150706.27412-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214150706.27412-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Dec 14, 2016 at 04:07:06PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo Handa has pointed out that 0a0337e0d1d1 ("mm, oom: rework oom
> detection") has subtly changed semantic for costly high order requests
> with __GFP_NOFAIL and withtout __GFP_REPEAT and those can fail right now.
> My code inspection didn't reveal any such users in the tree but it is
> true that this might lead to unexpected allocation failures and
> subsequent OOPs.
> 
> __alloc_pages_slowpath wrt. GFP_NOFAIL is hard to follow currently.
> There are few special cases but we are lacking a catch all place to be
> sure we will not miss any case where the non failing allocation might
> fail. This patch reorganizes the code a bit and puts all those special
> cases under nopage label which is the generic go-to-fail path. Non
> failing allocations are retried or those that cannot retry like
> non-sleeping allocation go to the failure point directly. This should
> make the code flow much easier to follow and make it less error prone
> for future changes.
> 
> While we are there we have to move the stall check up to catch
> potentially looping non-failing allocations.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

It's not the nicest thing that we have to duplicate all the conditions
to warn on, but it's preferable over unreliable GFP_NOFAIL handling.
Consolidating the handling of this flag makes a lot of sense to me.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
