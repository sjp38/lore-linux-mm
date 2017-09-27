Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3EDF6B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 03:16:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q75so21474800pfl.1
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 00:16:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p84si6823936pfi.246.2017.09.27.00.16.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 00:16:13 -0700 (PDT)
Date: Wed, 27 Sep 2017 09:16:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 1/2] mm: avoid marking swap cached page as lazyfree
Message-ID: <20170927071609.vywaxvf4gsn2pcvn@dhcp22.suse.cz>
References: <cover.1506105110.git.shli@fb.com>
 <e4e1de7f06de9f6f50fd64b83d7da7b9597d2d97.1506105110.git.shli@fb.com>
 <20170926130705.wjtw55kj7cw4k34j@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926130705.wjtw55kj7cw4k34j@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, Artem Savkov <asavkov@redhat.com>, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

[ups this got stuck in the outgoing queue]

On Tue 26-09-17 15:07:05, Michal Hocko wrote:
> On Fri 22-09-17 11:46:30, Shaohua Li wrote:
> > From: Shaohua Li <shli@fb.com>
> > 
> > MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
> > SwapBacked). There is no lock to prevent the page is added to swap cache
> > between these two steps by page reclaim. If the page is added to swap
> > cache, marking the page lazyfree will confuse page fault if the page is
> > reclaimed and refault.
> 
> Could you be more specific how exactly what kind of the confusion is the
> result? I suspect you are talking about VM_BUG_ON_PAGE in
> __add_to_swap_cache right?

I completely mixed reclaim and the #PF path here

> I am also not sure how that would actually happen to be honest. If we
> raced with the reclaim then the page should have been isolated and so
> PageLRU is no longer true. Or am I missing something?

And here I've completely missed that the swapcache page will go back to
the LRU. Stupid me. Your new changelog [1] explained it all. Thanks and
sorry for these stupid questions.

[1] http://lkml.kernel.org/r/6537ef3814398c0073630b03f176263bc81f0902.1506446061.git.shli@fb.com
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
