Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 739B66B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 19:25:39 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i83so224138wma.4
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 16:25:39 -0800 (PST)
Received: from outbound-smtp24.blacknight.com (outbound-smtp24.blacknight.com. [81.17.249.192])
        by mx.google.com with ESMTPS id j33si2134389edc.182.2017.12.07.16.25.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 16:25:37 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp24.blacknight.com (Postfix) with ESMTPS id 85C52B8D8E
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 00:25:37 +0000 (GMT)
Date: Fri, 8 Dec 2017 00:25:37 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: avoid excessive IRQ disabled times in
 free_unref_page_list
Message-ID: <20171208002537.z6h3v2yojnlcu3ai@techsingularity.net>
References: <20171207170314.4419-1-l.stach@pengutronix.de>
 <20171207195103.dkiqjoeasr35atqj@techsingularity.net>
 <20171207152059.96ebc2f7dfd1a65a91252029@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171207152059.96ebc2f7dfd1a65a91252029@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lucas Stach <l.stach@pengutronix.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On Thu, Dec 07, 2017 at 03:20:59PM -0800, Andrew Morton wrote:
> On Thu, 7 Dec 2017 19:51:03 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > On Thu, Dec 07, 2017 at 06:03:14PM +0100, Lucas Stach wrote:
> > > Since 9cca35d42eb6 (mm, page_alloc: enable/disable IRQs once when freeing
> > > a list of pages) we see excessive IRQ disabled times of up to 250ms on an
> > > embedded ARM system (tracing overhead included).
> > > 
> > > This is due to graphics buffers being freed back to the system via
> > > release_pages(). Graphics buffers can be huge, so it's not hard to hit
> > > cases where the list of pages to free has 2048 entries. Disabling IRQs
> > > while freeing all those pages is clearly not a good idea.
> > > 
> > 
> > 250ms to free 2048 entries? That seems excessive but I guess the
> > embedded ARM system is not that fast.
> 
> I wonder how common such lenghty lists are.
> 

Well, it's release_pages. From core VM and the block layer, not very long
but for drivers and filesystems, it can be arbitrarily long. Even from the
VM, the function can be called a lot but as it's from pagevec context so
it's naturally broken into small pieces anyway.

> If "significantly" then there may be additional benefit in rearranging
> free_hot_cold_page_list() so it only walks a small number of list
> entries at a time.  So the data from the first loop is still in cache
> during execution of the second loop.  And that way this
> long-irq-off-time problem gets fixed automagically.
> 

I'm not sure it's worthwhile. In too many cases, the list of pages being
released are either cache cold or are so long that the cache data is
being thrashed anyway. Once the core page allocator is involved, then
there will be further cache thrashing due to buddy page merging accessing
data that is potentially very close. I think it's unlikely there would be
much value in using alternative schemes unless we were willing to have
very large per-cpu lists -- something I prototyped for fast networking
but never heard back whether it's worthwhile or not.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
