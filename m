Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D53666B0253
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:52:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so221738470pfx.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 08:52:45 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id e3si27320881plj.316.2016.11.28.08.52.45
        for <linux-mm@kvack.org>;
        Mon, 28 Nov 2016 08:52:45 -0800 (PST)
Subject: Re: [PATCH] proc: mm: export PTE sizes directly in smaps (v2)
References: <20161117002851.C7BACB98@viggo.jf.intel.com>
 <8769d52a-de0b-8c98-1e0b-e5305c5c02f3@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <cf887736-2a62-bce5-0d72-0455a642cd99@sr71.net>
Date: Mon, 28 Nov 2016 08:52:43 -0800
MIME-Version: 1.0
In-Reply-To: <8769d52a-de0b-8c98-1e0b-e5305c5c02f3@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: hch@lst.de, akpm@linux-foundation.org, dan.j.williams@intel.com, khandual@linux.vnet.ibm.com, linux-mm@kvack.org

On 11/24/2016 06:22 AM, Vlastimil Babka wrote:
> On 11/17/2016 01:28 AM, Dave Hansen wrote:
>> @@ -702,11 +707,13 @@ static int smaps_hugetlb_range(pte_t *pt
>>      }
>>      if (page) {
>>          int mapcount = page_mapcount(page);
>> +        unsigned long hpage_size = huge_page_size(hstate_vma(vma));
>>
>> +        mss->rss_pud += hpage_size;
> 
> This hardcoded pud doesn't look right, doesn't the pmd/pud depend on
> hpage_size?

Urg, nope.  Thanks for noticing that!  I think we'll need something
along the lines of:

                if (hpage_size == PUD_SIZE)
                        mss->rss_pud += PUD_SIZE;
                else if (hpage_size == PMD_SIZE)
                        mss->rss_pmd += PMD_SIZE;

I'll respin and resend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
