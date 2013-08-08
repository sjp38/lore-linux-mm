Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 860A96B0032
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 04:23:03 -0400 (EDT)
Date: Thu, 8 Aug 2013 09:22:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 9/9] mm: zone_reclaim: compaction: add compaction to
 zone_reclaim_mode
Message-ID: <20130808082257.GY2296@suse.de>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-10-git-send-email-aarcange@redhat.com>
 <20130804165526.GG27921@redhat.com>
 <20130807161837.GW2296@suse.de>
 <20130807234800.GG4661@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130807234800.GG4661@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Thu, Aug 08, 2013 at 01:48:00AM +0200, Andrea Arcangeli wrote:
> On Wed, Aug 07, 2013 at 05:18:37PM +0100, Mel Gorman wrote:
> > > It is important to boot with numa_zonelist_order=n (n means nodes) to
> > > get more accurate NUMA locality if there are multiple zones per node.
> > > 
> > 
> > This appears to be an unrelated observation.
> 
> But things still don't work ok without it. After alloc_batch changes
> it matters only in the slowpath but it still related.
> 

Ok, that's curious in itself but I'm not going to dig into the why.

> > > <SNIP>
> > > @@ -3587,7 +3613,56 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > >  	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
> > >  		return ZONE_RECLAIM_NOSCAN;
> > >  
> > > +repeat_compaction:
> > > +	/*
> > > +	 * If this allocation may be satisfied by memory compaction,
> > > +	 * run compaction before reclaim.
> > > +	 */
> > > +	c_ret = zone_reclaim_compact(preferred_zone,
> > > +				     zone, gfp_mask, order,
> > > +				     sync_compaction,
> > > +				     &need_compaction);
> > > +	if (need_compaction &&
> > > +	    c_ret != COMPACT_SKIPPED &&
> > 
> > need_compaction records whether compaction was attempted or not. Why
> > not just check for COMPACT_SKIPPED and have compact_zone_order return
> > COMPACT_SKIPPED if !CONFIG_COMPACTION?
> 
> How can it be ok that try_to_compact_pages returns COMPACT_CONTINUE
> but compact_zone order returns the opposite?

Good question and I expect it was because the return value of
try_to_compact_pages was never used in the !CONFIG_COMPACTION case and I
did not think it through properly. try_to_compact_pages has only one caller
in the CONFIG_COMPACTION case and zero callers in the !CONFIG_COMPACTION
making the return value was irrelevant. COMPACT_SKIPPED would still have
been a better choice to indicate "compaction didn't start as it was not
possible or direct reclaim was more suitable"

> I mean either we change both or none.
> 

I think both to COMPACT_SKIPPED would be a better fit for the documented
meaning of COMPACT_SKIPPED.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
