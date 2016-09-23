Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B94D6B0287
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 09:00:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so222654913pfv.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 06:00:36 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id dg5si7873127pad.122.2016.09.23.06.00.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 06:00:35 -0700 (PDT)
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
References: <57E20A69.5010206@zoho.com>
 <20160922124735.GB11204@dhcp22.suse.cz>
 <35661a34-c3e0-0ec2-b58f-ee59bef4e4d4@zoho.com>
 <20160923084551.GG4478@dhcp22.suse.cz>
 <f9e708e1-121e-367e-1141-5470e5baffe5@zoho.com>
 <20160923124244.GN4478@dhcp22.suse.cz>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57E52762.9000702@zoho.com>
Date: Fri, 23 Sep 2016 21:00:18 +0800
MIME-Version: 1.0
In-Reply-To: <20160923124244.GN4478@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 09/23/2016 08:42 PM, Michal Hocko wrote:
>>>> no, it don't work for many special case
>>>> for example, provided  PMD_SIZE=2M
>>>> mapping [0x1f8800, 0x208800) virtual range will be split to two ranges
>>>> [0x1f8800, 0x200000) and [0x200000,0x208800) and map them separately
>>>> the first range will cause dead loop
>>>
>>> I am not sure I see your point. How can we deadlock if _both_ addresses
>>> get aligned to the page boundary and how does PMD_SIZE make any
>>> difference.
>>>
>> i will take a example to illustrate my considerations
>> provided PUD_SIZE == 1G, PMD_SIZE == 2M, PAGE_SIZE == 4K
>> it is used by arm64 normally
>>
>> we want to map virtual range [0xffffffff_ffc08800, 0xffffffff_fffff800) by
>> ioremap_page_range(),ioremap_pmd_range() is called to map the range
>> finally, ioremap_pmd_range() will call
>> ioremap_pte_range(pmd, 0xffffffff_ffc08800, 0xffffffff_fffe0000) and
>> ioremap_pte_range(pmd, 0xffffffff_fffe0000, 0xffffffff fffff800) separately
> 
> but those ranges are not aligned and it ioremap_page_range fix them up
> to _be_ aligned then there is no problem, right? So either I am missing
> something or we are talking past each other.
> 
my complementary considerations are show below

why not to round up the range start boundary to page aligned?
1, it don't remain consistent with the original logic
   take map [0x1800, 0x4800) as example
   the original logic map range [0x1000, 0x2000), but rounding up start boundary
   don't mapping the range [0x1000, 0x2000)
2, the rounding up start boundary maybe cause overflow, consider start boundary =
   0xffffffff_fffff800  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
