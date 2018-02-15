Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 973C86B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:45:29 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u83so300420wmb.3
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 06:45:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k22si2635030wmc.253.2018.02.15.06.45.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Feb 2018 06:45:28 -0800 (PST)
Date: Thu, 15 Feb 2018 15:45:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
Message-ID: <20180215144525.GG7275@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
 <20180214095911.GB28460@dhcp22.suse.cz>
 <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Wed 14-02-18 02:28:38, David Rientjes wrote:
> On Wed, 14 Feb 2018, Michal Hocko wrote:
> 
> > I do not have any objections regarding the extension. What I am more
> > interested in is _why_ people are still using this command line
> > parameter at all these days. Why would anybody want to introduce lowmem
> > issues from 32b days. I can see the CMA/Hotplug usecases for
> > ZONE_MOVABLE but those have their own ways to define zone movable. I was
> > tempted to simply remove the kernelcore already. Could you be more
> > specific what is your usecase which triggered a need of an easier
> > scaling of the size?
> 
> Fragmentation of non-__GFP_MOVABLE pages due to low on memory situations 
> can pollute most pageblocks on the system, as much as 1GB of slab being 
> fragmented over 128GB of memory, for example.

OK, I was assuming something like that.

> When the amount of kernel 
> memory is well bounded for certain systems, it is better to aggressively 
> reclaim from existing MIGRATE_UNMOVABLE pageblocks rather than eagerly 
> fallback to others.
> 
> We have additional patches that help with this fragmentation if you're 
> interested, specifically kcompactd compaction of MIGRATE_UNMOVABLE 
> pageblocks triggered by fallback of non-__GFP_MOVABLE allocations and 
> draining of pcp lists back to the zone free area to prevent stranding.

Yes, I think we need a proper fix. (Ab)using zone_movable for this
usecase is just sad.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
