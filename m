Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA1A36B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 03:26:09 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p80so8174305lfp.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 00:26:09 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id h72si1094552ljh.96.2016.10.11.00.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 00:26:08 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id b75so2083076lfg.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 00:26:08 -0700 (PDT)
Date: Tue, 11 Oct 2016 09:26:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm: unreserve highatomic free pages fully before OOM
Message-ID: <20161011072605.GD31996@dhcp22.suse.cz>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-4-git-send-email-minchan@kernel.org>
 <20161007090917.GA18447@dhcp22.suse.cz>
 <20161007144345.GC3060@bbox>
 <20161010074139.GB20420@dhcp22.suse.cz>
 <20161011050141.GB30973@bbox>
 <20161011065048.GB31996@dhcp22.suse.cz>
 <20161011070945.GA21238@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011070945.GA21238@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Tue 11-10-16 16:09:45, Minchan Kim wrote:
> On Tue, Oct 11, 2016 at 08:50:48AM +0200, Michal Hocko wrote:
> > On Tue 11-10-16 14:01:41, Minchan Kim wrote:
[...]
> > > Also, your patch makes retry loop greater than MAX_RECLAIM_RETRIES
> > > if unreserve_highatomic_pageblock returns true. Theoretically,
> > > it would make live lock. You might argue it's *really really* rare
> > > but I don't want to add such subtle thing.
> > > Maybe, we could drain when no_progress_loops == MAX_RECLAIM_RETRIES.
> > 
> > What would be the scenario when we would really livelock here? How can
> > we have unreserve_highatomic_pageblock returning true for ever?
> 
> Other context freeing highorder page/reallocating repeatedly while
> a process stucked direct reclaim is looping with should_reclaim_retry.

If we unreserve those pages then we should converge to OOM. Btw. this
can happen even without highmem reserves. Heavy short lived allocations
might keep us looping at the lowest priority. They are just too unlikely
to care about.

> > > > aggressive to me. If we just do one at the time we have a chance to
> > > > keep some reserves if the OOM situation is really ephemeral.
> > > > 
> > > > Does this patch work in your usecase?
> > > 
> > > I didn't test but I guess it works but it has problems I mentioned
> > > above. 
> > 
> > Please do not make this too over complicated and be practical. I do not
> > really want to dismiss your usecase but I am really not convinced that
> > such a "perfectly fit into all memory" situations are sustainable and
> > justify to make the whole code more complex. I agree that we can at
> > least try to do something to release those reserves but let's do it
> > as simple as possible.
> 
> If you think it's too complicated, how about this?

Definitely better than the original patch. Little bit too aggressive
because we could really go with one block at the time. But this is a
minor thing and easily fixable...

> @@ -2154,12 +2156,24 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
>  			 * may increase.
>  			 */
>  			set_pageblock_migratetype(page, ac->migratetype);
> -			move_freepages_block(zone, page, ac->migratetype);
> -			spin_unlock_irqrestore(&zone->lock, flags);
> -			return;
> +			ret = move_freepages_block(zone, page,
> +						ac->migratetype);
> +			/*
> +			 * By race with page freeing functions, !highatomic
> +			 * pageblocks can have free pages in highatomic free
> +			 * list so if drain is true, try to unreserve every
> +			 * free pages in highatomic free list without bailing
> +			 * out.
> +			 */
> +			if (!drain) {

			if (ret)
> +				spin_unlock_irqrestore(&zone->lock, flags);
> +				return ret;
> +			}

arguably this would work better also for !drain case which currently
tries to unreserve but in case of the race it would do nothing.

>  		}
>  		spin_unlock_irqrestore(&zone->lock, flags);
>  	}
> +
> +	return ret;
>  }
>  
>  /* Remove an element from the buddy allocator from the fallback list */
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
