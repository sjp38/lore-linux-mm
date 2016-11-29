Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7398C6B0253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:01:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so42337337wmf.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:01:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t126si1392239wmg.88.2016.11.29.00.01.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 00:01:34 -0800 (PST)
Subject: Re: [PATCH] proc: mm: export PTE sizes directly in smaps (v2)
References: <20161117002851.C7BACB98@viggo.jf.intel.com>
 <8769d52a-de0b-8c98-1e0b-e5305c5c02f3@suse.cz>
 <cf887736-2a62-bce5-0d72-0455a642cd99@sr71.net>
 <763d778a-2637-39e0-bcde-265055cf1c18@suse.cz>
 <6262d9fa-8098-4e18-4129-932e5e4857cb@sr71.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <956c8885-87af-5f72-4aae-984b52c7a766@suse.cz>
Date: Tue, 29 Nov 2016 09:01:17 +0100
MIME-Version: 1.0
In-Reply-To: <6262d9fa-8098-4e18-4129-932e5e4857cb@sr71.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: hch@lst.de, akpm@linux-foundation.org, dan.j.williams@intel.com, khandual@linux.vnet.ibm.com, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On 11/28/2016 10:39 PM, Dave Hansen wrote:
> ... cc'ing the arm64 maintainers
> 
> On 11/28/2016 01:07 PM, Vlastimil Babka wrote:
>> On 11/28/2016 05:52 PM, Dave Hansen wrote:
>>> On 11/24/2016 06:22 AM, Vlastimil Babka wrote:
>>>> On 11/17/2016 01:28 AM, Dave Hansen wrote:
>>>>> @@ -702,11 +707,13 @@ static int smaps_hugetlb_range(pte_t *pt
>>>>>      }
>>>>>      if (page) {
>>>>>          int mapcount = page_mapcount(page);
>>>>> +        unsigned long hpage_size = huge_page_size(hstate_vma(vma));
>>>>>
>>>>> +        mss->rss_pud += hpage_size;
>>>>
>>>> This hardcoded pud doesn't look right, doesn't the pmd/pud depend on
>>>> hpage_size?
>>>
>>> Urg, nope.  Thanks for noticing that!  I think we'll need something
>>> along the lines of:
>>>
>>>                 if (hpage_size == PUD_SIZE)
>>>                         mss->rss_pud += PUD_SIZE;
>>>                 else if (hpage_size == PMD_SIZE)
>>>                         mss->rss_pmd += PMD_SIZE;
>>
>> Sounds better, although I wonder whether there are some weird arches
>> supporting hugepage sizes that don't match page table levels. I recall
>> that e.g. MIPS could do arbitrary size, but dunno if the kernel supports
>> that...
> 
> arm64 seems to have pretty arbitrary sizes, and seems to be able to
> build them out of multiple hardware PTE sizes.  I think I can fix my
> code to handle those:
> 
>                 if (hpage_size >= PGD_SIZE)
>                         mss->rss_pgd += PGD_SIZE;
>                 else if (hpage_size >= PUD_SIZE)
>                         mss->rss_pud += PUD_SIZE;
>                 else if (hpage_size >= PMD_SIZE)
>                         mss->rss_pmd += PMD_SIZE;
>                 else
>                         mss->rss_pte += PAGE_SIZE;
> 
> But, I *think* that means that smaps_hugetlb_range() is *currently*
> broken for these intermediate arm64 sizes.  The code does:
> 
>                 if (mapcount >= 2)
>                         mss->shared_hugetlb += hpage_size;
>                 else
>                         mss->private_hugetlb += hpage_size;
> 
> So I *think* if we may count a hugetlbfs arm64 CONT_PTES page multiple
> times, and account hpage_size for *each* of the CONT_PTES.  That would
> artificially inflate the smaps output for those pages.

Hmm IIUC walk_hugetlb_range() will call the smaps_hugetlb_range()
callback once per hugepage, not once per "pte", no? See
hugetlb_entry_end(). In that case the current code should be OK and
yours would undercount?

> Will / Catalin, is there something I'm missing?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
