Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E40CF6B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 03:49:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so69838556wmw.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 00:49:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g78si19428550wmc.117.2016.05.02.00.49.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 May 2016 00:49:51 -0700 (PDT)
Subject: Re: [PATCH v2 0/6] Introduce ZONE_CMA
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160425053653.GA25662@js1304-P5Q-DELUXE>
 <20160428103927.GM2858@techsingularity.net>
 <20160429065145.GA19896@js1304-P5Q-DELUXE>
 <20160429092902.GQ2858@techsingularity.net>
 <20160502061423.GA31646@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5727069B.5070600@suse.cz>
Date: Mon, 2 May 2016 09:49:47 +0200
MIME-Version: 1.0
In-Reply-To: <20160502061423.GA31646@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/02/2016 08:14 AM, Joonsoo Kim wrote:
>>> > >Although it's separate issue, I should mentioned one thing. Related to
>>> > >I/O pinning issue, ZONE_CMA don't get blockdev allocation request so
>>> > >I/O pinning problem is much reduced.
>>> > >
>> >
>> >This is not super-clear from the patch. blockdev is using GFP_USER so it
>> >already should not be classed as MOVABLE. I could easily be looking in
>> >the wrong place or missed which allocation path sets GFP_MOVABLE.
> Okay. Please see sb_bread(), sb_getblk(), __getblk() and __bread() in
> include/linux/buffer_head.h. These are main functions used by blockdev
> and they uses GFP_MOVABLE. To fix permanent allocation case which is
> used by mount and cannot be released until umount, Gioh introduces
> sb_bread_unmovable() but there are many remaining issues that prevent
> migration at the moment and avoid blockdev allocation from CMA area is
> preferable approach.

Hm Patch 3/6 describes the lack of blockdev allocations mostly as a 
limitation, although it does mention the possible advantages later. 
Anyway, this doesn't have to be specific to ZONE_CMA, right? You could 
just change ALLOC_CMA handling to consider GFP_HIGHUSER_MOVABLE instead 
of just __GFP_MOVABLE. For ZONE_CMA it might be inevitable as you 
describe, but it's already possible to do that now, if the advantages 
are larger than the disadvantages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
