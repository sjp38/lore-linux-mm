Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EEF46B0069
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 10:16:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b80so10142945wme.1
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 07:16:10 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id z2si4706112wje.203.2016.10.04.07.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 07:16:09 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id f193so15300546wmg.2
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 07:16:08 -0700 (PDT)
Date: Tue, 4 Oct 2016 16:16:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom: print nodemask in the oom report
Message-ID: <20161004141607.GC32214@dhcp22.suse.cz>
References: <20160930214146.28600-1-mhocko@kernel.org>
 <65c637df-a9a3-777d-f6d3-322033980f86@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65c637df-a9a3-777d-f6d3-322033980f86@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Sellami Abdelkader <abdelkader.sellami@sap.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 04-10-16 15:24:53, Vlastimil Babka wrote:
> On 09/30/2016 11:41 PM, Michal Hocko wrote:
[...]
> > Fix this by always priting the nodemask. It is either mempolicy mask
> > (and non-null) or the one defined by the cpusets.
> 
> I wonder if it's helpful to print the cpuset one when that's printed
> separately, and seeing both pieces of information (nodemask and cpuset)
> unmodified might tell us more. Is it to make it easier to deal with NULL
> nodemask? Or to make sure the info gets through pr_warn() and not pr_info()?

I am not sure I understand the question. I wanted to print the nodemask
separatelly in the same line with all other allocation request
parameters like order and gfp mask because that is what the page
allocator got (via policy_nodemask). cpusets builds on top - aka applies
__cpuset_zone_allowed on top of the nodemask. So imho it makes sense to
look at the cpuset as an allocation domain while the mempolicy as a
restriction within this domain.

Does that answer your question?

> > The new output for
> > the above oom report would be
> > 
> > PoolThread invoked oom-killer: gfp_mask=0x280da(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0, order=0, oom_adj=0, oom_score_adj=0
> > 
> > This patch doesn't touch show_mem and the node filtering based on the
> > cpuset node mask because mempolicy is always a subset of cpusets and
> > seeing the full cpuset oom context might be helpful for tunning more
> > specific mempolicies inside cpusets (e.g. when they turn out to be too
> > restrictive). To prevent from ugly ifdefs the mask is printed even
> > for !NUMA configurations but this should be OK (a single node will be
> > printed).
> > 
> > Reported-by: Sellami Abdelkader <abdelkader.sellami@sap.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Other than that,
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
