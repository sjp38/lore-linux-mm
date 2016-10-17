Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 703726B0260
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 04:42:48 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d186so96002073lfg.7
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:42:48 -0700 (PDT)
Received: from mail-lf0-f68.google.com (mail-lf0-f68.google.com. [209.85.215.68])
        by mx.google.com with ESMTPS id 191si17885435lfz.327.2016.10.17.01.42.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 01:42:46 -0700 (PDT)
Received: by mail-lf0-f68.google.com with SMTP id x23so19716754lfi.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:42:46 -0700 (PDT)
Date: Mon, 17 Oct 2016 10:42:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161017084244.GF23322@dhcp22.suse.cz>
References: <20161013080936.GG21678@dhcp22.suse.cz>
 <20161014083219.GA20260@spreadtrum.com>
 <20161014113044.GB6063@dhcp22.suse.cz>
 <20161014134604.GA2179@blaptop>
 <20161014135334.GF6063@dhcp22.suse.cz>
 <20161014144448.GA2899@blaptop>
 <20161014150355.GH6063@dhcp22.suse.cz>
 <20161014152633.GA3157@blaptop>
 <20161015071044.GC9949@dhcp22.suse.cz>
 <20161016230618.GB9196@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161016230618.GB9196@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ming Ling <ming.ling@spreadtrum.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

On Mon 17-10-16 08:06:18, Minchan Kim wrote:
> Hi Michal,
> 
> On Sat, Oct 15, 2016 at 09:10:45AM +0200, Michal Hocko wrote:
> > On Sat 15-10-16 00:26:33, Minchan Kim wrote:
> > > On Fri, Oct 14, 2016 at 05:03:55PM +0200, Michal Hocko wrote:
> > [...]
> > > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > > index 0409a4ad6ea1..6584705a46f6 100644
> > > > --- a/mm/compaction.c
> > > > +++ b/mm/compaction.c
> > > > @@ -685,7 +685,8 @@ static bool too_many_isolated(struct zone *zone)
> > > >   */
> > > >  static unsigned long
> > > >  isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> > > > -			unsigned long end_pfn, isolate_mode_t isolate_mode)
> > > > +			unsigned long end_pfn, isolate_mode_t isolate_mode,
> > > > +			unsigned long *isolated_file, unsigned long *isolated_anon)
> > > >  {
> > > >  	struct zone *zone = cc->zone;
> > > >  	unsigned long nr_scanned = 0, nr_isolated = 0;
> > > > @@ -866,6 +867,10 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> > > >  
> > > >  		/* Successfully isolated */
> > > >  		del_page_from_lru_list(page, lruvec, page_lru(page));
> > > > +		if (page_is_file_cache(page))
> > > > +			(*isolated_file)++;
> > > > +		else
> > > > +			(*isolated_anon)++;
> > > >  
> > > >  isolate_success:
> > > >  		list_add(&page->lru, &cc->migratepages);
> > > > 
> > > > Makes more sense?
> > > 
> > > It is doable for isolation part. IOW, maybe we can make acct_isolated
> > > simple with those counters but we need to handle migrate, putback part.
> > > If you want to remove the check of __PageMoable with those counter, it
> > > means we should pass the counter on every functions related migration
> > > where isolate, migrate, putback parts.
> > 
> > OK, I see. Can we just get rid of acct_isolated altogether? Why cannot
> > we simply update NR_ISOLATED_* while isolating pages? Just looking at
> > isolate_migratepages_block:
> > 			acct_isolated(zone, cc);
> > 			putback_movable_pages(&cc->migratepages);
> > 
> > suggests we are doing something suboptimal. I guess we cannot get rid of
> > __PageMoveble checks which is sad because that just adds a lot of
> > confusion because checking for !__PageMovable(page) for LRU pages is
> > just a head scratcher (LRU pages are movable arent' they?). Maybe it
> > would be even good to get rid of this misnomer. PageNonLRUMovable?
> 
> Yeah, I hated the naming but didn't have a good idea.
> PageNonLRUMovable, definitely, one I thought as candidate but dropped
> by lenghthy naming. If others don't object, I am happy to change it.

Yes it is long but it is less confusing because it is just utterly
confusing to test for LRU pages with !__PageMovable when in fact they
are movable. Heck even unreclaimable pages are movable unless explicitly
configured to not be.
 
> > Anyway, I would suggest to do something like this. Batching NR_ISOLATED*
> > just doesn't make all that much sense as these are per-cpu and the
> > resulting code seems to be easier without it.
> 
> Agree. Could you resend it as formal patch?

Sure, what do you think about the following? I haven't marked it for
stable because there was no bug report for it AFAIU.
---
