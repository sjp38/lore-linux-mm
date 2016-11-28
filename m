Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 42EE76B02BF
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 16:07:22 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so39671043wms.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:07:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dy10si56119383wjb.80.2016.11.28.13.07.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 13:07:21 -0800 (PST)
Subject: Re: [PATCH] proc: mm: export PTE sizes directly in smaps (v2)
References: <20161117002851.C7BACB98@viggo.jf.intel.com>
 <8769d52a-de0b-8c98-1e0b-e5305c5c02f3@suse.cz>
 <cf887736-2a62-bce5-0d72-0455a642cd99@sr71.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <763d778a-2637-39e0-bcde-265055cf1c18@suse.cz>
Date: Mon, 28 Nov 2016 22:07:07 +0100
MIME-Version: 1.0
In-Reply-To: <cf887736-2a62-bce5-0d72-0455a642cd99@sr71.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: hch@lst.de, akpm@linux-foundation.org, dan.j.williams@intel.com, khandual@linux.vnet.ibm.com, linux-mm@kvack.org

On 11/28/2016 05:52 PM, Dave Hansen wrote:
> On 11/24/2016 06:22 AM, Vlastimil Babka wrote:
>> On 11/17/2016 01:28 AM, Dave Hansen wrote:
>>> @@ -702,11 +707,13 @@ static int smaps_hugetlb_range(pte_t *pt
>>>      }
>>>      if (page) {
>>>          int mapcount = page_mapcount(page);
>>> +        unsigned long hpage_size = huge_page_size(hstate_vma(vma));
>>>
>>> +        mss->rss_pud += hpage_size;
>>
>> This hardcoded pud doesn't look right, doesn't the pmd/pud depend on
>> hpage_size?
> 
> Urg, nope.  Thanks for noticing that!  I think we'll need something
> along the lines of:
> 
>                 if (hpage_size == PUD_SIZE)
>                         mss->rss_pud += PUD_SIZE;
>                 else if (hpage_size == PMD_SIZE)
>                         mss->rss_pmd += PMD_SIZE;

Sounds better, although I wonder whether there are some weird arches
supporting hugepage sizes that don't match page table levels. I recall
that e.g. MIPS could do arbitrary size, but dunno if the kernel supports
that...

> I'll respin and resend.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
