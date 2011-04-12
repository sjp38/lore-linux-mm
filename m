Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A2D84900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 12:29:08 -0400 (EDT)
Message-ID: <4DA47D83.30707@fiec.espol.edu.ec>
Date: Tue, 12 Apr 2011 11:27:47 -0500
From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
 <avillaci@fiec.espol.edu.ec>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
References: <20110321163742.GA24244@csn.ul.ie> <4D878564.6080608@fiec.espol.edu.ec> <20110321201641.GA5698@random.random> <20110322112032.GD24244@csn.ul.ie> <20110322150314.GC5698@random.random> <4D8907C2.7010304@fiec.espol.edu.ec> <20110322214020.GD5698@random.random> <20110323003718.GH5698@random.random> <4D8A2517.3090403@fiec.espol.edu.ec> <4D99E5C8.7090505@fiec.espol.edu.ec> <20110408190912.GI29444@random.random> <4D9F6AB6.6000809@fiec.espol.edu.ec>
In-Reply-To: <4D9F6AB6.6000809@fiec.espol.edu.ec>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

El 08/04/11 15:06, Alex Villaci-s Lasso escribio:
> El 08/04/11 14:09, Andrea Arcangeli escribio:
>> Hi Alex,
>>
>> On Mon, Apr 04, 2011 at 10:37:44AM -0500, Alex Villaci-s Lasso wrote:
>>> Latest update: with 2.6.39-rc1 the stalls only last for a few
>>> seconds, but they are still there. So, as I said before, they are
>>> reduced but not eliminated.
>> Ok from a complete stall for the whole duration of the I/O to a few
>> second stall we're clearly going into the right direction.
>>
>> The few second stalls happen with udf? And vfat doesn't stall?
>>
>> Minchan rightly pointed out that the (panik) change we made in
>> page_alloc.c changes the semantics of the __GFP_NO_KSWAPD bit. I also
>> talked with Mel about it. We think it's nicer if we can keep THP
>> allocations as close as any other high order allocation as
>> possible. There are already plenty of __GFP bits with complex
>> semantics. __GFP_NO_KSWAPD is simple and it's nice to stay simple: it
>> means the allocation relies on a different kernel daemon for the
>> background work (which is khugepaged instead of kswapd in the THP
>> case, where khugepaged uses a non intrusive alloc_sleep_millisec
>> throttling in case of MM congestion, unlike kswapd would do).
>>
>> So this is no solution to your problem (if vfat already works I think
>> that might be a better solution), but we'd like to know if you get any
>> _worse_ stall compared to current 2.6.39-rc, by applying the below
>> patch on top of 2.6.39-rc. If this doesn't make any difference, we can
>> safely apply it to remove unnecessary complications.
>>
>> Thanks,
>> Andrea
>>
>> ===
>> Subject: compaction: reverse the change that forbid sync migraton with __GFP_NO_KSWAPD
>>
>> From: Andrea Arcangeli<aarcange@redhat.com>
>>
>> It's uncertain this has been beneficial, so it's safer to undo it. All other
>> compaction users would still go in synchronous mode if a first attempt of async
>> compaction failed. Hopefully we don't need to force special behavior for THP
>> (which is the only __GFP_NO_KSWAPD user so far and it's the easier to exercise
>> and to be noticeable). This also make __GFP_NO_KSWAPD return to its original
>> strict semantics specific to bypass kswapd, as THP allocations have khugepaged
>> for the async THP allocations/compactions.
>>
>> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
>> ---
>>   mm/page_alloc.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2105,7 +2105,7 @@ rebalance:
>>                       sync_migration);
>>       if (page)
>>           goto got_pg;
>> -    sync_migration = !(gfp_mask&  __GFP_NO_KSWAPD);
>> +    sync_migration = true;
>>
>>       /* Try direct reclaim and then allocating */
>>       page = __alloc_pages_direct_reclaim(gfp_mask, order,
>>
> The stalls occur even with vfat. I am no longer using udf, since (right now) it is not necessary. I will test this patch now.
>
 From preliminary tests, I feel that the patch actually eliminates the stalls. I have just copied nearly 6 GB of data into my USB stick and noticed no application freezes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
