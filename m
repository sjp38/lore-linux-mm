Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 194846B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 06:33:05 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so10609187wid.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 03:33:04 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id gk19si38020836wjc.187.2015.08.25.03.33.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 03:33:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id B3F61C005D
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:33:02 +0000 (UTC)
Date: Tue, 25 Aug 2015 11:33:00 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/12] mm, page_alloc: Only check cpusets when one exists
 that can be mem-controlled
Message-ID: <20150825103300.GM12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-5-git-send-email-mgorman@techsingularity.net>
 <55DB1015.4080103@suse.cz>
 <20150824131616.GK12432@techsingularity.net>
 <55DB8451.4000102@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55DB8451.4000102@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 24, 2015 at 10:53:37PM +0200, Vlastimil Babka wrote:
> On 24.8.2015 15:16, Mel Gorman wrote:
> >>>
> >>>  	return read_seqcount_retry(&current->mems_allowed_seq, seq);
> >>> @@ -139,7 +141,7 @@ static inline void set_mems_allowed(nodemask_t nodemask)
> >>>
> >>>  #else /* !CONFIG_CPUSETS */
> >>>
> >>> -static inline bool cpusets_enabled(void) { return false; }
> >>> +static inline bool cpusets_mems_enabled(void) { return false; }
> >>>
> >>>  static inline int cpuset_init(void) { return 0; }
> >>>  static inline void cpuset_init_smp(void) {}
> >>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>> index 62ae28d8ae8d..2c1c3bf54d15 100644
> >>> --- a/mm/page_alloc.c
> >>> +++ b/mm/page_alloc.c
> >>> @@ -2470,7 +2470,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> >>>  		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
> >>>  			!zlc_zone_worth_trying(zonelist, z, allowednodes))
> >>>  				continue;
> >>> -		if (cpusets_enabled() &&
> >>> +		if (cpusets_mems_enabled() &&
> >>>  			(alloc_flags & ALLOC_CPUSET) &&
> >>>  			!cpuset_zone_allowed(zone, gfp_mask))
> >>>  				continue;
> >>
> >> Here the benefits are less clear. I guess cpuset_zone_allowed() is
> >> potentially costly...
> >>
> >> Heck, shouldn't we just start the static key on -1 (if possible), so that
> >> it's enabled only when there's 2+ cpusets?
> 
> Hm wait a minute, that's what already happens:
> 
> static inline int nr_cpusets(void)
> {
>         /* jump label reference count + the top-level cpuset */
>         return static_key_count(&cpusets_enabled_key) + 1;
> }
> 
> I.e. if there's only the root cpuset, static key is disabled, so I think this
> patch is moot after all?
> 

static_key_count is an atomic read on a field in struct static_key where
as static_key_false is a arch_static_branch which can be eliminated. The
patch eliminates an atomic read so I didn't think it was moot.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
