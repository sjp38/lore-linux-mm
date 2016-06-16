Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33FDB6B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:25:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k184so24730727wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:25:52 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id b68si3495521wmi.95.2016.06.16.03.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 03:17:50 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id m124so62216915wme.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:17:50 -0700 (PDT)
Date: Thu, 16 Jun 2016 12:17:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/compaction: remove unnecessary order check in
 direct compact path
Message-ID: <20160616101748.GF6836@dhcp22.suse.cz>
References: <1466044956-3690-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466044956-3690-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mina86@mina86.com, minchan@kernel.org, mgorman@techsingularity.net, rientjes@google.com, kirill.shutemov@linux.intel.com, izumi.taku@jp.fujitsu.com, hannes@cmpxchg.org, khandual@linux.vnet.ibm.com, bsingharora@gmail.com

On Thu 16-06-16 10:42:36, Ganesh Mahendran wrote:
> In direct compact path, both __alloc_pages_direct_compact and
> try_to_compact_pages check (order == 0).
> 
> This patch removes the check in __alloc_pages_direct_compact() and
> move the modifying of current->flags to the entry point of direct
> page compaction where we really do the compaction.

I do not have strong opinion on whether the order should be checked at
try_to_compact_pages or __alloc_pages_direct_compact. The later one
sounds more suitable because no further steps are really appropriate for
order == 0. try_to_compact_pages is not used anywhere else to be order
aware (maybe it will in future, who knows). But this all is a matter of
taste.

[...]
> diff --git a/mm/compaction.c b/mm/compaction.c
> index fbb7b38..dcfaf57 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1686,12 +1686,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  
>  	*contended = COMPACT_CONTENDED_NONE;
>  
> -	/* Check if the GFP flags allow compaction */
> +	/*
> +	 * Check if this is an order-0 request and
> +	 * if the GFP flags allow compaction.
> +	 */

If you are touching this comment then it would be appropriate to change
it from "what is checked" into "why it is checked" because that is far
from obvious from this context. Especially !fs/io part.

>  	if (!order || !may_enter_fs || !may_perform_io)
>  		return COMPACT_SKIPPED;
>  

That being said, I am not really sure the patch is an improvement. If
anything I would much rather see the above comment updated.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
