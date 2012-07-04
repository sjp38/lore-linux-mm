Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 1B2DB6B0078
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 22:33:30 -0400 (EDT)
Message-ID: <4FF3ABA1.3070808@kernel.org>
Date: Wed, 04 Jul 2012 11:34:09 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where
 it left
References: <20120628135520.0c48b066@annuminas.surriel.com> <20120628135940.2c26ada9.akpm@linux-foundation.org> <4FECCB89.2050400@redhat.com> <20120628143546.d02d13f9.akpm@linux-foundation.org> <1341250950.16969.6.camel@lappy> <4FF2435F.2070302@redhat.com> <20120703101024.GG13141@csn.ul.ie> <20120703144808.4daa4244.akpm@linux-foundation.org>
In-Reply-To: <20120703144808.4daa4244.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Sasha Levin <levinsasha928@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com, Dave Jones <davej@redhat.com>

Hi Andrew,

On 07/04/2012 06:48 AM, Andrew Morton wrote:

> On Tue, 3 Jul 2012 11:10:24 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
>>>>>>>> +          if (cc->order>   0)
>>>>>>>> +                  zone->compact_cached_free_pfn = high_pfn;
>>>>>>>
>>>>>>> Is high_pfn guaranteed to be aligned to pageblock_nr_pages here?  I
>>>>>>> assume so, if lots of code in other places is correct but it's
>>>>>>> unobvious from reading this function.
>>>>>>
>>>>>> Reading the code a few more times, I believe that it is
>>>>>> indeed aligned to pageblock size.
>>>>>
>>>>> I'll slip this into -next for a while.
>>>>>
>>>>> --- a/mm/compaction.c~isolate_freepages-check-that-high_pfn-is-aligned-as-expected
>>>>> +++ a/mm/compaction.c
>>>>> @@ -456,6 +456,7 @@ static void isolate_freepages(struct zon
>>>>>                 }
>>>>>                 spin_unlock_irqrestore(&zone->lock, flags);
>>>>>
>>>>> +               WARN_ON_ONCE(high_pfn&  (pageblock_nr_pages - 1));
>>>>>                 /*
>>>>>                  * Record the highest PFN we isolated pages from. When next
>>>>>                  * looking for free pages, the search will restart here as
>>>>
>>>> I've triggered the following with today's -next:
>>>
>>> I've been staring at the migrate code for most of the afternoon,
>>> and am not sure how this is triggered.
>>>
>>
>> That warning is placed in isolate_freepages(). When the migration
>> scanner and free scanner have almost met it is possible for high_pfn to
>> be
>>
>> cc->migrate_pfn + pageblock_nr_pages
>>
>> and that is not necessarily pageblock aligned. Forcing it to be aligned
>> raises the possibility that the free scanner moves to another zone. This
>> is very unlikely but could happen if a high zone was very small.
>>
>> I should have caught this when the warning was proposed :( IMO it's
>> safe to just drop the warning.
> 
> The rest of this patch takes care to ensure that
> ->compact_cached_free_pfn is aligned to pageblock_nr_pages.  But it now
> appears that this particular site will violate that.
> 
> What's up?  Do we need to fix this site, or do we remove all that
> make-compact_cached_free_pfn-aligned code?


I vote removing the warning because it doesn't related to Rik's incremental compaction.
Let's see. 

high_pfn = min(low_pfn, pfn) = cc->migrate_pfn + pageblock_nr_pages.
In here, cc->migrate_pfn isn't necessarily pageblock aligined.
So if we don't consider compact_cached_free_pfn, it can hit.

static void isolate_freepages()
{
	high_pfn = min(low_pfn, pfn) = cc->migrate_pfn + pageblock_nr_pages;
	for (..) {
		...
		 WARN_ON_ONCE(high_pfn & (pageblock_nr_pages - 1));
		
	}
}

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
