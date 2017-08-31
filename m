Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01EBA6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 21:40:05 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u15so15278140pgb.7
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 18:40:04 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l91si5586577plb.721.2017.08.30.18.40.02
        for <linux-mm@kvack.org>;
        Wed, 30 Aug 2017 18:40:03 -0700 (PDT)
Date: Thu, 31 Aug 2017 10:40:49 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/cma: manage the memory of the CMA area by using
 the ZONE_MOVABLE
Message-ID: <20170831014048.GA24271@js1304-P5Q-DELUXE>
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1503556593-10720-2-git-send-email-iamjoonsoo.kim@lge.com>
 <adae04f0-73f4-7772-d056-9ed13122af0e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <adae04f0-73f4-7772-d056-9ed13122af0e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Tue, Aug 29, 2017 at 11:16:18AM +0200, Vlastimil Babka wrote:
> On 08/24/2017 08:36 AM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > 0. History
> > 
> > This patchset is the follow-up of the discussion about the
> > "Introduce ZONE_CMA (v7)" [1]. Please reference it if more information
> > is needed.
> > 
> 
> [...]
> 
> > 
> > [1]: lkml.kernel.org/r/1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com
> > [2]: https://lkml.org/lkml/2014/10/15/623
> > [3]: http://www.spinics.net/lists/linux-mm/msg100562.html
> > 
> > Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> The previous version has introduced ZONE_CMA, so I would think switching
> to ZONE_MOVABLE is enough to drop previous reviews. Perhaps most of the
> code involved is basically the same, though?

Yes, most of the code involved is the same. I considered to drop
previous review tags but most of the code and concept is the same so I
decide to keep review tags. I should mention it in cover-letter but I
forgot to mention it. Sorry about that.

> Anyway I checked the current patch and did some basic tests with qemu,
> so you can keep my ack.

Thanks!

> 
> BTW, if we dropped NR_FREE_CMA_PAGES, could we also drop MIGRATE_CMA and
> related hooks? Is that counter really that useful as it works right now?
> It will decrease both by CMA allocations (which has to be explicitly
> freed) and by movable allocations (which can be migrated). What if only
> CMA alloc/release touched it?

I think that NR_FREE_CMA_PAGES would not be as useful as previous. We
can remove it.

However, removing MIGRATE_CMA has a problem. There is an usecase to
check if the page comes from the CMA area or not. See
check_page_span() in mm/usercopy.c. I can implement it differently by
iterating whole CMA area and finding the match, but I'm not sure it's
performance effect. I guess that it would be marginal.

Anyway, I'd like not to cause any side-effect now. After patches are
settle down on mainline, I will try to remove them as you suggested.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
