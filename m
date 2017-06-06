Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2C36B03A1
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 08:03:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v104so5603998wrb.6
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 05:03:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f28si5368448ede.117.2017.06.06.05.03.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 05:03:21 -0700 (PDT)
Date: Tue, 6 Jun 2017 14:03:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/4] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
Message-ID: <20170606120314.GL1189@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-3-mhocko@kernel.org>
 <20170603022440.GA11080@WeideMacBook-Pro.local>
 <20170605064343.GE9248@dhcp22.suse.cz>
 <20170606030401.GA2259@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170606030401.GA2259@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 06-06-17 11:04:01, Wei Yang wrote:
> On Mon, Jun 05, 2017 at 08:43:43AM +0200, Michal Hocko wrote:
> >On Sat 03-06-17 10:24:40, Wei Yang wrote:
> >> Hi, Michal
> >> 
> >> Just go through your patch.
> >> 
> >> I have one question and one suggestion as below.
> >> 
> >> One suggestion:
> >> 
> >> This patch does two things to me:
> >> 1. Replace __GFP_REPEAT with __GFP_RETRY_MAYFAIL
> >> 2. Adjust the logic in page_alloc to provide the middle semantic
> >> 
> >> My suggestion is to split these two task into two patches, so that readers
> >> could catch your fundamental logic change easily.
> >
> >Well, the rename and the change is intentionally tight together. My
> >previous patches have removed all __GFP_REPEAT users for low order
> >requests which didn't have any implemented semantic. So as of now we
> >should only have those users which semantic will not change. I do not
> >add any new low order user in this patch so it in fact doesn't change
> >any existing semnatic.
> >
> >> 
> >> On Tue, Mar 07, 2017 at 04:48:41PM +0100, Michal Hocko wrote:
> >> >From: Michal Hocko <mhocko@suse.com>
> >[...]
> >> >@@ -3776,9 +3784,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >> > 
> >> > 	/*
> >> > 	 * Do not retry costly high order allocations unless they are
> >> >-	 * __GFP_REPEAT
> >> >+	 * __GFP_RETRY_MAYFAIL
> >> > 	 */
> >> >-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
> >> >+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_MAYFAIL))
> >> > 		goto nopage;
> >> 
> >> One question:
> >> 
> >> From your change log, it mentions will provide the same semantic for !costly
> >> allocations. While the logic here is the same as before.
> >> 
> >> For a !costly allocation with __GFP_REPEAT flag, the difference after this
> >> patch is no OOM will be invoked, while it will still continue in the loop.
> >
> >Not really. There are two things. The above will shortcut retrying if
> >there is _no_ __GFP_RETRY_MAYFAIL. If the flags _is_ specified we will
> >back of in __alloc_pages_may_oom.
> > 
> >> Maybe I don't catch your point in this message:
> >> 
> >>   __GFP_REPEAT was designed to allow retry-but-eventually-fail semantic to
> >>   the page allocator. This has been true but only for allocations requests
> >>   larger than PAGE_ALLOC_COSTLY_ORDER. It has been always ignored for
> >>   smaller sizes. This is a bit unfortunate because there is no way to
> >>   express the same semantic for those requests and they are considered too
> >>   important to fail so they might end up looping in the page allocator for
> >>   ever, similarly to GFP_NOFAIL requests.
> >> 
> >> I thought you will provide the same semantic to !costly allocation, or I
> >> misunderstand?
> >
> >yes and that is the case. __alloc_pages_may_oom will back off before OOM
> >killer is invoked and the allocator slow path will fail because
> >did_some_progress == 0;
> 
> Thanks for your explanation.
> 
> So same "semantic" doesn't mean same "behavior".
> 1. costly allocations will pick up the shut cut

yes and there are no such allocations yet (based on my previous
cleanups)

> 2. !costly allocations will try something more but finally fail without
> invoking OOM.

no, the behavior will not change for those.
 
> Hope this time I catch your point.
> 
> BTW, did_some_progress mostly means the OOM works to me. Are there some other
> important situations when did_some_progress is set to 1?

Yes e.g. for GFP_NOFS when we cannot really invoke the OOM killer yet we
cannot fail the allocation.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
