Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id DAB826B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 12:18:48 -0500 (EST)
Message-ID: <4F203939.70107@redhat.com>
Date: Wed, 25 Jan 2012 12:17:45 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 -mm 1/3] mm: reclaim at order 0 when compaction is
 enabled
References: <20120124131822.4dc03524@annuminas.surriel.com> <20120124132136.3b765f0c@annuminas.surriel.com> <20120125150016.GB3901@csn.ul.ie> <4F201F60.8080808@redhat.com> <20120125160752.GE3901@csn.ul.ie>
In-Reply-To: <20120125160752.GE3901@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On 01/25/2012 11:07 AM, Mel Gorman wrote:
> On Wed, Jan 25, 2012 at 10:27:28AM -0500, Rik van Riel wrote:

>> Maybe this is the place to check (in balanced_pgdat) ?
>>
>>                  /*
>>                   * We do this so kswapd doesn't build up large
>> priorities for
>>                   * example when it is freeing in parallel with
>> allocators. It
>>                   * matches the direct reclaim path behaviour in
>> terms of impact
>>                   * on zone->*_priority.
>>                   */
>>                  if (sc.nr_reclaimed>= SWAP_CLUSTER_MAX)
>>                          break;
>>
>
> It would be a good place all right. Preferably it would tie into
> compaction_ready() to decide whether to continue reclaiming or not.

Good point. We can just track compaction_ready for all
of the zones and bail out if at least one of the zones
is ready for compaction (somehow taking the classzone
index into account?).

Or maybe simply keep reclaiming order 0 pages until all
the memory zones in the pgdat are ready for compaction?

>>>> @@ -2922,8 +2939,6 @@ out:
>>>>
>>>>   			/* If balanced, clear the congested flag */
>>>>   			zone_clear_flag(zone, ZONE_CONGESTED);
>>>> -			if (i<= *classzone_idx)
>>>> -				balanced += zone->present_pages;
>>>>   		}
>>>
>>> Why is this being deleted? It is still used by pgdat_balanced().
>>
>> This is outside of the big while loop and is not used again
>> in the function.
>
> How about here?
>
>                 if (all_zones_ok || (order&&  pgdat_balanced(pgdat, balanced, *classzone_idx)))
>                          break;          /* kswapd: all done */
>
> Either way, it looks like something that should be in its own patch.

That code is above the lines that I removed.

The only way to get back there is to jump up to
loop_again, from where we will get to the main loop,
where balanced is zeroed out.

If you want I will split this out into its own patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
