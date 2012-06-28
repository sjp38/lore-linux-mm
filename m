Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 00D8B6B004D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:26:07 -0400 (EDT)
Message-ID: <4FEC9392.2090904@redhat.com>
Date: Thu, 28 Jun 2012 13:25:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm: have order>0 compaction start off where it left
References: <20120627233742.53225fc7@annuminas.surriel.com> <4FEC9181.9060000@sandia.gov>
In-Reply-To: <4FEC9181.9060000@sandia.gov>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Schutt <jaschut@sandia.gov>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, linux-kernel@vger.kernel.org

On 06/28/2012 01:16 PM, Jim Schutt wrote:
>
> On 06/27/2012 09:37 PM, Rik van Riel wrote:
>> Order> 0 compaction stops when enough free pages of the correct
>> page order have been coalesced. When doing subsequent higher order
>> allocations, it is possible for compaction to be invoked many times.
>>
>> However, the compaction code always starts out looking for things to
>> compact at the start of the zone, and for free pages to compact things
>> to at the end of the zone.
>>
>> This can cause quadratic behaviour, with isolate_freepages starting
>> at the end of the zone each time, even though previous invocations
>> of the compaction code already filled up all free memory on that end
>> of the zone.
>>
>> This can cause isolate_freepages to take enormous amounts of CPU
>> with certain workloads on larger memory systems.
>>
>> The obvious solution is to have isolate_freepages remember where
>> it left off last time, and continue at that point the next time
>> it gets invoked for an order> 0 compaction. This could cause
>> compaction to fail if cc->free_pfn and cc->migrate_pfn are close
>> together initially, in that case we restart from the end of the
>> zone and try once more.
>>
>> Forced full (order == -1) compactions are left alone.
>>
>> Reported-by: Jim Schutt<jaschut@sandia.gov>
>> Signed-off-by: Rik van Riel<riel@redhat.com>
>
> Tested-by: Jim Schutt<jaschut@sandia.gov>
>
> Please let me know if you further refine this patch
> and would like me to test it with my workload.

Mel pointed out a serious problem with the way wrapping
cc->free_pfn back to the top of the zone is handled.

I will send you a new patch once I have a fix for that.

> So far I've run a total of ~20 TB of data over fifty minutes
> or so through 12 machines running this patch; no hint of
> trouble, great performance.
>
> Without this patch I would typically start having trouble
> after just a few minutes of this load.

Good to hear that!

Thank you for testing last night's version.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
