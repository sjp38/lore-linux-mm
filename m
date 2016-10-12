Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D8ECF6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:33:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d128so4492592wmf.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:33:30 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id z8si1352690wmb.134.2016.10.12.00.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 00:33:29 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id c78so1032457wme.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:33:29 -0700 (PDT)
Date: Wed, 12 Oct 2016 09:33:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 4/4] mm: make unreserve highatomic functions reliable
Message-ID: <20161012073328.GC9504@dhcp22.suse.cz>
References: <1476250416-22733-1-git-send-email-minchan@kernel.org>
 <1476250416-22733-5-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476250416-22733-5-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Wed 12-10-16 14:33:36, Minchan Kim wrote:
[...]
> @@ -2138,8 +2146,10 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
>  			 */
>  			set_pageblock_migratetype(page, ac->migratetype);
>  			ret = move_freepages_block(zone, page, ac->migratetype);
> -			spin_unlock_irqrestore(&zone->lock, flags);
> -			return ret;
> +			if (!drain && ret) {
> +				spin_unlock_irqrestore(&zone->lock, flags);
> +				return ret;
> +			}

I've already mentioned that during the previous discussion. This sounds
overly aggressive to me. Why do we want to drain the whole reserve and
risk that we won't be able to build up a new one after OOM. Doing one
block at the time should be sufficient IMHO.

			if (ret) {
				spin_unlock_irqrestore(&zone->lock, flags);
				return ret;
			}

will do the trick and work both for drain and !drain cases which is a
good thing. Because even !drain case would like to see a block freed.
The only difference between those two is that the drain one would really
like to free something and ignore the "at least one block" reserve.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
