Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id BB87C6B0270
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:37:18 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 184so17843776pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:37:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kg11si9812155pab.171.2016.04.05.13.37.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:37:17 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:37:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: reclaim highmem zone if buffer_heads is
 over limit
Message-Id: <20160405133716.00e0f6ce92dc4bfed50c5334@linux-foundation.org>
In-Reply-To: <1459727169-5698-1-git-send-email-minchan@kernel.org>
References: <1459727169-5698-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, stable@vger.kernel.org

On Mon,  4 Apr 2016 08:46:09 +0900 Minchan Kim <minchan@kernel.org> wrote:

> We have been reclaimed highmem zone if buffer_heads is over limit
> but [1] changed the behavior so it doesn't reclaim highmem zone
> although buffer_heads is over the limit.
> This patch restores the logic.
> 
> [1] commit 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2550,7 +2550,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  		sc->gfp_mask |= __GFP_HIGHMEM;
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> -					requested_highidx, sc->nodemask) {
> +					gfp_zone(sc->gfp_mask), sc->nodemask) {
>  		enum zone_type classzone_idx;
>  
>  		if (!populated_zone(zone))

Wait wut wot.  We broke this over a year ago?  Highmem pagecache pages
pinning buffer_head lowmem used to be a huuuge problem.  Before most of
you were born ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
