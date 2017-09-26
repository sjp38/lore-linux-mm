Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F327E6B025E
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 16:24:03 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j16so23167044pga.6
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 13:24:03 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 73si6171890pfr.122.2017.09.26.13.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 13:24:02 -0700 (PDT)
Date: Tue, 26 Sep 2017 12:46:28 -0700
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH V3 2/2] mm: fix data corruption caused by lazyfree page
Message-ID: <20170926194628.ii5ugcow7jcqdgqg@kernel.org>
References: <cover.1506446061.git.shli@fb.com>
 <08c84256b007bf3f63c91d94383bd9eb6fee2daa.1506446061.git.shli@fb.com>
 <20170926194017.GB30943@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926194017.GB30943@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, asavkov@redhat.com, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 26, 2017 at 03:40:17PM -0400, Johannes Weiner wrote:
> On Tue, Sep 26, 2017 at 10:26:26AM -0700, Shaohua Li wrote:
> > From: Shaohua Li <shli@fb.com>
> > 
> > MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
> > SwapBacked). There is no lock to prevent the page is added to swap cache
> > between these two steps by page reclaim. If page reclaim finds such
> > page, it will simply add the page to swap cache without pageout the page
> > to swap because the page is marked as clean. Next time, page fault will
> > read data from the swap slot which doesn't have the original data, so we
> > have a data corruption. To fix issue, we mark the page dirty and pageout
> > the page.
> 
> Reclaim and MADV_FREE hold the page lock when manipulating the dirty
> and the swapcache state.
> 
> Instead of undoing a racing MADV_FREE in reclaim, wouldn't it be safe
> to check the dirty bit before add_to_swap() and skip clean pages?

That would work, but I don't see an easy/clean way to check the dirty bit.
Since the race is rare, I think this optimiztion isn't worthy.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
