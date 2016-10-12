Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24AF96B0261
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:48:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u84so34904234pfj.6
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:48:46 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id hv8si6631134pad.137.2016.10.12.00.48.44
        for <linux-mm@kvack.org>;
        Wed, 12 Oct 2016 00:48:45 -0700 (PDT)
Date: Wed, 12 Oct 2016 16:48:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 4/4] mm: make unreserve highatomic functions reliable
Message-ID: <20161012074838.GA7688@bbox>
References: <1476250416-22733-1-git-send-email-minchan@kernel.org>
 <1476250416-22733-5-git-send-email-minchan@kernel.org>
 <20161012073328.GC9504@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20161012073328.GC9504@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Wed, Oct 12, 2016 at 09:33:28AM +0200, Michal Hocko wrote:
> On Wed 12-10-16 14:33:36, Minchan Kim wrote:
> [...]
> > @@ -2138,8 +2146,10 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
> >  			 */
> >  			set_pageblock_migratetype(page, ac->migratetype);
> >  			ret = move_freepages_block(zone, page, ac->migratetype);
> > -			spin_unlock_irqrestore(&zone->lock, flags);
> > -			return ret;
> > +			if (!drain && ret) {
> > +				spin_unlock_irqrestore(&zone->lock, flags);
> > +				return ret;
> > +			}
> 
> I've already mentioned that during the previous discussion. This sounds

Yeb, we did but I sent wrong version in my git tree. :(

> overly aggressive to me. Why do we want to drain the whole reserve and
> risk that we won't be able to build up a new one after OOM. Doing one
> block at the time should be sufficient IMHO.

I will resend with updating with every reveiw points.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
