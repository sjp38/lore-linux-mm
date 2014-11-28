Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 945E86B0069
	for <linux-mm@kvack.org>; Fri, 28 Nov 2014 04:26:07 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l2so8351606wgh.41
        for <linux-mm@kvack.org>; Fri, 28 Nov 2014 01:26:05 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qm5si16158025wjc.16.2014.11.28.01.26.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Nov 2014 01:26:05 -0800 (PST)
Message-ID: <54783FB7.4030502@suse.cz>
Date: Fri, 28 Nov 2014 10:26:15 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
References: <20141119012110.GA2608@cucumber.iinet.net.au> <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com> <20141119212013.GA18318@cucumber.anchor.net.au> <546D2366.1050506@suse.cz> <20141121023554.GA24175@cucumber.bridge.anchor.net.au> <20141123093348.GA16954@cucumber.anchor.net.au> <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com> <20141128080331.GD11802@js1304-P5Q-DELUXE>
In-Reply-To: <20141128080331.GD11802@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Korolyov <andrey@xdel.ru>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 28.11.2014 9:03, Joonsoo Kim wrote:
> On Tue, Nov 25, 2014 at 01:48:42AM +0400, Andrey Korolyov wrote:
>> On Sun, Nov 23, 2014 at 12:33 PM, Christian Marie <christian@ponies.io> wrote:
>>> Here's an update:
>>>
>>> Tried running 3.18.0-rc5 over the weekend to no avail. A load spike through
>>> Ceph brings no perceived improvement over the chassis running 3.10 kernels.
>>>
>>> Here is a graph of *system* cpu time (not user), note that 3.18 was a005.block:
>>>
>>> http://ponies.io/raw/cluster.png
>>>
>>> It is perhaps faring a little better that those chassis running the 3.10 in
>>> that it did not have min_free_kbytes raised to 2GB as the others did, instead
>>> it was sitting around 90MB.
>>>
>>> The perf recording did look a little different. Not sure if this was just the
>>> luck of the draw in how the fractal rendering works:
>>>
>>> http://ponies.io/raw/perf-3.10.png
>>>
>>> Any pointers on how we can track this down? There's at least three of us
>>> following at this now so we should have plenty of area to test.
>>
>> Checked against 3.16 (3.17 hanged for an unrelated problem), the issue
>> is presented for single- and two-headed systems as well. Ceph-users
>> reported presence of the problem for 3.17, so probably we are facing
>> generic compaction issue.
>>
> Hello,
>
> I didn't follow-up this discussion, but, at glance, this excessive CPU
> usage by compaction is related to following fixes.
>
> Could you test following two patches?
>
> If these fixes your problem, I will resumit patches with proper commit
> description.
>
> Thanks.
>
> -------->8-------------
>  From 079f3f119f1e3cbe9d981e7d0cada94e0c532162 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Fri, 28 Nov 2014 16:36:00 +0900
> Subject: [PATCH 1/2] mm/compaction: fix wrong order check in
>   compact_finished()
>
> What we want to check here is whether there is highorder freepage
> in buddy list of other migratetype in order to steal it without
> fragmentation. But, current code just checks cc->order which means
> allocation request order. So, this is wrong.
>
> Without this fix, non-movable synchronous compaction below pageblock order
> would not stopped until compaction complete, because migratetype of most
> pageblocks are movable and cc->order is always below than pageblock order
> in this case.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/compaction.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index b544d61..052194f 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1082,7 +1082,7 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
>   			return COMPACT_PARTIAL;
>   
>   		/* Job done if allocation would set block type */
> -		if (cc->order >= pageblock_order && area->nr_free)
> +		if (order >= pageblock_order && area->nr_free)
>   			return COMPACT_PARTIAL;

Dang, good catch!
But I wonder, are MIGRATE_RESERVE pages counted towards area->nr_free?
Seems to me that they are, so this check can have false positives?
Hm probably for unmovable allocation, MIGRATE_CMA pages is the same case?

Vlastimil

>   	}
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
