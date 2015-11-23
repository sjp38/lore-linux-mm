Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 43D136B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 05:13:48 -0500 (EST)
Received: by wmvv187 with SMTP id v187so152861680wmv.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 02:13:47 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id k67si18168139wma.23.2015.11.23.02.13.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 02:13:47 -0800 (PST)
Received: by wmww144 with SMTP id w144so97530627wmw.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 02:13:46 -0800 (PST)
Date: Mon, 23 Nov 2015 11:13:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
Message-ID: <20151123101345.GF21050@dhcp22.suse.cz>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
 <5651BB43.8030102@suse.cz>
 <20151123092925.GB21050@dhcp22.suse.cz>
 <5652DFCE.3010201@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5652DFCE.3010201@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 23-11-15 10:43:42, Vlastimil Babka wrote:
> On 11/23/2015 10:29 AM, Michal Hocko wrote:
> >On Sun 22-11-15 13:55:31, Vlastimil Babka wrote:
> >>On 11.11.2015 14:48, mhocko@kernel.org wrote:
> >>>  mm/page_alloc.c | 10 +++++++++-
> >>>  1 file changed, 9 insertions(+), 1 deletion(-)
> >>>
> >>>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>>index 8034909faad2..d30bce9d7ac8 100644
> >>>--- a/mm/page_alloc.c
> >>>+++ b/mm/page_alloc.c
> >>>@@ -2766,8 +2766,16 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >>>  			goto out;
> >>>  	}
> >>>  	/* Exhausted what can be done so it's blamo time */
> >>>-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> >>>+	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> >>>  		*did_some_progress = 1;
> >>>+
> >>>+		if (gfp_mask & __GFP_NOFAIL) {
> >>>+			page = get_page_from_freelist(gfp_mask, order,
> >>>+					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> >>>+			WARN_ONCE(!page, "Unable to fullfil gfp_nofail allocation."
> >>>+				    " Consider increasing min_free_kbytes.\n");
> >>
> >>It seems redundant to me to keep the WARN_ON_ONCE also above in the if () part?
> >
> >They are warning about two different things. The first one catches a
> >buggy code which uses __GFP_NOFAIL from oom disabled context while the
> 
> Ah, I see, I misinterpreted what the return values of out_of_memory() mean.
> But now that I look at its code, it seems to only return false when
> oom_killer_disabled is set to true. Which is a global thing and nothing to
> do with the context of the __GFP_NOFAIL allocation?

I am not sure I follow you here. The point of the warning is to warn
when the oom killer is disbaled (out_of_memory returns false) _and_ the
request is __GFP_NOFAIL because we simply cannot guarantee any forward
progress and just a use of the allocation flag is not supproted.

[...]
> >>Hm and probably out of scope of your patch, but I understand the WARN_ONCE
> >>(WARN_ON_ONCE) to be _ONCE just to prevent a flood from a single task looping
> >>here. But for distinct tasks and potentially far away in time, wouldn't we want
> >>to see all the warnings? Would that be feasible to implement?
> >
> >I was thinking about that as well some time ago but it was quite
> >hard to find a good enough API to tell when to warn again. The first
> >WARN_ON_ONCE should trigger for all different _code paths_ no matter
> >how frequently they appear to catch all the buggy callers. The second
> >one would benefit from a new warning after min_free_kbytes was updated
> >because it would tell the administrator that the last update was not
> >sufficient for the workload.
> 
> Hm, what about adding a flag to the struct alloc_context, so that when the
> particular allocation attempt emits the warning, it sets a flag in the
> alloc_context so that it won't emit them again as long as it keeps looping
> and attempting oom. Other allocations will warn independently.

That could still trigger a flood of messages. Say you have many
concurrent users from the same call path...
 
I am not really sure making the code more complicating for this warning
is really worth it. If anything we can use ratelimited variant.

> We could also print the same info as the "allocation failed" warnings do,
> since it's very similar, except we can't fail - but the admin/bug reporter
> should be interested in the same details as for an allocation failure that
> is allowed to fail. But it's also true that we have probably just printed
> the info during out_of_memory()... except when we skipped that for some
> reason?

The first WARN_ON_ONCE happens when OOM killer doesn't trigger so a
memory situation might be worth considering. The later one might have
seen the OOM report which is the likely case. So if anyting the first
one should dump the info.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
