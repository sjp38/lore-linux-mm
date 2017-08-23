Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1072280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 04:23:51 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y44so1426063wrd.13
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 01:23:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d68si987195wme.83.2017.08.23.01.23.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 01:23:50 -0700 (PDT)
Subject: Re: [patch 1/2] mm, compaction: kcompactd should not ignore pageblock
 skip
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5d578461-0982-f719-3a04-b2f3552dc7cc@suse.cz>
Date: Wed, 23 Aug 2017 10:23:49 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/16/2017 01:39 AM, David Rientjes wrote:
> Kcompactd is needlessly ignoring pageblock skip information.  It is doing
> MIGRATE_SYNC_LIGHT compaction, which is no more powerful than
> MIGRATE_SYNC compaction.
> 
> If compaction recently failed to isolate memory from a set of pageblocks,
> there is nothing to indicate that kcompactd will be able to do so, or
> that it is beneficial from attempting to isolate memory.
> 
> Use the pageblock skip hint to avoid rescanning pageblocks needlessly
> until that information is reset.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

It would be much better if patches like this were accompanied by some
numbers.

Also there's now a danger that in cases where there's no direct
compaction happening (just kcompactd), nothing will ever call
__reset_isolation_suitable().

> ---
>  mm/compaction.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1927,9 +1927,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  		.total_free_scanned = 0,
>  		.classzone_idx = pgdat->kcompactd_classzone_idx,
>  		.mode = MIGRATE_SYNC_LIGHT,
> -		.ignore_skip_hint = true,
> +		.ignore_skip_hint = false,
>  		.gfp_mask = GFP_KERNEL,
> -
>  	};
>  	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
>  							cc.classzone_idx);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
