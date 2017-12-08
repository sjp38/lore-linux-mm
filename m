Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2E266B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 16:49:43 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i83so1561024wma.4
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 13:49:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i15si6573160wrf.104.2017.12.08.13.49.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 13:49:40 -0800 (PST)
Date: Fri, 8 Dec 2017 13:49:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: page_alloc: avoid excessive IRQ disabled times
 in free_unref_page_list
Message-Id: <20171208134937.489042cb1283039cc83caaac@linux-foundation.org>
In-Reply-To: <20171208114217.8491-1-l.stach@pengutronix.de>
References: <20171208114217.8491-1-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, patchwork-lst@pengutronix.de, kernel@pengutronix.de

On Fri,  8 Dec 2017 12:42:17 +0100 Lucas Stach <l.stach@pengutronix.de> wrote:

> Since 9cca35d42eb6 (mm, page_alloc: enable/disable IRQs once when freeing
> a list of pages) we see excessive IRQ disabled times of up to 25ms on an
> embedded ARM system (tracing overhead included).
> 
> This is due to graphics buffers being freed back to the system via
> release_pages(). Graphics buffers can be huge, so it's not hard to hit
> cases where the list of pages to free has 2048 entries. Disabling IRQs
> while freeing all those pages is clearly not a good idea.
> 
> Introduce a batch limit, which allows IRQ servicing once every few pages.
> The batch count is the same as used in other parts of the MM subsystem
> when dealing with IRQ disabled regions.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> v2: Try to keep the working set of pages used in the second loop cache
>     hot by going through both loops in swathes of SWAP_CLUSTER_MAX
>     entries, as suggested by Andrew Morton.
> 
>     To avoid the need to replicate the batch counting in both loops
>     I introduced a local batched_free_list where pages to be freed
>     in the critical section are collected. IMO this makes the code
>     easier to follow.

Thanks.  Is anyone motivated enough to determine whether this is
worthwhile?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
