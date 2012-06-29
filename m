Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3ABDA6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 23:00:44 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C89693EE0B6
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:00:42 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ACFE245DE5F
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:00:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 726BB45DE59
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:00:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 634781DB8053
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:00:42 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BD351DB804A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:00:42 +0900 (JST)
Message-ID: <4FED19D5.5070508@jp.fujitsu.com>
Date: Fri, 29 Jun 2012 11:58:29 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm: have order>0 compaction start off where it left
References: <20120627233742.53225fc7@annuminas.surriel.com> <20120628102919.GQ8103@csn.ul.ie> <4FEC86BA.9050004@redhat.com>
In-Reply-To: <4FEC86BA.9050004@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov

(2012/06/29 1:30), Rik van Riel wrote:
> On 06/28/2012 06:29 AM, Mel Gorman wrote:
>
>> Lets say there are two parallel compactions running. Process A meets
>> the migration PFN and moves to the end of the zone to restart. Process B
>> finishes scanning mid-way through the zone and updates last_free_pfn. This
>> will cause Process A to "jump" to where Process B left off which is not
>> necessarily desirable.
>>
>> Another side effect is that a workload that allocations/frees
>> aggressively will not compact as well as the "free" scanner is not
>> scanning the end of the zone each time. It would be better if
>> last_free_pfn was updated when a full pageblock was encountered
>>
>> So;
>>
>> 1. Initialise last_free_pfn to the end of the zone
>> 2. On compaction, scan from last_free_pfn and record where it started
>> 3. If a pageblock is full, update last_free_pfn
>> 4. If the migration and free scanner meet, reset last_free_pfn and
>>     the free scanner. Abort if the free scanner wraps to where it started
>>
>> Does that make sense?
>
> Yes, that makes sense.  We still have to keep track
> of whether we have wrapped around, but I guess that
> allows for a better name for the bool :)
>
> Maybe cc->wrapped?
>
> Does anyone have a better name?
>

cc->second_scan ? (I have no sense of naming ;)

> As for point (4), should we abort when we wrap
> around to where we started, or should we abort
> when free_pfn and migrate_pfn meet after we
> wrapped around?
>

I'd like to vote for aborting earlier.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
