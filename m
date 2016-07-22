Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7A656B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:33:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so218781585pfg.3
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 02:33:44 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 23si15005529pfq.32.2016.07.22.02.33.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 02:33:43 -0700 (PDT)
Message-ID: <5791E5B1.8060503@huawei.com>
Date: Fri, 22 Jul 2016 17:21:53 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mm/compact: why use low watermark to determine whether compact
 is finished instead of use high watermark?
References: <5791DFD4.5080207@huawei.com> <0b580155-d99a-f4a4-ef76-6166b41180aa@suse.cz>
In-Reply-To: <0b580155-d99a-f4a4-ef76-6166b41180aa@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "mel@csn.ul.ie" <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/7/22 17:04, Vlastimil Babka wrote:

> On 07/22/2016 10:56 AM, Xishi Qiu wrote:
>> Hi,
>>
>> I find all the watermarks in mm/compaction.c are low_wmark_pages(),
>> so why not use high watermark to determine whether compact is finished?
> 
> Why would you use high watermark? Quite the opposite, I want to move towards min watermark (precisely, the one in alloc_flags which is usually min) in this series:
> 
> https://lkml.org/lkml/2016/6/24/222
> 
> especially:
> 
> https://lkml.org/lkml/2016/6/24/214
> 
>> e.g.
>> __alloc_pages_nodemask()
>>     get_page_from_freelist()
>>     this is fast path, use use low_wmark_pages() in __zone_watermark_ok()
>>
>>     __alloc_pages_slowpath()
>>     this is slow path, usually use min_wmark_pages()
> 
> Yes, and compaction should be finished when allocation can succeed, so match __alloc_pages_slowpath().
> 

Sounds reasonable, but now we have kcompactd which called from kswapd,
so still use low wmark?

Thanks,
Xishi Qiu

>>
>> kswapd
>>     balance_pgdat()
>>     use high_wmark_pages() to determine whether zone is balanced
>>
>> Thanks,
>> Xishi Qiu
>>
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
