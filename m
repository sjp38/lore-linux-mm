Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7996D6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 16:26:52 -0500 (EST)
Received: by padhx2 with SMTP id hx2so202980925pad.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 13:26:52 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id nr10si22596185pbc.219.2015.11.23.13.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 13:26:51 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so209001461pab.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 13:26:51 -0800 (PST)
Date: Mon, 23 Nov 2015 13:26:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
In-Reply-To: <20151123101345.GF21050@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1511231320160.30886@chino.kir.corp.google.com>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org> <5651BB43.8030102@suse.cz> <20151123092925.GB21050@dhcp22.suse.cz> <5652DFCE.3010201@suse.cz> <20151123101345.GF21050@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 23 Nov 2015, Michal Hocko wrote:

> > >>>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > >>>index 8034909faad2..d30bce9d7ac8 100644
> > >>>--- a/mm/page_alloc.c
> > >>>+++ b/mm/page_alloc.c
> > >>>@@ -2766,8 +2766,16 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> > >>>  			goto out;
> > >>>  	}
> > >>>  	/* Exhausted what can be done so it's blamo time */
> > >>>-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> > >>>+	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> > >>>  		*did_some_progress = 1;
> > >>>+
> > >>>+		if (gfp_mask & __GFP_NOFAIL) {
> > >>>+			page = get_page_from_freelist(gfp_mask, order,
> > >>>+					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> > >>>+			WARN_ONCE(!page, "Unable to fullfil gfp_nofail allocation."
> > >>>+				    " Consider increasing min_free_kbytes.\n");
> > >>
> > >>It seems redundant to me to keep the WARN_ON_ONCE also above in the if () part?
> > >
> > >They are warning about two different things. The first one catches a
> > >buggy code which uses __GFP_NOFAIL from oom disabled context while the
> > 
> > Ah, I see, I misinterpreted what the return values of out_of_memory() mean.
> > But now that I look at its code, it seems to only return false when
> > oom_killer_disabled is set to true. Which is a global thing and nothing to
> > do with the context of the __GFP_NOFAIL allocation?
> 
> I am not sure I follow you here. The point of the warning is to warn
> when the oom killer is disbaled (out_of_memory returns false) _and_ the
> request is __GFP_NOFAIL because we simply cannot guarantee any forward
> progress and just a use of the allocation flag is not supproted.
> 

I don't think the WARN_ONCE() above is helpful for a few reasons:

 - it suggests that min_free_kbytes is the best way to work around such 
   issues and gives kernel developers a free pass to just say "raise
   min_free_kbytes" rather than reducing their reliance on __GFP_NOFAIL,

 - raising min_free_kbytes is not immediately actionable without memory
   freeing to fix any oom issue, and

 - it relies on the earlier warning to dump the state of memory and 
   doesn't add any significant information to help understand how seperate
   occurrences are similar or different.

I think the WARN_ONCE() should just be removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
