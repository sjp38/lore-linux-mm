Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09C37280842
	for <linux-mm@kvack.org>; Wed, 10 May 2017 03:22:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 44so5685559wry.5
        for <linux-mm@kvack.org>; Wed, 10 May 2017 00:22:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f124si3006013wmg.140.2017.05.10.00.22.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 00:22:08 -0700 (PDT)
Date: Wed, 10 May 2017 09:22:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: scan pages until it founds eligible pages
Message-ID: <20170510072205.GB31466@dhcp22.suse.cz>
References: <1493700038-27091-1-git-send-email-minchan@kernel.org>
 <20170502051452.GA27264@bbox>
 <20170502075432.GC14593@dhcp22.suse.cz>
 <20170502145150.GA19011@bgram>
 <20170502151436.GN14593@dhcp22.suse.cz>
 <20170503044809.GA21619@bgram>
 <20170503060044.GA1236@dhcp22.suse.cz>
 <20170510014654.GA23584@bbox>
 <20170510061312.GB26158@dhcp22.suse.cz>
 <20170510070311.GA24772@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510070311.GA24772@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 10-05-17 16:03:11, Minchan Kim wrote:
> On Wed, May 10, 2017 at 08:13:12AM +0200, Michal Hocko wrote:
> > On Wed 10-05-17 10:46:54, Minchan Kim wrote:
> > > On Wed, May 03, 2017 at 08:00:44AM +0200, Michal Hocko wrote:
[...]
> > > > +		scan++;
> > > >  		switch (__isolate_lru_page(page, mode)) {
> > > >  		case 0:
> > > >  			nr_pages = hpage_nr_pages(page);
> > > 
> > > Confirmed.
> > 
> > Hmm. I can clearly see how we could skip over too many pages and hit
> > small reclaim priorities too quickly but I am still scratching my head
> > about how we could hit the OOM killer as a result. The amount of pages
> > on the active anonymous list suggests that we are not able to rotate
> > pages quickly enough. I have to keep thinking about that.
> 
> I explained it but seems to be not enouggh. Let me try again.
> 
> The problem is that get_scan_count determines nr_to_scan with
> eligible zones.
> 
>         size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
>         size = size >> sc->priority;

Ohh, right. Who has done that ;) Now it is much more clear. We simply
reclaimed all the pages on the inactive LRU list and only very slowly
progress over active list and hit the OOM before we can actually reach
anything. I completely forgot about the scan window not being the full
LRU list.

Thanks for bearing with me!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
