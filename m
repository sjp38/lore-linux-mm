Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB796B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 02:43:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r203so22619440wmb.2
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 23:43:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y42si16919552wrd.240.2017.06.04.23.43.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Jun 2017 23:43:46 -0700 (PDT)
Date: Mon, 5 Jun 2017 08:43:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/4] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
Message-ID: <20170605064343.GE9248@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-3-mhocko@kernel.org>
 <20170603022440.GA11080@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170603022440.GA11080@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sat 03-06-17 10:24:40, Wei Yang wrote:
> Hi, Michal
> 
> Just go through your patch.
> 
> I have one question and one suggestion as below.
> 
> One suggestion:
> 
> This patch does two things to me:
> 1. Replace __GFP_REPEAT with __GFP_RETRY_MAYFAIL
> 2. Adjust the logic in page_alloc to provide the middle semantic
> 
> My suggestion is to split these two task into two patches, so that readers
> could catch your fundamental logic change easily.

Well, the rename and the change is intentionally tight together. My
previous patches have removed all __GFP_REPEAT users for low order
requests which didn't have any implemented semantic. So as of now we
should only have those users which semantic will not change. I do not
add any new low order user in this patch so it in fact doesn't change
any existing semnatic.

> 
> On Tue, Mar 07, 2017 at 04:48:41PM +0100, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
[...]
> >@@ -3776,9 +3784,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > 
> > 	/*
> > 	 * Do not retry costly high order allocations unless they are
> >-	 * __GFP_REPEAT
> >+	 * __GFP_RETRY_MAYFAIL
> > 	 */
> >-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
> >+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_MAYFAIL))
> > 		goto nopage;
> 
> One question:
> 
> From your change log, it mentions will provide the same semantic for !costly
> allocations. While the logic here is the same as before.
> 
> For a !costly allocation with __GFP_REPEAT flag, the difference after this
> patch is no OOM will be invoked, while it will still continue in the loop.

Not really. There are two things. The above will shortcut retrying if
there is _no_ __GFP_RETRY_MAYFAIL. If the flags _is_ specified we will
back of in __alloc_pages_may_oom.
 
> Maybe I don't catch your point in this message:
> 
>   __GFP_REPEAT was designed to allow retry-but-eventually-fail semantic to
>   the page allocator. This has been true but only for allocations requests
>   larger than PAGE_ALLOC_COSTLY_ORDER. It has been always ignored for
>   smaller sizes. This is a bit unfortunate because there is no way to
>   express the same semantic for those requests and they are considered too
>   important to fail so they might end up looping in the page allocator for
>   ever, similarly to GFP_NOFAIL requests.
> 
> I thought you will provide the same semantic to !costly allocation, or I
> misunderstand?

yes and that is the case. __alloc_pages_may_oom will back off before OOM
killer is invoked and the allocator slow path will fail because
did_some_progress == 0;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
