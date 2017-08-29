Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56E426B02B4
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 20:36:18 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q68so3177259pgq.11
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:36:18 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s194si1211331pgc.142.2017.08.28.17.36.16
        for <linux-mm@kvack.org>;
        Mon, 28 Aug 2017 17:36:17 -0700 (PDT)
Date: Tue, 29 Aug 2017 09:36:58 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
Message-ID: <20170829003657.GC14489@js1304-P5Q-DELUXE>
References: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
 <e919c65e-bc2f-6b3b-41fc-3589590a84ac@suse.cz>
 <20170825002031.GD29701@js1304-P5Q-DELUXE>
 <d57eeb5c-d91d-9718-8473-3c6db465b154@suse.cz>
 <20170828002857.GB9167@js1304-P5Q-DELUXE>
 <78dd0160-14e8-22a6-bd10-d37bbd39f77b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <78dd0160-14e8-22a6-bd10-d37bbd39f77b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Mon, Aug 28, 2017 at 08:45:07AM +0200, Vlastimil Babka wrote:
> +CC linux-api
> 
> On 08/28/2017 02:28 AM, Joonsoo Kim wrote:
> > On Fri, Aug 25, 2017 at 09:56:10AM +0200, Vlastimil Babka wrote:
> >> On 08/25/2017 02:20 AM, Joonsoo Kim wrote:
> >>> On Thu, Aug 24, 2017 at 11:41:58AM +0200, Vlastimil Babka wrote:
> >>>
> >>> Hmm, this is already pointed by Minchan and I have answered that.
> >>>
> >>> lkml.kernel.org/r/<20170421013243.GA13966@js1304-desktop>
> >>>
> >>> If you have a better idea, please let me know.
> >>
> >> My idea is that size of sysctl_lowmem_reserve_ratio is ZONE_NORMAL+1 and
> >> it has no entries for zones > NORMAL. The
> >> setup_per_zone_lowmem_reserve() is adjusted to only set
> >> lower_zone->lowmem_reserve[j] for idx <= ZONE_NORMAL.
> >>
> >> I can't imagine somebody would want override the ratio for HIGHMEM or
> >> MOVABLE
> >> (where it has no effect anyway) so the simplest thing is not to expose
> >> it at all.
> > 
> > Seems reasonable. However, if there is a user who checks
> > sysctl_lowmem_reserve_ratio entry for HIGHMEM and change it, suggested
> > interface will cause a problem since it doesn't expose ratio for
> > HIGHMEM. Am I missing something?
> 
> As you explained, it makes little sense to change it for HIGHMEM which
> only affects MOVABLE allocations. Also I doubt there are many systems
> with both HIGHMEM (implies 32bit) *and* MOVABLE (implies NUMA, memory
> hotplug...) zones. So I would just remove it, and if somebody will
> really miss it, we can always add it back. In any case, please CC
> linux-api on the next version.

If we will accept a change that potentially breaks the user, I think
that making zero as a special value for sysctl_lowmem_reserve_ratio
is better solution. How about this way?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
