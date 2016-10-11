Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD51A6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 04:01:11 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x23so8928921lfi.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 01:01:11 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id c67si1189509lfe.227.2016.10.11.01.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 01:01:10 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id p80so2258522lfp.1
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 01:01:10 -0700 (PDT)
Date: Tue, 11 Oct 2016 10:01:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm: unreserve highatomic free pages fully before OOM
Message-ID: <20161011080108.GE31996@dhcp22.suse.cz>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-4-git-send-email-minchan@kernel.org>
 <20161007090917.GA18447@dhcp22.suse.cz>
 <20161007144345.GC3060@bbox>
 <20161010074139.GB20420@dhcp22.suse.cz>
 <20161011050141.GB30973@bbox>
 <20161011065048.GB31996@dhcp22.suse.cz>
 <20161011070945.GA21238@bbox>
 <20161011072605.GD31996@dhcp22.suse.cz>
 <20161011073716.GA22314@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011073716.GA22314@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Tue 11-10-16 16:37:16, Minchan Kim wrote:
> On Tue, Oct 11, 2016 at 09:26:06AM +0200, Michal Hocko wrote:
> > On Tue 11-10-16 16:09:45, Minchan Kim wrote:
[...]
> > > @@ -2154,12 +2156,24 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> > >  			 * may increase.
> > >  			 */
> > >  			set_pageblock_migratetype(page, ac->migratetype);
> > > -			move_freepages_block(zone, page, ac->migratetype);
> > > -			spin_unlock_irqrestore(&zone->lock, flags);
> > > -			return;
> > > +			ret = move_freepages_block(zone, page,
> > > +						ac->migratetype);
> > > +			/*
> > > +			 * By race with page freeing functions, !highatomic
> > > +			 * pageblocks can have free pages in highatomic free
> > > +			 * list so if drain is true, try to unreserve every
> > > +			 * free pages in highatomic free list without bailing
> > > +			 * out.
> > > +			 */
> > > +			if (!drain) {
> > 
> > 			if (ret)
> > > +				spin_unlock_irqrestore(&zone->lock, flags);
> > > +				return ret;
> > > +			}
> > 
> > arguably this would work better also for !drain case which currently
> > tries to unreserve but in case of the race it would do nothing.
> 
> I thought it but I was afraid if you say again it's over complicated.

Well, maybe there is even better/easier solution. Anyway, if
I were you I would just split it into two patches. The first
to unreserve from shoudl_reclaim_retry and the later to make
unreserve_highatomic_pageblock more reliable.

> I will do it with your SOB in next spin.

ok, thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
