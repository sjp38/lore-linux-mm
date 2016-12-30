Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E63D86B0038
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 21:05:25 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u5so580616354pgi.7
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 18:05:25 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h9si25327474pli.37.2016.12.29.18.05.24
        for <linux-mm@kvack.org>;
        Thu, 29 Dec 2016 18:05:25 -0800 (PST)
Date: Fri, 30 Dec 2016 11:05:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161230020522.GC4184@bbox>
References: <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
 <20161226124839.GB20715@dhcp22.suse.cz>
 <20161227155532.GI1308@dhcp22.suse.cz>
 <20161229012026.GB15541@bbox>
 <20161229090432.GE29208@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20161229090432.GE29208@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nils Holland <nholland@tisys.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Thu, Dec 29, 2016 at 10:04:32AM +0100, Michal Hocko wrote:
> On Thu 29-12-16 10:20:26, Minchan Kim wrote:
> > On Tue, Dec 27, 2016 at 04:55:33PM +0100, Michal Hocko wrote:
> > > Hi,
> > > could you try to run with the following patch on top of the previous
> > > one? I do not think it will make a large change in your workload but
> > > I think we need something like that so some testing under which is known
> > > to make a high lowmem pressure would be really appreciated. If you have
> > > more time to play with it then running with and without the patch with
> > > mm_vmscan_direct_reclaim_{start,end} tracepoints enabled could tell us
> > > whether it make any difference at all.
> > > 
> > > I would also appreciate if Mel and Johannes had a look at it. I am not
> > > yet sure whether we need the same thing for anon/file balancing in
> > > get_scan_count. I suspect we need but need to think more about that.
> > > 
> > > Thanks a lot again!
> > > ---
> > > From b51f50340fe9e40b68be198b012f8ab9869c1850 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Tue, 27 Dec 2016 16:28:44 +0100
> > > Subject: [PATCH] mm, vmscan: consider eligible zones in get_scan_count
> > > 
> > > get_scan_count considers the whole node LRU size when
> > > - doing SCAN_FILE due to many page cache inactive pages
> > > - calculating the number of pages to scan
> > > 
> > > in both cases this might lead to unexpected behavior especially on 32b
> > > systems where we can expect lowmem memory pressure very often.
> > > 
> > > A large highmem zone can easily distort SCAN_FILE heuristic because
> > > there might be only few file pages from the eligible zones on the node
> > > lru and we would still enforce file lru scanning which can lead to
> > > trashing while we could still scan anonymous pages.
> > 
> > Nit:
> > It doesn't make thrashing because isolate_lru_pages filter out them
> > but I agree it makes pointless CPU burning to find eligible pages.
> 
> This is not about isolate_lru_pages. The trashing could happen if we had
> lowmem pagecache user which would constantly reclaim recently faulted
> in pages while there is anonymous memory in the lowmem which could be
> reclaimed instead.
>  
> [...]
> > >  /*
> > > + * Return the number of pages on the given lru which are eligibne for the
> >                                                             eligible
> 
> fixed
> 
> > > + * given zone_idx
> > > + */
> > > +static unsigned long lruvec_lru_size_zone_idx(struct lruvec *lruvec,
> > > +		enum lru_list lru, int zone_idx)
> > 
> > Nit:
> > 
> > Although there is a comment, function name is rather confusing when I compared
> > it with lruvec_zone_lru_size.
> 
> I am all for a better name.
> 
> > lruvec_eligible_zones_lru_size is better?
> 
> this would be too easy to confuse with lruvec_eligible_zone_lru_size.
> What about lruvec_lru_size_eligible_zones?

Don't mind.

>  
> > Nit:
> > 
> > With this patch, inactive_list_is_low can use lruvec_lru_size_zone_idx rather than
> > own custom calculation to filter out non-eligible pages. 
> 
> Yes, that would be possible and I was considering that. But then I found
> useful to see total and reduced numbers in the tracepoint
> http://lkml.kernel.org/r/20161228153032.10821-8-mhocko@kernel.org
> and didn't want to call lruvec_lru_size 2 times. But if you insist then
> I can just do that.

I don't mind either but I think we need to describe the reason if you want to
go with your open-coded version. Otherwise, someone will try to fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
