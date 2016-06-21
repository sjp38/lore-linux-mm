Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D429E6B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 22:11:29 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s63so14557422ioi.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 19:11:29 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id u11si12088644otd.28.2016.06.20.19.11.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Jun 2016 19:11:29 -0700 (PDT)
Subject: Re: [PATCH v3 0/6] Introduce ZONE_CMA
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160526080454.GA11823@shbuild888>
 <20160527052820.GA13661@js1304-P5Q-DELUXE>
 <20160527062527.GA32297@shbuild888>
 <20160527064218.GA14858@js1304-P5Q-DELUXE> <20160527072702.GA7782@shbuild888>
 <5763A909.8080907@hisilicon.com> <20160620064816.GB13747@js1304-P5Q-DELUXE>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <5768A198.7050607@hisilicon.com>
Date: Tue, 21 Jun 2016 10:08:24 +0800
MIME-Version: 1.0
In-Reply-To: <20160620064816.GB13747@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Feng Tang <feng.tang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yiping Xu <xuyiping@hisilicon.com>, "fujun
 (F)" <oliver.fu@hisilicon.com>, Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>, saberlily.xia@hisilicon.com



On 2016/6/20 14:48, Joonsoo Kim wrote:
> On Fri, Jun 17, 2016 at 03:38:49PM +0800, Chen Feng wrote:
>> Hi Kim & feng,
>>
>> Thanks for the share. In our platform also has the same use case.
>>
>> We only let the alloc with GFP_HIGHUSER_MOVABLE in memory.c to use cma memory.
>>
>> If we add zone_cma, It seems can resolve the cma migrate issue.
>>
>> But when free_hot_cold_page, we need let the cma page goto system directly not the pcp.
>> It can be fail while cma_alloc and cma_release. If we alloc the whole cma pages which
>> declared before.
> 
> Hmm...I'm not sure I understand your explanation. So, if I miss
> something, please let me know. We calls drain_all_pages() when
> isolating pageblock and alloc_contig_range() also has one
> drain_all_pages() calls to drain pcp pages. And, after pageblock isolation,
> freed pages belonging to MIGRATE_ISOLATE pageblock will go to the
> buddy directly so there would be no problem you mentioned. Isn't it?
> 
Yes, you are right.

I mean if the we free cma page to pcp-list, it will goto the migrate_movable list.

Then the alloc with movable flag can use the cma memory from the list with buffered_rmqueue.

But that's not what we want. It will cause the migrate fail if all movable alloc can use cma memory.

If I am wrong, please correct me.

Thanks.

> Thanks.
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
