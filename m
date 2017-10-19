Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 514496B025E
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 09:21:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r18so6893028pgu.9
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 06:21:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10si448957plu.248.2017.10.19.06.21.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 06:21:41 -0700 (PDT)
Subject: Re: [PATCH 4/8] mm: Only drain per-cpu pagevecs once per pagevec
 usage
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-5-mgorman@techsingularity.net>
 <a9f2fc7c-906d-a49e-8e8f-d1024dc754ac@suse.cz>
 <20171019093346.ylahzdpzmoriyf4v@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bfd67339-6202-9a7a-3765-4608913bcbd3@suse.cz>
Date: Thu, 19 Oct 2017 15:21:38 +0200
MIME-Version: 1.0
In-Reply-To: <20171019093346.ylahzdpzmoriyf4v@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On 10/19/2017 11:33 AM, Mel Gorman wrote:
> On Thu, Oct 19, 2017 at 11:12:52AM +0200, Vlastimil Babka wrote:
>> On 10/18/2017 09:59 AM, Mel Gorman wrote:
>>> When a pagevec is initialised on the stack, it is generally used multiple
>>> times over a range of pages, looking up entries and then releasing them.
>>> On each pagevec_release, the per-cpu deferred LRU pagevecs are drained
>>> on the grounds the page being released may be on those queues and the
>>> pages may be cache hot. In many cases only the first drain is necessary
>>> as it's unlikely that the range of pages being walked is racing against
>>> LRU addition.  Even if there is such a race, the impact is marginal where
>>> as constantly redraining the lru pagevecs costs.
>>
>> Right, the drain is only to a local cpu, not all of them, so that kind
>> of "racing" shouldn't be even possible.
>>
> 
> Potentially the user of the pagevec can be preempted and another process
> modify the per-cpu pagevecs in parallel. Note even that users of a pagevec
> in a loop may call cond_resched so preemption is not even necessary if
> the pagevec is being used for a large enough number of operations. The
> risk is still marginal.
> 
>>> This patch ensures that pagevec is only drained once in a given lifecycle
>>> without increasing the cache footprint of the pagevec structure. Only
>>
>> Well, strictly speaking it does prevent decreasing the cache footprint
>> by removing the 'cold' field later :)
>>
> 
> Debatable. Even freeing a cold page if it was handled properly still has
> a cache footprint impact because the struct page fields are accessed.
> Maybe that's not what you meant and you are referring to the size of the
> structure itself.

Yes, I meant the size, sorry.

> If so, note that I change the type of the two fields so
> they should fit in the same size as an unsigned long in many cases.

Yeah.

> It's not draining the LRU as such. How about the following patch on top
> of the series? If another full series repost is necessary, I'll fold it
> in.

Looks good, thanks! The series is already in mmots so I expect Andrew
will fold it to the original patch.

> ---8<---
> mm, pagevec: Rename pagevec drained field
> 
> According to Vlastimil Babka, the drained field in pagevec is potentially
> misleading because it might be interpreted as draining this pagevec instead
> of the percpu lru pagevecs. Rename the field for clarity.
> 
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  include/linux/pagevec.h | 4 ++--
>  mm/swap.c               | 4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
> index 8dcde51e80ff..ba5dc27ef6bb 100644
> --- a/include/linux/pagevec.h
> +++ b/include/linux/pagevec.h
> @@ -16,7 +16,7 @@ struct address_space;
>  
>  struct pagevec {
>  	unsigned long nr;
> -	bool drained;
> +	bool percpu_pvec_drained;
>  	struct page *pages[PAGEVEC_SIZE];
>  };
>  
> @@ -52,7 +52,7 @@ static inline unsigned pagevec_lookup_tag(struct pagevec *pvec,
>  static inline void pagevec_init(struct pagevec *pvec)
>  {
>  	pvec->nr = 0;
> -	pvec->drained = false;
> +	pvec->percpu_pvec_drained = false;
>  }
>  
>  static inline void pagevec_reinit(struct pagevec *pvec)
> diff --git a/mm/swap.c b/mm/swap.c
> index b480279c760c..38e1b6374a97 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -833,9 +833,9 @@ EXPORT_SYMBOL(release_pages);
>   */
>  void __pagevec_release(struct pagevec *pvec)
>  {
> -	if (!pvec->drained) {
> +	if (!pvec->percpu_pvec_drained) {
>  		lru_add_drain();
> -		pvec->drained = true;
> +		pvec->percpu_pvec_drained = true;
>  	}
>  	release_pages(pvec->pages, pagevec_count(pvec));
>  	pagevec_reinit(pvec);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
