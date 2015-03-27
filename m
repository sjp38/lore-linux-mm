Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 62ABD6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 20:54:58 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so79344575pdb.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 17:54:58 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id pc10si538139pdb.109.2015.03.26.17.54.55
        for <linux-mm@kvack.org>;
        Thu, 26 Mar 2015 17:54:57 -0700 (PDT)
Message-ID: <5514A9AF.30108@lge.com>
Date: Fri, 27 Mar 2015 09:51:59 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFCv2] mm: page allocation for less fragmentation
References: <1427251155-12322-1-git-send-email-gioh.kim@lge.com> <20150325105640.GI4701@suse.de> <551325A6.5000405@lge.com> <20150326102803.GL4701@suse.de>
In-Reply-To: <20150326102803.GL4701@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, rientjes@google.com, vdavydov@parallels.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com



2015-03-26 i??i?? 7:28i?? Mel Gorman i?'(e??) i?' e,?:
> On Thu, Mar 26, 2015 at 06:16:22AM +0900, Gioh Kim wrote:
>>
>>
>> 2015-03-25 ?????? 7:56??? Mel Gorman ???(???) ??? ???:
>>> On Wed, Mar 25, 2015 at 11:39:15AM +0900, Gioh Kim wrote:
>>>> My driver allocates more than 40MB pages via alloc_page() at a time and
>>>> maps them at virtual address. Totally it uses 300~400MB pages.
>>>>
>>>> If I run a heavy load test for a few days in 1GB memory system, I cannot allocate even order=3 pages
>>>> because-of the external fragmentation.
>>>>
>>>> I thought I needed a anti-fragmentation solution for my driver.
>>>> But there is no allocation function that considers fragmentation.
>>>> The compaction is not helpful because it is only for movable pages, not unmovable pages.
>>>>
>>>> This patch proposes a allocation function allocates only pages in the same pageblock.
>>>>
>>>
>>> Is this not what CMA is for? Or creating a MOVABLE zone?
>>
>> It's not related to CMA and MOVABLE zone.
>> It's for compaction and anti-fragmentation for any zone.
>>
>
> Create a CMA area, allow your driver to use it use alloc_contig_range.
> As it is, this is creating another contiguous range allocation function
> with no in-kernel users.
>

I'm sorry but I cannot follow your point.
I think this is not contiguous range allocation.
And CMA is not suitable for my driver because it needs fast allocation.

I can move pages into CMA area if I need high-order pages.
But the pages are unmovable types so it would pin the CMA area.

Please let me explain my problem again.
I've been suffering for years from fragmentation via unmovable pages.
Many of them are via graphic driver such as gpu and coder/decoder.
Current kernel compaction is not sufficient with this situation.
Graphic memory of the embedded systems like TV, phone I'm working for is getting bigger.
For instance my platform has 1GB and 300MB~400MB are consumed for graphic processing.
There are two reason:
1. cpu and gpu share memory
2. screen size(resolution) is getting bigger so that icon and ux images also are getting bigger

Therefore I don't need any contigous pages, but less fragmentation page allocation for unmovable pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
