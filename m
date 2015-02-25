Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A05126B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 19:27:38 -0500 (EST)
Received: by pdjg10 with SMTP id g10so687197pdj.1
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:27:38 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id br8si2339835pdb.43.2015.02.24.16.27.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 16:27:37 -0800 (PST)
Received: by pdev10 with SMTP id v10so594640pde.10
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:27:37 -0800 (PST)
Date: Wed, 25 Feb 2015 09:27:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC 3/4] mm: move lazy free pages to inactive list
Message-ID: <20150225002728.GB6468@blaptop>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <1424765897-27377-3-git-send-email-minchan@kernel.org>
 <20150224161408.GB14939@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224161408.GB14939@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

On Tue, Feb 24, 2015 at 05:14:08PM +0100, Michal Hocko wrote:
> On Tue 24-02-15 17:18:16, Minchan Kim wrote:
> > MADV_FREE is hint that it's okay to discard pages if memory is
> > pressure and we uses reclaimers(ie, kswapd and direct reclaim)
> 
> s@if memory is pressure@if there is memory pressure@
> 
> > to free them so there is no worth to remain them in active
> > anonymous LRU list so this patch moves them to inactive LRU list.
> 
> Makes sense to me.
> 
> > A arguable issue for the approach is whether we should put it
> > head or tail in inactive list
> 
> Is it really arguable? Why should active MADV_FREE pages appear before
> those which were living on the inactive list. This doesn't make any
> sense to me.

It would be better to drop garbage pages(ie, freed from allocator)
rather than swap out and now anon LRU aging is seq model so
inacitve list can include a lot working set so putting hinted pages
into tail of LRU could enhance reclaim efficiency.
That's why I said it might be arguble.

> 
> > and selected it as head because
> > kernel cannot make sure it's really cold or warm for every usecase
> > but at least we know it's not hot so landing of inactive head
> > would be comprimise if it stayed in active LRU.
> 
> This is really hard to read. What do you think about the following
> wording?
> "
> The active status of those pages is cleared and they are moved to the
> head of the inactive LRU. This means that MADV_FREE-ed pages which
> were living on the inactive list are reclaimed first because they
> are more likely to be cold rather than recently active pages.
> "

My phrase is to focus why we should put them into head of inactive
so it's orthogonal with your phrase and maybe my phrase could be
complement.

> 
> > As well, if we put recent hinted pages to inactive's tail,
> > VM could discard cache hot pages, which would be bad.
> > 
> > As a bonus, we don't need to move them back and forth in inactive
> > list whenever MADV_SYSCALL syscall is called.
> > 
> > As drawback, VM should scan more pages in inactive anonymous LRU
> > to discard but it has happened all the time if recent reference
> > happens on those pages in inactive LRU list so I don't think
> > it's not a main drawback.
> 
> Rather than the above paragraphs I would like to see a description why
> this is needed. Something like the following?
> "
> This is fixing a suboptimal behavior of MADV_FREE when pages living on
> the active list will sit there for a long time even under memory
> pressure while the inactive list is reclaimed heavily. This basically
> breaks the whole purpose of using MADV_FREE to help the system to free
> memory which is might not be used.
> "

Good to me. I will add this. Thanks!

> 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Other than that the patch looks good to me.
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks for the review, Michal!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
