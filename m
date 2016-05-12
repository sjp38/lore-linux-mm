Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0166B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 08:00:24 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y84so53441225lfc.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 05:00:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10si16413930wmw.27.2016.05.12.05.00.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 May 2016 05:00:23 -0700 (PDT)
Subject: Re: [PATCH] mm, compaction: avoid uninitialized variable use
References: <1462973126-1183468-1-git-send-email-arnd@arndb.de>
 <20160512061636.GA4200@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57347052.7030307@suse.cz>
Date: Thu, 12 May 2016 14:00:18 +0200
MIME-Version: 1.0
In-Reply-To: <20160512061636.GA4200@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/12/2016 08:16 AM, Michal Hocko wrote:
> I think this would be slightly better than your proposal. Andrew, could
> you fold it into the original
> mm-compaction-simplify-__alloc_pages_direct_compact-feedback-interface.patch
> patch?
> ---
>  From 434bc8b6f3787724327499998c4fe651e8ce5d68 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 12 May 2016 08:10:33 +0200
> Subject: [PATCH] mmotm:
>   mm-compaction-simplify-__alloc_pages_direct_compact-feedback-interface-fix
>
> Arnd has reported the following compilation warning:
> mm/page_alloc.c: In function '__alloc_pages_nodemask':
> mm/page_alloc.c:3651:6: error: 'compact_result' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
> This should be a false positive TRANSPARENT_HUGEPAGE depends on COMPACTION
> so is_thp_gfp_mask shouldn't be true. GFP_TRANSHUGE is a bit tricky
> and somebody might be using this accidently. Make sure that compact_result
> is defined also for !CONFIG_COMPACT and set it to COMPACT_SKIPPED because
> the compaction was really withdrawn.
>
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Ack.

> ---
>   mm/page_alloc.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4950d01ff935..0d9008042efa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3300,6 +3300,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>   		unsigned int alloc_flags, const struct alloc_context *ac,
>   		enum migrate_mode mode, enum compact_result *compact_result)
>   {
> +	*compact_result = COMPACT_SKIPPED;
>   	return NULL;
>   }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
