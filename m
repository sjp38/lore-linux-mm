Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3300F6B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 05:45:41 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id b17so6558642lan.39
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 02:45:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pj6si12392463lbb.20.2014.08.12.02.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 02:45:39 -0700 (PDT)
Message-ID: <53E9E23C.6030709@suse.cz>
Date: Tue, 12 Aug 2014 11:45:32 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/8] mm/isolation: close the two race problems related
 to pageblock isolation
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com> <1407309517-3270-8-git-send-email-iamjoonsoo.kim@lge.com> <20140812051745.GC23418@gmail.com>
In-Reply-To: <20140812051745.GC23418@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/12/2014 07:17 AM, Minchan Kim wrote:
> On Wed, Aug 06, 2014 at 04:18:33PM +0900, Joonsoo Kim wrote:
>>
>> One solution to this problem is checking pageblock migratetype with
>> holding zone lock in __free_one_page() and I posted it before, but,
>> it didn't get welcome since it needs the hook in zone lock critical
>> section on freepath.
>
> I didn't review your v1 but IMHO, this patchset is rather complex.

It is, but the complexity is in the isolation code, and not fast paths, 
so that's justifiable IMHO.

> Normally, we don't like adding more overhead in fast path but we did
> several time on hotplug/cma, esp so I don't know a few more thing is
> really hesitant.

This actually undoes most of the overhead, so I'm all for it. Better 
than keep doing stuff the same way just because it was done previously.

> In addition, you proved by this patchset how this
> isolation code looks ugly and fragile for race problem so I vote
> adding more overhead in fast path if it can make code really simple.

Well, I recommend you to check out the v1 then :) That wasn't really 
simple, that was even more hooks rechecking migratetypes at various 
places of the fast paths, when merging buddies etc. This is much better. 
The complexity is mostly in the isolation code, and the overhead happens 
only during isolation.

> Vlastimil?

Well, I was the main opponent of v1 and suggested to do v2 like this, so 
here you go :)

> To Joonsoo,
>
> you want to send this patchset for stable since review is done?
> IIRC, you want to fix freepage couting bug and send it to stable but
> as I see this patchset, no make sense to send to stable. :(

Yeah that's one disadvantage. But I wouldn't like the v1 for stable even 
more.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
