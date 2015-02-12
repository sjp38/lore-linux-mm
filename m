Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id BAD746B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:08:26 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id eu11so9459317pac.10
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:08:26 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ml3si3857880pab.144.2015.02.11.23.08.23
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:08:25 -0800 (PST)
Date: Thu, 12 Feb 2015 16:10:37 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: fix negative nr_isolated counts
Message-ID: <20150212071037.GA3570@js1304-P5Q-DELUXE>
References: <alpine.LSU.2.11.1502102303040.13607@eggly.anvils>
 <54DB27B5.9060207@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54DB27B5.9060207@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, Feb 11, 2015 at 10:58:13AM +0100, Vlastimil Babka wrote:
> On 02/11/2015 08:06 AM, Hugh Dickins wrote:
> >The vmstat interfaces are good at hiding negative counts (at least
> >when CONFIG_SMP); but if you peer behind the curtain, you find that
> >nr_isolated_anon and nr_isolated_file soon go negative, and grow ever
> >more negative: so they can absorb larger and larger numbers of isolated
> >pages, yet still appear to be zero.
> >
> >I'm happy to avoid a congestion_wait() when too_many_isolated() myself;
> >but I guess it's there for a good reason, in which case we ought to get
> >too_many_isolated() working again.
> >
> >The imbalance comes from isolate_migratepages()'s ISOLATE_ABORT case:
> >putback_movable_pages() decrements the NR_ISOLATED counts, but we forgot
> >to call acct_isolated() to increment them.
> >
> >Fixes: edc2ca612496 ("mm, compaction: move pageblock checks up from isolate_migratepages_range()")
> 
> Ccing Joonsoo for completeness, as it seems he contributed to this
> part [1] (to fix another bug of mine, not trying to dismiss
> responsibility)
> 
> But yeah it looks correct. Thanks for finding and fixing!

Yes, it looks correct to me.

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> [1] https://lkml.org/lkml/2014/9/29/60
> 
> >Signed-off-by: Hugh Dickins <hughd@google.com>
> >Cc: stable@vger.kernel.org # v3.18+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
