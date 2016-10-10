Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 508366B0069
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 02:40:19 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n3so32130202lfn.5
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 23:40:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tp11si2686763wjb.241.2016.10.09.23.40.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 09 Oct 2016 23:40:17 -0700 (PDT)
Subject: Re: [PATCH] mm: init gfp mask in kcompactd_do_work()
References: <57FB0C89.3040304@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <982e8902-18ac-eaa2-214a-87e68ce75732@suse.cz>
Date: Mon, 10 Oct 2016 08:40:14 +0200
MIME-Version: 1.0
In-Reply-To: <57FB0C89.3040304@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Yisheng Xie <xieyisheng1@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/10/2016 05:35 AM, Xishi Qiu wrote:
> We will use gfp_mask in the following path, but it's not init.
>
> kcompactd_do_work
> 	compact_zone
> 		gfpflags_to_migratetype
>
> However if not init, gfp_mask is always 0, and the result of
> gfpflags_to_migratetype(0) and gfpflags_to_migratetype(GFP_KERNEL)
> are the same, but it's a little confusion, so init it first.

Michal already did this as part of his patch, as it was needed to avoid 
wrongly restricting kcompactd to anonymous pages:

http://lkml.kernel.org/r/<20161007065019.GA18439@dhcp22.suse.cz>

> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/compaction.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9affb29..4b9a9d1 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1895,10 +1895,10 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  	struct zone *zone;
>  	struct compact_control cc = {
>  		.order = pgdat->kcompactd_max_order,
> +		.gfp_mask = GFP_KERNEL,
>  		.classzone_idx = pgdat->kcompactd_classzone_idx,
>  		.mode = MIGRATE_SYNC_LIGHT,
>  		.ignore_skip_hint = true,
> -
>  	};
>  	bool success = false;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
