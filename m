Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 92D9C6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 17:49:23 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id t59so8650237yho.5
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 14:49:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h66si1175894yka.66.2015.01.15.14.49.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 14:49:22 -0800 (PST)
Date: Thu, 15 Jan 2015 14:49:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmscan: fix highidx argument type
Message-Id: <20150115144920.33c446af388ed74c11dc573e@linux-foundation.org>
In-Reply-To: <1421360175-18899-1-git-send-email-mst@redhat.com>
References: <1421360175-18899-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

On Fri, 16 Jan 2015 00:18:12 +0200 "Michael S. Tsirkin" <mst@redhat.com> wrote:

> for_each_zone_zonelist_nodemask wants an enum zone_type
> argument, but is passed gfp_t:
> 
> mm/vmscan.c:2658:9:    expected int enum zone_type [signed] highest_zoneidx
> mm/vmscan.c:2658:9:    got restricted gfp_t [usertype] gfp_mask
> mm/vmscan.c:2658:9: warning: incorrect type in argument 2 (different base types)
> mm/vmscan.c:2658:9:    expected int enum zone_type [signed] highest_zoneidx
> mm/vmscan.c:2658:9:    got restricted gfp_t [usertype] gfp_mask

Which tool emitted these warnings?

> convert argument to the correct type.
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2656,7 +2656,7 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
>  	 * should make reasonable progress.
>  	 */
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> -					gfp_mask, nodemask) {
> +					gfp_zone(gfp_mask), nodemask) {
>  		if (zone_idx(zone) > ZONE_NORMAL)
>  			continue;

hm, I wonder what the runtime effects are.

The throttle_direct_reclaim() comment isn't really accurate, is it? 
"Throttle direct reclaimers if backing storage is backed by the
network".  The code is applicable to all types of backing, but was
added to address problems which are mainly observed with network
backing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
