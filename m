Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F44A6B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:04:24 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p41so68538106lfi.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 02:04:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g6si8935244lfd.337.2016.07.22.02.04.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 02:04:22 -0700 (PDT)
Subject: Re: mm/compact: why use low watermark to determine whether compact is
 finished instead of use high watermark?
References: <5791DFD4.5080207@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0b580155-d99a-f4a4-ef76-6166b41180aa@suse.cz>
Date: Fri, 22 Jul 2016 11:04:20 +0200
MIME-Version: 1.0
In-Reply-To: <5791DFD4.5080207@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/22/2016 10:56 AM, Xishi Qiu wrote:
> Hi,
>
> I find all the watermarks in mm/compaction.c are low_wmark_pages(),
> so why not use high watermark to determine whether compact is finished?

Why would you use high watermark? Quite the opposite, I want to move 
towards min watermark (precisely, the one in alloc_flags which is 
usually min) in this series:

https://lkml.org/lkml/2016/6/24/222

especially:

https://lkml.org/lkml/2016/6/24/214

> e.g.
> __alloc_pages_nodemask()
> 	get_page_from_freelist()
> 	this is fast path, use use low_wmark_pages() in __zone_watermark_ok()
>
> 	__alloc_pages_slowpath()
> 	this is slow path, usually use min_wmark_pages()

Yes, and compaction should be finished when allocation can succeed, so 
match __alloc_pages_slowpath().

>
> kswapd
> 	balance_pgdat()
> 	use high_wmark_pages() to determine whether zone is balanced
>
> Thanks,
> Xishi Qiu
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
