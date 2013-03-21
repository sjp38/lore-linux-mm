Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 752446B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 13:55:06 -0400 (EDT)
Message-ID: <514B4925.2010909@redhat.com>
Date: Thu, 21 Mar 2013 13:53:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/10] mm: vmscan: Have kswapd writeback pages based on
 dirty pages encountered, not priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-7-git-send-email-mgorman@suse.de> <m2620qjdeo.fsf@firstfloor.org> <20130317151155.GC2026@suse.de>
In-Reply-To: <20130317151155.GC2026@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/17/2013 11:11 AM, Mel Gorman wrote:
> On Sun, Mar 17, 2013 at 07:42:39AM -0700, Andi Kleen wrote:
>> Mel Gorman <mgorman@suse.de> writes:
>>
>>> @@ -495,6 +495,9 @@ typedef enum {
>>>   	ZONE_CONGESTED,			/* zone has many dirty pages backed by
>>>   					 * a congested BDI
>>>   					 */
>>> +	ZONE_DIRTY,			/* reclaim scanning has recently found
>>> +					 * many dirty file pages
>>> +					 */
>>
>> Needs a better name. ZONE_DIRTY_CONGESTED ?
>>
>
> That might be confusing. The underlying BDI is not necessarily
> congested. I accept your point though and will try thinking of a better
> name.

ZONE_LOTS_DIRTY ?

>>> +	 * currently being written then flag that kswapd should start
>>> +	 * writing back pages.
>>> +	 */
>>> +	if (global_reclaim(sc) && nr_dirty &&
>>> +			nr_dirty >= (nr_taken >> (DEF_PRIORITY - sc->priority)))
>>> +		zone_set_flag(zone, ZONE_DIRTY);
>>> +
>>>   	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
>>
>> I suppose you want to trace the dirty case here too.
>>
>
> I guess it wouldn't hurt to have a new tracepoint for when the flag gets
> set. A vmstat might be helpful as well.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
