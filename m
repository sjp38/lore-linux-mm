Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id BC3846B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 07:16:37 -0400 (EDT)
Message-ID: <5215F300.6070901@suse.cz>
Date: Thu, 22 Aug 2013 13:16:16 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/7] mm: munlock: bypass per-cpu pvec for putback_lru_page
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz> <1376915022-12741-6-git-send-email-vbabka@suse.cz> <20130819154522.c32fb38d8d3c55d48bc9a49a@linux-foundation.org>
In-Reply-To: <20130819154522.c32fb38d8d3c55d48bc9a49a@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On 08/20/2013 12:45 AM, Andrew Morton wrote:
> On Mon, 19 Aug 2013 14:23:40 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> After introducing batching by pagevecs into munlock_vma_range(), we can further
>> improve performance by bypassing the copying into per-cpu pagevec and the
>> get_page/put_page pair associated with that. Instead we perform LRU putback
>> directly from our pagevec. However, this is possible only for single-mapped
>> pages that are evictable after munlock. Unevictable pages require rechecking
>> after putting on the unevictable list, so for those we fallback to
>> putback_lru_page(), hich handles that.
>>
>> After this patch, a 13% speedup was measured for munlocking a 56GB large memory
>> area with THP disabled.
>>
>> ...
>>
>> +static void __putback_lru_fast(struct pagevec *pvec, int pgrescued)
>> +{
>> +	count_vm_events(UNEVICTABLE_PGMUNLOCKED, pagevec_count(pvec));
>> +	/* This includes put_page so we don't call it explicitly */
> 
> This had me confused for a sec.  __pagevec_lru_add() includes put_page,
> so we don't call __pagevec_lru_add()?  That's the problem with the word
> "it" - one often doesn't know what it refers to.
> 
> Clarity: 
> 
> --- a/mm/mlock.c~mm-munlock-bypass-per-cpu-pvec-for-putback_lru_page-fix
> +++ a/mm/mlock.c
> @@ -264,7 +264,10 @@ static bool __putback_lru_fast_prepare(s
>  static void __putback_lru_fast(struct pagevec *pvec, int pgrescued)
>  {
>  	count_vm_events(UNEVICTABLE_PGMUNLOCKED, pagevec_count(pvec));
> -	/* This includes put_page so we don't call it explicitly */
> +	/*
> +	 *__pagevec_lru_add() calls release_pages() so we don't call
> +	 * put_page() explicitly
> +	 */
>  	__pagevec_lru_add(pvec);
>  	count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
>  }

Yes this is definitely better, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
