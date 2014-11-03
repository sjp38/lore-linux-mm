Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4686B010C
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 03:29:07 -0500 (EST)
Received: by mail-lb0-f172.google.com with SMTP id w7so1692995lbi.17
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 00:29:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si6897266lag.49.2014.11.03.00.29.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 00:29:06 -0800 (PST)
Message-ID: <54573CCE.2090800@suse.cz>
Date: Mon, 03 Nov 2014 09:29:02 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v5 4/4] mm/page_alloc: restrict max order of merging on
 isolated pageblock
References: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com> <1414740330-4086-5-git-send-email-iamjoonsoo.kim@lge.com> <54539F11.7080501@suse.cz> <20141103081031.GC7052@js1304-P5Q-DELUXE>
In-Reply-To: <20141103081031.GC7052@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 11/03/2014 09:10 AM, Joonsoo Kim wrote:
> On Fri, Oct 31, 2014 at 03:39:13PM +0100, Vlastimil Babka wrote:
>>> +				__isolate_free_page(page, order);
>>> +				set_page_refcounted(page);
>>> +				isolated_page = page;
>>> +			}
>>> +		}
>>> +	}
>>>   	nr_pages = move_freepages_block(zone, page, migratetype);
>>
>> - this is a costly no-op when the whole pageblock is an isolated
>> page, right?
>
> Okay. I will fix it.
>
>>
>>>   	__mod_zone_freepage_state(zone, nr_pages, migratetype);
>>
>> - with isolated_page set, this means you increase freepage_state
>> here, and then the second time in __free_pages() below?
>> __isolate_free_page() won't decrease it as the pageblock is still
>> MIGRATE_ISOLATE, so the net result is overcounting?
>
> After __isolate_free_page(), freepage has no buddy flag and
> move_freepages_block() doesn't move and count it. So, freepage_state
> only increase in __free_pages(). So net result will be correct.

Ah right, I forgot that it gets nr_pages from the move_freepages_block() 
result (which is 0 in this case).

> Below is the update for your comment.
>
> Thanks.
>
> ------------>8----------------
>  From 4bf298908aba16935c7699589c60d00fa0cf389c Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Mon, 25 Aug 2014 09:52:13 +0900
> Subject: [PATCH v6 4/4] mm/page_alloc: restrict max order of merging on isolated
>   pageblock
>
> Current pageblock isolation logic could isolate each pageblock
> individually. This causes freepage accounting problem if freepage with
> pageblock order on isolate pageblock is merged with other freepage on
> normal pageblock. We can prevent merging by restricting max order of
> merging to pageblock order if freepage is on isolate pageblock.
>
> Side-effect of this change is that there could be non-merged buddy
> freepage even if finishing pageblock isolation, because undoing pageblock
> isolation is just to move freepage from isolate buddy list to normal buddy
> list rather than to consider merging. So, the patch also makes undoing
> pageblock isolation consider freepage merge. When un-isolation, freepage
> with more than pageblock order and it's buddy are checked. If they are
> on normal pageblock, instead of just moving, we isolate the freepage and
> free it in order to get merged.
>
> Changes from v5:
> Avoid costly move_freepages_block() if there is no freepage.
> Some cosmetic changes.
>
> Changes from v4:
> Consider merging on un-isolation process.
>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
