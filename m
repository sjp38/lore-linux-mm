Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2A8A56B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 12:18:26 -0400 (EDT)
Message-ID: <49F87DCE.8090207@redhat.com>
Date: Wed, 29 Apr 2009 12:18:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
References: <20090428044426.GA5035@eskimo.com>	 <20090428192907.556f3a34@bree.surriel.com>	 <1240987349.4512.18.camel@laptop>	 <20090429114708.66114c03@cuia.bos.redhat.com> <2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com>
In-Reply-To: <2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
>
> Looks good than previous version. but I have one question.
>
>   
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index eac9577..4471dcb 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1489,6 +1489,18 @@ static void shrink_zone(int priority, struct zone *zone,
>>                        nr[l] = scan;
>>        }
>>
>> +       /*
>> +        * When the system is doing streaming IO, memory pressure here
>> +        * ensures that active file pages get deactivated, until more
>> +        * than half of the file pages are on the inactive list.
>> +        *
>> +        * Once we get to that situation, protect the system's working
>> +        * set from being evicted by disabling active file page aging.
>> +        * The logic in get_scan_ratio protects anonymous pages.
>> +        */
>> +       if (nr[LRU_INACTIVE_FILE] > nr[LRU_ACTIVE_FILE])
>> +               nr[LRU_ACTIVE_FILE] = 0;
>> +
>>        while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>>                                        nr[LRU_INACTIVE_FILE]) {
>>                for_each_evictable_lru(l) {
>>     
>
> we handle active_anon vs inactive_anon ratio by shrink_list().
> Why do you insert this logic insert shrink_zone() ?
>   
Good question.  I guess that at lower priority levels, we get to scan
a lot more pages and we could go from having too many inactive
file pages to not having enough in one invocation of shrink_zone().

That makes shrink_list() the better place to implement this, even if
it means doing this comparison more often.

I'll send a new patch this afternoon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
