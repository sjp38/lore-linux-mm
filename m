Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A76196B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 11:37:50 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2056314pzk.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 08:37:49 -0700 (PDT)
Date: Tue, 31 May 2011 00:37:43 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v2] mm: compaction: fix special case -1 order checks
Message-ID: <20110530153743.GA2200@barrios-laptop>
References: <20110530123831.GG20166@tiehlicka.suse.cz>
 <20110530151633.GB1505@barrios-laptop>
 <20110530152450.GH20166@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110530152450.GH20166@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, May 30, 2011 at 05:24:50PM +0200, Michal Hocko wrote:
> On Tue 31-05-11 00:16:33, Minchan Kim wrote:
> > >  	/* Direct compactor: Is a suitable page free? */
> > >  	for (order = cc->order; order < MAX_ORDER; order++) {
> > >  		/* Job done if page is free of the right migratetype */
> > 
> > It looks good to me.
> > Let's think about another place, compaction_suitable.
> 
> Good spotted.
> 
> > It has same problem so we can move the check right before zone_watermark_ok.
> > As I look it more, I thought we need free pages for compaction so we would 
> > be better to give up early if we can't get enough free pages. But I changed
> > my mind. It's a totally user request and we can get free pages in migration
> > progress(ex, other big memory hogger might free his big rss). 
> > So my conclusion is that we should do *best effort* than early give up.
> 
> Agreed
> 
> > If you agree with me, how about resending patch with compaction_suitable fix?
> 
> Here we go. Thanks
> 
> ---
> mm: compaction: fix special case -1 order checks
> 
> 56de7263 (mm: compaction: direct compact when a high-order allocation
> fails) introduced a check for cc->order == -1 in compact_finished. We
> should continue compacting in that case because the request came from
> userspace and there is no particular order to compact for.
> Similar check has been added by 82478fb7 (mm: compaction:
> prevent division-by-zero during user-requested compaction) for
> compaction_suitable.
> 
> The check is, however, done after zone_watermark_ok which uses order as
> a right hand argument for shifts. Not only watermark check is pointless
> if we can break out without it but it also uses 1 << -1 which is not
> well defined (at least from C standard). Let's move the -1 check above
> zone_watermark_ok.
> 
> [Minchan Kim <minchan.kim@gmail.com> - caught compaction_suitable]
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
