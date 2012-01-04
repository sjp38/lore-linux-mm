Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id AA5D76B004D
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 21:38:25 -0500 (EST)
Received: by ghrr18 with SMTP id r18so10857616ghr.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 18:38:24 -0800 (PST)
Message-ID: <4F03BBA1.7090606@gmail.com>
Date: Tue, 03 Jan 2012 21:38:25 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm,mlock: drain pagevecs asynchronously
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com> <1325403025-22688-1-git-send-email-kosaki.motohiro@gmail.com> <20120104011715.GA18399@barrios-laptop.redhat.com>
In-Reply-To: <20120104011715.GA18399@barrios-laptop.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>


>> @@ -704,10 +747,23 @@ static void ____pagevec_lru_add_fn(struct page *page, void *arg)
>>   	VM_BUG_ON(PageLRU(page));
>>
>>   	SetPageLRU(page);
>> -	if (active)
>> -		SetPageActive(page);
>> -	update_page_reclaim_stat(zone, page, file, active);
>> -	add_page_to_lru_list(zone, page, lru);
>> + redo:
>> +	if (page_evictable(page, NULL)) {
>> +		if (active)
>> +			SetPageActive(page);
>> +		update_page_reclaim_stat(zone, page, file, active);
>> +		add_page_to_lru_list(zone, page, lru);
>> +	} else {
>> +		SetPageUnevictable(page);
>> +		add_page_to_lru_list(zone, page, LRU_UNEVICTABLE);
>> +		smp_mb();
>
> Why do we need barrier in here? Please comment it.

To cut-n-paste a comment from putback_lru_page() is good idea? :)

+               /*
+                * When racing with an mlock clearing (page is
+                * unlocked), make sure that if the other thread does
+                * not observe our setting of PG_lru and fails
+                * isolation, we see PG_mlocked cleared below and move
+                * the page back to the evictable list.
+                *
+                * The other side is TestClearPageMlocked().
+                */
+               smp_mb();



>> +		if (page_evictable(page, NULL)) {
>> +			del_page_from_lru_list(zone, page, LRU_UNEVICTABLE);
>> +			ClearPageUnevictable(page);
>> +			goto redo;
>> +		}
>> +	}
>
> I am not sure it's a good idea.
> mlock is very rare event but ____pagevec_lru_add_fn is called frequently.
> We are adding more overhead in ____pagevec_lru_add_fn.
> Is it valuable?

dunno.

Personally, I think tao's case is too artificial and I haven't observed
any real world application do such crazy mlock/munlock repeatness. But
he said he has a such application.

If my remember is correct, ltp or some test suite depend on current 
meminfo synching behavior. then I'm afraid simple removing bring us
new annoying bug report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
