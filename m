Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6F56B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 11:40:19 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so7161906pdi.19
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 08:40:19 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id tu7si17162340pac.280.2014.03.10.08.40.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 10 Mar 2014 08:40:18 -0700 (PDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N2800LRH8V3OL40@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 11 Mar 2014 00:40:15 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCHv2] mm/compaction: Break out of loop on !PageBuddy in
 isolate_freepages_block
Date: Mon, 10 Mar 2014 16:40:02 +0100
Message-id: <6597669.aH5TlWtQEa@amdc1032>
In-reply-to: <1394130092-25440-1-git-send-email-lauraa@codeaurora.org>
References: <1394130092-25440-1-git-send-email-lauraa@codeaurora.org>
MIME-version: 1.0
Content-transfer-encoding: 7Bit
Content-type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>


Hi,

On Thursday, March 06, 2014 10:21:32 AM Laura Abbott wrote:
> We received several reports of bad page state when freeing CMA pages
> previously allocated with alloc_contig_range:
> 
> <1>[ 1258.084111] BUG: Bad page state in process Binder_A  pfn:63202
> <1>[ 1258.089763] page:d21130b0 count:0 mapcount:1 mapping:  (null) index:0x7dfbf
> <1>[ 1258.096109] page flags: 0x40080068(uptodate|lru|active|swapbacked)
> 
> Based on the page state, it looks like the page was still in use. The page
> flags do not make sense for the use case though. Further debugging showed
> that despite alloc_contig_range returning success, at least one page in the
> range still remained in the buddy allocator.
> 
> There is an issue with isolate_freepages_block. In strict mode (which CMA
> uses), if any pages in the range cannot be isolated,
> isolate_freepages_block should return failure 0. The current check keeps
> track of the total number of isolated pages and compares against the size
> of the range:
> 
>         if (strict && nr_strict_required > total_isolated)
>                 total_isolated = 0;
> 
> After taking the zone lock, if one of the pages in the range is not
> in the buddy allocator, we continue through the loop and do not
> increment total_isolated. If in the last iteration of the loop we isolate
> more than one page (e.g. last page needed is a higher order page), the
> check for total_isolated may pass and we fail to detect that a page was
> skipped. The fix is to bail out if the loop immediately if we are in
> strict mode. There's no benfit to continuing anyway since we need all
> pages to be isolated. Additionally, drop the error checking based on
> nr_strict_required and just check the pfn ranges. This matches with
> what isolate_freepages_range does.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Acked-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Thanks for catching & fixing this!

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
