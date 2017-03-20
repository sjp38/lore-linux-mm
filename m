Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B02AE6B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 11:23:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v66so27315015wrc.4
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 08:23:25 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 139si12375604wml.77.2017.03.20.08.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Mar 2017 08:23:24 -0700 (PDT)
Date: Mon, 20 Mar 2017 11:23:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Message-ID: <20170320152315.GA27672@cmpxchg.org>
References: <20170317231636.142311-1-timmurray@google.com>
 <20170320055930.GA30167@bbox>
 <3023449c-8012-333d-1da9-81f18d3f8540@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3023449c-8012-333d-1da9-81f18d3f8540@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, surenb@google.com, totte@google.com, kernel-team@android.com

On Mon, Mar 20, 2017 at 07:28:53PM +0530, Vinayak Menon wrote:
> From the discussions @ https://lkml.org/lkml/2017/3/3/752, I assume you are trying
> per-app memcg. We were trying to implement per app memory cgroups and were
> encountering some issues (https://www.spinics.net/lists/linux-mm/msg121665.html) .
> I am curious if you have seen similar issues and would like to know if the patch also
> address some of these problems.
> 
> The major issues were:
> (1) Because of multiple per-app memcgs, the per memcg LRU size is so small and
> results in kswapd priority drop. This results in sudden increase in scan at lower priorities.
> And kswapd ends up consuming around 3 times more time.

There shouldn't be a connection between those two things.

Yes, priority levels used to dictate aggressiveness of reclaim, and we
did add a bunch of memcg code to avoid priority drops.

But nowadays the priority level should only set the LRU scan window
and we bail out once we have reclaimed enough (see the code in
shrink_node_memcg()).

If kswapd gets stuck on smaller LRUs, we should find out why and then
address that problem.

> (2) Due to kswapd taking more time in freeing up memory, allocstalls are high and for
> similar reasons stated above direct reclaim path consumes 2.5 times more time.
> (3) Because of multiple LRUs, the aging of pages is affected and this results in wrong
> pages being evicted resulting in higher number of major faults.
>
> Since soft reclaim was not of much help in mitigating the problem, I was trying out
> something similar to memcg priority. But what I have seen is that this aggravates the
> above mentioned problems. I think this is because, even though the high priority tasks
> (foreground) are having pages which are used at the moment, there are idle pages too
> which could be reclaimed. But due to the high priority of foreground memcg, it requires
> the kswapd priority to drop down much to reclaim these idle pages. This results in excessive
> reclaim from background apps resulting in increased major faults, pageins and thus increased
> launch latency when these apps are later brought back to foreground.

This is what the soft limit *should* do, but unfortunately its
semantics and implementation in cgroup1 are too broken for this.

Have you tried configuring memory.low for the foreground groups in
cgroup2? That protects those pages from reclaim as long as there are
reclaimable idle pages in the memory.low==0 background groups.

> One thing which is found to fix the above problems is to have both global LRU and the per-memcg LRU.
> Global reclaim can use the global LRU thus fixing the above 3 issues. The memcg LRUs can then be used
> for soft reclaim or a proactive reclaim similar to Minchan's Per process reclaim for the background or
> low priority tasks. I have been trying this change on 4.4 kernel (yet to try the per-app
> reclaim/soft reclaim part). One downside is the extra list_head in struct page and the memory it consumes.

That would be a major step backwards, and I'm not entirely convinced
that the issues you are seeing cannot be fixed by improving the way we
do global round-robin reclaim and/or configuring memory.low.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
