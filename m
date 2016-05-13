Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9BB36B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 08:37:51 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j8so67369213lfd.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:37:51 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ts7si8616170wjb.215.2016.05.13.05.37.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 05:37:50 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r12so3464567wme.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:37:50 -0700 (PDT)
Date: Fri, 13 May 2016 14:37:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 07/13] mm, compaction: introduce direct compaction priority
Message-ID: <20160513123748.GM20141@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-8-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-8-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 10-05-16 09:35:57, Vlastimil Babka wrote:
> In the context of direct compaction, for some types of allocations we would
> like the compaction to either succeed or definitely fail while trying as hard
> as possible. Current async/sync_light migration mode is insufficient, as there
> are heuristics such as caching scanner positions, marking pageblocks as
> unsuitable or deferring compaction for a zone. At least the final compaction
> attempt should be able to override these heuristics.
> 
> To communicate how hard compaction should try, we replace migration mode with
> a new enum compact_priority and change the relevant function signatures. In
> compact_zone_order() where struct compact_control is constructed, the priority
> is mapped to suitable control flags. This patch itself has no functional
> change, as the current priority levels are mapped back to the same migration
> modes as before. Expanding them will be done next.
> 
> Note that !CONFIG_COMPACTION variant of try_to_compact_pages() is removed, as
> the only caller exists under CONFIG_COMPACTION.

Your s-o-b is missing

Anyway I like the idea. The migration_mode felt really weird. It exposes
an internal detail of the compaction code which should have no business
in the allocator path.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/compaction.h | 18 +++++++++---------
>  mm/compaction.c            | 14 ++++++++------
>  mm/page_alloc.c            | 27 +++++++++++++--------------
>  3 files changed, 30 insertions(+), 29 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 4ba90e74969c..900d181ff1b0 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -1,6 +1,14 @@
>  #ifndef _LINUX_COMPACTION_H
>  #define _LINUX_COMPACTION_H
>  
> +// TODO: lower value means higher priority to match reclaim, makes sense?

Yes this makes sense to me.

> +enum compact_priority {

enums might be tricky but I guess it should work ok here. I would just
add

	COMPACT_MIN_PRIO,
> +	COMPACT_PRIO_SYNC_LIGHT = COMPACT_MIN_PRIO,
> +	DEF_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
> +	COMPACT_PRIO_ASYNC,
> +	INIT_COMPACT_PRIORITY = COMPACT_PRIO_ASYNC
> +};
> +

to make an implementation independent lowest priority.

[...]

> @@ -3269,11 +3269,11 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  	/*
>  	 * compaction considers all the zone as desperately out of memory
>  	 * so it doesn't really make much sense to retry except when the
> -	 * failure could be caused by weak migration mode.
> +	 * failure could be caused by insufficient priority
>  	 */
>  	if (compaction_failed(compact_result)) {
> -		if (*migrate_mode == MIGRATE_ASYNC) {
> -			*migrate_mode = MIGRATE_SYNC_LIGHT;
> +		if (*compact_priority > 0) {

		if (*compact_priority > COMPACT_MIN_PRIO)

> +			(*compact_priority)--;
>  			return true;
>  		}
>  		return false;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
