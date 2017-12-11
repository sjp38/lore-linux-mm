Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02E516B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 06:02:31 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j4so10238570wrg.15
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 03:02:30 -0800 (PST)
Received: from outbound-smtp11.blacknight.com ([46.22.139.106])
        by mx.google.com with ESMTPS id j34si128190edb.273.2017.12.11.03.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 03:02:28 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id D68A71C29C8
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 11:02:27 +0000 (GMT)
Date: Mon, 11 Dec 2017 11:02:24 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm: page_alloc: avoid excessive IRQ disabled times in
 free_unref_page_list
Message-ID: <20171211104342.4bkmczdhdi227wu7@techsingularity.net>
References: <20171208114217.8491-1-l.stach@pengutronix.de>
 <20171208134937.489042cb1283039cc83caaac@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171208134937.489042cb1283039cc83caaac@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lucas Stach <l.stach@pengutronix.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, patchwork-lst@pengutronix.de, kernel@pengutronix.de

On Fri, Dec 08, 2017 at 01:49:37PM -0800, Andrew Morton wrote:
> On Fri,  8 Dec 2017 12:42:17 +0100 Lucas Stach <l.stach@pengutronix.de> wrote:
> 
> > Since 9cca35d42eb6 (mm, page_alloc: enable/disable IRQs once when freeing
> > a list of pages) we see excessive IRQ disabled times of up to 25ms on an
> > embedded ARM system (tracing overhead included).
> > 
> > This is due to graphics buffers being freed back to the system via
> > release_pages(). Graphics buffers can be huge, so it's not hard to hit
> > cases where the list of pages to free has 2048 entries. Disabling IRQs
> > while freeing all those pages is clearly not a good idea.
> > 
> > Introduce a batch limit, which allows IRQ servicing once every few pages.
> > The batch count is the same as used in other parts of the MM subsystem
> > when dealing with IRQ disabled regions.
> > 
> > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> > Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > v2: Try to keep the working set of pages used in the second loop cache
> >     hot by going through both loops in swathes of SWAP_CLUSTER_MAX
> >     entries, as suggested by Andrew Morton.
> > 
> >     To avoid the need to replicate the batch counting in both loops
> >     I introduced a local batched_free_list where pages to be freed
> >     in the critical section are collected. IMO this makes the code
> >     easier to follow.
> 
> Thanks.  Is anyone motivated enough to determine whether this is
> worthwhile?
> 

I didn't try and I'm not sure I'll get time before dropping offline for
holidays but I would expect the benefit to be marginal and only detected
through close examination of cache miss stats. We're talking about the
cache hotness of a few struct pages for one set of operations before the
pages are back on the per-cpu lists. For any large release_pages operation,
they are likely to be pushed off the per-cpu lists and onto the buddy
lists where the cache data will be thrashed in the near future. It's
a nice micro-optimisation but I expect it to be lost in the noise of a
release_pages operation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
