Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6A6686B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 09:30:53 -0400 (EDT)
Message-ID: <49F8567F.4010703@redhat.com>
Date: Wed, 29 Apr 2009 09:30:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: evict use-once pages first
References: <20090428044426.GA5035@eskimo.com>	 <20090428192907.556f3a34@bree.surriel.com> <1240987349.4512.18.camel@laptop>
In-Reply-To: <1240987349.4512.18.camel@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Tue, 2009-04-28 at 19:29 -0400, Rik van Riel wrote:
> 
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index eac9577..4c0304e 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1489,6 +1489,21 @@ static void shrink_zone(int priority, struct zone *zone,
>>  			nr[l] = scan;
>>  	}
>>  
>> +	/*
>> +	 * When the system is doing streaming IO, memory pressure here
>> +	 * ensures that active file pages get deactivated, until more
>> +	 * than half of the file pages are on the inactive list.
>> +	 *
>> +	 * Once we get to that situation, protect the system's working
>> +	 * set from being evicted by disabling active file page aging
>> +	 * and swapping of swap backed pages.  We still do background
>> +	 * aging of anonymous pages.
>> +	 */
>> +	if (nr[LRU_INACTIVE_FILE] > nr[LRU_ACTIVE_FILE]) {
>> +		nr[LRU_ACTIVE_FILE] = 0;
>> +		nr[LRU_INACTIVE_ANON] = 0;
>> +	}
>> +
> 
> Isn't there a hole where LRU_*_FILE << LRU_*_ANON and we now stop
> shrinking INACTIVE_ANON even though it makes sense to.

Only temporarily, until the number of active file pages
is larger than the number of inactive ones.

Think of it as reducing the frequency of shrinking anonymous
pages while the system is near the threshold.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
