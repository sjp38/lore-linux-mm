Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9CC82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:55:41 -0500 (EST)
Received: by wicll6 with SMTP id ll6so41400315wic.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:55:40 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s201si6194949wmd.92.2015.11.04.14.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 14:55:39 -0800 (PST)
Date: Wed, 4 Nov 2015 17:55:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: move lazily freed pages to inactive list
Message-ID: <20151104225527.GA25941@cmpxchg.org>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-6-git-send-email-minchan@kernel.org>
 <20151104205504.GA9927@cmpxchg.org>
 <563A7D21.6040505@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563A7D21.6040505@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>

On Wed, Nov 04, 2015 at 04:48:17PM -0500, Daniel Micay wrote:
> > Even if we're wrong about the aging of those MADV_FREE pages, their
> > contents are invalidated; they can be discarded freely, and restoring
> > them is a mere GFP_ZERO allocation. All other anonymous pages have to
> > be written to disk, and potentially be read back.
> > 
> > [ Arguably, MADV_FREE pages should even be reclaimed before inactive
> >   page cache. It's the same cost to discard both types of pages, but
> >   restoring page cache involves IO. ]
> 
> Keep in mind that this is memory the kernel wouldn't be getting back at
> all if the allocator wasn't going out of the way to purge it, and they
> aren't going to go out of their way to purge it if it means the kernel
> is going to steal the pages when there isn't actually memory pressure.

Well, obviously you'd still only reclaim them on memory pressure. I'm
only talking about where these pages should go on the LRU hierarchy.

> > It probably makes sense to stop thinking about them as anonymous pages
> > entirely at this point when it comes to aging. They're really not. The
> > LRU lists are split to differentiate access patterns and cost of page
> > stealing (and restoring). From that angle, MADV_FREE pages really have
> > nothing in common with in-use anonymous pages, and so they shouldn't
> > be on the same LRU list.
> > 
> > That would also fix the very unfortunate and unexpected consequence of
> > tying the lazy free optimization to the availability of swap space.
> > 
> > I would prefer to see this addressed before the code goes upstream.
> 
> I don't think it would be ideal for these potentially very hot pages to
> be dropped before very cold pages were swapped out. It's the kind of
> tuning that needs to be informed by lots of real world experience and
> lots of testing. It wouldn't impact the API.

What about them is hot? They contain garbage, you have to write to
them before you can use them. Granted, you might have to refetch
cachelines if you don't do cacheline-aligned populating writes, but
you can do a lot of them before it's more expensive than doing IO.

> Whether MADV_FREE is useful as an API vs. something like a pair of
> system calls for pinning and unpinning memory is what should be worried
> about right now. The internal implementation just needs to be correct
> and useful right now, not perfect. Simpler is probably better than it
> being more well tuned for an initial implementation too.

Yes, it wouldn't impact the API, but the dependency on swap is very
random from a user experience and severely limits the usefulness of
this. It should probably be addressed before this gets released. As
this involves getting the pages off the anon LRU, we need to figure
out where they should go instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
