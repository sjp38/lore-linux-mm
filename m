Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE0506B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 16:39:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so385002045pgd.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:39:52 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id e4si28075455plb.274.2016.11.28.13.39.51
        for <linux-mm@kvack.org>;
        Mon, 28 Nov 2016 13:39:51 -0800 (PST)
Subject: Re: [PATCH] proc: mm: export PTE sizes directly in smaps (v2)
References: <20161117002851.C7BACB98@viggo.jf.intel.com>
 <8769d52a-de0b-8c98-1e0b-e5305c5c02f3@suse.cz>
 <cf887736-2a62-bce5-0d72-0455a642cd99@sr71.net>
 <763d778a-2637-39e0-bcde-265055cf1c18@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <6262d9fa-8098-4e18-4129-932e5e4857cb@sr71.net>
Date: Mon, 28 Nov 2016 13:39:49 -0800
MIME-Version: 1.0
In-Reply-To: <763d778a-2637-39e0-bcde-265055cf1c18@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: hch@lst.de, akpm@linux-foundation.org, dan.j.williams@intel.com, khandual@linux.vnet.ibm.com, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

... cc'ing the arm64 maintainers

On 11/28/2016 01:07 PM, Vlastimil Babka wrote:
> On 11/28/2016 05:52 PM, Dave Hansen wrote:
>> On 11/24/2016 06:22 AM, Vlastimil Babka wrote:
>>> On 11/17/2016 01:28 AM, Dave Hansen wrote:
>>>> @@ -702,11 +707,13 @@ static int smaps_hugetlb_range(pte_t *pt
>>>>      }
>>>>      if (page) {
>>>>          int mapcount = page_mapcount(page);
>>>> +        unsigned long hpage_size = huge_page_size(hstate_vma(vma));
>>>>
>>>> +        mss->rss_pud += hpage_size;
>>>
>>> This hardcoded pud doesn't look right, doesn't the pmd/pud depend on
>>> hpage_size?
>>
>> Urg, nope.  Thanks for noticing that!  I think we'll need something
>> along the lines of:
>>
>>                 if (hpage_size == PUD_SIZE)
>>                         mss->rss_pud += PUD_SIZE;
>>                 else if (hpage_size == PMD_SIZE)
>>                         mss->rss_pmd += PMD_SIZE;
> 
> Sounds better, although I wonder whether there are some weird arches
> supporting hugepage sizes that don't match page table levels. I recall
> that e.g. MIPS could do arbitrary size, but dunno if the kernel supports
> that...

arm64 seems to have pretty arbitrary sizes, and seems to be able to
build them out of multiple hardware PTE sizes.  I think I can fix my
code to handle those:

                if (hpage_size >= PGD_SIZE)
                        mss->rss_pgd += PGD_SIZE;
                else if (hpage_size >= PUD_SIZE)
                        mss->rss_pud += PUD_SIZE;
                else if (hpage_size >= PMD_SIZE)
                        mss->rss_pmd += PMD_SIZE;
                else
                        mss->rss_pte += PAGE_SIZE;

But, I *think* that means that smaps_hugetlb_range() is *currently*
broken for these intermediate arm64 sizes.  The code does:

                if (mapcount >= 2)
                        mss->shared_hugetlb += hpage_size;
                else
                        mss->private_hugetlb += hpage_size;

So I *think* if we may count a hugetlbfs arm64 CONT_PTES page multiple
times, and account hpage_size for *each* of the CONT_PTES.  That would
artificially inflate the smaps output for those pages.

Will / Catalin, is there something I'm missing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
