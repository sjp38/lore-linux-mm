Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A73BC6B025E
	for <linux-mm@kvack.org>; Mon, 23 May 2016 04:20:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o70so17065495lfg.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 01:20:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hb10si40972392wjb.95.2016.05.23.01.20.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 May 2016 01:20:26 -0700 (PDT)
Subject: Re: [PATCH] mm: compact: remove watermark check at compact suitable
References: <1463973617-10599-1-git-send-email-puck.chen@hisilicon.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5742BD46.8050403@suse.cz>
Date: Mon, 23 May 2016 10:20:22 +0200
MIME-Version: 1.0
In-Reply-To: <1463973617-10599-1-git-send-email-puck.chen@hisilicon.com>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, mina86@mina86.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: xuyiping@hisilicon.com, suzhuangluan@hisilicon.com, dan.zhao@hisilicon.com, qijiwen@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com

On 05/23/2016 05:20 AM, Chen Feng wrote:
> There are two paths calling this function.
> For direct compact, there is no need to check the zone watermark here.
> For kswapd wakeup kcompactd, since there is a reclaim before this.
> It makes sense to do compact even the watermark is ok at this time.

Hi,

I'm just working on v2 of the series [1] and some patches planned for v2 are 
trying to simplify the watermark checks around compaction. The check you are 
removing looked like simple and obvious one, so I didn't change it. But I'll 
think more about your patch, e.g. if there are some corner cases. See for 
example the fragindex check:

          * index of -1000 would imply allocations might succeed depending on
          * watermarks, but we already failed the high-order watermark check

After your patch, there is no more high-order watermark check, so the assumption 
here is gone.
Also the comment above __compaction_suitable() should be updated too.

[1] http://lkml.kernel.org/r/<1462865763-22084-1-git-send-email-vbabka@suse.cz>

> Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
> ---
>   mm/compaction.c | 7 -------
>   1 file changed, 7 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8fa2540..cb322df 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1260,13 +1260,6 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
>   		return COMPACT_CONTINUE;
>
>   	watermark = low_wmark_pages(zone);
> -	/*
> -	 * If watermarks for high-order allocation are already met, there
> -	 * should be no need for compaction at all.
> -	 */
> -	if (zone_watermark_ok(zone, order, watermark, classzone_idx,
> -								alloc_flags))
> -		return COMPACT_PARTIAL;
>
>   	/*
>   	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
