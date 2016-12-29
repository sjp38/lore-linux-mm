Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 994806B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 04:04:37 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so93266878wjb.3
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 01:04:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si23955929wme.37.2016.12.29.01.04.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Dec 2016 01:04:36 -0800 (PST)
Date: Thu, 29 Dec 2016 10:04:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161229090432.GE29208@dhcp22.suse.cz>
References: <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
 <20161226124839.GB20715@dhcp22.suse.cz>
 <20161227155532.GI1308@dhcp22.suse.cz>
 <20161229012026.GB15541@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161229012026.GB15541@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nils Holland <nholland@tisys.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Thu 29-12-16 10:20:26, Minchan Kim wrote:
> On Tue, Dec 27, 2016 at 04:55:33PM +0100, Michal Hocko wrote:
> > Hi,
> > could you try to run with the following patch on top of the previous
> > one? I do not think it will make a large change in your workload but
> > I think we need something like that so some testing under which is known
> > to make a high lowmem pressure would be really appreciated. If you have
> > more time to play with it then running with and without the patch with
> > mm_vmscan_direct_reclaim_{start,end} tracepoints enabled could tell us
> > whether it make any difference at all.
> > 
> > I would also appreciate if Mel and Johannes had a look at it. I am not
> > yet sure whether we need the same thing for anon/file balancing in
> > get_scan_count. I suspect we need but need to think more about that.
> > 
> > Thanks a lot again!
> > ---
> > From b51f50340fe9e40b68be198b012f8ab9869c1850 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Tue, 27 Dec 2016 16:28:44 +0100
> > Subject: [PATCH] mm, vmscan: consider eligible zones in get_scan_count
> > 
> > get_scan_count considers the whole node LRU size when
> > - doing SCAN_FILE due to many page cache inactive pages
> > - calculating the number of pages to scan
> > 
> > in both cases this might lead to unexpected behavior especially on 32b
> > systems where we can expect lowmem memory pressure very often.
> > 
> > A large highmem zone can easily distort SCAN_FILE heuristic because
> > there might be only few file pages from the eligible zones on the node
> > lru and we would still enforce file lru scanning which can lead to
> > trashing while we could still scan anonymous pages.
> 
> Nit:
> It doesn't make thrashing because isolate_lru_pages filter out them
> but I agree it makes pointless CPU burning to find eligible pages.

This is not about isolate_lru_pages. The trashing could happen if we had
lowmem pagecache user which would constantly reclaim recently faulted
in pages while there is anonymous memory in the lowmem which could be
reclaimed instead.
 
[...]
> >  /*
> > + * Return the number of pages on the given lru which are eligibne for the
>                                                             eligible

fixed

> > + * given zone_idx
> > + */
> > +static unsigned long lruvec_lru_size_zone_idx(struct lruvec *lruvec,
> > +		enum lru_list lru, int zone_idx)
> 
> Nit:
> 
> Although there is a comment, function name is rather confusing when I compared
> it with lruvec_zone_lru_size.

I am all for a better name.

> lruvec_eligible_zones_lru_size is better?

this would be too easy to confuse with lruvec_eligible_zone_lru_size.
What about lruvec_lru_size_eligible_zones?
 
> Nit:
> 
> With this patch, inactive_list_is_low can use lruvec_lru_size_zone_idx rather than
> own custom calculation to filter out non-eligible pages. 

Yes, that would be possible and I was considering that. But then I found
useful to see total and reduced numbers in the tracepoint
http://lkml.kernel.org/r/20161228153032.10821-8-mhocko@kernel.org
and didn't want to call lruvec_lru_size 2 times. But if you insist then
I can just do that.

> Anyway, I think this patch does right things so I suppose this.
> 
> Acked-by: Minchan Kim <minchan@kernel.org>

Thanks for the review!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
