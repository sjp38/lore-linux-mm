Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0A36682BEF
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 02:53:44 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id n3so9525454wiv.12
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 23:53:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id we10si27877628wjb.121.2014.11.09.23.53.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 09 Nov 2014 23:53:42 -0800 (PST)
Message-ID: <54606F02.5070808@suse.cz>
Date: Mon, 10 Nov 2014 08:53:38 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
References: <12996532.NCRhVKzS9J@xorhgos3.pefnos> <3583067.00bS4AInhm@xorhgos3.pefnos> <545BEA3B.40005@suse.cz> <3443150.6EQzxj6Rt9@xorhgos3.pefnos> <545E96BD.5040103@suse.cz> <20141110060726.GA4900@js1304-P5Q-DELUXE>
In-Reply-To: <20141110060726.GA4900@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "P. Christeas" <xrg@linux.gr>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Norbert Preining <preining@logic.at>, Markus Trippelsdorf <markus@trippelsdorf.de>, Pavel Machek <pavel@ucw.cz>

On 11/10/2014 07:07 AM, Joonsoo Kim wrote:
> On Sat, Nov 08, 2014 at 11:18:37PM +0100, Vlastimil Babka wrote:
>> On 11/08/2014 02:11 PM, P. Christeas wrote:
>>
>> Hi,
>>
>> I think I finally found the cause by staring into the code... CCing
>> people from all 4 separate threads I know about this issue.
>> The problem with finding the cause was that the first report I got from
>> Markus was about isolate_freepages_block() overhead, and later Norbert
>> reported that reverting a patch for isolate_freepages* helped. But the
>> problem seems to be that although the loop in isolate_migratepages exits
>> because the scanners almost meet (they are within same pageblock), they
>> don't truly meet, therefore compact_finished() decides to continue, but
>> isolate_migratepages() exits immediately... boom! But indeed e14c720efdd7
>> made this situation possible, as free scaner pfn can now point to a
>> middle of pageblock.
>
> Indeed.
>
>>
>> So I hope the attached patch will fix the soft-lockup issues in
>> compact_zone. Please apply on 3.18-rc3 or later without any other reverts,
>> and test. It probably won't help Markus and his isolate_freepages_block()
>> overhead though...
>
> Yes, I found this bug too, but, it can't explain
> isolate_freepages_block() overhead. Anyway, I can't find another bug
> related to isolate_freepages_block(). :/

Thanks for checking.

>> Thanks,
>> Vlastimil
>>
>> ------8<------
>> >From fbf8eb0bcd2897090312e23da6a31bad9cc6b337 Mon Sep 17 00:00:00 2001
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Date: Sat, 8 Nov 2014 22:20:43 +0100
>> Subject: [PATCH] mm, compaction: prevent endless loop in migrate scanner
>>
>> ---
>>   mm/compaction.c | 8 ++++++--
>>   1 file changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index ec74cf0..1b7a1be 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -1029,8 +1029,12 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>>   	}
>>
>>   	acct_isolated(zone, cc);
>> -	/* Record where migration scanner will be restarted */
>> -	cc->migrate_pfn = low_pfn;
>> +	/*
>> +	 * Record where migration scanner will be restarted. If we end up in
>> +	 * the same pageblock as the free scanner, make the scanners fully
>> +	 * meet so that compact_finished() terminates compaction.
>> +	 */
>> +	cc->migrate_pfn = (end_pfn <= cc->free_pfn) ? low_pfn : cc->free_pfn;
>>
>>   	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>>   }
>
> IMHO, proper fix is not to change this logic, but, to change decision
> logic in compact_finished() and in compact_zone(). Maybe helper
> function would be good for readability.

OK but I would think that to fix 3.18 ASAP and not introduce more 
regressions, go with the patch above first, as it is the minimal fix and 
people already test it. Then we can implement your suggestion later as a 
cleanup for 3.19?

Vlastimil

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
