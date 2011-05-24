Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C47A56B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 01:45:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 260583EE0AE
	for <linux-mm@kvack.org>; Tue, 24 May 2011 14:45:28 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F311245DF49
	for <linux-mm@kvack.org>; Tue, 24 May 2011 14:45:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D366745DF46
	for <linux-mm@kvack.org>; Tue, 24 May 2011 14:45:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C7038E08001
	for <linux-mm@kvack.org>; Tue, 24 May 2011 14:45:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 84918E08002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 14:45:27 +0900 (JST)
Message-ID: <4DDB45EF.2080803@jp.fujitsu.com>
Date: Tue, 24 May 2011 14:45:19 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
References: <4DCDA347.9080207@cray.com> <BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com> <4DD2991B.5040707@cray.com> <BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com> <20110520164924.GB2386@barrios-desktop> <4DDB3A1E.6090206@jp.fujitsu.com>
In-Reply-To: <4DDB3A1E.6090206@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: abarry@cray.com, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

(2011/05/24 13:54), KOSAKI Motohiro wrote:
>> >From 8bd3f16736548375238161d1bd85f7d7c381031f Mon Sep 17 00:00:00 2001
>> From: Minchan Kim <minchan.kim@gmail.com>
>> Date: Sat, 21 May 2011 01:37:41 +0900
>> Subject: [PATCH] Prevent unending loop in __alloc_pages_slowpath
>>
>> From: Andrew Barry <abarry@cray.com>
>>
>> I believe I found a problem in __alloc_pages_slowpath, which allows a process to
>> get stuck endlessly looping, even when lots of memory is available.
>>
>> Running an I/O and memory intensive stress-test I see a 0-order page allocation
>> with __GFP_IO and __GFP_WAIT, running on a system with very little free memory.
>> Right about the same time that the stress-test gets killed by the OOM-killer,
>> the utility trying to allocate memory gets stuck in __alloc_pages_slowpath even
>> though most of the systems memory was freed by the oom-kill of the stress-test.
>>
>> The utility ends up looping from the rebalance label down through the
>> wait_iff_congested continiously. Because order=0, __alloc_pages_direct_compact
>> skips the call to get_page_from_freelist. Because all of the reclaimable memory
>> on the system has already been reclaimed, __alloc_pages_direct_reclaim skips the
>> call to get_page_from_freelist. Since there is no __GFP_FS flag, the block with
>> __alloc_pages_may_oom is skipped. The loop hits the wait_iff_congested, then
>> jumps back to rebalance without ever trying to get_page_from_freelist. This loop
>> repeats infinitely.
>>
>> The test case is pretty pathological. Running a mix of I/O stress-tests that do
>> a lot of fork() and consume all of the system memory, I can pretty reliably hit
>> this on 600 nodes, in about 12 hours. 32GB/node.
>>
>> Signed-off-by: Andrew Barry <abarry@cray.com>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> ---
>>  mm/page_alloc.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3f8bce2..e78b324 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2064,6 +2064,7 @@ restart:
>>  		first_zones_zonelist(zonelist, high_zoneidx, NULL,
>>  					&preferred_zone);
>>  
>> +rebalance:
>>  	/* This is the last chance, in general, before the goto nopage. */
>>  	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
>>  			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
>> @@ -2071,7 +2072,6 @@ restart:
>>  	if (page)
>>  		goto got_pg;
>>  
>> -rebalance:
>>  	/* Allocate without watermarks if the context allows */
>>  	if (alloc_flags & ALLOC_NO_WATERMARKS) {
>>  		page = __alloc_pages_high_priority(gfp_mask, order,
> 
> I'm sorry I missed this thread long time.
> 
> In this case, I think we should call drain_all_pages(). then following
> patch is better.
> However I also think your patch is valuable. because while the task is
> sleeping in wait_iff_congested(), an another task may free some pages.
> thus, rebalance path should try to get free pages. iow, you makes sense.
> 
> So, I'd like to propose to merge both your and my patch.

I forgot to write important thing. Your patch looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
