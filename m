Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6F7A6B0253
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 10:09:51 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so84335360wma.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 07:09:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ay9si81690378wjc.120.2017.01.04.07.09.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 07:09:50 -0800 (PST)
Date: Wed, 4 Jan 2017 16:09:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/7] mm, vmscan: extract shrink_page_list reclaim
 counters into a struct
Message-ID: <20170104150947.GP25453@dhcp22.suse.cz>
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-6-mhocko@kernel.org>
 <01c9e2c9-3a04-48cd-cf0e-265db33d1a24@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01c9e2c9-3a04-48cd-cf0e-265db33d1a24@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 04-01-17 15:51:43, Vlastimil Babka wrote:
[...]
> > @@ -1266,11 +1270,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  	list_splice(&ret_pages, page_list);
> >  	count_vm_events(PGACTIVATE, pgactivate);
> >  
> > -	*ret_nr_dirty += nr_dirty;
> > -	*ret_nr_congested += nr_congested;
> > -	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
> > -	*ret_nr_writeback += nr_writeback;
> > -	*ret_nr_immediate += nr_immediate;
> > +	if (stat) {
> > +		stat->nr_dirty = nr_dirty;
> > +		stat->nr_congested = nr_congested;
> > +		stat->nr_unqueued_dirty = nr_unqueued_dirty;
> > +		stat->nr_writeback = nr_writeback;
> > +		stat->nr_immediate = nr_immediate;
> > +	}
> 
> This change of '+=' to '=' raised my eybrows, but it seems both callers
> don't care so this is indeed no functional change and potentially faster.

Yes, I was quite surprised as well, maybe we had a code which relied on
the aggregated numbers in the past but I didn't bother to go over git
logs to check. There is no such user anymore...
 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
