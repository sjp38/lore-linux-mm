Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9CB6B0253
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 10:30:32 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id l13so27077729itl.0
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 07:30:32 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 20si24344728ioe.163.2016.10.07.07.30.30
        for <linux-mm@kvack.org>;
        Fri, 07 Oct 2016 07:30:31 -0700 (PDT)
Date: Fri, 7 Oct 2016 23:30:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/4] mm: prevent double decrease of nr_reserved_highatomic
Message-ID: <20161007143025.GB3060@bbox>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-3-git-send-email-minchan@kernel.org>
 <6bcd7066-2748-8a96-4479-f85b18765948@suse.cz>
MIME-Version: 1.0
In-Reply-To: <6bcd7066-2748-8a96-4479-f85b18765948@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Fri, Oct 07, 2016 at 02:44:15PM +0200, Vlastimil Babka wrote:
> On 10/07/2016 07:45 AM, Minchan Kim wrote:
> >There is race between page freeing and unreserved highatomic.
> >
> > CPU 0				    CPU 1
> >
> >    free_hot_cold_page
> >      mt = get_pfnblock_migratetype
> 
> so here mt == MIGRATE_HIGHATOMIC?

Yes.

> 
> >      set_pcppage_migratetype(page, mt)
> >    				    unreserve_highatomic_pageblock
> >    				    spin_lock_irqsave(&zone->lock)
> >    				    move_freepages_block
> >    				    set_pageblock_migratetype(page)
> >    				    spin_unlock_irqrestore(&zone->lock)
> >      free_pcppages_bulk
> >        __free_one_page(mt) <- mt is stale
> >
> >By above race, a page on CPU 0 could go non-highorderatomic free list
> >since the pageblock's type is changed.
> >By that, unreserve logic of
> >highorderatomic can decrease reserved count on a same pageblock
> >several times and then it will make mismatch between
> >nr_reserved_highatomic and the number of reserved pageblock.
> 
> Hmm I see.
> 
> >So, this patch verifies whether the pageblock is highatomic or not
> >and decrease the count only if the pageblock is highatomic.
> 
> Yeah I guess that's the easiest solution.
> 
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks, Vlastimil.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
