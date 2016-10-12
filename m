Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 70ADC6B0253
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:36:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c78so3089769wme.1
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 22:36:14 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id mu9si8433238wjb.18.2016.10.11.22.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 22:36:13 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 202371C2063
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:36:13 +0100 (IST)
Date: Wed, 12 Oct 2016 06:36:11 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/4] mm: prevent double decrease of nr_reserved_highatomic
Message-ID: <20161012053611.GB22174@techsingularity.net>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1475819136-24358-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Fri, Oct 07, 2016 at 02:45:34PM +0900, Minchan Kim wrote:
> There is race between page freeing and unreserved highatomic.
> 
>  CPU 0				    CPU 1
> 
>     free_hot_cold_page
>       mt = get_pfnblock_migratetype
>       set_pcppage_migratetype(page, mt)
>     				    unreserve_highatomic_pageblock
>     				    spin_lock_irqsave(&zone->lock)
>     				    move_freepages_block
>     				    set_pageblock_migratetype(page)
>     				    spin_unlock_irqrestore(&zone->lock)
>       free_pcppages_bulk
>         __free_one_page(mt) <- mt is stale
> 
> By above race, a page on CPU 0 could go non-highorderatomic free list
> since the pageblock's type is changed. By that, unreserve logic of
> highorderatomic can decrease reserved count on a same pageblock
> several times and then it will make mismatch between
> nr_reserved_highatomic and the number of reserved pageblock.
> 
> So, this patch verifies whether the pageblock is highatomic or not
> and decrease the count only if the pageblock is highatomic.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
