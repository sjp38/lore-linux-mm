Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D409800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:19:23 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e195so2614910wmd.9
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 10:19:23 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id 93si521200edh.107.2018.01.24.10.19.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 10:19:22 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id ADE2C1C393A
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 18:19:21 +0000 (GMT)
Date: Wed, 24 Jan 2018 18:19:21 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] free_pcppages_bulk: prefetch buddy while not holding
 lock
Message-ID: <20180124181921.vnivr32q72ey7p5i@techsingularity.net>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124023050.20097-2-aaron.lu@intel.com>
 <20180124164344.lca63gjn7mefuiac@techsingularity.net>
 <148a42d8-8306-2f2f-7f7c-86bc118f8ccd@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <148a42d8-8306-2f2f-7f7c-86bc118f8ccd@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Jan 24, 2018 at 08:57:43AM -0800, Dave Hansen wrote:
> On 01/24/2018 08:43 AM, Mel Gorman wrote:
> > I'm less convinced by this for a microbenchmark. Prefetch has not been a
> > universal win in the past and we cannot be sure that it's a good idea on
> > all architectures or doesn't have other side-effects such as consuming
> > memory bandwidth for data we don't need or evicting cache hot data for
> > buddy information that is not used.
> 
> I had the same reaction.
> 
> But, I think this case is special.  We *always* do buddy merging (well,
> before the next patch in the series is applied) and check an order-0
> page's buddy to try to merge it when it goes into the main allocator.
> So, the cacheline will always come in.
> 
> IOW, I don't think this has the same downsides normally associated with
> prefetch() since the data is always used.

That doesn't side-step the calculations are done twice in the
free_pcppages_bulk path and there is no guarantee that one prefetch
in the list of pages being freed will not evict a previous prefetch
due to collisions. At least on the machine I'm writing this from, the
prefetches necessary for a standard drain are 1/16th of the L1D cache so
some collisions/evictions are possible. We're doing definite work in one
path on the chance it'll still be cache-resident when it's recalculated.
I suspect that only a microbenchmark that is doing very large amounts of
frees (or a large munmap or exit) will notice and the costs of a large
munmap/exit are so high that the prefetch will be negligible savings.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
