Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 51A816B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 09:45:32 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n186so181850451wmn.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 06:45:32 -0800 (PST)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id e127si10959133wmd.94.2016.03.09.06.45.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 06:45:30 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 88FC798BE6
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 14:45:30 +0000 (UTC)
Date: Wed, 9 Mar 2016 14:45:29 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/27] mm, vmscan: Make kswapd reclaim in terms of nodes
Message-ID: <20160309144529.GB31585@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-9-git-send-email-mgorman@techsingularity.net>
 <56D84026.3010409@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <56D84026.3010409@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 03, 2016 at 02:46:14PM +0100, Vlastimil Babka wrote:
> On 02/23/2016 04:04 PM, Mel Gorman wrote:
> > -static bool zone_balanced(struct zone *zone, int order, bool highorder,
> > +static bool zone_balanced(struct zone *zone, int order,
> >  			unsigned long balance_gap, int classzone_idx)
> >  {
> >  	unsigned long mark = high_wmark_pages(zone) + balance_gap;
> >  
> > -	/*
> > -	 * When checking from pgdat_balanced(), kswapd should stop and sleep
> > -	 * when it reaches the high order-0 watermark and let kcompactd take
> > -	 * over. Other callers such as wakeup_kswapd() want to determine the
> > -	 * true high-order watermark.
> > -	 */
> > -	if (IS_ENABLED(CONFIG_COMPACTION) && !highorder) {
> > -		mark += (1UL << order);
> > -		order = 0;
> > -	}
> > -
> >  	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);
> 
> Did you really intend to remove this or was it due to rebasing on top of
> kcompactd?

It was intentional because kswapd_shrink_node() sets sc.order to 0 when
pages have been reclaimed. There is no guarantee it'll be enough to actually
compact but it's conservative in terms of reclaim. The end result should
be that this check is no longer necessary.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
