Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 999806B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 10:51:45 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id kq3so705552wjc.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 07:51:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 207si2561396wma.80.2017.01.13.07.51.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 07:51:44 -0800 (PST)
Date: Fri, 13 Jan 2017 16:51:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
Message-ID: <20170113155142.GO25212@dhcp22.suse.cz>
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
 <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
 <CAFpQJXWD8pSaWUrkn5Rxy-hjTCvrczuf0F3TdZ8VHj4DSYpivg@mail.gmail.com>
 <20170111164616.GJ16365@dhcp22.suse.cz>
 <45ed555a-c6a3-fc8e-1e87-c347c8ed086b@suse.cz>
 <CAFpQJXUVRKXLUvM5PnpjT_UH+ac-0=caND43F882oP+Rm5gxUQ@mail.gmail.com>
 <89fec1bd-52b7-7861-2e02-a719c5631610@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89fec1bd-52b7-7861-2e02-a719c5631610@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ganapatrao Kulkarni <gpkulkarni@gmail.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Fri 13-01-17 10:06:14, Vlastimil Babka wrote:
[...]
> >From 9f041839401681f2678edf5040c851d11963c5fe Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 13 Jan 2017 10:01:26 +0100
> Subject: [PATCH] mm, page_alloc: fix race with cpuset update or removal
> 
> Changelog and S-O-B TBD.
> ---
>  mm/page_alloc.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440e3ae2..c397f146843a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3775,9 +3775,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	/*
>  	 * Restore the original nodemask if it was potentially replaced with
>  	 * &cpuset_current_mems_allowed to optimize the fast-path attempt.
> +	 * Also recalculate the starting point for the zonelist iterator or
> +	 * we could end up iterating over non-eligible zones endlessly.
>  	 */
> -	if (cpusets_enabled())
> +	if (unlikely(ac.nodemask != nodemask)) {
>  		ac.nodemask = nodemask;
> +		ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
> +						ac.high_zoneidx, ac.nodemask);
> +		if (!ac.preferred_zoneref)
> +			goto no_zone;
> +	}
> +
>  	page = __alloc_pages_slowpath(alloc_mask, order, &ac);

I think you nailed it. It is really possible that preferred_zoneref is
outside of the cpuset_current_mems_allowed and if we are unlucky there
won't be any other zones on the zonelist...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
