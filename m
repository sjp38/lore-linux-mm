Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id EEF6A6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 14:02:08 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id q58so21860165wes.12
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 11:02:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si5767300wic.38.2015.01.16.11.02.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 11:02:07 -0800 (PST)
Message-ID: <54B9602E.70707@suse.cz>
Date: Fri, 16 Jan 2015 20:02:06 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmscan: fix highidx argument type
References: <1421360175-18899-1-git-send-email-mst@redhat.com> <20150115144920.33c446af388ed74c11dc573e@linux-foundation.org> <20150116070744.GA12190@redhat.com> <54B95E41.5010305@suse.cz>
In-Reply-To: <54B95E41.5010305@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

On 01/16/2015 07:53 PM, Vlastimil Babka wrote:
> BTW, I wonder if the whole code couldn't be much simpler by capping high_zoneidx
> by ZONE_NORMAL before traversing the zonelist, like this:
> 
> int high_zoneidx = min(gfp_zone(gfp_mask), ZONE_NORMAL);
> 
> first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);

Erm, s/NULL/nodemask/ here. I copy/pasted this from before 675becce15f32, where
it didn't actually use the nodemask parameter of throttle_direct_reclaim(),
Wonder why, looks like another bug to me, that the commit has silently fixed.

> pgdat = zone->zone_pgdat;
> 
> if (!pgdat || pfmemalloc_watermark_ok(pgdat))
> 	goto out;
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
