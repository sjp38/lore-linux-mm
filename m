Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 045276B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 02:50:52 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b75so7684800lfg.3
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 23:50:51 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id o81si1024182lfo.88.2016.10.10.23.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 23:50:50 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id b75so1943921lfg.3
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 23:50:50 -0700 (PDT)
Date: Tue, 11 Oct 2016 08:50:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm: unreserve highatomic free pages fully before OOM
Message-ID: <20161011065048.GB31996@dhcp22.suse.cz>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-4-git-send-email-minchan@kernel.org>
 <20161007090917.GA18447@dhcp22.suse.cz>
 <20161007144345.GC3060@bbox>
 <20161010074139.GB20420@dhcp22.suse.cz>
 <20161011050141.GB30973@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011050141.GB30973@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Tue 11-10-16 14:01:41, Minchan Kim wrote:
> Hi Michal,
> 
> On Mon, Oct 10, 2016 at 09:41:40AM +0200, Michal Hocko wrote:
> > On Fri 07-10-16 23:43:45, Minchan Kim wrote:
> > > On Fri, Oct 07, 2016 at 11:09:17AM +0200, Michal Hocko wrote:
[...]
> > > > @@ -2102,10 +2109,12 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> > > >  			set_pageblock_migratetype(page, ac->migratetype);
> > > >  			move_freepages_block(zone, page, ac->migratetype);
> > > >  			spin_unlock_irqrestore(&zone->lock, flags);
> > > > -			return;
> > > > +			return true;
> > > 
> > > Such cut-off makes reserved pageblock remained before the OOM.
> > > We call it as premature OOM kill.
> > 
> > Not sure I understand. The above should get rid of all atomic reserves
> > before we go OOM. We can do it all at once but that sounds too
> 
> The problem is there is race between page freeing path and unreserve
> logic so that some pages could be in highatomic free list even though
> zone->nr_reserved_highatomic is already zero.

Does it make any sense to handle such an unlikely case?

> So, at least, it would be better to have a draining step at some point
> where was (no_progress_loops == MAX_RECLAIM RETRIES) in my patch.
> 
> Also, your patch makes retry loop greater than MAX_RECLAIM_RETRIES
> if unreserve_highatomic_pageblock returns true. Theoretically,
> it would make live lock. You might argue it's *really really* rare
> but I don't want to add such subtle thing.
> Maybe, we could drain when no_progress_loops == MAX_RECLAIM_RETRIES.

What would be the scenario when we would really livelock here? How can
we have unreserve_highatomic_pageblock returning true for ever?

> > aggressive to me. If we just do one at the time we have a chance to
> > keep some reserves if the OOM situation is really ephemeral.
> > 
> > Does this patch work in your usecase?
> 
> I didn't test but I guess it works but it has problems I mentioned
> above. 

Please do not make this too over complicated and be practical. I do not
really want to dismiss your usecase but I am really not convinced that
such a "perfectly fit into all memory" situations are sustainable and
justify to make the whole code more complex. I agree that we can at
least try to do something to release those reserves but let's do it
as simple as possible.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
