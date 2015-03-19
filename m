Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id A39356B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 04:41:17 -0400 (EDT)
Received: by wixw10 with SMTP id w10so5730621wix.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 01:41:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ui2si1221132wjc.15.2015.03.19.01.41.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 01:41:15 -0700 (PDT)
Message-ID: <550A8BA9.9040005@suse.cz>
Date: Thu, 19 Mar 2015 09:41:13 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] [RFC] mm/compaction: initialize compaction information
References: <1426743031-30096-1-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1426743031-30096-1-git-send-email-gioh.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

On 03/19/2015 06:30 AM, Gioh Kim wrote:
> I tried to start compaction via /proc/sys/vm/compact_memory
> as soon as I turned on my ARM-based platform.
> But the compaction didn't start.
> I found some variables in struct zone are not initalized.
> 
> I think zone->compact_cached_free_pfn and some cache values for compaction
> are initalized when the kernel starts compaction, not via
> /proc/sys/vm/compact_memory.
> If my guess is correct, an initialization are needed for that case.
> 
> 
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> ---
>  mm/compaction.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8c0d945..944a9cc 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1299,6 +1299,14 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  		__reset_isolation_suitable(zone);
>  
>  	/*
> +	 * If this is activated by /proc/sys/vm/compact_memory
> +	 * and the first try, cached information for compaction is not
> +	 * initialized.
> +	 */
> +	if (cc->order == -1 && zone->compact_cached_free_pfn == 0)
> +		__reset_isolation_suitable(zone);
> +
> +	/*
>  	 * Setup to move all movable pages to the end of the zone. Used cached
>  	 * information on where the scanners should start but check that it
>  	 * is initialised by ensuring the values are within zone boundaries.

The code below this comment already does the initialization if the cached values
are outside zone boundaries (e.g. due to not being initialized). So if I go
through what your __reset_isolation_suitable(zone) call possibly fixes:

- the code below comment should take care of zone->compact_cached_migrate_pfn
and zone->compact_cached_free_pfn.
- the value of zone->compact_blockskip_flush shouldn't affect whether compaction
is done.
- the state of pageblock_skip bits shouldn't matter for compaction via
/proc/sys... as that sets ignore_skip_hint = true

It might be perhaps possible that the cached scanner positions are close to
meeting and compaction occurs but doesn't process much. That would be also true
if both were zero, but at least on my x86 system, lowest zone's start_pfn is 1
so that would be detected and corrected. Maybe it is zero on yours though? (ARM?).

So in any case, the problem should be identified in more detail so we know the
fix is not accidental. It could be also worthwile to always reset scanner
positions when doing a /proc triggered compaction, so it's not depending on what
happened before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
