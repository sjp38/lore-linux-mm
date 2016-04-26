Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5FF6B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:05:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so9514805wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:05:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v68si2716044wmd.42.2016.04.26.04.05.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 04:05:51 -0700 (PDT)
Subject: Re: [PATCH 05/28] mm, page_alloc: Inline the fast path of the
 zonelist iterator
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-6-git-send-email-mgorman@techsingularity.net>
 <571E2EAA.2050206@suse.cz> <20160426103017.GA2858@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F4B8D.6050807@suse.cz>
Date: Tue, 26 Apr 2016 13:05:49 +0200
MIME-Version: 1.0
In-Reply-To: <20160426103017.GA2858@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/26/2016 12:30 PM, Mel Gorman wrote:
> On Mon, Apr 25, 2016 at 04:50:18PM +0200, Vlastimil Babka wrote:
>> > @@ -3193,17 +3193,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>> >   	 */
>> >   	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>> >
>> > -	/*
>> > -	 * Find the true preferred zone if the allocation is unconstrained by
>> > -	 * cpusets.
>> > -	 */
>> > -	if (!(alloc_flags & ALLOC_CPUSET) && !ac->nodemask) {
>> > -		struct zoneref *preferred_zoneref;
>> > -		preferred_zoneref = first_zones_zonelist(ac->zonelist,
>> > -				ac->high_zoneidx, NULL, &ac->preferred_zone);
>> > -		ac->classzone_idx = zonelist_zone_idx(preferred_zoneref);
>> > -	}
>> > -
>> >   	/* This is the last chance, in general, before the goto nopage. */
>> >   	page = get_page_from_freelist(gfp_mask, order,
>> >   				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
>> > @@ -3359,14 +3348,21 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>> >   	struct zoneref *preferred_zoneref;
>> >   	struct page *page = NULL;
>> >   	unsigned int cpuset_mems_cookie;
>> > -	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
>> > +	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
>> >   	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>> >   	struct alloc_context ac = {
>> >   		.high_zoneidx = gfp_zone(gfp_mask),
>> > +		.zonelist = zonelist,
>> >   		.nodemask = nodemask,
>> >   		.migratetype = gfpflags_to_migratetype(gfp_mask),
>> >   	};
>> >
>> > +	if (cpusets_enabled()) {
>> > +		alloc_flags |= ALLOC_CPUSET;
>> > +		if (!ac.nodemask)
>> > +			ac.nodemask = &cpuset_current_mems_allowed;
>> > +	}
>>
>> My initial reaction is that this is setting ac.nodemask in stone outside
>> of cpuset_mems_cookie, but I guess it's ok since we're taking a pointer
>> into current's task_struct, not the contents of the current's nodemask.
>> It's however setting a non-NULL nodemask into stone, which means no
>> zonelist iterator fasthpaths... but only in the slowpath. I guess it's
>> not an issue then.
>>
>
> You're right in that setting it in stone is problematic if the cpuset
> nodemask changes duration allocation. The retry loop knows there is a
> change but does not look it up which would loop once then potentially fail
> unnecessarily.

That's what I thought first, but I think the *pointer* 
cpuset_current_mems_allowed itself doesn't change when cookie changes, only the 
bitmask it points to, so changes in that bitmask should be seen. But it deserves 
a comment maybe so people reading the code in future won't get the same suspicion.

> I should have moved the retry_cpuset label above the point
> where cpuset_current_mems_allowed gets set. That's option 1 as a fixlet
> to this patch.
>
>> > +
>> >   	gfp_mask &= gfp_allowed_mask;
>> >
>> >   	lockdep_trace_alloc(gfp_mask);
>> > @@ -3390,16 +3386,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>> >   retry_cpuset:
>> >   	cpuset_mems_cookie = read_mems_allowed_begin();
>> >
>> > -	/* We set it here, as __alloc_pages_slowpath might have changed it */
>> > -	ac.zonelist = zonelist;
>>
>> This doesn't seem relevant to the preferred_zoneref changes in
>> __alloc_pages_slowpath, so why it became ok? Maybe it is, but it's not
>> clear from the changelog.
>>
>
> The slowpath is no longer altering the preferred_zoneref.

But the hunk above is about ac.zonelist, not preferred_zoneref?

>
>> Anyway, thinking about it made me realize that maybe we could move the
>> whole mems_cookie thing into slowpath? As soon as the optimistic
>> fastpath succeeds, we don't check the cookie anyway, so what about
>> something like this on top?
>>
>
> That in general would seem reasonable although I don't think it applies
> to the series properly. Do you want to do this as a patch on top of the
> series or will I use the fixlet for now and probably follow up with the
> cookie move in a week or so when I've caught up after LSF/MM?

I guess fixlet is fine for now and you have better setup to test the effect (if 
any) of the cookie move.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
