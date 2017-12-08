Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA036B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 05:21:33 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 96so5645067wrk.7
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 02:21:33 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id 88si136750edy.434.2017.12.08.02.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 02:21:31 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 865071C3055
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 10:21:31 +0000 (GMT)
Date: Fri, 8 Dec 2017 10:21:30 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: avoid excessive IRQ disabled times in
 free_unref_page_list
Message-ID: <20171208102130.4d4rwpwkseziniug@techsingularity.net>
References: <20171207170314.4419-1-l.stach@pengutronix.de>
 <20171207195103.dkiqjoeasr35atqj@techsingularity.net>
 <20171207152059.96ebc2f7dfd1a65a91252029@linux-foundation.org>
 <20171208002537.z6h3v2yojnlcu3ai@techsingularity.net>
 <20171207165317.9ef234b9f83cb62cdad72427@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171207165317.9ef234b9f83cb62cdad72427@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lucas Stach <l.stach@pengutronix.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On Thu, Dec 07, 2017 at 04:53:17PM -0800, Andrew Morton wrote:
> On Fri, 8 Dec 2017 00:25:37 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > Well, it's release_pages. From core VM and the block layer, not very long
> > but for drivers and filesystems, it can be arbitrarily long. Even from the
> > VM, the function can be called a lot but as it's from pagevec context so
> > it's naturally broken into small pieces anyway.
> 
> OK.
> 
> > > If "significantly" then there may be additional benefit in rearranging
> > > free_hot_cold_page_list() so it only walks a small number of list
> > > entries at a time.  So the data from the first loop is still in cache
> > > during execution of the second loop.  And that way this
> > > long-irq-off-time problem gets fixed automagically.
> > > 
> > 
> > I'm not sure it's worthwhile. In too many cases, the list of pages being
> > released are either cache cold or are so long that the cache data is
> > being thrashed anyway.
> 
> Well, whether the incoming data is cache-cold or very-long, doing that
> double pass in small bites would reduce thrashing.
> 
> > Once the core page allocator is involved, then
> > there will be further cache thrashing due to buddy page merging accessing
> > data that is potentially very close. I think it's unlikely there would be
> > much value in using alternative schemes unless we were willing to have
> > very large per-cpu lists -- something I prototyped for fast networking
> > but never heard back whether it's worthwhile or not.
> 
> I mean something like this....
> 

Ok yes, I see. That is a viable alternative to Lucas's patch that should
achieve the same result with the bonus of some of the entries still being
cache hot. Lucas, care to give it a spin and see does it also address
your problem?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
