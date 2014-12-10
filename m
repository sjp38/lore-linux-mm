Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9EEB16B006E
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 10:06:22 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so11531180wiw.1
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 07:06:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si8781750wiy.17.2014.12.10.07.06.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 07:06:21 -0800 (PST)
Message-ID: <5488616B.3070104@suse.cz>
Date: Wed, 10 Dec 2014 16:06:19 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
References: <20141123093348.GA16954@cucumber.anchor.net.au> <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com> <20141128080331.GD11802@js1304-P5Q-DELUXE> <54783FB7.4030502@suse.cz> <20141201083118.GB2499@js1304-P5Q-DELUXE> <20141202014724.GA22239@cucumber.bridge.anchor.net.au> <20141202045324.GC6268@js1304-P5Q-DELUXE> <20141202050608.GA11051@cucumber.bridge.anchor.net.au> <20141203075747.GB6276@js1304-P5Q-DELUXE> <20141204073045.GA2960@cucumber.anchor.net.au> <20141205010733.GA13751@js1304-P5Q-DELUXE>
In-Reply-To: <20141205010733.GA13751@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On 12/05/2014 02:07 AM, Joonsoo Kim wrote:
> ------------>8-----------------
>  From b7daa232c327a4ebbb48ca0538a2dbf9ca83ca1f Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Fri, 5 Dec 2014 09:38:30 +0900
> Subject: [PATCH] mm/compaction: stop the compaction if there isn't enough
>   freepage
>
> After compaction_suitable() passed, there is no check whether the system
> has enough memory to compact and blindly try to find freepage through
> iterating all memory range. This causes excessive cpu usage in low free
> memory condition and finally compaction would be failed. It makes sense
> that compaction would be stopped if there isn't enough freepage. So,
> this patch adds watermark check to isolate_freepages() in order to stop
> the compaction in this case.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/compaction.c |    9 +++++++++
>   1 file changed, 9 insertions(+)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index e005620..31c4009 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -828,6 +828,7 @@ static void isolate_freepages(struct compact_control *cc)
>   	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
>   	int nr_freepages = cc->nr_freepages;
>   	struct list_head *freelist = &cc->freepages;
> +	unsigned long watermark = low_wmark_pages(zone) + (2UL << cc->order);

Given that we maybe have already isolated up to 31 free pages (if 
cc->nr_migratepages is the maximum 32), then this is somewhat stricter 
than the check in isolation_suitable() (when nothing was isolated yet) 
and may interrupt us prematurely. We should allow for some slack.

>
>   	/*
>   	 * Initialise the free scanner. The starting point is where we last
> @@ -903,6 +904,14 @@ static void isolate_freepages(struct compact_control *cc)
>   		 */
>   		if (cc->contended)
>   			break;
> +
> +		/*
> +		 * Watermarks for order-0 must be met for compaction.
> +		 * See compaction_suitable for more detailed explanation.
> +		 */
> +		if (!zone_watermark_ok(zone, 0, watermark,
> +			cc->classzone_idx, cc->alloc_flags))
> +			break;
>   	}

I'm a also bit concerned about the overhead of doing this in each pageblock.

I wonder if there could be a mechanism where a process entering reclaim 
or compaction with the goal of meeting the watermarks to allocate, 
should increase the watermarks needed for further parallel allocation 
attempts to pass. Then it shouldn't happen that somebody else steals the 
memory.

>   	/* split_free_page does not map the pages */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
