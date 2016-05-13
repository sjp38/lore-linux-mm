Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8BA06B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 07:29:21 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so37156016lfq.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 04:29:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lz8si21760097wjb.35.2016.05.13.04.29.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 May 2016 04:29:20 -0700 (PDT)
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C402E@IRSMSX103.ger.corp.intel.com>
 <572CC092.5020702@intel.com> <20160511075313.GE16677@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5735BA8E.3080201@suse.cz>
Date: Fri, 13 May 2016 13:29:18 +0200
MIME-Version: 1.0
In-Reply-To: <20160511075313.GE16677@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>
Cc: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On 05/11/2016 09:53 AM, Michal Hocko wrote:
> On Fri 06-05-16 09:04:34, Dave Hansen wrote:
>> On 05/06/2016 08:10 AM, Odzioba, Lukasz wrote:
>>> On Thu 05-05-16 09:21:00, Michal Hocko wrote:
>>>> Or maybe the async nature of flushing turns
>>>> out to be just impractical and unreliable and we will end up skipping
>>>> THP (or all compound pages) for pcp LRU add cache. Let's see...
>>>
>>> What if we simply skip lru_add pvecs for compound pages?
>>> That way we still have compound pages on LRU's, but the problem goes
>>> away.  It is not quite what this naive patch does, but it works nice for me.
>>>
>>> diff --git a/mm/swap.c b/mm/swap.c
>>> index 03aacbc..c75d5e1 100644
>>> --- a/mm/swap.c
>>> +++ b/mm/swap.c
>>> @@ -392,7 +392,9 @@ static void __lru_cache_add(struct page *page)
>>>          get_page(page);
>>>          if (!pagevec_space(pvec))
>>>                  __pagevec_lru_add(pvec);
>>>          pagevec_add(pvec, page);
>>> +       if (PageCompound(page))
>>> +               __pagevec_lru_add(pvec);
>>>          put_cpu_var(lru_add_pvec);
>>>   }
>>
>> That's not _quite_ what I had in mind since that drains the entire pvec
>> every time a large page is encountered.  But I'm conflicted about what
>> the right behavior _is_.
>>
>> We'd taking the LRU lock for 'page' anyway, so we might as well drain
>> the pvec.

Note that pages in the pagevec can come from different zones, so this is 
not universally true.

>
> Yes I think this makes sense. The only case where it would be suboptimal
> is when the pagevec was already full and then we just created a single
> page pvec to drain it. This can be handled better though by:
>
> diff --git a/mm/swap.c b/mm/swap.c
> index 95916142fc46..3fe4f180e8bf 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -391,9 +391,8 @@ static void __lru_cache_add(struct page *page)
>   	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
>
>   	get_page(page);
> -	if (!pagevec_space(pvec))
> +	if (!pagevec_add(pvec, page) || PageCompound(page))
>   		__pagevec_lru_add(pvec);
> -	pagevec_add(pvec, page);
>   	put_cpu_var(lru_add_pvec);
>   }

Yeah that could work. There might be more complex solutions at the level
of lru_cache_add_active_or_unevictable() where we call it either from
base page code (mm/memory.c) or functions in mm/huge_memory.c. We could
redirect it at that point, but likely not worth the trouble unless this
simple solution doesn't show some performance regression...

>> Or, does the additional work to put the page on to a pvec and then
>> immediately drain it overwhelm that advantage?
>
> pagevec_add is quite trivial so I would be really surprised if it
> mattered.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
