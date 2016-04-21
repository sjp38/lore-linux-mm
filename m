Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFF5B83090
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 02:45:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so131421161pfb.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 23:45:44 -0700 (PDT)
Received: from out4133-82.mail.aliyun.com (out4133-82.mail.aliyun.com. [42.120.133.82])
        by mx.google.com with ESMTP id m86si1823629pfj.88.2016.04.20.23.45.43
        for <linux-mm@kvack.org>;
        Wed, 20 Apr 2016 23:45:44 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org> <1461181647-8039-7-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-7-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 06/14] mm, compaction: Update compaction_result ordering
Date: Thu, 21 Apr 2016 14:45:34 +0800
Message-ID: <02cc01d19b99$688e68c0$39ab3a40$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Joonsoo Kim' <js1304@gmail.com>, 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> 
> From: Michal Hocko <mhocko@suse.com>
> 
> compaction_result will be used as the primary feedback channel for
> compaction users. At the same time try_to_compact_pages (and potentially
> others) assume a certain ordering where a more specific feedback takes
> precendence. This gets a bit awkward when we have conflicting feedback
> from different zones. E.g one returing COMPACT_COMPLETE meaning the full
> zone has been scanned without any outcome while other returns with
> COMPACT_PARTIAL aka made some progress. The caller should get
> COMPACT_PARTIAL because that means that the compaction still can make
> some progress. The same applies for COMPACT_PARTIAL vs.
> COMPACT_PARTIAL_SKIPPED. Reorder PARTIAL to be the largest one so the
> larger the value is the more progress we have done.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  include/linux/compaction.h | 26 ++++++++++++++++----------
>  1 file changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 7c4de92d12cc..a7b9091ff349 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -4,6 +4,8 @@
>  /* Return values for compact_zone() and try_to_compact_pages() */
>  /* When adding new states, please adjust include/trace/events/compaction.h */
>  enum compact_result {
> +	/* For more detailed tracepoint output - internal to compaction */
> +	COMPACT_NOT_SUITABLE_ZONE,
>  	/*
>  	 * compaction didn't start as it was not possible or direct reclaim
>  	 * was more suitable
> @@ -11,30 +13,34 @@ enum compact_result {
>  	COMPACT_SKIPPED,
>  	/* compaction didn't start as it was deferred due to past failures */
>  	COMPACT_DEFERRED,
> +
>  	/* compaction not active last round */
>  	COMPACT_INACTIVE = COMPACT_DEFERRED,
> 
> +	/* For more detailed tracepoint output - internal to compaction */
> +	COMPACT_NO_SUITABLE_PAGE,
>  	/* compaction should continue to another pageblock */
>  	COMPACT_CONTINUE,
> +
>  	/*
> -	 * direct compaction partially compacted a zone and there are suitable
> -	 * pages
> +	 * The full zone was compacted scanned but wasn't successfull to compact
> +	 * suitable pages.
>  	 */
> -	COMPACT_PARTIAL,
> +	COMPACT_COMPLETE,
>  	/*
>  	 * direct compaction has scanned part of the zone but wasn't successfull
>  	 * to compact suitable pages.
>  	 */
>  	COMPACT_PARTIAL_SKIPPED,
> +
> +	/* compaction terminated prematurely due to lock contentions */
> +	COMPACT_CONTENDED,
> +
>  	/*
> -	 * The full zone was compacted scanned but wasn't successfull to compact
> -	 * suitable pages.
> +	 * direct compaction partially compacted a zone and there might be
> +	 * suitable pages
>  	 */
> -	COMPACT_COMPLETE,
> -	/* For more detailed tracepoint output */
> -	COMPACT_NO_SUITABLE_PAGE,
> -	COMPACT_NOT_SUITABLE_ZONE,
> -	COMPACT_CONTENDED,
> +	COMPACT_PARTIAL,
>  };
> 
>  /* Used to signal whether compaction detected need_sched() or lock contention */
> --
> 2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
