Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6736B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:08:23 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id q10so2426837ead.31
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:08:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si4811779eew.118.2013.12.17.05.08.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 05:08:22 -0800 (PST)
Message-ID: <52B04CC4.2020301@suse.cz>
Date: Tue, 17 Dec 2013 14:08:20 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: munlock: fix deadlock in __munlock_pagevec()
References: <52AE07B4.4020203@oracle.com>	<1387188856-21027-1-git-send-email-vbabka@suse.cz>	<1387188856-21027-3-git-send-email-vbabka@suse.cz> <20131216163120.28218456e2c870c4c1bfce1e@linux-foundation.org>
In-Reply-To: <20131216163120.28218456e2c870c4c1bfce1e@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, joern@logfs.org, Michel Lespinasse <walken@google.com>, stable@kernel.org

On 12/17/2013 01:31 AM, Andrew Morton wrote:
> On Mon, 16 Dec 2013 11:14:15 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
>
>> Commit 7225522bb ("mm: munlock: batch non-THP page isolation and
>> munlock+putback using pagevec" introduced __munlock_pagevec() to speed up
>> munlock by holding lru_lock over multiple isolated pages. Pages that fail to
>> be isolated are put_back() immediately, also within the lock.
>>
>> This can lead to deadlock when __munlock_pagevec() becomes the holder of the
>> last page pin and put_back() leads to __page_cache_release() which also locks
>> lru_lock. The deadlock has been observed by Sasha Levin using trinity.
>>
>> This patch avoids the deadlock by deferring put_back() operations until
>> lru_lock is released. Another pagevec (which is also used by later phases
>> of the function is reused to gather the pages for put_back() operation.
>>
>> ...
>>
>
> Thanks for fixing this one.  I'll cross it off the rather large list of
> recent MM regressions :(

Well I made this one in the first place :/

>> --- a/mm/mlock.c
>> +++ b/mm/mlock.c
>> @@ -295,10 +295,12 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>>   {
>>   	int i;
>>   	int nr = pagevec_count(pvec);
>> -	int delta_munlocked = -nr;
>> +	int delta_munlocked;
>>   	struct pagevec pvec_putback;
>>   	int pgrescued = 0;
>>
>> +	pagevec_init(&pvec_putback, 0);
>> +
>>   	/* Phase 1: page isolation */
>>   	spin_lock_irq(&zone->lru_lock);
>>   	for (i = 0; i < nr; i++) {
>> @@ -327,16 +329,22 @@ skip_munlock:
>>   			/*
>>   			 * We won't be munlocking this page in the next phase
>>   			 * but we still need to release the follow_page_mask()
>> -			 * pin.
>> +			 * pin. We cannot do it under lru_lock however. If it's
>> +			 * the last pin, __page_cache_release would deadlock.
>>   			 */
>> +			pagevec_add(&pvec_putback, pvec->pages[i]);
>>   			pvec->pages[i] = NULL;
>> -			put_page(page);
>> -			delta_munlocked++;
>>   		}
>>   	}
>> +	delta_munlocked = -nr + pagevec_count(&pvec_putback);
>>   	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
>>   	spin_unlock_irq(&zone->lru_lock);
>>
>> +	/* Now we can release pins of pages that we are not munlocking */
>> +	for (i = 0; i < pagevec_count(&pvec_putback); i++) {
>> +		put_page(pvec_putback.pages[i]);
>> +	}
>> +
>
> We could just do
>
> --- a/mm/mlock.c~mm-munlock-fix-deadlock-in-__munlock_pagevec-fix
> +++ a/mm/mlock.c
> @@ -341,12 +341,9 @@ skip_munlock:
>   	spin_unlock_irq(&zone->lru_lock);
>
>   	/* Now we can release pins of pages that we are not munlocking */
> -	for (i = 0; i < pagevec_count(&pvec_putback); i++) {
> -		put_page(pvec_putback.pages[i]);
> -	}
> +	pagevec_release(&pvec_putback);
>
>   	/* Phase 2: page munlock */
> -	pagevec_init(&pvec_putback, 0);
>   	for (i = 0; i < nr; i++) {
>   		struct page *page = pvec->pages[i];
>

Yeah that looks nicer.

> The lru_add_drain() is unnecessary overhead here.  What do you think?

I would expect these isolation failures to be sufficiently rare so that 
it doesn't matter. Especially in process exit path which was the 
original target of my munlock work. But I don't have any numbers and my 
mmtests benchmark for munlock is most likely too simple to trigger this. 
But even once per pagevec the drain shouldn't hurt I guess...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
