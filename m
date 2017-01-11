Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE4896B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 12:15:49 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id d184so165053811ybh.4
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:15:49 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c8si1894100ywk.386.2017.01.11.09.15.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 09:15:49 -0800 (PST)
Subject: Re: [PATCH v4 2/4] mm: Add function to support extra actions on swap
 in/out
References: <cover.1483999591.git.khalid.aziz@oracle.com>
 <c24c7a844c61d6f8d57dd3791ad7ab5f05305c6b.1483999591.git.khalid.aziz@oracle.com>
 <b31a3aef-26d9-6d3a-109b-c8453a3a2aef@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <c5469ff4-1ed8-e545-069d-3c2d48c9a4e0@oracle.com>
Date: Wed, 11 Jan 2017 10:15:27 -0700
MIME-Version: 1.0
In-Reply-To: <b31a3aef-26d9-6d3a-109b-c8453a3a2aef@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, akpm@linux-foundation.org, davem@davemloft.net, arnd@arndb.de
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, jmarchan@redhat.com, vbabka@suse.cz, dan.j.williams@intel.com, lstoakes@gmail.com, hannes@cmpxchg.org, mgorman@suse.de, hughd@google.com, vdavydov.dev@gmail.com, minchan@kernel.org, namit@vmware.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 01/11/2017 09:56 AM, Dave Hansen wrote:
> On 01/11/2017 08:12 AM, Khalid Aziz wrote:
>> +#ifndef set_swp_pte_at
>> +#define set_swp_pte_at(mm, addr, ptep, pte, oldpte)	\
>> +		set_pte_at(mm, addr, ptep, pte)
>> +#endif
>
> BTW, thanks for the *much* improved description of the series.  This is
> way easier to understand.

Your feedback was very helpful in getting me there.

>
> I really don't think this is the interface we want, though.
> set_swp_pte_at() is really doing *two* things:
> 1. Detecting _PAGE_MCD_4V and squirreling the MCD data away at swap-out
> 2. Reading back in the MCD data at swap-on
>
> You're effectively using (!pte_none(pte) && !pte_present(pte)) to
> determine whether you're at swap in or swap out time.  That's goofy, IMNHO.
>
> It isn't obvious from the context, but this hunk is creating a migration
> PTE.  Why is ADI tag manipulation needed?  We're just changing the
> physical address of the underlying memory, but neither the
> application-visible contents nor the tags are changing.

Memory controller associates tags with physical memory. MMU verifies 
these tags against the tag embedded in VA. If physical memory is moved, 
tags must move with it.

>
>> @@ -1539,7 +1539,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  		swp_pte = swp_entry_to_pte(entry);
>>  		if (pte_soft_dirty(pteval))
>>  			swp_pte = pte_swp_mksoft_dirty(swp_pte);
>> -		set_pte_at(mm, address, pte, swp_pte);
>> +		set_swp_pte_at(mm, address, pte, swp_pte, pteval);
>>  	} else if (PageAnon(page)) {
>>  		swp_entry_t entry = { .val = page_private(page) };
>>  		pte_t swp_pte;
>
> Which means you're down to a single call that does swap-out, and a
> single call that does swap-in.  There's no reason to hide all your code
> behind set_pte_at().
>
> Just add a new arch-specific call that takes the VMA and the swap PTE
> and stores the ADI bit in there, here:
>
>> @@ -1572,7 +1572,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  		swp_pte = swp_entry_to_pte(entry);
>>  		if (pte_soft_dirty(pteval))
>>  			swp_pte = pte_swp_mksoft_dirty(swp_pte);
>> -		set_pte_at(mm, address, pte, swp_pte);
>> +		set_swp_pte_at(mm, address, pte, swp_pte, pteval);
>>  	} else
>
> and in do_swap_page(), do the opposite with a second, new call.

That does sound simpler. I will give it more thought.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
