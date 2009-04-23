Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9B76B0099
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 18:53:36 -0400 (EDT)
Date: Thu, 23 Apr 2009 15:48:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/22] Calculate the preferred zone for allocation only
 once
Message-Id: <20090423154834.bde33a72.akpm@linux-foundation.org>
In-Reply-To: <1240408407-21848-8-git-send-email-mel@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	<1240408407-21848-8-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com, peterz@infradead.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009 14:53:12 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> get_page_from_freelist() can be called multiple times for an allocation.
> Part of this calculates the preferred_zone which is the first usable zone
> in the zonelist but the zone depends on the GFP flags specified at the
> beginning of the allocation call. This patch calculates preferred_zone
> once. It's safe to do this because if preferred_zone is NULL at the start
> of the call, no amount of direct reclaim or other actions will change the
> fact the allocation will fail.
> 
>
> ...
>
> -	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
> -
>							&preferred_zone);
> ...  
>
> +	/* The preferred zone is used for statistics later */
> +	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,

Let's quietly zap that dopey cast.

--- a/mm/page_alloc.c~page-allocator-calculate-the-preferred-zone-for-allocation-only-once-fix
+++ a/mm/page_alloc.c
@@ -1775,8 +1775,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
 		return NULL;
 
 	/* The preferred zone is used for statistics later */
-	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
-							&preferred_zone);
+	first_zones_zonelist(zonelist, high_zoneidx, nodemask, &preferred_zone);
 	if (!preferred_zone)
 		return NULL;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
